//
//  NeonMath.h
//  Neon21
//
//  Copyright Neon Games 2008. All rights reserved.
//

#pragma once

#include <stdbool.h>
#include <assert.h>

extern const float EPSILON;
extern const float SMALL_EPSILON;

typedef struct
{
    float mStart;
    float mLength;
} Range;

enum
{
    x = 0,
    y,
    z,
    w
};

typedef struct
{
    float   mVector[2];
} Vector2;

typedef struct
{
    float   mVector[3];
} Vector3;

typedef struct
{
    float   mVector[4];
} Vector4;

typedef struct
{
    float mXMin;
    float mXMax;
    float mYMin;
    float mYMax;
} Rect2D;

typedef struct
{
	union
	{
		struct
		{
			Vector3 mTopLeft;
			Vector3 mTopRight;
			Vector3 mBottomLeft;
			Vector3 mBottomRight;
		};
		
		Vector3	mVectors[4];
	};
} Rect3D;

typedef struct
{
    Vector3 mPoint;
    Vector3 mNormal;
	float	mDistance;	// D in the "Ax + By + Cz + D = 0" form of the equation
} Plane;

typedef struct
{
    float   mMinX;
    float   mMaxX;
    float   mMinY;
    float   mMaxY;
    float   mMinZ;
    float   mMaxZ;
} BoundingBox;

// Stick to a common convention for Boxes.  Let's say:
// The first 4 vertices are the one face of the box in a clockwise orientation.
// The second 4 vertices are the face on the opposite side of the box, also in a clockwise orientation.
//
// Note, clockwise is in the same sense for both faces.  So if we're looking at a box from the side, this is how the vertices
// should be specified (excuse the poor ASCII art).  1 2 3 4 is the "top" and 5 6 7 8 is the "bottom".
//
//      1
//                  2
//
//      4 
//                  3
//
//
//
//
//      5
//                  6
//
//
//      8
//                  7
//
//      It is up to the user of the class to ensure the vertices actually form a box (eg: 1 2 is parallel to 3 4 and
//      is perpendicular to 1 5, etc).

typedef struct
{
    Vector3     mVertices[8];
} Box;

typedef struct
{
    Vector3     mVertices[4];
} Face;


// Note: Despite the somewhat confusing nature of it, our matrices will be stored in column major order
// to match OpenGL.  That is to say:
//
// | a b c d |
// | e f g h |
// | i j k l |
// | m n o p |
//
// will be represented in mMatrix as [a, e, i, m, b, f, j, n, c, g, k, o, d, h, l p]

typedef struct
{
    float   mMatrix[16];
} Matrix44;

#ifdef __cplusplus
extern "C"
{
#endif

#pragma mark Scalar

float DegreesToRadians(float inDegrees);
float RadiansToDegrees(float inRadians);

float ClampFloat(float inValue, float inLower, float inUpper);
int   ClampInt(int inValue, int inLower, int inUpper);
unsigned int ClampUInt(unsigned int inValue, unsigned int inLower, unsigned int inUpper);
float LClampFloat(float inValue, float inLower);
int   LClampInt(float inValue, float inLower);

float FloorToMultipleFloat(float inValue, float inMultiplier);

bool RangesIntersect(Range* inLeft, Range* inRight);

int  RoundUpPOT(int inValue);
int  RoundDownPOT(int inValue);

float RandFloat(float inLower, float inUpper);

double Sinc(double x);
double Bessel0(double x);
double Kaiser(double alpha, double half_width, double x);

float LerpFloat(float inLeft, float inRight, float inBlend);
float ApproximateCubicBezierParameter(float atX, float P0_X, float C0_X, float C1_X, float P1_X );

float Min3(float inX, float inY, float inZ);
float Min3WithComponent(float inX, float inY, float inZ, unsigned int* outComponent);

void DistributeItemsOverRange(float inRangeWidth, float inNumItems, float inItemWidth, float* outStart, float* outStep);

#pragma mark Vector
void Set(Vector3* inVector, float inX, float inY, float inZ);
void SetVec2(Vector2* inVector, float inX, float inY);
void SetVec4(Vector4* inVector, float inX, float inY, float inZ, float inW);
Vector4* SetVec4From3(Vector4* inVector, Vector3* inVector3, float inW);
Vector3* SetVec3From4(Vector3* inVector, Vector4* inVector4);

void ZeroVec3(Vector3* inVector);
void ZeroVec4(Vector4* inVector);

void CloneVec2(Vector2* inSource, Vector2* inDest);
void CloneVec3(Vector3* inSource, Vector3* inDest);
void CloneVec4(Vector4* inSource, Vector4* inDest);

void Add2(Vector2* inFirst, Vector2* inSecond, Vector2* outResult);
void Add3(Vector3* inFirst, Vector3* inSecond, Vector3* outResult);
void Add4(Vector4* inFirst, Vector4* inSecond, Vector4* outResult);

void Sub2(Vector2* inFirst, Vector2* inSecond, Vector2* outResult);

inline void Sub3(Vector3* inFirst, Vector3* inSecond, Vector3* outResult)
{
    outResult->mVector[x] = inFirst->mVector[x] - inSecond->mVector[x];
    outResult->mVector[y] = inFirst->mVector[y] - inSecond->mVector[y];
    outResult->mVector[z] = inFirst->mVector[z] - inSecond->mVector[z];
}

void Sub4(Vector4* inFirst, Vector4* inSecond, Vector4* outResult);

void Scale2(Vector2* inVec, float inScale);
void Scale3(Vector3* inVec, float inScale);
void Scale4(Vector4* inVec, float inScale);

float Length2(Vector2* inVector);

void Mul3(float inMultiplier, Vector3* inOutVector);

void Normalize3(Vector3* inOutVector);

inline void Cross3(Vector3* inFirst, Vector3* inSecond, Vector3* outResult)
{
    // Cannot do in place cross-product.
    assert((inFirst != outResult) && (inSecond != outResult));
    
    outResult->mVector[x] = (inFirst->mVector[y] * inSecond->mVector[z]) - (inFirst->mVector[z] * inSecond->mVector[y]);
    outResult->mVector[y] = (inFirst->mVector[z] * inSecond->mVector[x]) - (inFirst->mVector[x] * inSecond->mVector[z]);
    outResult->mVector[z] = (inFirst->mVector[x] * inSecond->mVector[y]) - (inFirst->mVector[y] * inSecond->mVector[x]);
}

inline float Dot3(Vector3* inFirst, Vector3* inSecond)
{
    return (inFirst->mVector[x] * inSecond->mVector[x]) + (inFirst->mVector[y] * inSecond->mVector[y]) + (inFirst->mVector[z] * inSecond->mVector[z]);
}

float Length3(Vector3* inVector);
float Distance3(Vector3* inFirst, Vector3* inSecond);
bool Equal(Vector3* inLeft, Vector3* inRight);

void Normalize4(Vector4* inOutVector);
float Length4(Vector4* inVector);

void MidPointVec3(Vector3* inFirst, Vector3* inSecond, Vector3* outMidPoint);

void LerpVec3(Vector3* inLeft, Vector3* inRight, float inBlend, Vector3* outResult);
void PerpVec3(Vector3* inSource, Vector3* inDest);

typedef void (BresenhamCallback(int, int, void*));
void Bresenham(int x1, int y1, int x2, int y2, BresenhamCallback inCallback, void* BresenhamUserData);

#pragma mark Matrix
void PrintMatrix44(Matrix44* inMatrix, int inNumTabs);

void LoadFromRowMajorArrayOfArrays(Matrix44* inMatrix, float inData[][4]);
void LoadFromColMajorArrayOfArrays(Matrix44* inMatrix, float inData[][4]);

void LoadMatrixFromVector4(Vector4* inRowOne, Vector4* inRowTwo, Vector4* inRowThree, Vector4* inRowFour, Matrix44* outMatrix);
void LoadMatrixFromColMajorString(Matrix44* inMatrix, char* inString);
void LoadMatrixFromRowMajorString(Matrix44* inMatrix, char* inString);

void TransformVector4x3(Matrix44* inTransformationMatrix, const Vector3* inSourceVector, Vector4* outDestVector);
void TransformVector4x4(Matrix44* inTransformationMatrix, Vector4* inSourceVector, Vector4* outDestVector);

void CloneMatrix44(Matrix44* inSrc, Matrix44* inDest);

void SetIdentity(Matrix44* inMatrix);
void Transpose(Matrix44* inMatrix);

void DivideRow(Matrix44* inMatrix, int inRow, float inDivisor);
void SubtractRow(Matrix44* inMatrix, int inLeftRow, int inRightRow, float inRightRowScale, int inDestRow);

bool Inverse(Matrix44* inMatrix, Matrix44* outInverse);
void InverseTranspose(Matrix44* inMatrix, Matrix44* outInverseTranspose);
void InverseView(Matrix44* inMatrix, Matrix44* outInverse);
void InverseProjection(Matrix44* inMatrix, Matrix44* outInverse);

inline void matmul4_optimized(float m0[16], float m1[16], float d[16])
{
#if !defined(__i386__) && defined(__arm__)
	asm volatile (
	"vld1.32 		{d0, d1}, [%1]!			\n\t"	//q0 = m1
	"vld1.32 		{d2, d3}, [%1]!			\n\t"	//q1 = m1+4
	"vld1.32 		{d4, d5}, [%1]!			\n\t"	//q2 = m1+8
	"vld1.32 		{d6, d7}, [%1]			\n\t"	//q3 = m1+12
	"vld1.32 		{d16, d17}, [%0]!		\n\t"	//q8 = m0
	"vld1.32 		{d18, d19}, [%0]!		\n\t"	//q9 = m0+4
	"vld1.32 		{d20, d21}, [%0]!		\n\t"	//q10 = m0+8
	"vld1.32 		{d22, d23}, [%0]		\n\t"	//q11 = m0+12

	"vmul.f32 		q12, q8, d0[0] 			\n\t"	//q12 = q8 * d0[0]
	"vmul.f32 		q13, q8, d2[0] 			\n\t"	//q13 = q8 * d2[0]
	"vmul.f32 		q14, q8, d4[0] 			\n\t"	//q14 = q8 * d4[0]
	"vmul.f32 		q15, q8, d6[0]	 		\n\t"	//q15 = q8 * d6[0]
	"vmla.f32 		q12, q9, d0[1] 			\n\t"	//q12 = q9 * d0[1]
	"vmla.f32 		q13, q9, d2[1] 			\n\t"	//q13 = q9 * d2[1]
	"vmla.f32 		q14, q9, d4[1] 			\n\t"	//q14 = q9 * d4[1]
	"vmla.f32 		q15, q9, d6[1] 			\n\t"	//q15 = q9 * d6[1]
	"vmla.f32 		q12, q10, d1[0] 		\n\t"	//q12 = q10 * d0[0]
	"vmla.f32 		q13, q10, d3[0] 		\n\t"	//q13 = q10 * d2[0]
	"vmla.f32 		q14, q10, d5[0] 		\n\t"	//q14 = q10 * d4[0]
	"vmla.f32 		q15, q10, d7[0] 		\n\t"	//q15 = q10 * d6[0]
	"vmla.f32 		q12, q11, d1[1] 		\n\t"	//q12 = q11 * d0[1]
	"vmla.f32 		q13, q11, d3[1] 		\n\t"	//q13 = q11 * d2[1]
	"vmla.f32 		q14, q11, d5[1] 		\n\t"	//q14 = q11 * d4[1]
	"vmla.f32 		q15, q11, d7[1]	 		\n\t"	//q15 = q11 * d6[1]

	"vst1.32 		{d24, d25}, [%2]! 		\n\t"	//d = q12	
	"vst1.32 		{d26, d27}, [%2]!		\n\t"	//d+4 = q13	
	"vst1.32 		{d28, d29}, [%2]! 		\n\t"	//d+8 = q14	
	"vst1.32 		{d30, d31}, [%2]	 	\n\t"	//d+12 = q15	

	: "+r"(m0), "+r"(m1), "+r"(d) : 
    : "q0", "q1", "q2", "q3", "q8", "q9", "q10", "q11", "q12", "q13", "q14", "q15",
	"memory"
	);
#else
	d[0] = m0[0]*m1[0] + m0[4]*m1[1] + m0[8]*m1[2] + m0[12]*m1[3];
	d[1] = m0[1]*m1[0] + m0[5]*m1[1] + m0[9]*m1[2] + m0[13]*m1[3];
	d[2] = m0[2]*m1[0] + m0[6]*m1[1] + m0[10]*m1[2] + m0[14]*m1[3];
	d[3] = m0[3]*m1[0] + m0[7]*m1[1] + m0[11]*m1[2] + m0[15]*m1[3];
	d[4] = m0[0]*m1[4] + m0[4]*m1[5] + m0[8]*m1[6] + m0[12]*m1[7];
	d[5] = m0[1]*m1[4] + m0[5]*m1[5] + m0[9]*m1[6] + m0[13]*m1[7];
	d[6] = m0[2]*m1[4] + m0[6]*m1[5] + m0[10]*m1[6] + m0[14]*m1[7];
	d[7] = m0[3]*m1[4] + m0[7]*m1[5] + m0[11]*m1[6] + m0[15]*m1[7];
	d[8] = m0[0]*m1[8] + m0[4]*m1[9] + m0[8]*m1[10] + m0[12]*m1[11];
	d[9] = m0[1]*m1[8] + m0[5]*m1[9] + m0[9]*m1[10] + m0[13]*m1[11];
	d[10] = m0[2]*m1[8] + m0[6]*m1[9] + m0[10]*m1[10] + m0[14]*m1[11];
	d[11] = m0[3]*m1[8] + m0[7]*m1[9] + m0[11]*m1[10] + m0[15]*m1[11];
	d[12] = m0[0]*m1[12] + m0[4]*m1[13] + m0[8]*m1[14] + m0[12]*m1[15];
	d[13] = m0[1]*m1[12] + m0[5]*m1[13] + m0[9]*m1[14] + m0[13]*m1[15];
	d[14] = m0[2]*m1[12] + m0[6]*m1[13] + m0[10]*m1[14] + m0[14]*m1[15];
	d[15] = m0[3]*m1[12] + m0[7]*m1[13] + m0[11]*m1[14] + m0[15]*m1[15];
#endif
}

inline void MatrixMultiply(Matrix44* inLeft, Matrix44* inRight, Matrix44* outResult)
{
    Matrix44* leftSource = inLeft;
    Matrix44* rightSource = inRight;
    Matrix44 tempLeft, tempRight;
    
    if (inLeft == outResult)
    {
        CloneMatrix44(inLeft, &tempLeft);
        leftSource = &tempLeft;
    }
    
    if (inRight == outResult)
    {
        CloneMatrix44(inRight, &tempRight);
        rightSource = &tempRight;
    }
    
    float* m0 = leftSource->mMatrix;
    float* m1 = rightSource->mMatrix;
    float* d = outResult->mMatrix;

	matmul4_optimized(m0, m1, d);
}

void FlipMatrixY(Matrix44* inOutMatrix);
void FlipMatrixZ(Matrix44* inOutMatrix);

void GenerateRotationMatrix(float inAngle, float inX, float inY, float inZ, Matrix44* outMatrix);

// Generates a Matrix which performs a rotation about a line (as opposed to GenerateRotationMatrix() which generates a rotation about
// a vector, which is basically a line passing through the origin).  inPoint is any point on the line, inDirection is the direction
// vector of the line.
void GenerateRotationAroundLine(float inAngle, Vector3* inPoint, Vector3* inDirection, Matrix44* outMatrix);

void GenerateTranslationMatrix(float inTranslateX, float inTranslateY, float inTranslateZ, Matrix44* outMatrix);
void GenerateTranslationMatrixFromVector(Vector3* inTranslationVector, Matrix44* outMatrix);
void GenerateScaleMatrix(float inScaleX, float inScaleY, float inScaleZ, Matrix44* outMatrix);

void GenerateVectorToVectorTransform(Vector3* inOrig, Vector3* inDest, Matrix44* outTransform);

#pragma mark Rect
void NeonUnionRect(Rect2D* inBase, Rect2D* inAdd);
bool PointInRect3D(Vector3* inPoint, Rect3D* inRect);
bool RayIntersectsRect3D(Vector3* inPoint, Vector3* inDirection, Rect3D* inRect);
bool VerifyRectWinding(Rect3D* inRect);

#pragma mark BoundingBox
void ZeroBoundingBox(BoundingBox* inOutBox);
void CopyBoundingBox(BoundingBox* inSource, BoundingBox* outDest);

void BoxFromBoundingBox(BoundingBox* inBoundingBox, Box* outBox);
void CloneBox(Box* inSource, Box* outDest);

void GetTopCenterForBox(Box* inBoundingBox, Vector3* outTopCenter);
void GetTopFaceForBox(Box* inBoundingBox, Face* outFace);

void FaceCenter(Vector3* inPoints, Vector3* outCenter);
void FaceExtents(Face* inFace, float* outLeft, float* outRight, float* outTop, float* outBottom);

#pragma mark Plane
void ClonePlane(Plane* inSrcPlane, Plane* inDestPlane);
void PlaneFromRect3D(Rect3D* inRect, Plane* outPlane);
void RayIntersectionWithPlane(Vector3* inPoint, Vector3* inDirection, Plane* inPlane, Vector3* outIntersection, float* outT);
void BarycentricCoordsInTriangle(Vector3* inPoint, Vector3* inTri0, Vector3* inTri1, Vector3* inTri2, Vector3* outPoint);
void DistanceFromPointNormal(Plane* inPlane);

inline bool RayIntersectionWithTriangle(Vector3* inRayStart, Vector3* inRayDirection, Vector3* inTriangle0, Vector3* inTriangle1, Vector3* inTriangle2, float* outT, Vector3* outIntersectPosition)
{
    Vector3 e1, e2, h, s, q;
	float a, f, u, v;
    
	//vector(e1,v1,v0);
	Sub3(inTriangle1, inTriangle0, &e1);
    
    //vector(e2,v2,v0);
    Sub3(inTriangle2, inTriangle0, &e2);

	//crossProduct(h,d,e2);
    Cross3(inRayDirection, &e2, &h);
    
	//a = innerProduct(e1,h);
    a = Dot3(&e1, &h);
    
	if (a > -0.00001 && a < 0.00001)
		return(false);

	f = 1/a;
	//vector(s,p,v0);
    Sub3(inRayStart, inTriangle0, &s);
    
	u = f * (Dot3(&s, &h));

	if (u < 0.0 || u > 1.0)
		return(false);

	Cross3(&s, &e1, &q);
	v = f * Dot3(inRayDirection, &q);

	if (v < 0.0 || u + v > 1.0)
		return(false);

	// at this stage we can compute t to find out where
	// the intersection point is on the line
	float t = f * Dot3(&e2, &q);

	if (t > 0.00001) // ray intersection
    {
        Vector3 distance;
        CloneVec3(inRayDirection, &distance);
        Scale3(&distance, t);
        
        *outT = t;
        Add3(inRayStart, &distance, outIntersectPosition);
        
		return(true);
    }
	else // this means that there is a line intersection
		 // but not a ray intersection
    {
		 return (false);
    }
}

#ifdef __cplusplus
}
#endif

#define NeonMax(x, y)   ( (x > y) ? (x) : (y) )
#define NeonMin(x, y)   ( (x < y) ? (x) : (y) )
