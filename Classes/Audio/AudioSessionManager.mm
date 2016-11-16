//
//  AudioSessionManager.m
//  Neon21
//
//  Copyright Neon Games 2011. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "AudioSessionManager.h"
#import "NeonMusicPlayer.h"
#import "SoundPlayer.h"

static AudioSessionManager* sInstance = NULL;

@implementation AudioSessionManager

-(AudioSessionManager*)Init
{
    [self SetupAudioSession];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(interruptionHandler:)
                                                 name:AVAudioSessionInterruptionNotification
                                               object:[AVAudioSession sharedInstance]];

    return self;
}

-(void)dealloc
{
    [self DestroyAudioSession];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AVAudioSessionInterruptionNotification
                                                  object:[AVAudioSession sharedInstance]];

    [super dealloc];
}

+(void)CreateInstance
{
    NSAssert(sInstance == NULL, @"Attempting to double-create AudioSessionManager");
    sInstance = [(AudioSessionManager*)[AudioSessionManager alloc] Init];
}

+(void)DestroyInstance
{
    NSAssert(sInstance != NULL, @"Attempting to delete AudioSession when it is already destroyed");
    [sInstance release];
}

+(AudioSessionManager*)GetInstance
{
    return sInstance;
}

-(void)SetupAudioSession
{
    NSError* error = NULL;

    BOOL success = [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:&error];
    NSAssert(success, @"Couldn't setup AVAudioSession");
    
    success = [[AVAudioSession sharedInstance] setActive:YES error:&error];
    NSAssert(success, @"Couldn't setup AVAudioSession");
}

-(void)DestroyAudioSession
{
    NSError* error = NULL;
    
    BOOL success = [[AVAudioSession sharedInstance] setActive:NO error:&error];
    NSAssert(success, @"Couldn't deactivate AudioSession");
}

-(void)interruptionHandler:(NSNotification*)notification
{
    NSDictionary* userInfo = [notification userInfo];
    AVAudioSessionInterruptionType interruptionType = (AVAudioSessionInterruptionType)[[userInfo objectForKey:AVAudioSessionInterruptionTypeKey] intValue];
    
    switch(interruptionType)
    {
        case AVAudioSessionInterruptionTypeBegan:
        {
            [[NeonMusicPlayer GetInstance] HandleInterruption:TRUE];
            [[SoundPlayer GetInstance] HandleInterruption:TRUE];

            [self DestroyAudioSession];
            break;
        }
        
        case AVAudioSessionInterruptionTypeEnded:
        {
            [self SetupAudioSession];

            [[NeonMusicPlayer GetInstance] HandleInterruption:FALSE];
            [[SoundPlayer GetInstance] HandleInterruption:FALSE];

            break;
        }
    }
}

@end