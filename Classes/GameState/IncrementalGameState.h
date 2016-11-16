//
//  WaterBalloonTossState.h
//  WaterBalloonToss
//
//  Created by Rishi Gupta on 5/10/14.
//  Copyright (c) 2014 Neon Games LLC. All rights reserved.
//

#import "TutorialGameState.h"
#import "MessageChannel.h"

@class FoodManager;
@class WaterBalloonEnvironment;
@class IncrementalGameUI;
@class PizzaEntity;
@class IncrementalGameStateMachine;
@class CounterTopEntity;
@class PizzaOvenEntity;
@class Texture;

#define PIZZA_ENTITY_POOL_SIZE  (3)

@interface IncrementalGameState : TutorialGameState<MessageChannelListener, TriggerEvaluator>
{
    @public
        WaterBalloonEnvironment*    mEnvironment;
        IncrementalGameUI*          mIncrementalGameUI;
        FoodManager*                mFoodManager;
    
        IncrementalGameStateMachine*    mGameStateMachine;
    
        Texture*                    mFireTexture;
        Texture*                    mSmokeTexture;
    
        PizzaEntity*                mPizzaEntities[PIZZA_ENTITY_POOL_SIZE];
        int                         mCurPizzaIndex;
}

@property(atomic, assign) PizzaEntity*      PizzaEntity;
@property(atomic, assign) CounterTopEntity* CounterTopEntity;
@property(atomic, assign) PizzaOvenEntity*  PizzaOvenEntity;

-(void)Startup;
-(void)Shutdown;
-(void)Update:(CFTimeInterval)inTimeStep;
-(void)Suspend;
-(void)Resume;

-(void)ProcessMessage:(Message*)inMsg;

-(WaterBalloonEnvironment*)GetEnvironment;
-(BOOL)TriggerCondition:(NSString*)inTrigger;

@end
