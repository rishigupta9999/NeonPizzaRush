//
//  AdvertisingManager.h
//  Neon21
//
//  Copyright Neon Games 2012. All rights reserved.
//
#import "TextureManager.h"

@class NeonChartboostDelegate;
@class NeonFlurryDelegate;

#define ADVERTISING_MANAGER_TOP_BANNER_OFFSET   (50)

typedef enum
{
    AD_MANAGER_CACHE_WAITING,
    AD_MANAGER_CACHE_READY
} AdvertisingManagerCacheState;

typedef enum
{
    AD_MANAGER_DISPLAY_IDLE,
    AD_MANAGER_DISPLAY_PENDING
} AdvertisingManagerDisplayState;

@interface AdvertisingManager : NSObject<MessageChannelListener>
{
    CFAbsoluteTime  mLastAdTime;
    CFTimeInterval  mNextAdTime;
    
    AdvertisingManagerCacheState    mCacheState;
    AdvertisingManagerDisplayState  mDisplayState;
    
    NeonChartboostDelegate*  mChartboostDelegate;
    NeonFlurryDelegate*      mFlurryDelegate;
    
    BOOL                     mAdVisible;
}

@property BOOL AdsEnabled;

+(void)CreateInstance;
+(void)DestroyInstance;
+(AdvertisingManager*)GetInstance;
-(AdvertisingManager*)init;
-(void)dealloc;
-(void)Update:(CFTimeInterval)inTimeInterval;
-(void)ProcessMessage:(Message*)inMsg;

-(BOOL)ShouldShowAds;
-(void)ShowAd;
-(BOOL)ShouldShowBannerAds;

-(void)ReceivedAd;
-(void)AdDismissed;

@end