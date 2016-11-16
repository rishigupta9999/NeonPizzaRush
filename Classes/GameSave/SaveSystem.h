//
//  SaveSystem.h
//  Neon21
//
//  Copyright Neon Games 2010. All rights reserved.
//

#import "MenuFlowTypes.h"
#import "InAppPurchaseManager.h"
#import "DebugManager.h"
#import "LevelDefinitions.h"
#import "PizzaPowerupInfo.h"

typedef enum
{
    USER_GUEST,
    USER_REGISTERED_LOGGED_IN,
    USER_REGISTERED_LOGGED_OUT,
    USER_NUM,
} RegistrationLevel;

typedef enum
{
    REVIEW_LEVEL_NONE,
    REVIEW_LEVEL_DONT_ASK,
    REVIEW_LEVEL_COMPLETED
} ReviewLevel;

typedef enum
{
    SAVE_VALUE_NUM_PIZZA,
    SAVE_VALUE_POWERUP_FIRST,
    SAVE_VALUE_POWERUP_ROLLING_PIN = SAVE_VALUE_POWERUP_FIRST,
    SAVE_VALUE_POWERUP_ROLLING_PIN_PIZZAS,
    SAVE_VALUE_POWERUP_ROLLING_PIN_UNLOCK_STATE,
    SAVE_VALUE_POWERUP_ROLLING_PIN_UPGRADE_LEVEL,
    SAVE_VALUE_POWERUP_MARINARA,
    SAVE_VALUE_POWERUP_MARINARA_PIZZAS,
    SAVE_VALUE_POWERUP_MARINARA_UNLOCK_STATE,
    SAVE_VALUE_POWERUP_MARINARA_UPGRADE_LEVEL,
    SAVE_VALUE_POWERUP_COW_PASTURE,
    SAVE_VALUE_POWERUP_COW_PASTURE_PIZZAS,
    SAVE_VALUE_POWERUP_COW_PASTURE_UNLOCK_STATE,
    SAVE_VALUE_POWERUP_COW_PASTURE_UPGRADE_LEVEL,
    SAVE_VALUE_POWERUP_PIZZA_ATM,
    SAVE_VALUE_POWERUP_PIZZA_ATM_PIZZAS,
    SAVE_VALUE_POWERUP_PIZZA_ATM_UNLOCK_STATE,
    SAVE_VALUE_POWERUP_PIZZA_ATM_UPGRADE_LEVEL,
    SAVE_VALUE_POWERUP_PIZZA_PRINTER,
    SAVE_VALUE_POWERUP_PIZZA_PRINTER_PIZZAS,
    SAVE_VALUE_POWERUP_PIZZA_PRINTER_UNLOCK_STATE,
    SAVE_VALUE_POWERUP_PIZZA_PRINTER_UPGRADE_LEVEL,
    SAVE_VALUE_POWERUP_MOON_MINE,
    SAVE_VALUE_POWERUP_MOON_MINE_PIZZAS,
    SAVE_VALUE_POWERUP_MOON_MINE_UNLOCK_STATE,
    SAVE_VALUE_POWERUP_MOON_MINE_UPGRADE_LEVEL,
    SAVE_VALUE_POWERUP_LORD_PIZZA,
    SAVE_VALUE_POWERUP_LORD_PIZZA_PIZZAS,
    SAVE_VALUE_POWERUP_LORD_PIZZA_UNLOCK_STATE,
    SAVE_VALUE_POWERUP_LORD_PIZZA_UPGRADE_LEVEL,
    SAVE_VALUE_POWERUP_PIZZAMOGRIFIER,
    SAVE_VALUE_POWERUP_PIZZAMOGRIFIER_PIZZAS,
    SAVE_VALUE_POWERUP_PIZZAMOGRIFIER_UNLOCK_STATE,
    SAVE_VALUE_POWERUP_PIZZAMOGRIFIER_UPGRADE_LEVEL,
    SAVE_VALUE_POWERUP_LAST = SAVE_VALUE_POWERUP_PIZZAMOGRIFIER_UPGRADE_LEVEL,
    SAVE_VALUE_BOOSTER,
    SAVE_VALUE_NUM_LAUNCHES,
    SAVE_VALUE_NUM_MANUAL_ITEMS,
    SAVE_VALUE_RATED_GAME,
    SAVE_VALUE_CRYSTAL_ITEM_TUTORIAL,
    SAVE_VALUE_TIME_OF_FIRST_LAUNCH,
    SAVE_VALUE_NUM
} SaveValueIndex;

typedef struct
{
    double              mNumPizza;
    
	u32                     mNumRollingPin;
    double                  mNumRollingPinGeneratedPizzas;
    PizzaPowerupUnlockState mRollingPinUnlockState;
    u32                     mRollingPinUpgradeLevel;
    
    u32                     mNumMarinara;
    double                  mNumMarinaraGeneratedPizzas;
    PizzaPowerupUnlockState mMarinaraUnlockState;
    u32                     mMarinaraUpgradeLevel;
    
    u32                     mNumCowPasture;
    double                  mNumCowPastureGeneratedPizzas;
    PizzaPowerupUnlockState mCowPastureUnlockState;
    u32                     mCowPastureUpgradeLevel;
    
    u32                     mNumPizzaATM;
    double                  mNumPizzaATMGeneratedPizzas;
    PizzaPowerupUnlockState mPizzaATMUnlockState;
    u32                     mPizzaATMUpgradeLevel;
    
    u32                     mNumPizzaPrinter;
    double                  mNumPizzaPrinterGeneratedPizzas;
    PizzaPowerupUnlockState mPizzaPrinterUnlockState;
    u32                     mPizzaPrinterUpgradeLevel;
    
    u32                     mNumMoonMine;
    double                  mNumMoonMineGeneratedPizzas;
    PizzaPowerupUnlockState mMoonMineUnlockState;
    u32                     mMoonMineUpgradeLevel;
    
    u32                     mNumLordPizza;
    double                  mNumLordPizzaGeneratedPizzas;
    PizzaPowerupUnlockState mLordPizzaUnlockState;
    u32                     mLordPizzaUpgradeLevel;
    
    u32                     mNumPizzamogrifier;
    double                  mNumPizzamogrifierGeneratedPizzas;
    PizzaPowerupUnlockState mPizzamogrifierUnlockState;
    u32                     mPizzamogrifierUpgradeLevel;
    
    BOOL                mBooster;
    u32                 mNumLaunches;
    u32                 mNumManualItems;
    
    u32                 mRatedGame;
    
    u32                 mCrystalItemTutorial;
    
    double              mTimeOfFirstLaunch;
    
    u32                 mVaultLevel;
} SaveValues;

typedef enum
{
    SAVESYSTEM_STATE_IDLE,
    SAVESYSTEM_STATE_WAITING_TO_SYNC
} SaveSystemState;

@interface SaveSystem : NSObject<DebugMenuCallback, MessageChannelListener>
{
    SaveValues          mSaveValues;
    BOOL                mDebugItemRegistered;
    CFTimeInterval      mLastSynchronizeTime;
    SaveSystemState     mState;
    
    dispatch_queue_t    mQueue;
    NSLock*             mLock;
}

-(SaveSystem*)Init;
-(void)dealloc;

+(void)CreateInstance;
+(void)DestroyInstance;
+(SaveSystem*)GetInstance;

-(void)Update:(CFTimeInterval)inTimeStep;
-(void)ProcessMessage:(Message*)inMessage;

-(void)InitializeDefaultValues;
-(void)ParseSaveFile;

-(void)WriteEntry:(int)inIndex;
-(void)WriteEntry:(int)inIndex withOffset:(int)inOffset numEntries:(int)numEntries;
-(void)LoadEntryFromObject:(id)inObject withIndex:(int)inIndex;

-(SaveValues*)GetSaveValues;

-(double)GetNumPizza;
-(void)SetNumPizza:(double)inNumPizza;

-(void)SetNumPowerup:(PizzaPowerup)inPowerup numPowerup:(int)inNumPowerup;
-(int)GetNumPowerup:(PizzaPowerup)inPowerup;
-(void)SetNumPowerupGeneratedPizzas:(PizzaPowerup)inPizzaPowerup numPizzas:(double)inNumPizzas;
-(double)GetNumPowerupGeneratedPizzas:(PizzaPowerup)inPizzaPowerup;

-(PizzaPowerupUnlockState)GetPowerupUnlockState:(PizzaPowerup)inPowerup;
-(void)SetPowerupUnlockState:(PizzaPowerup)inPowerup state:(PizzaPowerupUnlockState)inState;

-(int)GetUpgradeLevelForPowerup:(PizzaPowerup)inPowerup;
-(void)SetUpgradeLevelForPowerup:(PizzaPowerup)inPowerup level:(int)inLevel;

-(BOOL)GetBooster;
-(void)SetBooster:(NSNumber*)inBooster;

-(void)SetRatedGame:(ReviewLevel)inRatedGame;
-(ReviewLevel)GetRatedGame;

-(void)DebugMenuItemPressed:(NSString*)inName;

-(void)SetNumLaunches:(u32)inNumLaunches;
-(u32)GetNumLaunches;

-(void)SetNumManualItems:(u32)inNumManualItems;
-(u32)GetNumManualItems;

-(int)GetCrystalItemTutorial;
-(void)SetCrystalItemTutorial:(BOOL)inCrystalItemTutorial;

-(CFTimeInterval)GetTimeOfFirstLaunch;

-(void)SetVaultLevel:(u32)inVaultLevel;
-(u32)GetVaultLevel;

@end

