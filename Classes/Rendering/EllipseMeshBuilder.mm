//
//  EllipseMeshBuilder.m
//  WaterBalloonToss
//
//  Created by Rishi Gupta on 5/15/14.
//  Copyright (c) 2014 Neon Games LLC. All rights reserved.
//

// To eliminate build warnings
#undef min
#undef max

#import "EllipseMeshBuilder.h"
#import "SimpleModel.h"
#import "NeonMath.h"

#import <vector>
#import <map>

struct TriangleIndices
{
    int mV1;
    int mV2;
    int mV3;
    
    TriangleIndices(int inV1, int inV2, int inV3);
};

TriangleIndices::TriangleIndices(int inV1, int inV2, int inV3)
{
    mV1 = inV1;
    mV2 = inV2;
    mV3 = inV3;
}

class Geometry
{
    public:
        std::vector<Vector3*>   mPositions;
        std::vector<int>        mTriangleIndices;
};

@implementation EllipseMeshBuilder(PrivateData)
    Geometry*   mGeometry;
    int         mIndex;
    std::map<int64_t, int> mMiddlePointIndexCache;
@end

@implementation EllipseMeshBuilder

-(instancetype)Init
{
    mGeometry = NULL;
    mIndex = 0;
    
    return self;
}

-(int)addVertex:(Vector3*)inVector
{
    return [self addVertex:inVector withDelete:FALSE];
}

-(int)addVertex:(Vector3*)inVector withDelete:(BOOL)inDelete
{
    Vector3* newVec = new Vector3;
    
    CloneVec3(inVector, newVec);
    Normalize3(newVec);
    
    mGeometry->mPositions.push_back(newVec);
    
    if (inDelete)
    {
        delete inVector;
    }
    
    return mIndex++;
}


-(int)getMiddlePointP1:(int)p1 p2:(int)p2
{
    // first check if we have it already
    bool firstIsSmaller = p1 < p2;

    int64_t smallerIndex = firstIsSmaller ? p1 : p2;
    int64_t greaterIndex = firstIsSmaller ? p2 : p1;
    int64_t key = (smallerIndex << 32) + greaterIndex;

    if (mMiddlePointIndexCache.count(key) > 0)
    {
        return mMiddlePointIndexCache[key];
    }

    // not in cache, calculate it
    Vector3* point1 = mGeometry->mPositions[p1];
    Vector3* point2 = mGeometry->mPositions[p2];

    Vector3 middle;
    Set(&middle, (point1->mVector[x] + point2->mVector[x]) / 2.0, (point1->mVector[y] + point2->mVector[y]) / 2.0, (point1->mVector[z] + point2->mVector[z]) / 2.0);

    // add vertex makes sure point is on unit sphere
    int i = [self addVertex:&middle];

    // store it, return index
    mMiddlePointIndexCache[key] = i;

    return i;
}


-(SimpleModel*)Create:(int)recursionLevel withScale:(Vector3*)inScale
{
    mGeometry = new Geometry();

    // create 12 vertices of a icosahedron
    float t = (1.0 + sqrt(5.0)) / 2.0;

    [self addVertex:(new Vector3{-1,  t,  0}) withDelete:TRUE];
    [self addVertex:(new Vector3{ 1,  t,  0}) withDelete:TRUE];
    [self addVertex:(new Vector3{-1, -t,  0}) withDelete:TRUE];
    [self addVertex:(new Vector3{ 1, -t,  0}) withDelete:TRUE];


    [self addVertex:(new Vector3{ 0, -1,  t}) withDelete:TRUE];
    [self addVertex:(new Vector3{ 0,  1,  t}) withDelete:TRUE];
    [self addVertex:(new Vector3{ 0, -1, -t}) withDelete:TRUE];
    [self addVertex:(new Vector3{ 0,  1, -t}) withDelete:TRUE];

    [self addVertex:(new Vector3{ t,  0, -1}) withDelete:TRUE];
    [self addVertex:(new Vector3{ t,  0,  1}) withDelete:TRUE];
    [self addVertex:(new Vector3{-t,  0, -1}) withDelete:TRUE];
    [self addVertex:(new Vector3{-t,  0,  1}) withDelete:TRUE];

    // create 20 triangles of the icosahedron
    std::vector<TriangleIndices*>* faces = new std::vector<TriangleIndices*>;

    // 5 faces around point 0
    faces->push_back(new TriangleIndices(0, 11, 5));
    faces->push_back(new TriangleIndices(0, 5, 1));
    faces->push_back(new TriangleIndices(0, 1, 7));
    faces->push_back(new TriangleIndices(0, 7, 10));
    faces->push_back(new TriangleIndices(0, 10, 11));

    // 5 adjacent faces
    faces->push_back(new TriangleIndices(1, 5, 9));
    faces->push_back(new TriangleIndices(5, 11, 4));
    faces->push_back(new TriangleIndices(11, 10, 2));
    faces->push_back(new TriangleIndices(10, 7, 6));
    faces->push_back(new TriangleIndices(7, 1, 8));

    // 5 faces around point 3
    faces->push_back(new TriangleIndices(3, 9, 4));
    faces->push_back(new TriangleIndices(3, 4, 2));
    faces->push_back(new TriangleIndices(3, 2, 6));
    faces->push_back(new TriangleIndices(3, 6, 8));
    faces->push_back(new TriangleIndices(3, 8, 9));

    // 5 adjacent faces
    faces->push_back(new TriangleIndices(4, 9, 5));
    faces->push_back(new TriangleIndices(2, 4, 11));
    faces->push_back(new TriangleIndices(6, 2, 10));
    faces->push_back(new TriangleIndices(8, 6, 7));
    faces->push_back(new TriangleIndices(9, 8, 1));

     // refine triangles
    for (int i = 0; i < recursionLevel; i++)
    {
        std::vector<TriangleIndices*>* faces2 = new std::vector<TriangleIndices*>;

        for(std::vector<TriangleIndices*>::iterator curTri = faces->begin(); curTri != faces->end(); curTri++)
        {
             // replace triangle by 4 triangles
             int a = [self getMiddlePointP1:(*curTri)->mV1 p2:(*curTri)->mV2];
             int b = [self getMiddlePointP1:(*curTri)->mV2 p2:(*curTri)->mV3];
             int c = [self getMiddlePointP1:(*curTri)->mV3 p2:(*curTri)->mV1];

             faces2->push_back(new TriangleIndices((*curTri)->mV1, a, c));
             faces2->push_back(new TriangleIndices((*curTri)->mV2, b, a));
             faces2->push_back(new TriangleIndices((*curTri)->mV3, c, b));
             faces2->push_back(new TriangleIndices(a, b, c));
        }

        for (std::vector<TriangleIndices*>::iterator it = faces->begin(); it != faces->end(); it++)
        {
            delete *it;
        }
        
        delete faces;
        faces = faces2;
    }

    // done, now add triangles to mesh
    for(std::vector<TriangleIndices*>::iterator curTri = faces->begin(); curTri != faces->end(); curTri++)
    {
        mGeometry->mTriangleIndices.push_back((*curTri)->mV1);
        mGeometry->mTriangleIndices.push_back((*curTri)->mV2);
        mGeometry->mTriangleIndices.push_back((*curTri)->mV3);
    }
    
    // Convert to SimpleModel
    SimpleModel* newModel = [[SimpleModel alloc] Init];
    
    newModel->mNumVertices = (u32)mGeometry->mTriangleIndices.size();
    newModel->mStream = (unsigned char*)malloc(sizeof(float) * 6 * newModel->mNumVertices);
    
    int curVertexNumber = 0;
    
    Matrix44 scaleMatrix;
    GenerateScaleMatrix(inScale->mVector[x], inScale->mVector[y], inScale->mVector[z], &scaleMatrix);
    
    Matrix44 inverseTranspose;
    InverseTranspose(&scaleMatrix, &inverseTranspose);
    
    for (std::vector<int>::iterator curIndex = mGeometry->mTriangleIndices.begin(); curIndex != mGeometry->mTriangleIndices.end(); curIndex++)
    {
        int writeOffset = curVertexNumber * (6 * sizeof(float));
        int curIndexVal = *curIndex;
        
        Vector3* vertex = mGeometry->mPositions[curIndexVal];
        
        Vector4 transformedVertex;
        TransformVector4x3(&scaleMatrix, vertex, &transformedVertex);
        
        Vector3 transformedVertex3;
        SetVec3From4(&transformedVertex3, &transformedVertex);
        
        // Write position
        memcpy(newModel->mStream + writeOffset, &transformedVertex3, sizeof(float) * 3);
        
        TransformVector4x3(&inverseTranspose, vertex, &transformedVertex);
        SetVec3From4(&transformedVertex3, &transformedVertex);
        
        Normalize3(&transformedVertex3);
        
        // Normal is the same as position
        memcpy(newModel->mStream + writeOffset + (3 * sizeof(float)), &transformedVertex3, sizeof(float) * 3);
        
        curVertexNumber++;
    }
    
    newModel->mPositionStride = 3;
    newModel->mNormalStride = 3;
    newModel->mTexcoordStride = 0;
    newModel->mNumMatricesPerVertex = 0;
    newModel->mStride = 6 * sizeof(float);
        
    for (std::vector<TriangleIndices*>::iterator it = faces->begin(); it != faces->end(); it++)
    {
        delete *it;
    }
    
    return newModel;
}

@end
