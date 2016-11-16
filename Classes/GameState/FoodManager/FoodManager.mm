//
//  FoodManager.mm
//
//  Copyright (c) 2014 Neon Games LLC. All rights reserved.
//

#import "FoodManager.h"
#import "Flow.h"
#import "SaveSystem.h"
#import "MessageChannel.h"
#import "InGameNotificationManager.h"
#import "SplitTestingSystem.h"

static FoodManager* sInstance = NULL;

static const float REGEN_INTERVAL = 0.25;
static const float BOOSTER_MULTIPLIER = 2.0;

static const int CRYSTAL_ITEM_LOWER = 10;
static const int CRYSTAL_ITEM_UPPER = 30;

static int    CRYSTAL_ITEM_DURATION = 60;
static double CRYSTAL_ITEM_MULTIPLIER = 8.0;

static int    CRYSTAL_ITEM_INTERVAL = 45;
static int    CRYSTAL_ITEM_MINIMUM  = 35;

static int    CRYSTAL_ITEM_AUTO_EXPIRATION = 10;

static const float  CRYSTAL_ITEM_REGEN_PROBABILITY = 0.65;

static const NSString*  CRYSTAL_PIZZA_TYPE_STRINGS[CRYSTAL_PIZZA_NUM] = {   @"Crystal Pizza Regen",
                                                                            @"Crystal Pizza Quantity"   };

@interface FoodManager(Private)<MessageChannelListener>

-(void)ProcessMessage:(Message*)inMsg;

@end

@implementation FoodManager

-(FoodManager*)Init
{
    mLastUpdateTime = CACurrentMediaTime();
    
    if (![[SaveSystem GetInstance] GetCrystalItemTutorial])
    {
        int numPizzasMade = [[SaveSystem GetInstance] GetNumManualItems];
        int range = CRYSTAL_ITEM_UPPER - NeonMax(CRYSTAL_ITEM_LOWER, numPizzasMade);
        int lower = NeonMax(CRYSTAL_ITEM_LOWER, numPizzasMade);
        int rand = arc4random_uniform(range);
        
        mCrystalItemManualTrigger = lower + rand;
    }
    else
    {
        mCrystalItemManualTrigger = 0;
    }
    
    int crystalTestingVariation = [[SplitTestingSystem GetInstance] GetSplitTestValue:SPLIT_TEST_CRYSTAL_PIZZA_TIMES];
    
    if (crystalTestingVariation != 0)
    {
        switch(crystalTestingVariation)
        {
            case 1:
            {
                CRYSTAL_ITEM_INTERVAL = 25;
                CRYSTAL_ITEM_MINIMUM = 20;
                CRYSTAL_ITEM_DURATION = 30;
                CRYSTAL_ITEM_AUTO_EXPIRATION = 7;
                break;
            }
            
            case 2:
            {
                CRYSTAL_ITEM_INTERVAL = 10;
                CRYSTAL_ITEM_MINIMUM = 10;
                CRYSTAL_ITEM_DURATION = 15;
                CRYSTAL_ITEM_AUTO_EXPIRATION = 5;
                break;
            }
        }
    }
    
    mCrystalItemCurrentMultiplier = 1;
    mCrystalItemTimeRemaining = 0;
    mCrystalItemVisibleTime = 0;
    
    mCrystalItemState = CRYSTAL_ITEM_STATE_IDLE;
    
    [self CacheUpgradeModifiers];
    [self SetCrystalItemTrigger];
    
    [GetGlobalMessageChannel() AddListener:self];
    
    return self;
}

-(void)dealloc
{
    [super dealloc];
}

+(void)CreateInstance
{
    NSAssert(sInstance == NULL, @"Attempting to double-create FoodManager.");
    sInstance = [[FoodManager alloc] Init];
}

+(void)DestroyInstance
{
    NSAssert(sInstance != NULL, @"Attempting to delete FoodManager. when one doesn't exist");
    [sInstance release];
}

+(FoodManager*)GetInstance
{
    return sInstance;
}

-(void)ProcessMessage:(Message*)inMsg
{
    switch(inMsg->mId)
    {
        case EVENT_CRYSTAL_ITEM_TAPPED:
        {
            int rand = arc4random_uniform(100);
            CrystalPizzaType type = CRYSTAL_PIZZA_QUANTITY;
            
            if (rand < (CRYSTAL_ITEM_REGEN_PROBABILITY * 100))
            {
                type = CRYSTAL_PIZZA_REGEN_RATE;
            }
            
            NSString* notificationString = NULL;
            
            switch(type)
            {
                case CRYSTAL_PIZZA_REGEN_RATE:
                {
                    mCrystalItemTimeRemaining = CRYSTAL_ITEM_DURATION;
                    mCrystalItemCurrentMultiplier = CRYSTAL_ITEM_MULTIPLIER;
                    
                    notificationString = [NSString stringWithFormat:NSLocalizedString(@"LS_CrystalPizza_Regen", NULL), (int)CRYSTAL_ITEM_MULTIPLIER, (int)CRYSTAL_ITEM_DURATION];
                    break;
                }
                
                case CRYSTAL_PIZZA_QUANTITY:
                {
                    u64 awardedPizzas = NeonMax(100, (u64)(0.1 * [self GetNumPizza] + 30 * [self GetTotalRegenRate]));
                    notificationString = [NSString stringWithFormat:NSLocalizedString(@"LS_CrystalPizza_Quantity", NULL), awardedPizzas];
                    
                    mCrystalItemState = CRYSTAL_ITEM_STATE_IDLE;
                    [self SetCrystalItemTrigger];
                    
                    [self AddPizza:awardedPizzas];

                    break;
                }
                
                default:
                {
                    NSAssert(FALSE, @"Unknown crystal pizza type");
                    break;
                }
            }
            
            [[InGameNotificationManager GetInstance] NotificationWithText:notificationString];
            
            mCrystalItemState = CRYSTAL_ITEM_STATE_ACTIVE;
            
            [[NeonMetrics GetInstance] logEvent:@"Crystal Pizza Tapped" withParameters:[NSDictionary dictionaryWithObject:CRYSTAL_PIZZA_TYPE_STRINGS[type] forKey:@"Crystal Pizza Type"]];
            
            break;
        }
    }
}

-(void)CacheUpgradeModifiers
{
    mSpinIncrementModifier = 0;
    mSpinMultiplierModifier = 0;
    mGlobalPerSecondMultiplierModifier = 1.0;

    for (int i = 0; i < PIZZA_POWERUP_NUM; i++)
    {
        PizzaPowerupStats* stats = [[Flow GetInstance].PizzaPowerupInfo GetStatsForPowerup:(PizzaPowerup)i];
        int numUpgrades = [[SaveSystem GetInstance] GetUpgradeLevelForPowerup:(PizzaPowerup)i];
        
        mSingleMultiplierModifiers[i] = 1.0;
        
        for (int curUpgrade = 0; curUpgrade < numUpgrades; curUpgrade++)
        {
            PizzaUpgradeInfo* info = [stats GetUpgradeInfo:curUpgrade];
            
            switch(info->mUpgradeType)
            {
                case PIZZA_POWERUP_UPGRADE_SINGLE_MULTIPLIER:
                {
                    mSingleMultiplierModifiers[i] *= info->mUpgradeData;
                    break;
                }
                
                case PIZZA_POWERUP_UPGRADE_GLOBAL_MULTIPLIER:
                {
                    mGlobalPerSecondMultiplierModifier *= info->mUpgradeData;
                    break;
                }
                
                case PIZZA_POWERUP_UPGRADE_SPIN_MULTIPLIER:
                {
                    mSpinMultiplierModifier += info->mUpgradeData;
                    break;
                }
                
                case PIZZA_POWERUP_UPGRADE_SPIN_INCREMENT:
                {
                    mSpinIncrementModifier += info->mUpgradeData;
                    break;
                }
            }
        }
    }
}

-(void)AddPizza:(double)inNumPizza
{
    double numPizza = [[SaveSystem GetInstance] GetNumPizza];
    numPizza += inNumPizza;
    [[SaveSystem GetInstance] SetNumPizza:numPizza];
}

-(double)GetNumPizza
{
    return [[SaveSystem GetInstance] GetNumPizza];
}

-(void)SetNumPizza:(double)inNumPizza
{
    [[SaveSystem GetInstance] SetNumPizza:inNumPizza];
}

-(double)GetRegenRateForPowerup:(PizzaPowerup)inPowerup
{
    PizzaPowerupStats* stats = [[Flow GetInstance].PizzaPowerupInfo GetStatsForPowerup:inPowerup];
    
    return stats.PizzasPerSecond * mSingleMultiplierModifiers[inPowerup] * mGlobalPerSecondMultiplierModifier * [self GetBoosterMultiplier];
}

-(double)GetNumPizzasForPowerup:(PizzaPowerup)inPowerup
{
    PizzaPowerupStats* info = [[Flow GetInstance].PizzaPowerupInfo GetStatsForPowerup:inPowerup];
    double returnValue = [[SaveSystem GetInstance] GetNumPowerupGeneratedPizzas:inPowerup];

    return returnValue;
}

-(void)SetNumPizzasForPowerup:(PizzaPowerup)inPowerup num:(double)inNum
{
    PizzaPowerupStats* info = [[Flow GetInstance].PizzaPowerupInfo GetStatsForPowerup:inPowerup];
    [[SaveSystem GetInstance] SetNumPowerupGeneratedPizzas:inPowerup numPizzas:inNum];
}

-(void)SetCrystalItemTrigger
{
    if ((mCrystalItemManualTrigger == 0) && (mCrystalItemTimeTrigger < CACurrentMediaTime()))
    {
        CFAbsoluteTime curTime = CACurrentMediaTime();
        mCrystalItemTimeTrigger = curTime + CRYSTAL_ITEM_MINIMUM + arc4random_uniform(CRYSTAL_ITEM_INTERVAL);
    }
}

-(void)SpawnCrystalItem
{
    [GetGlobalMessageChannel() SendEvent:EVENT_CRYSTAL_ITEM_SPAWN withData:NULL];
    
    mCrystalItemManualTrigger = 0;
    mCrystalItemTimeTrigger = 0;
    mCrystalItemState = CRYSTAL_ITEM_STATE_VISIBLE;
    mCrystalItemVisibleTime = 0;
    
    [[NeonMetrics GetInstance] logEvent:@"Crystal Pizza Spawned" withParameters:NULL];
}

-(double)GetTotalRegenRate
{
    double totalRegen = 0;
    
    for (int i = 0; i < PIZZA_POWERUP_NUM; i++)
    {
        PizzaPowerupStats* info = [[Flow GetInstance].PizzaPowerupInfo GetStatsForPowerup:(PizzaPowerup)i];
        double boosterMultiplier = [self GetBooster] ? BOOSTER_MULTIPLIER : 1.0;
        totalRegen += [self GetNumPowerup:(PizzaPowerup)i] * mSingleMultiplierModifiers[i] * mGlobalPerSecondMultiplierModifier * boosterMultiplier * info.PizzasPerSecond;
    }
    
    return (totalRegen + START_REGEN_RATE) * mCrystalItemCurrentMultiplier;
}

-(double)GetNumPizzasPerSpin
{
    double basePizza = 1.0;
    double boosterMultiplier = [self GetBooster] ? BOOSTER_MULTIPLIER : 1.0;
    double pizzaIncrement = mSpinIncrementModifier;
    double spinMultiplier = mSpinMultiplierModifier * [self GetTotalRegenRate];
    
    return ((basePizza + pizzaIncrement) * boosterMultiplier * mCrystalItemCurrentMultiplier) + spinMultiplier;
}

-(void)AddPowerup:(PizzaPowerup)inPowerup
{
    int costPizza = [self GetPowerupCost:inPowerup];
    int numPowerup = [self GetNumPowerup:inPowerup];
    [self SetNumPowerup:inPowerup num:(numPowerup + 1)];
    
    u64 numPizza = [self GetNumPizza];
    numPizza -= costPizza;
    
    [self SetNumPizza:numPizza];
}

-(int)GetNumPowerup:(PizzaPowerup)inPowerup
{
    PizzaPowerupStats* info = [[Flow GetInstance].PizzaPowerupInfo GetStatsForPowerup:inPowerup];
    int returnValue = [[SaveSystem GetInstance] GetNumPowerup:inPowerup];
    
    return returnValue;
}

-(void)SetNumPowerup:(PizzaPowerup)inPowerup num:(int)inNum
{
    PizzaPowerupStats* info = [[Flow GetInstance].PizzaPowerupInfo GetStatsForPowerup:inPowerup];
    [[SaveSystem GetInstance] SetNumPowerup:inPowerup numPowerup:inNum];
    
    [GetGlobalMessageChannel() SendEvent:EVENT_INCREMENTAL_GAME_ADD_POWERUP withData:[NSNumber numberWithInt:inPowerup]];
}

-(void)UpgradePowerup:(PizzaPowerup)inPowerup
{
    int curLevel = [[SaveSystem GetInstance] GetUpgradeLevelForPowerup:inPowerup];
    PizzaUpgradeInfo* upgradeInfo = [[[Flow GetInstance].PizzaPowerupInfo GetStatsForPowerup:inPowerup] GetUpgradeInfo:curLevel];
    NSAssert(upgradeInfo != NULL, @"Attempting to upgrade powerup beyond the maximum possible level");
    
    double numPizza = [[FoodManager GetInstance] GetNumPizza];
    numPizza -= upgradeInfo->mUpgradeCost;
    [[FoodManager GetInstance] SetNumPizza:numPizza];
    
    [[SaveSystem GetInstance] SetUpgradeLevelForPowerup:inPowerup level:(curLevel + 1)];
    
    [self CacheUpgradeModifiers];
}

-(double)GetPowerupCost:(PizzaPowerup)inPowerup
{
    PizzaPowerupInfo* pizzaPowerupInfo = [Flow GetInstance].PizzaPowerupInfo;
    
    const int numOwned = [self GetNumPowerup:inPowerup];
    const int basePrice = [pizzaPowerupInfo GetStatsForPowerup:inPowerup].Cost;
    const double price = pow(1.1, numOwned) * basePrice;
    return price;
}

-(PizzaUpgradeInfo*)GetNextUpgradeInfo:(PizzaPowerup)inPowerup
{
    PizzaPowerupInfo* pizzaPowerupInfo = [Flow GetInstance].PizzaPowerupInfo;
    int nextUpgradeIndex = [[SaveSystem GetInstance] GetUpgradeLevelForPowerup:inPowerup];
    
    return [[pizzaPowerupInfo GetStatsForPowerup:inPowerup] GetUpgradeInfo:nextUpgradeIndex];
}

-(NSString*)GetUpgradeStringForPowerup:(PizzaPowerup)inPowerup
{
    PizzaUpgradeInfo* info = [self GetNextUpgradeInfo:inPowerup];
    
    if (info == NULL)
    {
        return NULL;
    }
    
    switch(info->mUpgradeType)
    {
        case PIZZA_POWERUP_UPGRADE_SPIN_INCREMENT:
        {
            return [NSString stringWithFormat:NSLocalizedString(@"LS_Upgrade_SpinIncrement", NULL), info->mUpgradeData];
            break;
        }
        
        case PIZZA_POWERUP_UPGRADE_SINGLE_MULTIPLIER:
        {
            NSString* powerupName = [[Flow GetInstance].PizzaPowerupInfo GetStatsForPowerup:inPowerup].Name;
            
            return [NSString stringWithFormat:NSLocalizedString(@"LS_Upgrade_SingleMultiplier", NULL), powerupName, info->mUpgradeData];
            break;
        }
        
        case PIZZA_POWERUP_UPGRADE_GLOBAL_MULTIPLIER:
        {
            return [NSString stringWithFormat:NSLocalizedString(@"LS_Upgrade_GlobalMultiplier", NULL), (int)((info->mUpgradeData - 1) * 100 + 0.5)];
            break;
        }
        
        case PIZZA_POWERUP_UPGRADE_SPIN_MULTIPLIER:
        {
            return [NSString stringWithFormat:NSLocalizedString(@"LS_Upgrade_SpinMultiplier", NULL), (int)((info->mUpgradeData) * 100 + 0.5)];
            break;
        }
        
        default:
        {
            NSAssert(FALSE, @"Unknown upgrade type");
            break;
        }
    }
    
    return NULL;
}

-(BOOL)GetBooster
{
    return [[SaveSystem GetInstance] GetBooster];
}

-(double)GetBoosterMultiplier
{
    return [self GetBooster] ? BOOSTER_MULTIPLIER : 1.0;
}

-(void)IncrementManualItems
{
    u32 manualItems = [[SaveSystem GetInstance] GetNumManualItems];
    u32 newItems = manualItems + 1;
    
    [[SaveSystem GetInstance] SetNumManualItems:newItems];
    
    if ((newItems > 0) && ((newItems % 5) == 0))
    {
        [[NeonMetrics GetInstance] logEvent:@"Pizza Made (5)" withParameters:NULL];
    }
    
    if ((newItems >= mCrystalItemManualTrigger) && (mCrystalItemManualTrigger > 0))
    {
        [self SpawnCrystalItem];
        [[SaveSystem GetInstance] SetCrystalItemTutorial:1];
    }
}

-(double)GetCrystalItemPercentRemaining
{
    return mCrystalItemTimeRemaining / (double)CRYSTAL_ITEM_DURATION;
}

-(void)Update:(CFTimeInterval)inTimeStep
{
    CFAbsoluteTime currentTime = CACurrentMediaTime();
    
    if ((currentTime - mLastUpdateTime) > REGEN_INTERVAL)
    {
        CFTimeInterval regenTime = currentTime - mLastUpdateTime;
        float addCookies = regenTime * (float)[self GetTotalRegenRate];
        
        [self AddPizza:addCookies];
        
        for (int i = 0; i < PIZZA_POWERUP_NUM; i++)
        {
            int numPowerup = [self GetNumPowerup:(PizzaPowerup)i];
            
            if (numPowerup > 0)
            {
                PizzaPowerupStats* stats = [[Flow GetInstance].PizzaPowerupInfo GetStatsForPowerup:(PizzaPowerup)i];
                double curPizza = [self GetNumPizzasForPowerup:(PizzaPowerup)i];
                double boosterMultiplier = [self GetBooster] ? BOOSTER_MULTIPLIER : 1.0;
                double addPizza = curPizza + (stats.PizzasPerSecond * numPowerup * mCrystalItemCurrentMultiplier * mGlobalPerSecondMultiplierModifier * boosterMultiplier * regenTime);
                
                [self SetNumPizzasForPowerup:(PizzaPowerup)i num:addPizza];
            }
        }
        
        mLastUpdateTime = currentTime;
    }
    
    for (PizzaPowerup i = PIZZA_POWERUP_FIRST; i < PIZZA_POWERUP_NUM; i = (PizzaPowerup)((int)i + 1))
    {
        PizzaPowerupUnlockState unlockState = [[SaveSystem GetInstance] GetPowerupUnlockState:i];
        
        if (unlockState != PIZZA_POWERUP_UNLOCKED)
        {
            if ([self GetNumPizza] >= [self GetPowerupCost:i])
            {
                [[SaveSystem GetInstance] SetPowerupUnlockState:i state:PIZZA_POWERUP_UNLOCKED];
                [GetGlobalMessageChannel() SendEvent:EVENT_INCREMENTAL_GAME_UNLOCK_STATE_CHANGED withData:[NSNumber numberWithInt:i]];
                
                PizzaPowerupStats* stats = [[Flow GetInstance].PizzaPowerupInfo GetStatsForPowerup:(PizzaPowerup)i];
                
                NSString* eventName = [NSString stringWithFormat:@"Unlocked %@", stats.Name];
                [[NeonMetrics GetInstance] logEvent:eventName withParameters:NULL];
                
                if (i < PIZZA_POWERUP_LAST)
                {
                    [[SaveSystem GetInstance] SetPowerupUnlockState:((PizzaPowerup)(i + 1)) state:PIZZA_POWERUP_QUESTION];
                    [GetGlobalMessageChannel() SendEvent:EVENT_INCREMENTAL_GAME_UNLOCK_STATE_CHANGED withData:[NSNumber numberWithInt:(i + 1)]];
                }
            }
            
            break;
        }
    }
    
    switch(mCrystalItemState)
    {
        case CRYSTAL_ITEM_STATE_IDLE:
        {
            if ((CACurrentMediaTime() > mCrystalItemTimeTrigger) && (mCrystalItemManualTrigger == 0))
            {
                [self SpawnCrystalItem];
            }

            break;
        }
        
        case CRYSTAL_ITEM_STATE_VISIBLE:
        {
            mCrystalItemVisibleTime += inTimeStep;
            
            if (mCrystalItemVisibleTime > CRYSTAL_ITEM_AUTO_EXPIRATION)
            {
                [GetGlobalMessageChannel() SendEvent:EVENT_CRYSTAL_ITEM_AUTO_EXPIRED withData:NULL];
                [self SetCrystalItemTrigger];
                
                mCrystalItemState = CRYSTAL_ITEM_STATE_IDLE;
                
                [[NeonMetrics GetInstance] logEvent:@"Crystal Pizza Expired" withParameters:NULL];
            }
            
            break;
        }
        
        case CRYSTAL_ITEM_STATE_ACTIVE:
        {
            mCrystalItemTimeRemaining = LClampFloat(mCrystalItemTimeRemaining - inTimeStep, 0);
    
            if (mCrystalItemTimeRemaining <= 0)
            {
                [GetGlobalMessageChannel() SendEvent:EVENT_CRYSTAL_ITEM_EXPIRED withData:NULL];
                
                mCrystalItemCurrentMultiplier = 1.0;
                mCrystalItemState = CRYSTAL_ITEM_STATE_IDLE;
                
                [self SetCrystalItemTrigger];
            }

            break;
        }
    }
    
    
}

@end
