//
//  Run21Environment.h
//  Neon21
//
//  Copyright Neon Games 2011. All rights reserved.
//

#import "GameEnvironment.h"

@interface WaterBalloonEnvironmentParams : GameEnvironmentParams
{
}

-(instancetype)Init;

@end

@class Light;

@interface WaterBalloonEnvironment : GameEnvironment
{
    Light*  mUnderLight;
}

-(instancetype)InitWithParams:(GameEnvironmentParams*)inParams;

@end