//
//  WaterBalloonDuringPlayCamera.m
//  WaterBalloonToss
//
//  Created by Rishi Gupta on 5/13/14.
//  Copyright (c) 2014 Neon Games LLC. All rights reserved.
//

#import "SpinnerGamePrePlayCamera.h"
#import "CameraUVN.h"
#import "GameStateMgr.h"
#import "Path.h"
#import "CameraStateMgr.h"
#import "IncrementalGameState.h"
#import "CameraStateMachine.h"

@implementation SpinnerGamePrePlayCamera

-(void)Startup
{
    // Create a basic UVN camera
    mCamera = [(CameraUVN*)[CameraUVN alloc] Init];
    
    [[[GameStateMgr GetInstance] GetMessageChannel] AddListener:self];
    
    Set(&mCamera->mPosition, 0, 5.8, 7.6);
    Set(&mCamera->mLookAt, 0, 0.6, 0);
    mCamera->mFov = 29;
    
    GenerateTranslationMatrix(0.5, 0, 0, &mCamera->mPostProjectionMatrix);
}

-(void)Resume
{
}

-(void)Suspend
{
}

-(void)Shutdown
{
    [GetGlobalMessageChannel() RemoveListener:self];
}

-(void)dealloc
{
    [mCamera release];
    
    [super dealloc];
}

-(CameraUVN*)GetActiveCamera
{
    return mCamera;
}

-(void)ProcessMessage:(Message*)inMsg
{
}

-(void)Update:(CFAbsoluteTime)inTimeStep
{
    if (![mCamera GetDebugCameraAttached])
    {
    }
}

@end
