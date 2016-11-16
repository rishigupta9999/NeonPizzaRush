//
//  EllipseMeshBuilder.h
//  WaterBalloonToss
//
//  Created by Rishi Gupta on 5/15/14.
//  Copyright (c) 2014 Neon Games LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SimpleModel;

@interface EllipseMeshBuilder : NSObject
{
}

-(instancetype)Init;
-(SimpleModel*)Create:(int)recursionLevel withScale:(Vector3*)inScale;

@end
