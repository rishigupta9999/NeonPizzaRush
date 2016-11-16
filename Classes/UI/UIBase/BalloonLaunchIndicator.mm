//
//  BalloonLaunchIndicator.m
//  WaterBalloonToss
//
//  Created by Rishi Gupta on 5/31/14.
//  Copyright (c) 2014 Neon Games LLC. All rights reserved.
//

#import "BalloonLaunchIndicator.h"
#import "ImageWell.h"
#import "GameObjectBatch.h"
#import "TextureManager.h"

static const NSString* sCircleTextureFilename = @"launchindicator_circle.papng";
static const NSString* sLineTexture = @"Comet.papng";

static const float sRedColor[4] = { 1.0, 0.0, 0.0, 1.0 };
static const float sYellowColor[4] = { 1.0, 1.0, 0.0, 1.0 };

static const float sLineThickness = 5.0;

static const float sInitialCircleAlpha = 0.5;
static const float sCurrentCircleAlpha = 0.65;

static const float sSpringConstant = 10;
static const float sIndicatorMass = 5.0;

static const float sDecayTime = 1.0;

@implementation BalloonLaunchIndicatorParams

-(instancetype)Init
{
    mUIGroup = NULL;
    return self;
}

@end


@implementation BalloonLaunchIndicator

-(instancetype)InitWithParams:(BalloonLaunchIndicatorParams*)inParams
{
    [super InitWithUIGroup:inParams->mUIGroup];
    
    mOrtho = TRUE;
    
    ImageWellParams imageWellParams;
    [ImageWell InitDefaultParams:&imageWellParams];
    
    imageWellParams.mTextureName = [NSString stringWithString:(NSString*)sCircleTextureFilename];
    imageWellParams.mUIGroup = inParams->mUIGroup;
    
    mInitialCircle = [[ImageWell alloc] InitWithParams:&imageWellParams];
    mInitialCircle.Parent = self;
    [mInitialCircle release];
    
    mCurrentCircle = [[ImageWell alloc] InitWithParams:&imageWellParams];
    mCurrentCircle.Parent = self;
    [mCurrentCircle release];
    
    [mInitialCircle SetVisible:FALSE];
    [mCurrentCircle SetVisible:FALSE];
    
    mInitialCircle->mColorMultiplyEnabled = TRUE;
    SetColorFloat(&mInitialCircle->mColorMultiply, 1.0, 0.0, 0.0, sInitialCircleAlpha);
    
    mCurrentCircle->mColorMultiplyEnabled = TRUE;
    SetColorFloat(&mCurrentCircle->mColorMultiply, 1.0, 1.0, 0.0, sCurrentCircleAlpha);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
        {
            while(([[mInitialCircle GetTexture] GetStatus] != TEXTURE_STATUS_DECODING_COMPLETE) || ([[mCurrentCircle GetTexture] GetStatus] != TEXTURE_STATUS_DECODING_COMPLETE))
            {
                [NSThread sleepForTimeInterval:0.001f];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^
                {
                    PlacementValue placementValue;
                    SetRelativePlacement(&placementValue, PLACEMENT_ALIGN_RIGHT, PLACEMENT_ALIGN_CENTER);
                    
                    [mInitialCircle SetPlacement:&placementValue];
                    [mCurrentCircle SetPlacement:&placementValue];
                } );
        } );
    
    mLaunchIndicatorState = BALLOON_LAUNCH_INDICATOR_IDLE;
    
    mInitialPath = [[Path alloc] Init];
    
    [mInitialPath AddNodeX:0.0 y:0.0 z:1.0 atTime:0.0];
    [mInitialPath AddNodeX:0.5 y:0.5 z:1.0 atTime:0.5];
    
    UIObjectTextureLoadParams textureLoadParams;
    [UIObject InitDefaultTextureLoadParams:&textureLoadParams];
    
    textureLoadParams.mTexDataLifetime = TEX_DATA_DISPOSE;
    textureLoadParams.mTextureName = [NSString stringWithString:(NSString*)sLineTexture];
    
    mLineTexture = [self LoadTextureWithParams:&textureLoadParams];
    [mLineTexture retain];
    
    [[self GetGameObjectBatch] moveObjectToBack:self];
    
    return self;
}

-(void)dealloc
{
    [mInitialPath release];
    [mLineTexture release];
    
    [super dealloc];
}

-(void)BeginLaunchAtX:(float)inX y:(float)inY
{
    NSAssert(mLaunchIndicatorState == BALLOON_LAUNCH_INDICATOR_IDLE, @"Expected launch indicator to be idle");
    
    [mInitialCircle Enable];
    [mCurrentCircle Enable];
    
    [mInitialCircle SetPositionX:inX Y:inY Z:0.0];
    [mCurrentCircle SetPositionX:inX Y:inY Z:0.0];
    
    [mInitialPath SetTime:0.0];
    [mInitialCircle AnimateProperty:GAMEOBJECT_PROPERTY_SCALE withPath:mInitialPath];
    
    mLaunchIndicatorState = BALLOON_LAUNCH_INDICATOR_ACTIVE;
    
    Set(&mInitialPosition, inX, inY, 0);
    Set(&mCurrentPosition, inX, inY, 0);
}

-(void)UpdateCurrentPositionToX:(float)inX y:(float)inY
{
    NSAssert(mLaunchIndicatorState == BALLOON_LAUNCH_INDICATOR_ACTIVE, @"Expected launch indicator to be active");
    
    [mCurrentCircle SetPositionX:inX Y:inY Z:0.0];
    
    float xDistance = fabsf(inX - mInitialPosition.mVector[x]);
    float yDistance = fabsf(inY - mInitialPosition.mVector[y]);
    float distance = sqrt(xDistance * xDistance + yDistance * yDistance);
    float scale = distance / 256.0;
    
    float clampedScale = ClampFloat(scale, 0, 0.75);
 
    [mCurrentCircle SetScaleX:scale Y:scale Z:1.0];
    
    float desiredColorScale = ClampFloat(scale, 0, 1.0);
    
    SetColorFloat(  &mCurrentCircle->mColorMultiply,
                    LerpFloat(sRedColor[0], sYellowColor[0], desiredColorScale),
                    LerpFloat(sRedColor[1], sYellowColor[1], desiredColorScale),
                    LerpFloat(sRedColor[2], sYellowColor[2], desiredColorScale),
                    sCurrentCircleAlpha );
    
    Set(&mCurrentPosition, inX, inY, 0);
}

-(void)Update:(CFTimeInterval)inTimeStep
{
    [super Update:inTimeStep];
    
    if (mLaunchIndicatorState == BALLOON_LAUNCH_INDICATOR_COOLDOWN)
    {
        Vector3 directionVector;
        Sub3(&mEndPosition, &mInitialPosition, &directionVector);
        Normalize3(&directionVector);
        
        Vector3 curForce;
        
        // Add gravity
        Set(&curForce, 0, sIndicatorMass * 10, 0);
        
        // Add spring force
        Vector3 springForce;
        CloneVec3(&directionVector, &springForce);
        
        float distance = Distance3(&mEndPosition, &mInitialPosition);
        Scale3(&springForce, -distance * sSpringConstant);
        
        Add3(&curForce, &springForce, &curForce);
        
        // Add damping force
        Vector3 negativeVelocity;
        CloneVec3(&mVelocity, &negativeVelocity);
        Scale3(&negativeVelocity, -0.5);
        Add3(&curForce, &negativeVelocity, &curForce);
        
        // Divide out mass
        Scale3(&curForce, sIndicatorMass);
        
        mVelocity.mVector[x] += curForce.mVector[x] * inTimeStep;
        mVelocity.mVector[y] += curForce.mVector[y] * inTimeStep;
        
        mEndPosition.mVector[x] += mVelocity.mVector[x] * inTimeStep;
        mEndPosition.mVector[y] += mVelocity.mVector[y] * inTimeStep;
        
        [mCurrentCircle SetPosition:&mEndPosition];
        
        mCurrentDecay += inTimeStep;
        
        if (mCurrentDecay > sDecayTime)
        {
            mLaunchIndicatorState = BALLOON_LAUNCH_INDICATOR_IDLE;
            
            [mInitialCircle Disable];
            [mCurrentCircle Disable];
        }
    }
}

-(void)DrawOrtho
{
    if ((mLaunchIndicatorState == BALLOON_LAUNCH_INDICATOR_ACTIVE) || (mLaunchIndicatorState == BALLOON_LAUNCH_INDICATOR_COOLDOWN))
    {
        GameObjectBatch* gameObjectBatch = [self GetGameObjectBatch];
        MeshBuilder* meshBuilder = [gameObjectBatch GetMeshBuilder];
        
        NSAssert(meshBuilder != NULL, @"We haven't implemented this function without the use of a mesh builder");
        
        Vector3 diff;
        Sub3(&mInitialPosition, &mCurrentPosition, &diff);
        Normalize3(&diff);
        
        float temp = diff.mVector[x];
        diff.mVector[x] = diff.mVector[y];
        diff.mVector[y] = -temp;
        
        Scale3(&diff, sLineThickness);
        
        Vector3 pointI1, pointI2, pointC1, pointC2;
        Vector3 negDiff;
        
        CloneVec3(&diff, &negDiff);
        Scale3(&negDiff, -1);
        
        Vector3 initialPosition;
        Vector3 currentPosition;
        
        CloneVec3(&mInitialPosition, &initialPosition);
        
        if (mLaunchIndicatorState == BALLOON_LAUNCH_INDICATOR_ACTIVE)
        {
            CloneVec3(&mCurrentPosition, &currentPosition);
        }
        else
        {
            CloneVec3(&mEndPosition, &currentPosition);
        }
        
        float initialWidth = [mInitialCircle GetWidth] / 2.0;
        float currentWidth = [mCurrentCircle GetWidth] / 2.0;
        
        Vector3 initialScale;
        [mInitialCircle GetScale:&initialScale];
        
        initialScale.mVector[x] *= initialWidth;
        initialScale.mVector[y]  = 0;
        initialScale.mVector[z]  = 0;
        
        Vector3 currentScale;
        [mCurrentCircle GetScale:&currentScale];
        
        currentScale.mVector[x] *= currentWidth;
        currentScale.mVector[y]  = 0;
        currentScale.mVector[z]  = 0;
        
        Sub3(&initialPosition, &initialScale, &initialPosition);
        Sub3(&currentPosition, &currentScale, &currentPosition);
        
        Add3(&initialPosition, &diff, &pointI1);
        Add3(&initialPosition, &negDiff, &pointI2);
        
        Add3(&currentPosition, &diff, &pointC1);
        Add3(&currentPosition, &negDiff, &pointC2);
        
        pointI1.mVector[z] = -0.1;
        pointI2.mVector[z] = -0.1;
        pointC1.mVector[z] = -0.1;
        pointC2.mVector[z] = -0.1;
        
        QuadParams quadParams;
        [UIObject InitQuadParams:&quadParams];
        
        memcpy(&quadParams.mPositionCoords[0], &pointI1.mVector[0], sizeof(float) * 3);
        memcpy(&quadParams.mPositionCoords[3], &pointI2.mVector[0], sizeof(float) * 3);
        memcpy(&quadParams.mPositionCoords[6], &pointC1.mVector[0], sizeof(float) * 3);
        memcpy(&quadParams.mPositionCoords[9], &pointC2.mVector[0], sizeof(float) * 3);
        
        memcpy(&quadParams.mColor[0], &mInitialCircle->mColorMultiply, sizeof(Color));
        memcpy(&quadParams.mColor[1], &mInitialCircle->mColorMultiply, sizeof(Color));
        memcpy(&quadParams.mColor[2], &mCurrentCircle->mColorMultiply, sizeof(Color));
        memcpy(&quadParams.mColor[3], &mCurrentCircle->mColorMultiply, sizeof(Color));
        
        quadParams.mColorMultiplyEnabled = TRUE;
        quadParams.mPositionCoordsEnabled = TRUE;
        quadParams.mTexture = mLineTexture;
        
        quadParams.mScaleType = QUAD_PARAMS_SCALE_BOTH;
        quadParams.mScale.mVector[0] = 1.0;
        quadParams.mScale.mVector[1] = 1.0;
        
        [self DrawQuad:&quadParams];
    }
}

-(void)EndLaunch
{
    mLaunchIndicatorState = BALLOON_LAUNCH_INDICATOR_COOLDOWN;
    
    CloneVec3(&mCurrentPosition, &mEndPosition);
    Set(&mVelocity, 0, 0, 0);
    
    mCurrentDecay = 0;
}

@end
