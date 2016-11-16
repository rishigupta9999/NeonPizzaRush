//
//  PhysicsDebugDrawer.h
//  WaterBalloonToss
//
//  Created by Rishi Gupta on 5/16/14.
//  Copyright (c) 2014 Neon Games LLC. All rights reserved.
//

#ifndef __WaterBalloonToss__PhysicsDebugDrawer__
#define __WaterBalloonToss__PhysicsDebugDrawer__

#undef min
#undef max

#include "LinearMath/btIDebugDraw.h"

#include <iostream>
#include <vector>

#import "NeonArray.h"

class btSoftRigidDynamicsWorld;

class PhysicsDebugDrawer : public btIDebugDraw
{
    public:
        PhysicsDebugDrawer();
        void DrawWorld(btSoftRigidDynamicsWorld* inWorld);
    
        virtual void drawLine(const btVector3& from, const btVector3& to, const btVector3& color);
        virtual void drawContactPoint(const btVector3& PointOnB,const btVector3& normalOnB,btScalar distance,int lifeTime,const btVector3& color);
        virtual void reportErrorWarning(const char* warningString);
        virtual void draw3dText(const btVector3& location,const char* textString);
        virtual void setDebugMode(int debugMode);
        virtual int  getDebugMode() const;
    
    private:
        int         mDebugMode;
        NeonArray*  mPositionData;
        NeonArray*  mColorData;
};

#endif /* defined(__WaterBalloonToss__PhysicsDebugDrawer__) */
