//
//  ParticleSystem.m
//  PizzaSpinner
//
//  Created by Rishi Gupta on 6/21/14.
//  Copyright (c) 2014 Neon Games LLC. All rights reserved.
//

#import "ParticleSystem.h"
#import "ModelManager.h"

#undef max
#undef min
#include <SPK.h>
#include <SPK_GL.h>

static ParticleSystem* sInstance = NULL;

using namespace SPK;
using namespace SPK::GL;

@implementation ParticleSystem

-(instancetype)Init
{
    System::setClampStep(true,0.1f);			// clamp the step to 100 ms
	System::useAdaptiveStep(0.001f,0.01f);		// use an adaptive step from 1ms to 10ms (1000fps to 100fps)
    
    mParticleSystem = System::create();

    return self;
}

-(void)dealloc
{
    delete mParticleSystem;
    
    [super dealloc];
}

+(ParticleSystem*)GetInstance
{
    return sInstance;
}

+(void)CreateInstance
{
    NSAssert(sInstance == NULL, @"Expected NULL");
    sInstance = [[ParticleSystem alloc] Init];
}

+(void)DestroyInstance
{
    NSAssert(sInstance != NULL, @"Expected non-NULL");
    [sInstance release];
    sInstance = NULL;
}

-(void)Update:(CFTimeInterval)inTimeStep
{
    if (mParticleSystem != NULL)
    {
        mParticleSystem->update(inTimeStep);
    }
}

-(void)Draw
{
    if (mParticleSystem == NULL)
    {
        return;
    }
    
    GLState glState;
    SaveGLState(&glState);
    
    //glDisable(GL_DEPTH_TEST);
    
    [[ModelManager GetInstance] SetupWorldCamera];
    mParticleSystem->render();
    [[ModelManager GetInstance] TeardownWorldCamera];
    
    RestoreGLState(&glState);
}

-(void)AddGroup:(SPK::Group*)inGroup
{
    mParticleSystem->addGroup(inGroup);
}

@end
