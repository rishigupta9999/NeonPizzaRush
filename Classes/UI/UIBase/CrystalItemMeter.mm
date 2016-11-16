//
//  CrystalItemMeter.m
//  PizzaSpinner
//
//  Created by Rishi Gupta on 9/22/14.
//  Copyright (c) 2014 Neon Games LLC. All rights reserved.
//

#import "CrystalItemMeter.h"
#import "FoodManager.h"

@implementation CrystalItemMeter

-(instancetype)InitWithUIGroup:(UIGroup*)inUIGroup
{
    [super InitWithUIGroup:inUIGroup];
    
    UIObjectTextureLoadParams params;
    [UIObject InitDefaultTextureLoadParams:&params];
    
    params.mTexDataLifetime = TEX_DATA_DISPOSE;
    params.mTextureName = @"crystal_pizza_meter.papng";
    
    mTexture = [self LoadTextureWithParams:&params];
    [mTexture retain];
    
    return self;
}

-(void)dealloc
{
    [mTexture release];
    [super dealloc];
}

-(void)DrawOrtho
{
    QuadParams  quadParams;
    
    [UIObject InitQuadParams:&quadParams];
    
    quadParams.mColorMultiplyEnabled = TRUE;
    quadParams.mBlendEnabled = TRUE;
    quadParams.mTexture = mTexture;
    
    for (int i = 0; i < 4; i++)
    {
        float rMultiply = 1.0;
        float gMultiply = 1.0;
        float bMultiply = 1.0;
        float aMultiply = 1.0;
        
        if (mColorMultiplyEnabled)
        {
            rMultiply = GetRedFloat(&mColorMultiply);
            gMultiply = GetGreenFloat(&mColorMultiply);
            bMultiply = GetBlueFloat(&mColorMultiply);
            aMultiply = GetAlphaFloat(&mColorMultiply);
        }
        
        SetColorFloat(&quadParams.mColor[i], rMultiply, gMultiply, bMultiply, [self GetCombinedAlpha] * aMultiply);
    }
    
    float curHeight = GetScreenAbsoluteHeight() * [[FoodManager GetInstance] GetCrystalItemPercentRemaining];
    SetVec2(&quadParams.mScale, 4, curHeight);
    quadParams.mScaleType = QUAD_PARAMS_SCALE_BOTH;
    
    [self DrawQuad:&quadParams];
    
    [super DrawOrtho];
}

-(Texture*)GetTexture
{
    return mTexture;
}

-(Texture*)GetUseTexture
{
    return mTexture;
}

@end
