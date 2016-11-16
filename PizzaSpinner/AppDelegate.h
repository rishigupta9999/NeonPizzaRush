//
//  AppDelegate.h
//  CarnivalHorseRacing
//
//  Created by Rishi Gupta on 4/26/14.
//  Copyright (c) 2014 Neon Games LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageChannel.h"

@interface NeonAssertionHandler : NSAssertionHandler
{
}

- (void)handleFailureInMethod:(SEL)selector object:(id)object file:(NSString *)fileName lineNumber:(NSInteger)line description:(NSString *)format,...;
- (void)handleFailureInFunction:(NSString *)functionName file:(NSString *)fileName lineNumber:(NSInteger)line description:(NSString *)format,...;

@end

@class EAGLViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate, MessageChannelListener>
{
    @public
        MessageChannel*     mGlobalMessageChannel;

    @protected
        NSTimer *mAnimationTimer;
        NSTimeInterval mAnimationInterval;

        CFAbsoluteTime mLastFrameTime;
        CFAbsoluteTime mTimeStep;
        
        BOOL    mUsingDisplayLink;
        id      mDisplayLink;
            
        u32     mFrameNumber;
        
        BOOL    mSuspended;
}

@property (strong, nonatomic) UIWindow* window;
@property (retain, nonatomic) EAGLView* glView;
@property (retain, nonatomic) EAGLViewController* glViewController;

@property u32 frameNumber;

-(void)Init;
-(void)Shutdown;
-(void)ProcessMessage:(Message*)inMsg;

@end
