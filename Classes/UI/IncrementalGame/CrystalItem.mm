//
//  CrystalItem.m
//  PizzaSpinner
//
//  Created by Rishi Gupta on 9/17/14.
//  Copyright (c) 2014 Neon Games LLC. All rights reserved.
//

#import "CrystalItem.h"
#import "ImageWell.h"
#import "Event.h"

static const int NUM_LIGHT_RAYS = 24;
static const float DEGREES_PER_SECOND = 10;

static const float LIGHT_RAY_LENGTH_MIN = 56;
static const float LIGHT_RAY_LENGTH_MAX = 72;

@interface LightRay : NSObject
{
}

@property float Rotation;
@property(assign) Path* Path;

-(instancetype)Init;

@end

@implementation LightRay

@synthesize Rotation = mRotation;

-(instancetype)Init
{
    mRotation = 0;
    return self;
}

@end

@implementation CrystalItemParams

@synthesize UIGroup = mUIGroup;
@synthesize ImageName = mImageName;
@synthesize PizzaVisible = mPizzaVisible;

-(instancetype)Init
{
    mPizzaVisible = TRUE;
    mImageName = NULL;
    mUIGroup = NULL;
    
    return self;
}

@end

@implementation CrystalItem

-(instancetype)InitWithParams:(CrystalItemParams*)inParams
{
    [super InitWithUIGroup:inParams.UIGroup];

    if (inParams.PizzaVisible)
    {
        ImageWellParams imageWellParams;
        [ImageWell InitDefaultParams:&imageWellParams];
        
        imageWellParams.mTextureName = inParams.ImageName;
        imageWellParams.mUIGroup = inParams.UIGroup;
        
        mImage = [[ImageWell alloc] InitWithParams:&imageWellParams];
        [mImage release];
    }
    
    mImage.Parent = self;
    
    // Light shaft texture
    UIObjectTextureLoadParams params;
    [UIObject InitDefaultTextureLoadParams:&params];
    
    params.mTexDataLifetime = TEX_DATA_DISPOSE;
    params.mTextureName = @"LightShaft.papng";
    
    mTexture = [self LoadTextureWithParams:&params];
    [mTexture retain];
    
    // Light rays
    mLightRays = [[NSMutableArray alloc] init];
    [self CreateLightRays];
    
    // Scale path for when button is tapped
    mScalePath = [[Path alloc] Init];
    
    [mScalePath AddNodeScalar:1.0 atTime:0.0];
    [mScalePath AddNodeScalar:1.75 atTime:0.3];
    
    // Crystal Item State
    mCrystalItemState = CRYSTAL_ITEM_STATE_NORMAL;
    
    return self;
}

-(void)dealloc
{
    [mLightRays release];
    [mScalePath release];
    
    [super dealloc];
}

-(void)Update:(CFTimeInterval)inTimeStep
{
    for (LightRay* curLightRay in mLightRays)
    {
        curLightRay.Rotation += DEGREES_PER_SECOND * inTimeStep;
        [curLightRay.Path Update:inTimeStep];
    }
    
    switch(mCrystalItemState)
    {
        case CRYSTAL_ITEM_STATE_GROWING:
        {
            [mScalePath Update:inTimeStep];
            
            if ([mScalePath Finished])
            {
                [self Disable];
            }
            
            break;
        }
    }
    
    [super Update:inTimeStep];
}

-(void)DrawOrtho
{
    QuadParams  quadParams;
    
    for (LightRay* curLightRay in mLightRays)
    {
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
            
            SetColorFloat(&quadParams.mColor[i], rMultiply, gMultiply, bMultiply, mAlpha * aMultiply);
        }

        quadParams.mTexCoordEnabled = TRUE;
        
        quadParams.mTexCoords[0] = mTexture->mTextureAtlasInfo.mSMin;
        quadParams.mTexCoords[1] = mTexture->mTextureAtlasInfo.mTMax;
        quadParams.mTexCoords[2] = mTexture->mTextureAtlasInfo.mSMin;
        quadParams.mTexCoords[3] = mTexture->mTextureAtlasInfo.mTMin;
        quadParams.mTexCoords[4] = mTexture->mTextureAtlasInfo.mSMax;
        quadParams.mTexCoords[5] = mTexture->mTextureAtlasInfo.mTMax;
        quadParams.mTexCoords[6] = mTexture->mTextureAtlasInfo.mSMax;
        quadParams.mTexCoords[7] = mTexture->mTextureAtlasInfo.mTMin;
        
        quadParams.mTranslation.mVector[x] = [mImage GetWidth] / 2;
        quadParams.mTranslation.mVector[y] = [mImage GetHeight] / 2;
        
        quadParams.mRotation = curLightRay.Rotation;
        
        quadParams.mScaleType = QUAD_PARAMS_SCALE_BOTH;
        quadParams.mScale.mVector[x] = 10;
        
        float yScale;
        [curLightRay.Path GetValueScalar:&yScale];
        
        if (mCrystalItemState == CRYSTAL_ITEM_STATE_GROWING)
        {
            float multiplier;
            [mScalePath GetValueScalar:&multiplier];
            
            yScale *= multiplier;
            quadParams.mScale.mVector[x] *= sqrt(multiplier);
        }
        
        quadParams.mScale.mVector[y] = yScale;
        
        [self DrawQuad:&quadParams];
    }
    
    [super DrawOrtho];
}

-(void)CreateLightRays
{
    float angleDelta = 360.0f / (float)NUM_LIGHT_RAYS;
    
    for (int i = 0; i < NUM_LIGHT_RAYS; i++)
    {
        LightRay* lightRay = [[LightRay alloc] Init];
        lightRay.Rotation = i * angleDelta;
        
        [mLightRays addObject:lightRay];
        [lightRay release];
        
        lightRay.Path = [[Path alloc] Init];
        
        if ((i % 2) == 0)
        {
            [lightRay.Path AddNodeScalar:LIGHT_RAY_LENGTH_MIN atTime:0];
            [lightRay.Path AddNodeScalar:LIGHT_RAY_LENGTH_MAX atTime:1];
            [lightRay.Path AddNodeScalar:LIGHT_RAY_LENGTH_MIN atTime:2];
        }
        else
        {
            [lightRay.Path AddNodeScalar:LIGHT_RAY_LENGTH_MAX atTime:0];
            [lightRay.Path AddNodeScalar:LIGHT_RAY_LENGTH_MIN atTime:1];
            [lightRay.Path AddNodeScalar:LIGHT_RAY_LENGTH_MAX atTime:2];
        }
        
        [lightRay.Path SetPeriodic:TRUE];
    }
}

-(u32)GetWidth
{
    return [mImage GetWidth];
}

-(u32)GetHeight
{
    return [mImage GetHeight];
}

-(void)Enable
{
    [super Enable];
    
    mCrystalItemState = CRYSTAL_ITEM_STATE_NORMAL;
    [mScalePath SetTime:0.0];
}

-(void)StatusChanged:(UIObjectState)inState
{
    [super StatusChanged:inState];
    
    switch(inState)
    {
        case UI_OBJECT_STATE_HIGHLIGHTED:
        {
            mCrystalItemState = CRYSTAL_ITEM_STATE_GROWING;
            [GetGlobalMessageChannel() SendEvent:EVENT_CRYSTAL_ITEM_TAPPED withData:NULL];
            
            break;
        }
    }
}

-(BOOL)HitTestWithPoint:(CGPoint*)inPoint
{
    BOOL buttonTouched = FALSE;
    
    if (mImage != NULL)
    {
        if  (   (inPoint->x >= 0) &&
                (inPoint->y >= 0) &&
                (inPoint->x < [mImage GetWidth]) &&
                (inPoint->y < [mImage GetHeight])   )
        {
            buttonTouched = TRUE;
        }
    }

    return buttonTouched;
}

@end