//
//  SimpleModel.h
//  Neon21
//
//  Copyright Neon Games 2009. All rights reserved.
//

#import "Model.h"

// Typically a ray will intersect a mesh in two places.  The front facing and back facing position.  Each index in the arrays denotes an intersection point
typedef struct
{
    u32     mIntersectionVertexIndex[2];    // Index of the nth vertex in the first intersection triangle.  The next two indices are the next two vertices in the triangle
    float   mT[2];                          // The "t" or amount of the ray direction that must be added to the ray position to get the intersection point
    Vector3 mIntersectionPosition[2];       // Intersection position
    Vector2 mIntersectionTexcoord[2];       // Intersection texcoord
} RayIntersectionInfo;

@interface SimpleModel : Model
{
    @public
        unsigned char*  mStream;
        u32     mNumVertices;
        
        u32     mPositionStride;
        u32     mNormalStride;
        u32     mTexcoordStride;
        u32     mNumMatricesPerVertex;
        u32     mStride;
        
        Matrix44*   mJointMatrices;
        Matrix44*   mJointMatricesInverseTranspose;
        
        Matrix44    mBindShapeMatrix;
        
        GLuint  mVBO;
        
        float*   mSkinnedPositions;
        float*   mSkinnedNormals;
}

-(instancetype)InitWithData:(NSData*)inData;
-(instancetype)Init;

-(void)dealloc;

-(void)Draw;
-(void)DrawGPUSkinned;

-(void)SetupSkinningState;
-(void)SetupGPUSkinningState;

-(void)SetupVertexBuffers;
-(void)SetupGPUVertexBuffers;
-(void)SetupCPUVertexBuffers;

-(void)TransformInPlace:(Matrix44*)inTransform;

#if CPU_SKINNING
-(void)DrawCPUSkinned;
-(void)SetupCPUSkinningState;
#endif

-(void)SetupTextureState;
-(void)SetupTextureBufferState;

-(void)CleanupDrawState;

-(void)Update:(u32)inFrameTime;

-(void)GenerateGLBoundingBox;
-(void)GenerateVBO;

-(void)BindSkeleton:(Skeleton*)inSkeleton;
-(void)BindSkeletonWithFilename:(NSString*)inFilename;

-(int)CalculateNumJointsIndexed;

-(BOOL)RayIntersectsMesh:(Vector3*)inRayStart direction:(Vector3*)inDirection intersectionInfo:(RayIntersectionInfo*)outIntersectionInfo;

@end