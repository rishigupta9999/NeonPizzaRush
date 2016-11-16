//
//  NeonFlurryDelegate.h
//  PizzaSpinner
//
//  Created by Rishi Gupta on 7/30/14.
//  Copyright (c) 2014 Neon Games LLC. All rights reserved.
//


@interface NeonFlurryDelegate : NSObject
{
}

-(instancetype)Init;
-(void)CacheAd;

-(void)spaceDidReceiveAd:(NSString*)adSpace;
-(void)spaceDidFailToReceiveAd:(NSString*)adSpace error:(NSError*)error;


@end
