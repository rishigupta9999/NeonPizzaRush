//
//  WaterBalloonPlayerEntity.m
//  WaterBalloonToss
//
//  Created by Rishi Gupta on 5/13/14.
//  Copyright (c) 2014 Neon Games LLC. All rights reserved.
//

#import "WaterBalloonPlayerEntity.h"
#import "ModelManager.h"
#import "TextureManager.h"
#import "SimpleModel.h"
#import "PhysicsManager.h"

#include "LinearMath/btConvexHullComputer.h"
#include "btBulletDynamicsCommon.h"

static const Vector3 sHandsPositionLocal = { { 0.0, -4.75, 5.25 } };

@implementation WaterBalloonPlayerEntity

-(instancetype)Init
{
    [super Init];
    
    mPuppet = [[ModelManager GetInstance] ModelWithName:@"WaterBalloonPlayer.STM" owner:self];
    [mPuppet retain];
    
    mRenderBinId = RENDERBIN_COMPANIONS;
    
    TextureParams textureParams;
    [Texture InitDefaultParams:&textureParams];
    
    textureParams.mTexDataLifetime = TEX_DATA_DISPOSE;
    Texture* companionTexture = [[TextureManager GetInstance] TextureWithName:@"WaterBalloonPlayer.pvrtc"
                                                              textureParams:&textureParams];
                                                              
    [mPuppet SetTexture:companionTexture];
    
    
    mPhysicsMesh = (SimpleModel*)[[ModelManager GetInstance] ModelWithName:@"WaterBalloonPlayerPhysicsMesh.STM" owner:self];
    [mPhysicsMesh retain];
    
    
    self.RigidBody = [[PhysicsManager GetInstance] CreateRigidBodyFromModel:mPhysicsMesh withMass:0];

    mUsesLighting = TRUE;

    return self;
}

-(void)dealloc
{
    [mPhysicsMesh release];
    
    [super dealloc];
}

-(void)Remove
{
}

-(void)GetHandsPosition:(Vector3*)outHandPosition
{
    [self TransformLocalToWorld:&sHandsPositionLocal result:outHandPosition];
}

-(void)Draw
{
    [super Draw];

#if 0
    GLState glState;
    SaveGLState(&glState);
    
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_NORMAL_ARRAY);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    
    glEnable(GL_TEXTURE_2D);
    [mPuppet->mTexture Bind];
    
    glVertexPointer(3, GL_FLOAT, 8 * sizeof(float), mPhysicsMesh->mStream);
    glNormalPointer(GL_FLOAT, 8 * sizeof(float), mPhysicsMesh->mStream + 3 * sizeof(float));
    glTexCoordPointer(2, GL_FLOAT, 8 * sizeof(float), mPhysicsMesh->mStream + 6 * sizeof(float));
    
    glDrawArrays(GL_TRIANGLES, 0, mPhysicsMesh->mNumVertices);
    
    RestoreGLState(&glState);
#endif
}

@end
