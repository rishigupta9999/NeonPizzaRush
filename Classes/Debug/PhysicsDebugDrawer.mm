//
//  PhysicsDebugDrawer.cpp
//  WaterBalloonToss
//
//  Created by Rishi Gupta on 5/16/14.
//  Copyright (c) 2014 Neon Games LLC. All rights reserved.
//

#undef min
#undef max

#import "PhysicsDebugDrawer.h"
#import "NeonUtilities.h"
#import "NeonGL.h"
#import "btSoftRigidDynamicsWorld.h"
#import "ModelManager.h"
#import "btSoftBodyHelpers.h"

struct PositionData
{
    float   mX1, mY1, mZ1;
    float   mX2, mY2, mZ2;
};

struct ColorData
{
    float   mR1, mG1, mB1, mA1;
    float   mR2, mG2, mB2, mA2;
};

PhysicsDebugDrawer::PhysicsDebugDrawer()
{
    mDebugMode = 0;
    
    NeonArrayParams positionArrayParams;
    NeonArray_InitParams(&positionArrayParams);
    
    positionArrayParams.mElementSize = sizeof(PositionData);
    NSCAssert(sizeof(PositionData) == sizeof(float) * 6, @"Unexpected sized of PositionData");
    
    mPositionData = NeonArray_Create(&positionArrayParams);
    
    
    NeonArrayParams colorArrayParams;
    NeonArray_InitParams(&colorArrayParams);

    colorArrayParams.mElementSize = sizeof(ColorData);
    NSCAssert(sizeof(ColorData) == sizeof(float) * 8, @"Unexpected sized of ColorData");
    
    mColorData = NeonArray_Create(&colorArrayParams);
}

void PhysicsDebugDrawer::drawLine(const btVector3& from, const btVector3& to, const btVector3& color)
{
    PositionData positionData;
    
    positionData.mX1 = from.x();
    positionData.mY1 = from.y();
    positionData.mZ1 = from.z();
    
    positionData.mX2 = to.x();
    positionData.mY2 = to.y();
    positionData.mZ2 = to.z();
    
    NeonArray_InsertElementAtEnd(mPositionData, &positionData);
    
    ColorData colorData;
    
    colorData.mR1 = color.x();
    colorData.mG1 = color.y();
    colorData.mB1 = color.z();
    colorData.mA1 = 0.5;
    
    colorData.mR2 = color.x();
    colorData.mG2 = color.y();
    colorData.mB2 = color.z();
    colorData.mA2 = 0.5;
    
    NeonArray_InsertElementAtEnd(mColorData, &colorData);
}

void PhysicsDebugDrawer::drawContactPoint(const btVector3& PointOnB,const btVector3& normalOnB,btScalar distance,int lifeTime,const btVector3& color)
{
}

void PhysicsDebugDrawer::reportErrorWarning(const char* warningString)
{
    NSLog(@"%s", warningString);
}

void PhysicsDebugDrawer::draw3dText(const btVector3& location,const char* textString)
{
}

void PhysicsDebugDrawer::setDebugMode(int debugMode)
{
    mDebugMode = debugMode;
}

int PhysicsDebugDrawer::getDebugMode() const
{
    return mDebugMode;
}

void PhysicsDebugDrawer::DrawWorld(btSoftRigidDynamicsWorld* inWorld)
{
    [[ModelManager GetInstance] SetupWorldCamera];
    
    inWorld->setDrawFlags(inWorld->getDrawFlags() | fDrawFlags::Normals);

#if 0
    for (  int i=0;i<inWorld->getSoftBodyArray().size();i++)
	{
		btSoftBody*	psb=(btSoftBody*)inWorld->getSoftBodyArray()[i];

        btSoftBodyHelpers::Draw(psb,inWorld->getDebugDrawer(),inWorld->getDrawFlags());
	}
#endif
    
    inWorld->debugDrawWorld();
    
    GLState glState;
    SaveGLState(&glState);
    
    NeonGLDisable(GL_DEPTH_TEST);
    NeonGLEnable(GL_BLEND);
    NeonGLBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_COLOR_ARRAY);
    
    glVertexPointer(3, GL_FLOAT, 0, mPositionData->mArrayContents);
    glColorPointer(4, GL_FLOAT, 0, mColorData->mArrayContents);
    
    NSCAssert(NeonArray_GetNumElements(mPositionData) == NeonArray_GetNumElements(mColorData), @"Expected same number of position and color elements");
    glDrawArrays(GL_LINES, 0, NeonArray_GetNumElements(mPositionData));
    
    RestoreGLState(&glState);
    
    NeonArray_RemoveAllElements(mPositionData);
    NeonArray_RemoveAllElements(mColorData);
    
    [[ModelManager GetInstance] TeardownWorldCamera];
}