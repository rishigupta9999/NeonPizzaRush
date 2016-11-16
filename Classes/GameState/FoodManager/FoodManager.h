//
//  FoodManager.h
//
//  Copyright (c) 2014 Neon Games LLC. All rights reserved.
//

#import "AppDelegate.h"
#import "Event.h"
#import "LevelDefinitions.h"
#import "SaveSystem.h"
#import "AppDelegate.h"
#import "PizzaPowerupInfo.h"

typedef enum
{
    CRYSTAL_PIZZA_REGEN_RATE,
    CRYSTAL_PIZZA_QUANTITY,
    CRYSTAL_PIZZA_NUM
} CrystalPizzaType;

typedef enum
{
    CRYSTAL_ITEM_STATE_IDLE,
    CRYSTAL_ITEM_STATE_VISIBLE,
    CRYSTAL_ITEM_STATE_ACTIVE
} CrystalItemState;

@interface FoodManager : NSObject
{
    CFAbsoluteTime  mLastUpdateTime;
    
    double          mSpinIncrementModifier;
    double          mSpinMultiplierModifier;
    double          mGlobalPerSecondMultiplierModifier;
    double          mSingleMultiplierModifiers[PIZZA_POWERUP_NUM];
    
    double          mCrystalItemCurrentMultiplier;
    double          mCrystalItemTimeRemaining;
    CrystalItemState    mCrystalItemState;
    
    int             mCrystalItemManualTrigger;
    CFAbsoluteTime  mCrystalItemTimeTrigger;
    CFAbsoluteTime  mCrystalItemVisibleTime;
}

-(FoodManager*)Init;
-(void)dealloc;

+(void)CreateInstance;
+(void)DestroyInstance;
+(FoodManager*)GetInstance;

-(void)CacheUpgradeModifiers;

-(void)AddPizza:(double)inNumPizza;
-(double)GetNumPizza;
-(void)SetNumPizza:(double)inNumPizza;

-(double)GetRegenRateForPowerup:(PizzaPowerup)inPowerup;
-(double)GetNumPizzasForPowerup:(PizzaPowerup)inPowerup;
-(void)SetNumPizzasForPowerup:(PizzaPowerup)inPowerup num:(double)inNumPizza;

-(void)SetCrystalItemTrigger;
-(void)SpawnCrystalItem;

-(double)GetTotalRegenRate;

-(double)GetNumPizzasPerSpin;

-(void)AddPowerup:(PizzaPowerup)inPowerup;
-(int)GetNumPowerup:(PizzaPowerup)inPowerup;
-(void)SetNumPowerup:(PizzaPowerup)inPowerup num:(int)inNum;

-(void)IncrementManualItems;

-(void)UpgradePowerup:(PizzaPowerup)inPowerup;

-(double)GetPowerupCost:(PizzaPowerup)inPowerup;
-(PizzaUpgradeInfo*)GetNextUpgradeInfo:(PizzaPowerup)inPowerup;
-(NSString*)GetUpgradeStringForPowerup:(PizzaPowerup)inPowerup;

-(BOOL)GetBooster;
-(double)GetBoosterMultiplier;

-(double)GetCrystalItemPercentRemaining;

-(void)Update:(CFTimeInterval)inTimeInterval;

@end
