//
//  PhysicsManager.h
//  WaterBalloonToss
//
//  Created by Rishi Gupta on 5/14/14.
//  Copyright (c) 2014 Neon Games LLC. All rights reserved.
//

@class SimpleModel;
@class GameObject;

class btSoftBody;
class btRigidBody;
class btCollisionObject;
class btBvhTriangleMeshShape;
class btSoftRigidDynamicsWorld;

struct PhysicsCollisionInfo
{
    btCollisionObject*  mFirst;
    btCollisionObject*  mSecond;
    
    PhysicsCollisionInfo() :
        mFirst(NULL), mSecond(NULL)
    {
    }
    
    bool DidCollide(btCollisionObject* inObject)
    {
        return ((mFirst == inObject) || (mSecond == inObject));
    }
};

@interface PhysicsManager : NSObject
{
@public
    btSoftRigidDynamicsWorld*   mDynamicsWorld;
    float                       mExcessTime;
    dispatch_queue_t            mPhysicsQueue;
}

-(instancetype)Init;
-(void)dealloc;
+(void)CreateInstance;
+(void)DestroyInstance;
+(PhysicsManager*)GetInstance;

-(void)Update:(CFTimeInterval)inTimeStep;
-(void)Draw;

-(dispatch_queue_t)GetPhysicsQueue;

-(btSoftBody*)CreateSoftBodyFromModel:(SimpleModel*)inModel;
-(btSoftBody*)CreateEllipticalSoftBodyX:(float)inX y:(float)inY z:(float)inZ;
-(SimpleModel*)CreateModelFromSoftBody:(btSoftBody*)inSoftBody;

-(btRigidBody*)CreateRigidBodyFromModel:(SimpleModel*)inModel withMass:(float)inMass;
-(btBvhTriangleMeshShape*)CreateTriangleMeshFromModel:(SimpleModel*)inModel;

-(void)DisableSoftBody:(btSoftBody*)inSoftBody;
-(void)EnableSoftBody:(btSoftBody*)inSoftBody;

-(void)DisableRigidBody:(btRigidBody*)inRigidBody;
-(void)EnableRigidBody:(btRigidBody*)inRigidBody;

-(void)RemoveSoftBody:(btSoftBody*)inSoftBody;
-(void)RemoveRigidBody:(btRigidBody*)inRigidBody;

-(void)AddCollisionObjectToWorld:(btCollisionObject*)inCollisionObject;

-(void)UpdateSoftBodyTransform:(btSoftBody*)inSoftBody fromObject:(GameObject*)inObject;
-(void)UpdateSoftBody:(btSoftBody*)inSoftBody withDelta:(Vector3*)inDelta;

@end
