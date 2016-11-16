//
//  BrickEntity.m
//  WaterBalloonToss
//
//  Created by Rishi Gupta on 6/13/14.
//  Copyright (c) 2014 Neon Games LLC. All rights reserved.
//

#import "BrickEntity.h"
#import "SimpleModel.h"
#import "ModelManager.h"
#import "TextureManager.h"
#import "PhysicsManager.h"

@implementation BrickEntity

-(instancetype)InitWithScaleX:(float)inX y:(float)inY z:(float)inZ
{
    [super Init];
    
    mPuppet = [[ModelManager GetInstance] ModelWithName:@"Brick.STM" owner:self];
    [mPuppet retain];
    
    TextureParams texParams;
    [Texture InitDefaultParams:&texParams];
    
    texParams.mTexDataLifetime = TEX_DATA_DISPOSE;
    
    mBrickTexture = [[TextureManager GetInstance] TextureWithName:@"Brick.pvrtc" textureParams:&texParams];
    [mPuppet SetTexture:mBrickTexture];
    
    Matrix44 scale;
    GenerateScaleMatrix(inX, inY, inZ, &scale);
    
    [(SimpleModel*)mPuppet TransformInPlace:&scale];
    
    self.RigidBody = [[PhysicsManager GetInstance] CreateRigidBodyFromModel:(SimpleModel*)mPuppet withMass:0];
    
    return self;
}

-(void)dealloc
{
    [super dealloc];
}

@end
