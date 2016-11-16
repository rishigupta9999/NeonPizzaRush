//
//  WaterBalloonEntity.m
//  WaterBalloonToss
//
//  Created by Rishi Gupta on 5/15/14.
//  Copyright (c) 2014 Neon Games LLC. All rights reserved.
//

#import "WaterBalloonEntity.h"
#import "ModelManager.h"
#import "PhysicsManager.h"
#import "SimpleModel.h"
#import "GameStateMgr.h"

#include "btSoftBodyHelpers.h"

class WaterBalloonCollisionCallback : public btSoftBodyCollisionCallback
{
    public:
        WaterBalloonCollisionCallback(WaterBalloonEntity* inWaterBalloonEntity):
            mWaterBalloonEntity(inWaterBalloonEntity)
        {
        }
    
        void CollisionHandlerCallback(const btRigidBody* inRigidBody)
        {
            PhysicsCollisionInfo collisionInfo;
            
            collisionInfo.mFirst = (btCollisionObject*)inRigidBody;
            collisionInfo.mSecond = (btCollisionObject*)mWaterBalloonEntity.SoftBody;
            
            [[[GameStateMgr GetInstance] GetMessageChannel] SendEvent:EVENT_PHYSICS_COLLISION withData:&collisionInfo];
        }
    
    protected:
        WaterBalloonEntity* mWaterBalloonEntity;
};

@implementation WaterBalloonEntity

-(instancetype)InitWithPosition:(Vector3*)inPosition
{
    [super Init];
    
    Vector3 scale;
    Set(&scale, 1.0, 1.0, 2.0);
    
    mUsesLighting = TRUE;
    
    [self SetScaleX:1.0 Y:1.0 Z:1.0];
    [self SetPosition:inPosition];
    
    mCollisionCallback = new WaterBalloonCollisionCallback(self);
    
    [self ResetSoftBodyWithBlock:NULL];
    
    mLock = [[NSLock alloc] init];
    
    return self;
}

-(void)dealloc
{
    delete mCollisionCallback;
    
    free(mPhysicsVertexBuffer);
    
    [mLock release];
    
    [super dealloc];
}

-(void)ResetSoftBodyWithBlock:(dispatch_block_t)inBlock
{
    BOOL firstTime = TRUE;
    
    BOOL derivedPositionValid = FALSE;
    Vector3 derivedPosition;
    
    btSoftBody* softBody = NULL;
    
    //NSLog(@"Reset soft body 1");
    
    if (self.SoftBody)
    {
        derivedPositionValid = TRUE;
        [self GetDerivedPosition:&derivedPosition];
        
        softBody = self.SoftBody;
        self.SoftBody = NULL;
        
        firstTime = FALSE;
    }
    
    //NSLog(@"Reset soft body 2");
    
    if (inBlock != NULL)
    {
        Block_copy(inBlock);
    }
    
    dispatch_async([[PhysicsManager GetInstance] GetPhysicsQueue], ^
    {
        //NSLog(@"Reset soft body 3");
        btSoftBody* ellipticalSoftBody = [[PhysicsManager GetInstance] CreateEllipticalSoftBodyX:1.0 y:1.0 z:1.0];
        
        if (softBody != NULL)
        {
            [[PhysicsManager GetInstance] RemoveSoftBody:softBody];
        }
        
        Block_copy(inBlock);
        
        dispatch_async(dispatch_get_main_queue(), ^
        {
            //NSLog(@"Reset soft body 4");
            if (derivedPositionValid)
            {
                [self SetPosition:(Vector3*)&derivedPosition];
            }

            self.SoftBody = ellipticalSoftBody;
            self.SoftBody->m_customCollisionCallback = mCollisionCallback;
            
            mPuppet = [[PhysicsManager GetInstance] CreateModelFromSoftBody:self.SoftBody];
            
            if (firstTime)
            {
                mPhysicsVertexBuffer = (float*)malloc(((SimpleModel*)mPuppet)->mNumVertices * sizeof(float) * 6);
            }
            
            if (inBlock != NULL)
            {
                dispatch_async(dispatch_get_main_queue(), inBlock);
                Block_release(inBlock);
            }
        });
    });
}

-(void)Update:(CFTimeInterval)inTimeStep
{
    [super Update:inTimeStep];
    
    if (self.SoftBody == NULL)
    {
        return;
    }
    
    dispatch_async([[PhysicsManager GetInstance] GetPhysicsQueue], ^
    {
        if (self.SoftBody == NULL)
        {
            return;
        }
        
        [mLock lock];
        
        btSoftBody::tFaceArray* faces = &(self.SoftBody->m_faces);
        
        int numFaces = faces->size();
        
        float* writeArray = mPhysicsVertexBuffer;
        
        NSAssert((numFaces * 3) == ((SimpleModel*)mPuppet)->mNumVertices, @"Number of vertices in object changed from the initial creation");
        
        for (int curFace = 0; curFace < numFaces; curFace++)
        {
            btSoftBody::Face* face = &faces->at(curFace);
            
            for (int vertex = 0; vertex < 3; vertex++)
            {
                btSoftBody::Node* curNode = face->m_n[vertex];
                
                // 3 normals and positions per vertex
                u32 writeOffset = 6 * ((curFace * 3) + vertex);
                
                // Write position
                writeArray[writeOffset++] = curNode->m_x.x();
                writeArray[writeOffset++] = curNode->m_x.y();
                writeArray[writeOffset++] = curNode->m_x.z();
                
                // Write normal
                writeArray[writeOffset++] = curNode->m_n.x();
                writeArray[writeOffset++] = curNode->m_n.y();
                writeArray[writeOffset++] = curNode->m_n.z();
            }
        }
        
        [mLock unlock];
    });
}

-(void)Draw
{
    if (mPuppet != NULL)
    {
        [mLock lock];
        memcpy(((SimpleModel*)mPuppet)->mStream, mPhysicsVertexBuffer, sizeof(float) * 6 * ((SimpleModel*)mPuppet)->mNumVertices);
        [mLock unlock];
        
        [super Draw];
    }
    else
    {
        NSLog(@"Null puppet");
    }
}

@end
