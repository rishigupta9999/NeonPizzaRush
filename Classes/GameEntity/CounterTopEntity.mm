//
//  CounterTopEntity.m
//  PizzaSpinner
//
//  Created by Rishi Gupta on 6/18/14.
//  Copyright (c) 2014 Neon Games LLC. All rights reserved.
//

#import "CounterTopEntity.h"
#import "ModelManager.h"
#import "TextureManager.h"

@implementation CounterTopEntity

-(instancetype)Init
{
    [super Init];
    
    mPuppet = [[ModelManager GetInstance] ModelWithName:@"Counter.STM" owner:self];
    [mPuppet retain];
    
    mRenderBinId = RENDERBIN_COMPANIONS;
    
    TextureParams textureParams;
    [Texture InitDefaultParams:&textureParams];
    
    textureParams.mTexDataLifetime = TEX_DATA_DISPOSE;
    Texture* companionTexture = [[TextureManager GetInstance] TextureWithName:@"Granite.pvrtc"
                                                              textureParams:&textureParams];
                                                              
    [mPuppet SetTexture:companionTexture];
    
    mUsesLighting = TRUE;

    return self;
}

-(void)dealloc
{
    [super dealloc];
}

-(void)Draw
{
    float newSpecular[4] = { 1, 1, 1, 1};
    float oldSpecular[4] = { 0, 0, 0, 1};
    float newDiffuse[4] = { 0.2, 0.2, 0.2, 0.2 };
    float oldDiffuse[4] = { 0.8, 0.8, 0.8, 1};
    
    glMaterialfv(GL_FRONT_AND_BACK, GL_SPECULAR, newSpecular);
    glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, newDiffuse);
    glMaterialf(GL_FRONT_AND_BACK, GL_SHININESS, 2);
    [super Draw];
    glMaterialfv(GL_FRONT_AND_BACK, GL_SPECULAR, oldSpecular);
    glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, oldDiffuse);
    glMaterialf(GL_FRONT_AND_BACK, GL_SHININESS, 0);
}

@end
