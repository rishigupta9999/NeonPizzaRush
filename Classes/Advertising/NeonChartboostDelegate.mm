//
//  NeonChartboostDelegate.m
//  Neon21
//
//  Copyright (c) 2013 Neon Games.
//

#import "NeonChartboostDelegate.h"
#import "InAppPurchaseManager.h"
#import "AchievementManager.h"
#import "SaveSystem.h"
#import "GameStateMgr.h"
#import "CameraStateMgr.h"
#import "AdvertisingManager.h"

@implementation NeonChartboostDelegate

-(NeonChartboostDelegate*)Init
{
    [GetGlobalMessageChannel() AddListener:self];
    
    [Chartboost sharedChartboost].delegate = self;
    [self StartSession];
    
    return self;
}

-(void)StartSession
{
    Chartboost *cb  = [Chartboost sharedChartboost];
    
    cb.appId        = @"53d863c889b0bb3ad3c0239b";
    cb.appSignature = @"69bdd9cadd6ff41867a38aba563578331ee9d84a";
    
    cb.delegate     = self;
    [cb startSession];
    
    [cb cacheInterstitial];
    
    mAdClicked = FALSE;
}

- (BOOL)shouldRequestInterstitial:(NSString *)location
{
    AdLog(@"%@", location);
    return TRUE;
}

- (BOOL)shouldRequestInterstitialsInFirstSession:(NSString *)location
{
    AdLog(@"%@", location);
    return FALSE;
}

// Called when an interstitial has been received, before it is presented on screen
// Return NO if showing an interstitial is currently innapropriate, for example if the user has entered the main game mode.
- (BOOL)shouldDisplayInterstitial:(NSString *)location
{
    return TRUE;
}

// Called when an interstitial has been received and cached.
- (void)didCacheInterstitial:(NSString *)location
{
    [[AdvertisingManager GetInstance] ReceivedAd];
    AdLog(@"%@", location);
}

// Called when an interstitial has failed to come back from the server
- (void)didFailToLoadInterstitial:(NSString *)location
{
    AdLog(@"%@", location);
}

// Called when the user dismisses the interstitial
// If you are displaying the add yourself, dismiss it now.
- (void)didDismissInterstitial:(NSString *)location
{
}

// Same as above, but only called when dismissed for a close
- (void)didCloseInterstitial:(NSString *)location
{
    [[AdvertisingManager GetInstance] AdDismissed];
    AdLog(@"%@", location);
}

// Same as above, but only called when dismissed for a click
- (void)didClickInterstitial:(NSString *)location
{
    [[NeonMetrics GetInstance] logEvent:@"Clicked On Ad" withParameters:NULL];
    
    mAdClicked = TRUE;
}

-(void)SetAdClicked:(BOOL)inClicked
{
    mAdClicked = inClicked;
}

-(BOOL)GetAdClicked
{
    return mAdClicked;
}

-(void)ProcessMessage:(Message*)inMsg
{
    switch (inMsg->mId)
    {
        case EVENT_APPLICATION_RESUMED:
        {
            [self StartSession];
            break;
        }
    }
}

-(void)CacheAd
{
    [[Chartboost sharedChartboost] cacheInterstitial];
}

@end