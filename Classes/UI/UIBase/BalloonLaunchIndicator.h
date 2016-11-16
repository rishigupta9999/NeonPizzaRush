//
//  BalloonLaunchIndicator.h
//  WaterBalloonToss
//
//  Created by Rishi Gupta on 5/31/14.
//  Copyright (c) 2014 Neon Games LLC. All rights reserved.
//

#import "UIObject.h"

@interface BalloonLaunchIndicatorParams : NSObject
{
    @public
        UIGroup*    mUIGroup;
}

-(instancetype)Init;

@end


@class ImageWell;

typedef enum
{
    BALLOON_LAUNCH_INDICATOR_IDLE,
    BALLOON_LAUNCH_INDICATOR_ACTIVE,
    BALLOON_LAUNCH_INDICATOR_COOLDOWN
} BalloonLaunchIndicatorState;

@interface BalloonLaunchIndicator : UIObject
{
    ImageWell*  mInitialCircle;
    ImageWell*  mCurrentCircle;
    
    BalloonLaunchIndicatorState mLaunchIndicatorState;
    
    Path*       mInitialPath;
    Vector3     mInitialPosition;
    Vector3     mCurrentPosition;
    
    Texture*    mLineTexture;
    
    Vector3     mEndPosition;
    Vector3     mVelocity;
    
    CFTimeInterval  mCurrentDecay;
}

-(instancetype)InitWithParams:(BalloonLaunchIndicatorParams*)inParams;
-(void)dealloc;

-(void)BeginLaunchAtX:(float)inX y:(float)inY;
-(void)UpdateCurrentPositionToX:(float)inX y:(float)inY;
-(void)EndLaunch;

-(void)Update:(CFTimeInterval)inTimeStep;
-(void)DrawOrtho;

@end
