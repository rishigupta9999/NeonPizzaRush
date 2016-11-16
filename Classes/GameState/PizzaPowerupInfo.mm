//
//  PizzaPowerupInfo.m
//  PizzaSpinner
//
//  Created by Rishi Gupta on 6/23/14.
//  Copyright (c) 2014 Neon Games LLC. All rights reserved.
//

#import "PizzaPowerupInfo.h"

@implementation PizzaUpgradeInfo

-(instancetype)InitWithType:(PizzaPowerupUpgradeType)inType data:(float)inData cost:(double)inCost minQuantity:(int)inMinQuantity
{
    mUpgradeType = inType;
    mUpgradeData = inData;
    mUpgradeCost = inCost;
    mMinQuantity = inMinQuantity;
    
    return self;
}

-(void)dealloc
{
    [super dealloc];
}
@end

@implementation PizzaPowerupStats

@synthesize Name = mName;
@synthesize Description = mDescription;
@synthesize IconTexture = mIconTexture;
@synthesize PizzasPerSecond = mPizzasPerSecond;
@synthesize Cost = mCost;

-(instancetype)Init
{
    mName = NULL;
    mDescription = NULL;
    mIconTexture = NULL;
    mPizzasPerSecond = 0;
    mCost = 0;
    
    mUpgradeInfo = [[NSMutableArray alloc] init];
    
    return self;
}

-(void)dealloc
{
    [mUpgradeInfo release];
    
    [super dealloc];
}

-(void)AddPowerupType:(PizzaPowerupUpgradeType)inPowerupType data:(float)inData cost:(double)inCost minQuantity:(int)inMinQuantity;
{
    PizzaUpgradeInfo* info = [[PizzaUpgradeInfo alloc] InitWithType:inPowerupType data:inData cost:inCost minQuantity:inMinQuantity];
    [mUpgradeInfo addObject:info];
    [info release];
}

-(PizzaUpgradeInfo*)GetUpgradeInfo:(int)inIndex
{
    if (inIndex >= [mUpgradeInfo count])
    {
        return NULL;
    }
    
    return [mUpgradeInfo objectAtIndex:inIndex];
}

-(int)GetNumUpgrades
{
    return (int)[mUpgradeInfo count];
}

@end

@implementation PizzaPowerupInfo

-(instancetype)Init
{
    double upgradeCost = 100;
    mPowerupInfo = [[NSMutableArray alloc] init];
    
    // Golden Rolling Pins
    PizzaPowerupStats* stats = [[PizzaPowerupStats alloc] Init];
    
    stats.Name = NSLocalizedString(@"LS_Powerup_GoldenRollingPin", NULL);
    stats.Description = NSLocalizedString(@"LS_Powerup_GoldenRollingPin_Description", NULL);
    stats.IconTexture = @"GoldenRollingPin.papng";
    stats.PizzasPerSecond = 0.1;
    stats.Cost = 10;
    
    [stats AddPowerupType:PIZZA_POWERUP_UPGRADE_SPIN_INCREMENT      data:3.0    cost:upgradeCost * 10 minQuantity:25];
    [stats AddPowerupType:PIZZA_POWERUP_UPGRADE_SINGLE_MULTIPLIER   data:2.0    cost:upgradeCost * 25 minQuantity:50];
    [stats AddPowerupType:PIZZA_POWERUP_UPGRADE_SPIN_INCREMENT      data:12.0   cost:upgradeCost * 50 minQuantity:100];
    upgradeCost *= 10;
    
    [mPowerupInfo addObject:stats];
    [stats release];
    
    // Marinara Rig
    stats = [[PizzaPowerupStats alloc] Init];
    
    stats.Name = NSLocalizedString(@"LS_Powerup_MarinaraRig", NULL);
    stats.Description = NSLocalizedString(@"LS_Powerup_MarinaraRig_Description", NULL);
    stats.IconTexture = @"MarinaraRig.papng";
    stats.PizzasPerSecond = 1;
    stats.Cost = 100;
    
    [stats AddPowerupType:PIZZA_POWERUP_UPGRADE_SINGLE_MULTIPLIER   data:2.0    cost:upgradeCost * 10   minQuantity:25];
    [stats AddPowerupType:PIZZA_POWERUP_UPGRADE_SPIN_INCREMENT      data:25.0   cost:upgradeCost * 25   minQuantity:50];
    [stats AddPowerupType:PIZZA_POWERUP_UPGRADE_SINGLE_MULTIPLIER   data:2.0    cost:upgradeCost * 50   minQuantity:100];
    upgradeCost *= 10;
    
    [mPowerupInfo addObject:stats];
    [stats release];

    // Cow Pasture
    stats = [[PizzaPowerupStats alloc] Init];
    
    stats.Name = NSLocalizedString(@"LS_Powerup_CowPasture", NULL);
    stats.Description = NSLocalizedString(@"LS_Powerup_CowPasture_Description", NULL);
    stats.IconTexture = @"CowPasture.papng";
    stats.PizzasPerSecond = 4;
    stats.Cost = 500;
    
    [stats AddPowerupType:PIZZA_POWERUP_UPGRADE_GLOBAL_MULTIPLIER data:1.1      cost:upgradeCost * 10   minQuantity:25];
    [stats AddPowerupType:PIZZA_POWERUP_UPGRADE_SINGLE_MULTIPLIER data:2.0      cost:upgradeCost * 25   minQuantity:50];
    [stats AddPowerupType:PIZZA_POWERUP_UPGRADE_GLOBAL_MULTIPLIER data:1.15     cost:upgradeCost * 50   minQuantity:100];
    upgradeCost *= 10;
    
    [mPowerupInfo addObject:stats];
    [stats release];
    
    // Pizza ATM
    stats = [[PizzaPowerupStats alloc] Init];
    
    stats.Name = NSLocalizedString(@"LS_Powerup_PizzaATM", NULL);
    stats.Description = NSLocalizedString(@"LS_Powerup_PizzaATM_Description", NULL);
    stats.IconTexture = @"PizzaATM.papng";
    stats.PizzasPerSecond = 14;
    stats.Cost = 2500;
    
    [stats AddPowerupType:PIZZA_POWERUP_UPGRADE_SINGLE_MULTIPLIER data:2.0      cost:upgradeCost * 10   minQuantity:25];
    [stats AddPowerupType:PIZZA_POWERUP_UPGRADE_SINGLE_MULTIPLIER data:2.0      cost:upgradeCost * 25   minQuantity:50];
    [stats AddPowerupType:PIZZA_POWERUP_UPGRADE_SPIN_MULTIPLIER data:0.02       cost:upgradeCost * 50   minQuantity:100];
    upgradeCost *= 10;
    
    [mPowerupInfo addObject:stats];
    [stats release];
    
    // 3D Pizza Printer
    stats = [[PizzaPowerupStats alloc] Init];
    
    stats.Name = NSLocalizedString(@"LS_Powerup_3DPrintedPizzas", NULL);
    stats.Description = NSLocalizedString(@"LS_Powerup_3DPrintedPizzas_Description", NULL);
    stats.IconTexture = @"3DPrintedPizzas.papng";
    stats.PizzasPerSecond = 120;
    stats.Cost = 20000;
    
    [stats AddPowerupType:PIZZA_POWERUP_UPGRADE_SPIN_MULTIPLIER data:0.05       cost:upgradeCost * 10   minQuantity:25];
    [stats AddPowerupType:PIZZA_POWERUP_UPGRADE_SINGLE_MULTIPLIER data:2.0      cost:upgradeCost * 25   minQuantity:50];
    [stats AddPowerupType:PIZZA_POWERUP_UPGRADE_GLOBAL_MULTIPLIER data:1.1      cost:upgradeCost * 50   minQuantity:100];
    upgradeCost *= 10;
    
    [mPowerupInfo addObject:stats];
    [stats release];
    
    // Moon Mine
    stats = [[PizzaPowerupStats alloc] Init];
    
    stats.Name = NSLocalizedString(@"LS_Powerup_MoonMine", NULL);
    stats.Description = NSLocalizedString(@"LS_Powerup_MoonMine_Description", NULL);
    stats.IconTexture = @"MoonMine.papng";
    stats.PizzasPerSecond = 960;
    stats.Cost = 125000;
    
    [stats AddPowerupType:PIZZA_POWERUP_UPGRADE_SPIN_MULTIPLIER data:0.05       cost:upgradeCost * 10   minQuantity:25];
    [stats AddPowerupType:PIZZA_POWERUP_UPGRADE_SINGLE_MULTIPLIER data:2.0      cost:upgradeCost * 25   minQuantity:50];
    [stats AddPowerupType:PIZZA_POWERUP_UPGRADE_SINGLE_MULTIPLIER data:2.0      cost:upgradeCost * 50   minQuantity:100];
    upgradeCost *= 10;
    
    [mPowerupInfo addObject:stats];
    [stats release];
    
    // Pepperonium Accelerator
    stats = [[PizzaPowerupStats alloc] Init];
    
    stats.Name = NSLocalizedString(@"LS_Powerup_PepperoniumAccelerator", NULL);
    stats.Description = NSLocalizedString(@"LS_Powerup_PepperoniumAccelerator_Description", NULL);
    stats.IconTexture = @"PepperoniumAccelerator.papng";
    stats.PizzasPerSecond = 6000;
    stats.Cost = 1500000;
    
    [stats AddPowerupType:PIZZA_POWERUP_UPGRADE_GLOBAL_MULTIPLIER data:1.15     cost:upgradeCost * 10   minQuantity:25];
    [stats AddPowerupType:PIZZA_POWERUP_UPGRADE_SINGLE_MULTIPLIER data:2.0      cost:upgradeCost * 25   minQuantity:50];
    [stats AddPowerupType:PIZZA_POWERUP_UPGRADE_SPIN_MULTIPLIER data:0.03       cost:upgradeCost * 50   minQuantity:100];
    upgradeCost *= 10;
    
    [mPowerupInfo addObject:stats];
    [stats release];
    
    // Pizzamogrifier
    stats = [[PizzaPowerupStats alloc] Init];
    
    stats.Name = NSLocalizedString(@"LS_Powerup_Pizzamogrifier", NULL);
    stats.Description = NSLocalizedString(@"LS_Powerup_Pizzamogrifier_Description", NULL);
    stats.IconTexture = @"Pizzamogrifier.papng";
    stats.PizzasPerSecond = 20000;
    stats.Cost = 10000000;
    
    [stats AddPowerupType:PIZZA_POWERUP_UPGRADE_SINGLE_MULTIPLIER data:2.0      cost:upgradeCost * 10   minQuantity:25];
    [stats AddPowerupType:PIZZA_POWERUP_UPGRADE_SINGLE_MULTIPLIER data:2.0      cost:upgradeCost * 25   minQuantity:50];
    [stats AddPowerupType:PIZZA_POWERUP_UPGRADE_GLOBAL_MULTIPLIER data:1.3      cost:upgradeCost * 50   minQuantity:100];
    upgradeCost *= 10;

    [mPowerupInfo addObject:stats];
    [stats release];
    
    return self;
}

-(void)dealloc
{
    [mPowerupInfo release];
    [super dealloc];
}

-(PizzaPowerupStats*)GetStatsForPowerup:(PizzaPowerup)inPowerup
{
    return [mPowerupInfo objectAtIndex:inPowerup];
}

@end
