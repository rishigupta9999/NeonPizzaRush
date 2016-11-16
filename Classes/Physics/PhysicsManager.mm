//
//  PhysicsManager.m
//  WaterBalloonToss
//
//  Created by Rishi Gupta on 5/14/14.
//  Copyright (c) 2014 Neon Games LLC. All rights reserved.
//

#import "PhysicsManager.h"
#import "PhysicsDebugDrawer.h"

#include "btBulletDynamicsCommon.h"
#include "btSoftRigidDynamicsWorld.h"
#include "btSoftBodyRigidBodyCollisionConfiguration.h"
#include "btSoftBodyHelpers.h"

#import "NeonGL.h"
#import "SimpleModel.h"
#import "GameObject.h"

static PhysicsManager* sInstance = NULL;
static const float sTimeStep = 0.001;   // Step at 240 hz.  Alleviates issue with soft bodies getting stuck inside objects since they can travel relatively fast in our world.


@implementation PhysicsManager(PrivateData)
    btSoftBodyWorldInfo                         mSoftBodyWorldInfo;
    btSoftBodyRigidBodyCollisionConfiguration*  mCollisionConfiguration;
    btCollisionDispatcher*                      mCollisionDispatcher;
    btAxisSweep3*                               mBroadphase;
    btSequentialImpulseConstraintSolver*        mSolver;

    PhysicsDebugDrawer*                         mDebugDrawer;
@end

@implementation PhysicsManager

static const int MAX_PROXIES = 32766;

-(instancetype)Init
{
	mCollisionConfiguration = new btSoftBodyRigidBodyCollisionConfiguration();
	mCollisionDispatcher = new	btCollisionDispatcher(mCollisionConfiguration);
    
    btVector3 worldAabbMin(-1000,-1000,-1000);
	btVector3 worldAabbMax(1000,1000,1000);

	mBroadphase = new btAxisSweep3(worldAabbMin, worldAabbMax, MAX_PROXIES);
    
    mSolver = new btSequentialImpulseConstraintSolver();
    
	mSoftBodyWorldInfo.m_dispatcher = mCollisionDispatcher;
    mSoftBodyWorldInfo.m_broadphase = mBroadphase;
    
    mSoftBodyWorldInfo.air_density		=	(btScalar)1.2;
	mSoftBodyWorldInfo.water_density	=	0;
	mSoftBodyWorldInfo.water_offset		=	0;
	mSoftBodyWorldInfo.water_normal		=	btVector3(0,0,0);
	mSoftBodyWorldInfo.m_gravity.setValue(0, -4.9, 0);


	mDynamicsWorld = new btSoftRigidDynamicsWorld(mCollisionDispatcher, mBroadphase, mSolver, mCollisionConfiguration, NULL);
    
    mDebugDrawer = new PhysicsDebugDrawer;
    mDynamicsWorld->setDebugDrawer(mDebugDrawer);
    
    mDebugDrawer->setDebugMode(btIDebugDraw::DBG_DrawWireframe | btIDebugDraw::DBG_DrawNormals);
    
    btCollisionShape* groundBox = new btBoxShape (btVector3(100,0.0,100));
    btCollisionObject* collisionObject = new btCollisionObject();
    
    collisionObject->setCollisionShape(groundBox);
    
	mDynamicsWorld->addCollisionObject(collisionObject);
    
    mSoftBodyWorldInfo.m_sparsesdf.Initialize();
    mDynamicsWorld->setGravity(btVector3(0,-4.9,0));
    
    mExcessTime = 0;
    
    mPhysicsQueue = dispatch_queue_create("com.neongames.physicsqueue.bgqueue", NULL);
    
    return self;
}

-(void)dealloc
{
    delete mDebugDrawer;
    
    [super dealloc];
}

+(void)CreateInstance
{
    NSAssert(sInstance == NULL, @"sInstance should be NULL");
    sInstance = [[PhysicsManager alloc] Init];
}

+(void)DestroyInstance
{
}

+(PhysicsManager*)GetInstance
{
    return sInstance;
}

-(void)Update:(CFTimeInterval)inTimeStep
{
    dispatch_async(mPhysicsQueue, ^{
        // Divide by 2 to intentionally slow down physics.
        // Remove division by 2 for normal speed.
        
        mExcessTime += inTimeStep;
        
        while(true)
        {
            if (mExcessTime > sTimeStep)
            {
                mDynamicsWorld->stepSimulation(sTimeStep);
                mExcessTime -= sTimeStep;
            }
            else
            {
                break;
            }
        }
    });
}

-(void)Draw
{
    //mDebugDrawer->DrawWorld(mDynamicsWorld);
}

-(dispatch_queue_t)GetPhysicsQueue
{
    return mPhysicsQueue;
}

-(btSoftBody*)CreateSoftBodyFromModel:(SimpleModel*)inModel
{
    float* positions = (float*)malloc(sizeof(float) * inModel->mNumVertices * 3);
    
    for (int i = 0; i < inModel->mNumVertices; i++)
    {
        memcpy(positions + (i * 3), &inModel->mStream[i * inModel->mStride], inModel->mPositionStride * sizeof(float));
    }
    
    int* indices = (int*)malloc(sizeof(int) * inModel->mNumVertices);
    
    for (int i = 0; i < inModel->mNumVertices; i++)
    {
        indices[i] = i;
    }

    btSoftBody*	psb = btSoftBodyHelpers::CreateFromTriMesh(mSoftBodyWorldInfo, positions, indices, inModel->mNumVertices / 3);
    
    psb->generateClusters(64);
    
	psb->setTotalMass(0.5, false);
    psb->m_materials[0]->m_kLST	=	1.0;
    psb->m_cfg.kVC				=	40;
    psb->generateBendingConstraints(2);
	psb->setPose(true, false);
    
    free(positions);
    free(indices);
    
    mDynamicsWorld->addSoftBody(psb);
    
    return psb;
}

-(btSoftBody*)CreateEllipticalSoftBodyX:(float)inX y:(float)inY z:(float)inZ
{
    btSoftBody*	psb = btSoftBodyHelpers::CreateEllipsoid(mSoftBodyWorldInfo, btVector3(0, 0, 0), btVector3(inX, inY, inZ), 192);
    
    //psb->generateClusters(0);
    
	psb->setTotalMass(0.5, false);
    psb->m_materials[0]->m_kLST	=	0.1;
    psb->m_materials[0]->m_kVST =   0.3;
    psb->m_cfg.kVC				=	15;
    psb->m_cfg.piterations = 120;
    psb->m_cfg.diterations = 12;
    psb->m_cfg.viterations = 10;
	psb->setPose(true, false);
        
    return psb;
}

-(btRigidBody*)CreateRigidBodyFromModel:(SimpleModel*)inModel withMass:(float)inMass
{
    btBvhTriangleMeshShape* triangleMeshShape = [self CreateTriangleMeshFromModel:inModel];
    
    btDefaultMotionState* motionState = new btDefaultMotionState();
 
    btScalar bodyMass = inMass;
    btVector3 bodyInertia;
    triangleMeshShape->calculateLocalInertia(bodyMass, bodyInertia);
 
    btRigidBody::btRigidBodyConstructionInfo bodyCI = btRigidBody::btRigidBodyConstructionInfo(bodyMass, motionState, triangleMeshShape, bodyInertia);
 
    bodyCI.m_restitution = 1.0f;
    bodyCI.m_friction = 0.5f;
 
    btRigidBody* rigidBody = new btRigidBody(bodyCI);
    
    if (inMass == 0)
    {
        rigidBody->setCollisionFlags(rigidBody->getCollisionFlags() | btCollisionObject::CF_KINEMATIC_OBJECT);
    }
    
    mDynamicsWorld->addRigidBody(rigidBody);
    
    return rigidBody;
}

-(btBvhTriangleMeshShape*)CreateTriangleMeshFromModel:(SimpleModel*)inModel
{
    btTriangleIndexVertexArray* meshInterface = new btTriangleIndexVertexArray();
    btIndexedMesh part;
    
    float* positions = (float*)malloc(sizeof(float) * inModel->mNumVertices * 3);
    
    for (int i = 0; i < inModel->mNumVertices; i++)
    {
        memcpy(positions + (i * 3), &inModel->mStream[i * inModel->mStride], inModel->mPositionStride * sizeof(float));
    }
    
    int* indices = (int*)malloc(sizeof(int) * inModel->mNumVertices);
    
    for (int i = 0; i < inModel->mNumVertices; i++)
    {
        indices[i] = i;
    }

    part.m_vertexBase = (const unsigned char*)positions;
    part.m_vertexStride = sizeof(btScalar) * 3;
    part.m_numVertices = inModel->mNumVertices;
    part.m_triangleIndexBase = (const unsigned char*)indices;
    part.m_triangleIndexStride = sizeof(int) * 3;
    part.m_numTriangles = inModel->mNumVertices / 3;
    part.m_indexType = PHY_INTEGER;

    meshInterface->addIndexedMesh(part, PHY_INTEGER);

    bool	useQuantizedAabbCompression = true;
    btBvhTriangleMeshShape* triMeshShape = new btBvhTriangleMeshShape(meshInterface,useQuantizedAabbCompression);
        
    return triMeshShape;
}

-(void)DisableSoftBody:(btSoftBody*)inSoftBody
{
    if (inSoftBody == NULL)
    {
        return;
    }
    
    dispatch_async(mPhysicsQueue, ^
    {
        mDynamicsWorld->removeSoftBody(inSoftBody);
    });
}

-(void)EnableSoftBody:(btSoftBody*)inSoftBody
{
    if (inSoftBody == NULL)
    {
        return;
    }
    
    dispatch_async(mPhysicsQueue, ^
    {
        mDynamicsWorld->addSoftBody(inSoftBody);
    });
}

-(void)DisableRigidBody:(btRigidBody*)inRigidBody
{
    if (inRigidBody == NULL)
    {
        return;
    }
    
    dispatch_async(mPhysicsQueue, ^
    {
        mDynamicsWorld->removeRigidBody(inRigidBody);
    });
}

-(void)EnableRigidBody:(btRigidBody*)inRigidBody
{
    if (inRigidBody == NULL)
    {
        return;
    }
    
    dispatch_async(mPhysicsQueue, ^
    {
        mDynamicsWorld->addRigidBody(inRigidBody);
    });
}

-(void)RemoveSoftBody:(btSoftBody*)inSoftBody
{
    if (inSoftBody == NULL)
    {
        return;
    }
    
    dispatch_async(mPhysicsQueue, ^
    {
        mDynamicsWorld->removeSoftBody(inSoftBody);
        delete inSoftBody;
    });
}

-(void)RemoveRigidBody:(btRigidBody*)inRigidBody
{
    if (inRigidBody == NULL)
    {
        return;
    }
    
    mDynamicsWorld->removeRigidBody(inRigidBody);
    
    btBvhTriangleMeshShape* collisionShape = (btBvhTriangleMeshShape*)inRigidBody->getCollisionShape();
    btTriangleIndexVertexArray* meshInterface = (btTriangleIndexVertexArray*)collisionShape->getMeshInterface();
    
    IndexedMeshArray* indexedMeshes = &meshInterface->getIndexedMeshArray();
    int numMeshes = indexedMeshes->size();
    
    for (int i = 0; i < numMeshes; i++)
    {
        btIndexedMesh* curMesh = &indexedMeshes->at(i);
        free((void*)curMesh->m_triangleIndexBase);
        free((void*)curMesh->m_vertexBase);
    }
    
    delete inRigidBody;
}

-(SimpleModel*)CreateModelFromSoftBody:(btSoftBody*)inSoftBody
{
    SimpleModel* retModel = [[SimpleModel alloc] Init];
    
    retModel->mPositionStride = 3;
    retModel->mNormalStride = 3;
    retModel->mTexcoordStride = 0;
    retModel->mNumMatricesPerVertex = 0;
    retModel->mStride = 6 * sizeof(float);
    
    btSoftBody::tFaceArray* faces = &(inSoftBody->m_faces);
    
    int numFaces = faces->size();
    int numVertices = numFaces * 3;
    
    retModel->mStream = (u8*)malloc(numVertices * sizeof(float) * 6);
    retModel->mNumVertices = numVertices;
    
    float* writeArray = (float*)retModel->mStream;
    
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
    
    return retModel;
}

-(void)AddCollisionObjectToWorld:(btCollisionObject*)inCollisionObject
{
    mDynamicsWorld->addCollisionObject(inCollisionObject);
}

-(void)UpdateSoftBodyTransform:(btSoftBody*)inSoftBody fromObject:(GameObject*)inObject
{
    Matrix44 transform;
    [inObject GetLocalToWorldTransform:&transform];
    
    btMatrix3x3 upperRight;
    upperRight.setFromOpenGLSubMatrix(transform.mMatrix);
    
	inSoftBody->transform(btTransform(upperRight, btVector3(transform.mMatrix[12], transform.mMatrix[13], transform.mMatrix[14])));
}

-(void)UpdateSoftBody:(btSoftBody*)inSoftBody withDelta:(Vector3*)inDelta
{
    Matrix44 transform;
    GenerateTranslationMatrix(inDelta->mVector[x], inDelta->mVector[y], inDelta->mVector[z], &transform);
    
    btMatrix3x3 upperRight;
    upperRight.setFromOpenGLSubMatrix(transform.mMatrix);

    dispatch_async(mPhysicsQueue, ^
    {
        inSoftBody->transform(btTransform(upperRight, btVector3(transform.mMatrix[12], transform.mMatrix[13], transform.mMatrix[14])));
    });
}

@end
