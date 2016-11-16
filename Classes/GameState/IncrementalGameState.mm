//
//  WaterBalloonTossState.m
//  WaterBalloonToss
//
//  Created by Rishi Gupta on 5/10/14.
//  Copyright (c) 2014 Neon Games LLC. All rights reserved.
//

#import "IncrementalGameState.h"
#import "IncrementalGameUI.h"
#import "WaterBalloonEnvironment.h"
#import "Fader.h"
#import "CameraStateMgr.h"
#import "SpinnerGamePrePlayCamera.h"
#import "PizzaEntity.h"
#import "AppDelegate.h"
#import "EAGLView.h"
#import "MessageChannel.h"
#import "BrickEntity.h"
#import "CounterTopEntity.h"
#import "PaintBrush.h"
#import "ParticleSystem.h"
#import "FoodManager.h"
#import "PizzaOvenEntity.h"
#import "NeonMetrics.h"
#import "AdvertisingManager.h"

// Particle system stuff
#undef min
#undef max
#include <SPK.h>
#include <SPK_GL.h>

#include <iostream>

static const int NUM_REQUIRED_PIZZA_QUADS = 16;

using namespace SPK;
using namespace SPK::GL;

Group* particleGroup = NULL;

IncrementalGameState* GetIncrementalGameState()
{
    return (IncrementalGameState*)[[GameStateMgr GetInstance] GetActiveState];
}

#define GetStateMachine()  ((IncrementalGameStateMachine*)mStateMachine)

// PizzaSpinnerStateMachine
@interface IncrementalGameStateMachine : StateMachine
{
    int mQueuedPizzas;
}

-(instancetype)Init;
-(void)dealloc;

-(void)ProcessEvent:(EventId)inEventId withData:(void*)inData;

@end

// PizzaPaintState
@interface PizzaPaintState : State

-(void)Startup;
-(void)Shutdown;
-(void)Update:(CFTimeInterval)inTimeStep;

@end

// PizzaCompleteState
@interface PizzaCompleteState : State

-(void)Startup;
-(void)Shutdown;

@end

@implementation IncrementalGameStateMachine

-(instancetype)Init
{
    [super Init];
    
    return self;
}

-(void)dealloc
{
    [super dealloc];
}

-(void)ProcessEvent:(EventId)inEventId withData:(void*)inData
{
}

@end

// PizzaPaintState
@implementation PizzaPaintState

-(void)Startup
{
    PizzaEntity* pizza = GetIncrementalGameState()->mPizzaEntities[GetIncrementalGameState()->mCurPizzaIndex];
    int nextPizza = (GetIncrementalGameState()->mCurPizzaIndex + 1) % PIZZA_ENTITY_POOL_SIZE;
    GetIncrementalGameState()->mCurPizzaIndex = nextPizza;
    
    [pizza SetVisible:TRUE];
    [pizza SetScaleX:0.05 Y:0.1 Z:0.05];
    [pizza SetPositionX:0 Y:0.2 Z:6];
    
    Path* animatePath = [[Path alloc] Init];
    [animatePath AddNodeX:0 y:0.2 z:5 atTime:0];
    [animatePath AddNodeX:0 y:0.2 z:1 atTime:0.4];
    
    [pizza AnimateProperty:GAMEOBJECT_PROPERTY_POSITION withPath:animatePath];
    [animatePath release];
    
    GetIncrementalGameState().PizzaEntity = pizza;
}

-(void)Shutdown
{
}

-(void)Update:(CFTimeInterval)inTimeStep
{
    [super Update:inTimeStep];
    
    if ([GetIncrementalGameState().PizzaEntity.PaintBrush GetTotalArea] > 930000)
    {
        [mStateMachine ReplaceTop:[PizzaCompleteState alloc]];
    }
}

@end

// PizzaCompleteState
@implementation PizzaCompleteState

-(void)Startup
{
    [[[GameStateMgr GetInstance] GetMessageChannel] SendEvent:EVENT_INCREMENTAL_GAME_ITEM_CLICKED withData:NULL];
    
    Vector3 startPosition;
    PizzaEntity* pizzaEntity = GetIncrementalGameState().PizzaEntity;
    
    [pizzaEntity GetPosition:&startPosition];
    
    Path* animatePath = [[Path alloc] Init];
    [animatePath AddNodeVec3:&startPosition atTime:0.0];
    
    startPosition.mVector[z] -= 8.0;
    [animatePath AddNodeVec3:&startPosition atTime:0.4];
    
    [pizzaEntity AnimateProperty:GAMEOBJECT_PROPERTY_POSITION withPath:animatePath];
    [animatePath release];
    
    [pizzaEntity PerformAfterOperationsInQueue:dispatch_get_main_queue() block:^
        {
            [pizzaEntity Reset];
            [pizzaEntity SetVisible:FALSE];
        }];
    
    double numPizzas = [[FoodManager GetInstance] GetNumPizzasPerSpin];
    [[FoodManager GetInstance] AddPizza:numPizzas];
    [[FoodManager GetInstance] IncrementManualItems];
    
    [mStateMachine ReplaceTop:[PizzaPaintState alloc]];
}

-(void)Shutdown
{
}

@end

// PizzaSpinnerState
@implementation IncrementalGameState

@synthesize PizzaEntity = mPizzaEntity;
@synthesize CounterTopEntity = mCounterTopEntity;
@synthesize PizzaOvenEntity = mPizzaOvenEntity;

-(void)Startup
{
    [super Startup];
    
    if ([[AdvertisingManager GetInstance] ShouldShowBannerAds])
    {
        //[FlurryAds fetchAndDisplayAdForSpace:@"Pizza Rush Top Banner" view:(UIView*)GetAppDelegate().glView size:BANNER_TOP];
    }
    
    // Create environment
    WaterBalloonEnvironmentParams* environmentParams = [[WaterBalloonEnvironmentParams alloc] Init];
        
    mEnvironment = [[WaterBalloonEnvironment alloc] InitWithParams:environmentParams];
    [environmentParams release];
    
    // Create UI
    mIncrementalGameUI = [[IncrementalGameUI alloc] InitWithEnvironment:mEnvironment gameState:self];
    mFoodManager = [FoodManager GetInstance];
    
    // Create Pizzas
    for (int i = 0; i < PIZZA_ENTITY_POOL_SIZE; i++)
    {
        mPizzaEntities[i] = [[PizzaEntity alloc] Init];
        [mPizzaEntities[i] SetVisible:FALSE];
        
        [[GameObjectManager GetInstance] Add:mPizzaEntities[i]];
    }
    
    mCurPizzaIndex = 0;
    
    mCounterTopEntity = [[CounterTopEntity alloc] Init];
    [[GameObjectManager GetInstance] Add:mCounterTopEntity];
    [mCounterTopEntity SetScaleX:0.6 Y:1.0 Z:0.7];
    [mCounterTopEntity SetPositionX:0 Y:0 Z:1.0];
    
    mPizzaOvenEntity = [[PizzaOvenEntity alloc] Init];
    [[GameObjectManager GetInstance] Add:mPizzaOvenEntity];
    [mPizzaOvenEntity SetScaleX:0.12 Y:0.12 Z:0.12];
    [mPizzaOvenEntity SetPositionX:0 Y:0.6 Z:-2.75];
    
    [[CameraStateMgr GetInstance] Push:[SpinnerGamePrePlayCamera alloc]];
    
    mGameStateMachine = [[IncrementalGameStateMachine alloc] Init];
    [mGameStateMachine Push:[PizzaPaintState alloc]];
    
    // Setup tutorial
    [self SetStingerSpawner:NULL];
    [self SetTriggerEvaluator:self];
    
    [[[GameStateMgr GetInstance] GetMessageChannel] AddListener:self];
    
    // Particle system test
    float startX = 0, startY = 0.5;
    
    mFireTexture = [[TextureManager GetInstance] TextureWithName:@"fire_particles.png"];
    mSmokeTexture = [[TextureManager GetInstance] TextureWithName:@"explosion_particles.png"];
    
    [mFireTexture retain];
    [mSmokeTexture retain];

	GLQuadRenderer* fireRenderer = GLQuadRenderer::create();
	fireRenderer->setScale(0.2f,0.2f);
	fireRenderer->setTexturingMode(TEXTURE_2D);
	fireRenderer->setTexture(mFireTexture->mTexName);
	fireRenderer->setTextureBlending(GL_MODULATE);
	fireRenderer->setBlending(BLENDING_ADD);
	fireRenderer->enableRenderingHint(DEPTH_WRITE,false);
	fireRenderer->setAtlasDimensions(2,2);

	GLQuadRenderer* smokeRenderer = GLQuadRenderer::create();
	smokeRenderer->setScale(0.2f,0.2f);
	smokeRenderer->setTexturingMode(TEXTURE_2D);
	smokeRenderer->setTexture(mSmokeTexture->mTexName);
	smokeRenderer->setTextureBlending(GL_MODULATE);
	smokeRenderer->setBlending(BLENDING_ALPHA);
	smokeRenderer->enableRenderingHint(DEPTH_WRITE,false);
	smokeRenderer->setAtlasDimensions(2,2);

	// Models
	SPK::Model* fireModel = SPK::Model::create(FLAG_RED | FLAG_GREEN | FLAG_BLUE | FLAG_ALPHA | FLAG_SIZE | FLAG_ANGLE | FLAG_TEXTURE_INDEX,
		FLAG_RED | FLAG_GREEN | FLAG_ALPHA | FLAG_ANGLE,
		FLAG_RED | FLAG_GREEN | FLAG_TEXTURE_INDEX | FLAG_ANGLE,
		FLAG_SIZE);
	fireModel->setParam(PARAM_RED,0.8f,0.9f,0.8f,0.9f);
	fireModel->setParam(PARAM_GREEN,0.5f,0.6f,0.5f,0.6f);
	fireModel->setParam(PARAM_BLUE,0.3f);
	fireModel->setParam(PARAM_ALPHA,0.4f,0.0f);
	fireModel->setParam(PARAM_ANGLE,0.0f,2.0f * M_PI,0.0f,2.0f * M_PI);
	fireModel->setParam(PARAM_TEXTURE_INDEX,0.0f,4.0f);
	fireModel->setLifeTime(1.0f,1.5f);

	Interpolator* interpolator = fireModel->getInterpolator(PARAM_SIZE);
	interpolator->addEntry(0.5f,2.0f,5.0f);
	interpolator->addEntry(1.0f,0.0f);

	SPK::Model* smokeModel = SPK::Model::create(FLAG_RED | FLAG_GREEN | FLAG_BLUE | FLAG_ALPHA | FLAG_SIZE | FLAG_ANGLE | FLAG_TEXTURE_INDEX,
		FLAG_RED | FLAG_GREEN | FLAG_SIZE | FLAG_ANGLE,
		FLAG_TEXTURE_INDEX | FLAG_ANGLE,
		FLAG_ALPHA);
	smokeModel->setParam(PARAM_RED,0.3f,0.2f);
	smokeModel->setParam(PARAM_GREEN,0.25f,0.2f);
	smokeModel->setParam(PARAM_BLUE,0.2f);
	smokeModel->setParam(PARAM_ALPHA,0.2f,0.0f);
	smokeModel->setParam(PARAM_SIZE,5.0,10.0f);
	smokeModel->setParam(PARAM_TEXTURE_INDEX,0.0f,4.0f);
	smokeModel->setParam(PARAM_ANGLE,0.0f,2.0f * M_PI,0.0f,2.0f * M_PI);
	smokeModel->setLifeTime(5.0f,5.0f);

	interpolator = smokeModel->getInterpolator(PARAM_ALPHA);
	interpolator->addEntry(0.0f,0.0f);
	interpolator->addEntry(0.2f,0.2f);
	interpolator->addEntry(1.0f,0.0f);

	// Emitters
	// The emitters are arranged so that the fire looks realistic
	StraightEmitter* fireEmitter1 = StraightEmitter::create(Vector3D(0.0f,1.0f,0.0f));
	fireEmitter1->setZone(Sphere::create(Vector3D(0.0f,0.0f + startY,-2.0f),1.5f));
	fireEmitter1->setFlow(40);
	fireEmitter1->setForce(1.0f,2.5f);

	StraightEmitter* fireEmitter2 = StraightEmitter::create(Vector3D(1.0f,0.6f,0.0f));
	fireEmitter2->setZone(Sphere::create(Vector3D(0.15f,-0.2f + startY,-1.925),0.3f));
	fireEmitter2->setFlow(15);
	fireEmitter2->setForce(0.5f,1.5f);

	StraightEmitter* fireEmitter3 = StraightEmitter::create(Vector3D(-0.6f,0.8f,-0.8f));
	fireEmitter3->setZone(Sphere::create(Vector3D(-0.375f,-0.15f + startY,-2.375f),0.9f));
	fireEmitter3->setFlow(15);
	fireEmitter3->setForce(0.5f,1.5f);

	StraightEmitter* fireEmitter4 = StraightEmitter::create(Vector3D(-0.8f,0.5f,0.2f));
	fireEmitter4->setZone(Sphere::create(Vector3D(-0.255f,-0.2f + startY,-1.775),0.6f));
	fireEmitter4->setFlow(10);
	fireEmitter4->setForce(0.5f,1.5f);

	StraightEmitter* fireEmitter5 = StraightEmitter::create(Vector3D(0.1f,0.8f,-1.0f));
	fireEmitter5->setZone(Sphere::create(Vector3D(-0.075f,0.2f + startY,-2.3f),0.6f));
	fireEmitter5->setFlow(10);
	fireEmitter5->setForce(0.5f,1.5f);

	Emitter* smokeEmitter = SphericEmitter::create(Vector3D(0.0f,1.0f,0.0f),0.0f,0.5f * M_PI);
	smokeEmitter->setZone(Sphere::create(Vector3D(0, 1 + startY, -2),3.6f));
	smokeEmitter->setFlow(25);
	smokeEmitter->setForce(0.5f,1.0f);

	// Groups
	Group* fireGroup = Group::create(fireModel,135);
	fireGroup->addEmitter(fireEmitter1);
	fireGroup->addEmitter(fireEmitter2);
	fireGroup->addEmitter(fireEmitter3);
	fireGroup->addEmitter(fireEmitter4);
	fireGroup->addEmitter(fireEmitter5);
	fireGroup->setRenderer(fireRenderer);
	fireGroup->setGravity(Vector3D(0.0f,3.0f,0.0f));

	Group* smokeGroup = Group::create(smokeModel,135);
	smokeGroup->addEmitter(smokeEmitter);
	smokeGroup->setRenderer(smokeRenderer);
	smokeGroup->setGravity(Vector3D(0.0f,0.4f,0.0f));
	
	// System
	[[ParticleSystem GetInstance] AddGroup:smokeGroup];
	[[ParticleSystem GetInstance] AddGroup:fireGroup];

	std::cout << "\nSPARK FACTORY AFTER INIT :" << std::endl;
	SPKFactory::getInstance().traceAll();
}

-(void)Shutdown
{
    [mEnvironment release];
    [mIncrementalGameUI Remove];
    
    [mGameStateMachine release];
    
    [super Shutdown];
}

-(void)Update:(CFTimeInterval)inTimeStep
{
    [mGameStateMachine Update:inTimeStep];
    [mIncrementalGameUI Update:inTimeStep];
    
    [super Update:inTimeStep];
}

-(void)Suspend
{
    [super Suspend];
}

-(void)Resume
{
    [super Resume];
}

-(void)ProcessMessage:(Message*)inMsg
{
    [super ProcessMessage:inMsg];
}

-(WaterBalloonEnvironment*)GetEnvironment
{
    return mEnvironment;
}

-(BOOL)TriggerCondition:(NSString*)inTrigger
{
    State* curState = [mGameStateMachine GetActiveState];
    NSString *stateName = NSStringFromClass([curState class]);

    return ([stateName compare:inTrigger] == NSOrderedSame);
}

-(void)Draw
{
}

@end
