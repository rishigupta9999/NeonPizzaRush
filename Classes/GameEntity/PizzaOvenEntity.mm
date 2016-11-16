//
//  PizzaOvenEntity.m
//  PizzaSpinner
//
//  Created by Rishi Gupta on 6/22/14.
//  Copyright (c) 2014 Neon Games LLC. All rights reserved.
//

#import "PizzaOvenEntity.h"
#import "ModelManager.h"
#import "TextureManager.h"

@implementation PizzaOvenEntity

-(instancetype)Init
{
    [super Init];
    
    mPuppet = [[ModelManager GetInstance] ModelWithName:@"PizzaOven.STM" owner:self];
    [mPuppet retain];
    
    mRenderBinId = RENDERBIN_COMPANIONS;
    
    TextureParams textureParams;
    [Texture InitDefaultParams:&textureParams];
    
    textureParams.mTexDataLifetime = TEX_DATA_DISPOSE;
    Texture* companionTexture = [[TextureManager GetInstance] TextureWithName:@"PizzaOvenTexture.pvrtc"
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
    [super Draw];
}

@end
