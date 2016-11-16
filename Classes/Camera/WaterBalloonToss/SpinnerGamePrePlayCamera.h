//
//  SpinnerGamePrePlayCamera.h
//
//  Created by Rishi Gupta on 5/13/14.
//  Copyright (c) 2014 Neon Games LLC. All rights reserved.
//

#import "CameraState.h"
#import "MessageChannel.h"

@class CameraUVN;
@class Path;

@interface SpinnerGamePrePlayCamera : CameraState<MessageChannelListener>
{
    CameraUVN*  mCamera;
}

-(void)Startup;
-(void)Resume;

-(void)Suspend;
-(void)Shutdown;

-(void)dealloc;

-(CameraUVN*)GetActiveCamera;

-(void)ProcessMessage:(Message*)inMsg;

@end
