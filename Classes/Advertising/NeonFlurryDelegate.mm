//
//  NeonFlurryDelegate.m
//  PizzaSpinner
//
//  Created by Rishi Gupta on 7/30/14.
//  Copyright (c) 2014 Neon Games LLC. All rights reserved.
//

#import "NeonFlurryDelegate.h"
#import "NeonUtilities.h"
#import "AppDelegate.h"
#import "AdvertisingManager.h"
#import "SplitTestingSystem.h"

@implementation NeonFlurryDelegate

-(instancetype)Init
{
    return self;
}

-(void)CacheAd
{
}

-(void)spaceDidReceiveAd:(NSString*)adSpace
{
   // if (![[SplitTestingSystem GetInstance] GetSplitTestValue:SPLIT_TEST_BANNER_ADS])
    {
        [[AdvertisingManager GetInstance] ReceivedAd];
    }
}

-(void)spaceDidFailToRender:(NSString *)space error:(NSError *)error
{
}

-(void)spaceDidFailToReceiveAd:(NSString*)adSpace error:(NSError*)error
{
}

-(void)spaceDidDismiss:(NSString*)adSpace interstitial:(BOOL)interstitial
{
    [[AdvertisingManager GetInstance] AdDismissed];
}

@end
