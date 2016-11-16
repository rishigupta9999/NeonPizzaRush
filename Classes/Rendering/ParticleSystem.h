//
//  ParticleSystem.h
//  PizzaSpinner
//
//  Created by Rishi Gupta on 6/21/14.
//  Copyright (c) 2014 Neon Games LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

namespace SPK
{
    class System;
    class Group;
};

@interface ParticleSystem : NSObject
{
    SPK::System*    mParticleSystem;
}

-(instancetype)Init;
-(void)dealloc;

+(ParticleSystem*)GetInstance;
+(void)CreateInstance;
+(void)DestroyInstance;

-(void)Update:(CFTimeInterval)inTimeStep;
-(void)Draw;

-(void)AddGroup:(SPK::Group*)inGroup;

@end
