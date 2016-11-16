//
//  PizzaPowerupInfo.h
//  PizzaSpinner
//
//  Created by Rishi Gupta on 6/23/14.
//  Copyright (c) 2014 Neon Games LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    PIZZA_POWERUP_FIRST,
    PIZZA_POWERUP_GOLDEN_ROLLING_PIN = PIZZA_POWERUP_FIRST,
    PIZZA_POWERUP_MARINARA_RIG,
    PIZZA_POWERUP_COW_PASTURE,
    PIZZA_POWERUP_PIZZA_ATM,
    PIZZA_POWERUP_PIZZA_PRINTER,
    PIZZA_POWERUP_MOON_MINE,
    PIZZA_POWERUP_LORD_PIZZA,
    PIZZA_POWERUP_PIZZAMOGRIFIER,
    PIZZA_POWERUP_LAST = PIZZA_POWERUP_PIZZAMOGRIFIER,
    PIZZA_POWERUP_NUM,
    PIZZA_POWERUP_INVALID = PIZZA_POWERUP_NUM
} PizzaPowerup;

typedef enum
{
    PIZZA_POWERUP_UNLOCKED,
    PIZZA_POWERUP_QUESTION,
    PIZZA_POWERUP_INVISIBLE
} PizzaPowerupUnlockState;

typedef enum
{
    PIZZA_POWERUP_UPGRADE_SINGLE_MULTIPLIER,
    PIZZA_POWERUP_UPGRADE_GLOBAL_MULTIPLIER,
    PIZZA_POWERUP_UPGRADE_SPIN_MULTIPLIER,
    PIZZA_POWERUP_UPGRADE_SPIN_INCREMENT,
    PIZZA_POWERUP_UPGRADE_TYPE_NUM
} PizzaPowerupUpgradeType;

typedef enum
{
    PIZZA_POWERUP_UPGRADE_NONE,
    PIZZA_POWERUP_UPGRADE_BRONZE,
    PIZZA_POWERUP_UPGRADE_SILVER,
    PIZZA_POWERUP_UPGRADE_GOLD,
    PIZZA_POWERUP_UPGRADE_NUM
} PizzaPowerupUpgradeLevel;

@interface PizzaUpgradeInfo : NSObject
{
@public
    PizzaPowerupUpgradeType mUpgradeType;
    float                   mUpgradeData;
    double                  mUpgradeCost;
    int                     mMinQuantity;
}

-(instancetype)InitWithType:(PizzaPowerupUpgradeType)inType data:(float)inData cost:(double)inCost minQuantity:(int)inMinQuantity;
-(void)dealloc;

@end

@interface PizzaPowerupStats : NSObject
{
    NSMutableArray* mUpgradeInfo;
}

-(instancetype)Init;
-(void)dealloc;

-(void)AddPowerupType:(PizzaPowerupUpgradeType)inPowerupType data:(float)inData cost:(double)inCost minQuantity:(int)inMinQuantity;
-(PizzaUpgradeInfo*)GetUpgradeInfo:(int)inIndex;
-(int)GetNumUpgrades;

@property(retain)   NSString* Name;
@property(retain)   NSString* Description;
@property(retain)   NSString* IconTexture;
@property           float     PizzasPerSecond;
@property           int       Cost;

@end

@interface PizzaPowerupInfo : NSObject
{
    NSMutableArray* mPowerupInfo;
}

-(instancetype)Init;
-(void)dealloc;

-(PizzaPowerupStats*)GetStatsForPowerup:(PizzaPowerup)inPowerup;

@end
