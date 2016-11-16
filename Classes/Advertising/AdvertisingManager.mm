//
//  AdvertisingManager.m
//  Neon21
//
//  (c) Neon Games LLC, 2012
//

#import "AdvertisingManager.h"
#import "InAppPurchaseManager.h"
#import "SplitTestingSystem.h"
#import "AppDelegate.h"
#import "GameStateMgr.h"
#import "CameraStateMgr.h"
#import "Event.h"
#import "Chartboost.h"
#import "LevelDefinitions.h"
#import "SaveSystem.h"
#import "AppDelegate.h"
#import "NeonChartboostDelegate.h"
#import "NeonFlurryDelegate.h"

#define GAME_ORIENTATION UIInterfaceOrientationLandscapeRight

static AdvertisingManager* sInstance = NULL;
static const int AD_TIME_BASE = 60;
static const int AD_TIME_VARIANCE = 30;

@implementation AdvertisingManager

@synthesize AdsEnabled = mAdsEnabled;

+(void)CreateInstance
{
    NSAssert(sInstance == NULL, @"Attempting to double-create AdvertisingManager");
    sInstance = [[AdvertisingManager alloc] init];
}

+(void)DestroyInstance
{
    NSAssert(sInstance != NULL, @"Attempting to delete AdvertisingManager when one doesn't exist");
    [sInstance release];
}

+(AdvertisingManager*)GetInstance
{
    return sInstance;
}

-(AdvertisingManager*)init
{
    [[[GameStateMgr GetInstance] GetMessageChannel] AddListener:self];
    [GetGlobalMessageChannel() AddListener:self];
    
    mChartboostDelegate = FALSE;
    mFlurryDelegate = FALSE;
    
    mCacheState = AD_MANAGER_CACHE_WAITING;
    mDisplayState = AD_MANAGER_DISPLAY_IDLE;
    
    mLastAdTime = CACurrentMediaTime();
    mNextAdTime = mLastAdTime + 0.5;
    mAdsEnabled = TRUE;
    mAdVisible = FALSE;

    return self;
}

-(void)dealloc
{
    [mChartboostDelegate release];
    [mFlurryDelegate release];
    
    [super dealloc];
}

-(void)Update:(CFTimeInterval)inTimeStep
{
    if (mAdVisible)
    {
        return;
    }
    
    if (mDisplayState != AD_MANAGER_DISPLAY_PENDING)
    {
        CFAbsoluteTime curTime = CACurrentMediaTime();
        BOOL showAd = FALSE;
        
        if (curTime >= mNextAdTime)
        {
            showAd = TRUE;
        }
        
        if (showAd)
        {
            [self ShowAd];
        }
    }
    
    if (mDisplayState == AD_MANAGER_DISPLAY_PENDING)
    {
        if (mCacheState == AD_MANAGER_CACHE_READY)
        {
            mDisplayState = AD_MANAGER_DISPLAY_IDLE;
            mCacheState = AD_MANAGER_CACHE_WAITING;
            
            mAdVisible = TRUE;
        }
    }
}

-(void)ProcessMessage:(Message*)inMsg
{
    switch(inMsg->mId)
    {
        case EVENT_STATE_STARTED:
        {
            GameState* activeState = (GameState*)[[GameStateMgr GetInstance] GetActiveState];
            [[activeState GetMessageChannel] AddListener:self];
            
            break;
        }

        case EVENT_IAP_DELIVER_CONTENT:
        {
            
            break;
        }
    }
}

-(BOOL)ShouldShowAds
{
    // No ads until retention tests completed
    return FALSE;
    
//    return !([[SaveSystem GetInstance] GetBooster] || ([[SaveSystem GetInstance] GetNumLaunches] == 1));
}

-(void)ShowAd
{
}

-(BOOL)ShouldShowBannerAds
{
    // No ads until retention tests completed
    return FALSE;
//    return ((![[SaveSystem GetInstance] GetBooster]) && [[SplitTestingSystem GetInstance] GetSplitTestValue:SPLIT_TEST_BANNER_ADS]);
}

-(void)ReceivedAd
{
    mCacheState = AD_MANAGER_CACHE_READY;
}

-(void)AdDismissed
{
    CFAbsoluteTime curTime = CACurrentMediaTime();

    mLastAdTime = curTime;
    mNextAdTime = curTime + arc4random_uniform(AD_TIME_VARIANCE) + AD_TIME_BASE;
    
    mAdVisible = FALSE;
}

@end