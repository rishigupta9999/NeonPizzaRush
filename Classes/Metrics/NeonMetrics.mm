//
//  NeonMetrics.m
//
//  Copyright Neon Games 2013. All rights reserved.
//

#import "NeonMetrics.h"
#import "KISSMetricsAPI.h"
#import "SplitTestingSystem.h"
#import "LocalyticsSession.h"
#import "Event.h"
#import <FacebookSDK/FacebookSDK.h>
#import "Mixpanel.h"

static NeonMetrics* sInstance = NULL;
static const NSString* sLocalyticsKey = @"4f40e1daaf0a838a2ec61bd-9b5ef0ec-1815-11e4-a1d7-009c5fda0a25";

@implementation NeonMetrics

-(NeonMetrics*)Init
{    
    mVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    [mVersion retain];
    
#if NEON_DEBUG
    //[Flurry setAppVersion:[NSString stringWithFormat:@"Prerelease-%@", mVersion]];
#else
    //[Flurry setAppVersion:mVersion];
#endif
    
#if !NEON_DEBUG
    //[Flurry startSession:@"WH2PKT8FWH8CBWKCFR5W"];
    
    [KISSMetricsAPI sharedAPIWithKey:@"6bff30626a43ab73f74ff38cbd821d256172b58f"];
    
    [[LocalyticsSession shared] LocalyticsSession:(NSString*)sLocalyticsKey];
    [[LocalyticsSession shared] resume];
    
    [FBSettings setDefaultAppID:@"284862355042874"];
    [FBAppEvents activateApp];
    
    [Mixpanel sharedInstanceWithToken:@"8219a0b081606236ed4d94aa345cec09"];
#endif
    
    
    mLocalyticsState = LOCALYTICS_SESSION_OPEN;
    
    [GetGlobalMessageChannel() AddListener:self];

    return self;
}

-(void)dealloc
{
    [mVersion release];
    
    [GetGlobalMessageChannel() RemoveListener:self];
    
    [super dealloc];
}

+(void)CreateInstance
{
    NSAssert(sInstance == NULL, @"NeonMetrics has already been created");
    
    sInstance = [(NeonMetrics*)[NeonMetrics alloc] Init];
}

+(void)DestroyInstance
{
    NSAssert(sInstance != NULL, @"NeonMetrics has already been destroyed");
    
    [sInstance release];
    sInstance = NULL;
}

+(NeonMetrics*)GetInstance
{
    return sInstance;
}

-(NSString*)GetVersion
{
    return mVersion;
}

-(void)ProcessMessage:(Message*)inMsg
{
    switch(inMsg->mId)
    {
        case EVENT_APPLICATION_RESUMED:
        {
            [[LocalyticsSession shared] resume];
            [[LocalyticsSession shared] upload];
            
            mLocalyticsState = LOCALYTICS_SESSION_OPEN;

            break;
        }
        
        case EVENT_APPLICATION_WILL_TERMINATE:
        case EVENT_APPLICATION_SUSPENDED:
        case EVENT_APPLICATION_ENTERED_BACKGROUND:
        {
            if (mLocalyticsState != LOCALYTICS_SESSION_CLOSED)
            {
                [[LocalyticsSession shared] close];
                [[LocalyticsSession shared] upload];
                
                mLocalyticsState = LOCALYTICS_SESSION_CLOSED;
            }

            break;
        }
    }
}

-(void)logEvent:(NSString*)inEvent withParameters:(NSDictionary*)inParameters
{
#if NEON_DEBUG
    return;
#endif

    NSMutableDictionary* newDictionary = [[NSMutableDictionary alloc] initWithDictionary:inParameters];
    
#if !SPLIT_TEST_FORCE_BUCKETS
    for (int i = 0; i < SPLIT_TEST_NUM; i++)
    {
        [newDictionary setObject:[NSNumber numberWithBool:[[SplitTestingSystem GetInstance] GetSplitTestValue:(SplitTest)i]] forKey:[[SplitTestingSystem GetInstance] GetSplitTestString:(SplitTest)i]];
    }
#endif
    
    //[Flurry logEvent:inEvent withParameters:newDictionary];
    [[KISSMetricsAPI sharedAPI] recordEvent:inEvent withProperties:newDictionary];
    [[LocalyticsSession shared] tagEvent:inEvent attributes:newDictionary];
    [[Mixpanel sharedInstance] track:inEvent properties:newDictionary];
    
    [newDictionary release];
}

-(void)logEvent:(NSString*)inEvent withParameters:(NSDictionary*)inParameters type:(NeonMetricType)inType
{
#if NEON_DEBUG
    return;
#endif

    NSMutableDictionary* newDictionary = [[NSMutableDictionary alloc] initWithDictionary:inParameters];

#if !SPLIT_TEST_FORCE_BUCKETS
    for (int i = 0; i < SPLIT_TEST_NUM; i++)
    {
        [newDictionary setObject:[NSNumber numberWithBool:[[SplitTestingSystem GetInstance] GetSplitTestValue:(SplitTest)i]] forKey:[[SplitTestingSystem GetInstance] GetSplitTestString:(SplitTest)i]];
    }
#endif

    switch(inType)
    {
        case NEON_METRIC_TYPE_KISS:
        {
            [[KISSMetricsAPI sharedAPI] recordEvent:inEvent withProperties:newDictionary];
            [[LocalyticsSession shared] tagEvent:inEvent attributes:newDictionary];
            break;
        }
        
        case NEON_METRIC_TYPE_FLURRY:
        {
            //[Flurry logEvent:inEvent withParameters:newDictionary];
            break;
        }
        
        default:
        {
            NSAssert(FALSE, @"Unknown metric type");
        }
    }
    
    [newDictionary release];
}

-(void)logEvent:(NSString*)inEvent withParameters:(NSDictionary*)inParameters timed:(BOOL)inTimed
{
#if NEON_DEBUG
    return;
#endif

    NSMutableDictionary* newDictionary = [[NSMutableDictionary alloc] initWithDictionary:inParameters];
    
    for (int i = 0; i < SPLIT_TEST_NUM; i++)
    {
        [newDictionary setObject:[NSNumber numberWithBool:[[SplitTestingSystem GetInstance] GetSplitTestValue:(SplitTest)i]] forKey:[[SplitTestingSystem GetInstance] GetSplitTestString:(SplitTest)i]];
    }

    //[Flurry logEvent:inEvent withParameters:newDictionary timed:inTimed];
    [[KISSMetricsAPI sharedAPI] recordEvent:[NSString stringWithFormat:@"%@_start", inEvent] withProperties:newDictionary];
    [[LocalyticsSession shared] tagEvent:[NSString stringWithFormat:@"%@_start", inEvent] attributes:newDictionary];
    
    [newDictionary release];
}

-(void)endTimedEvent:(NSString*)inEvent withParameters:(NSDictionary*)inParameters
{
#if NEON_DEBUG
    return;
#endif

    NSMutableDictionary* newDictionary = [[NSMutableDictionary alloc] initWithDictionary:inParameters];
    
    for (int i = 0; i < SPLIT_TEST_NUM; i++)
    {
        [newDictionary setObject:[NSNumber numberWithBool:[[SplitTestingSystem GetInstance] GetSplitTestValue:(SplitTest)i]] forKey:[[SplitTestingSystem GetInstance] GetSplitTestString:(SplitTest)i]];
    }

    //[Flurry endTimedEvent:inEvent withParameters:newDictionary];
    [[KISSMetricsAPI sharedAPI] recordEvent:[NSString stringWithFormat:@"%@_end", inEvent] withProperties:newDictionary];
    [[LocalyticsSession shared] tagEvent:[NSString stringWithFormat:@"%@_end", inEvent] attributes:newDictionary];
    
    [newDictionary release];
}

@end