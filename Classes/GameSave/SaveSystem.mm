//
//  SaveSystem.m
//  Neon21
//
//  Copyright Neon Games 2010. All rights reserved.
//

#import "SaveSystem.h"
#import "LevelDefinitions.h"
#import "Event.h"

// Instructions for adding a new field in the save file
//
// 1) Add the variable you want to save out in the SaveValues structure (see SaveSystem.h)
// 2) Initialize it InitializeDefaultValues
// 3) Add an accessor / setter for it.  Pattern it off the existing ones
// 4) Add an entry for it in the sSaveEntries table below.  The fields are pretty self explanatory, but are described below in more detail
// 5) Add an entry in the SaveValueIndex enum below

static SaveSystem* sInstance = NULL;

typedef enum
{
    SAVE_VALUE_TYPE_INTEGER,        // A single integer
    SAVE_VALUE_TYPE_LONG_INTEGER,   // 64 bit integer
    SAVE_VALUE_TYPE_DATA,           // Data of a specified length.  This is fixed and can never be changed without breaking compatbility
    SAVE_VALUE_TYPE_BOOL,
    SAVE_VALUE_TYPE_DOUBLE,
    SAVE_VALUE_TYPE_STRING,
} SaveValueType;

typedef struct
{
    u32             mOffset;        // Offset into the SaveValues structure that this value is stored
    const char*     mKey;           // What key is used to access this
    SaveValueType   mType;          // Data type
    u32             mSize;          // Size of the data
    const char*     mParseColumn;   // If this is mirrored on Parse, then this is the column that we'll write out.
} SaveEntry;

static const char* IAP_PARSE_COLUMN_NAMES[IAP_PRODUCT_NUM + 1] = { NULL };

// Limit synchronize to every 10 seconds
static const float MIN_SYNCHRONIZE_INTERVAL = 10;

// Note: Please prepend "Neon" to all keys to distinguish them from all other keys.
static SaveEntry    sSaveEntries[SAVE_VALUE_NUM] = {
        { offsetof(SaveValues, mNumPizza),                          "NeonPowerupPizza",                 SAVE_VALUE_TYPE_DOUBLE,  sizeof(double),    NULL    },
        // Golden Rolling Pin
        { offsetof(SaveValues, mNumRollingPin),                     "NeonPowerupRollingPin",            SAVE_VALUE_TYPE_INTEGER, sizeof(u32),       NULL    },
        { offsetof(SaveValues, mNumRollingPinGeneratedPizzas),      "NeonPowerupRollingPinPizzas",      SAVE_VALUE_TYPE_DOUBLE,  sizeof(double),    NULL    },
        { offsetof(SaveValues, mRollingPinUnlockState),             "NeonPowerupRollingPinUnlock",      SAVE_VALUE_TYPE_INTEGER, sizeof(u32),       NULL    },
        { offsetof(SaveValues, mRollingPinUpgradeLevel),            "NeonPowerupRollingPinUpgradeLevel", SAVE_VALUE_TYPE_INTEGER, sizeof(u32),       NULL    },
        // Marinara Rig
        { offsetof(SaveValues, mNumMarinara),                       "NeonPowerupMarinara",              SAVE_VALUE_TYPE_INTEGER, sizeof(u32),       NULL    },
        { offsetof(SaveValues, mNumMarinaraGeneratedPizzas),        "NeonPowerupMarinaraPizzas",        SAVE_VALUE_TYPE_DOUBLE,  sizeof(double),    NULL    },
        { offsetof(SaveValues, mMarinaraUnlockState),               "NeonPowerupMarinaraUnlock",        SAVE_VALUE_TYPE_INTEGER, sizeof(u32),       NULL    },
        { offsetof(SaveValues, mMarinaraUpgradeLevel),              "NeonPowerupMarinaraUpgradeLevel",  SAVE_VALUE_TYPE_INTEGER, sizeof(u32),       NULL    },
        // Cow Pasture
        { offsetof(SaveValues, mNumCowPasture),                     "NeonPowerupCowPasture",            SAVE_VALUE_TYPE_INTEGER, sizeof(u32),       NULL    },
        { offsetof(SaveValues, mNumCowPastureGeneratedPizzas),      "NeonPowerupCowPasturePizzas",      SAVE_VALUE_TYPE_DOUBLE,  sizeof(double),    NULL    },
        { offsetof(SaveValues, mCowPastureUnlockState),             "NeonPowerupCowPastureUnlock",      SAVE_VALUE_TYPE_INTEGER, sizeof(u32),       NULL    },
        { offsetof(SaveValues, mCowPastureUpgradeLevel),            "NeonPowerupCowPastureUpgrade",     SAVE_VALUE_TYPE_INTEGER, sizeof(u32),       NULL    },
        // Pizza ATM
        { offsetof(SaveValues, mNumPizzaATM),                       "NeonPowerupPizzaATM",              SAVE_VALUE_TYPE_INTEGER, sizeof(u32),       NULL    },
        { offsetof(SaveValues, mNumPizzaATMGeneratedPizzas),        "NeonPowerupPizzaATMPizzas",        SAVE_VALUE_TYPE_DOUBLE,  sizeof(double),    NULL    },
        { offsetof(SaveValues, mPizzaATMUnlockState),               "NeonPowerupPizzaATMUnlock",        SAVE_VALUE_TYPE_INTEGER, sizeof(u32),       NULL    },
        { offsetof(SaveValues, mPizzaATMUpgradeLevel),              "NeonPowerupPizzaATMUpgrade",       SAVE_VALUE_TYPE_INTEGER, sizeof(u32),       NULL    },
        // Pizza Printer
        { offsetof(SaveValues, mNumPizzaPrinter),                   "NeonPowerupPizzaPrinter",          SAVE_VALUE_TYPE_INTEGER, sizeof(u32),       NULL    },
        { offsetof(SaveValues, mNumPizzaPrinterGeneratedPizzas),    "NeonPowerupPizzaPrinterPizzas",    SAVE_VALUE_TYPE_DOUBLE,  sizeof(double),    NULL    },
        { offsetof(SaveValues, mPizzaPrinterUnlockState),           "NeonPowerupPizzaPrinterUnlock",    SAVE_VALUE_TYPE_INTEGER, sizeof(u32),       NULL    },
        { offsetof(SaveValues, mPizzaPrinterUpgradeLevel),          "NeonPowerupPizzaPrinterUpgrade",   SAVE_VALUE_TYPE_INTEGER, sizeof(u32),       NULL    },
        // Moon Mine
        { offsetof(SaveValues, mNumMoonMine),                       "NeonPowerupMoonMine",              SAVE_VALUE_TYPE_INTEGER, sizeof(u32),       NULL    },
        { offsetof(SaveValues, mNumMoonMineGeneratedPizzas),        "NeonPowerupMoonMinePizzas",        SAVE_VALUE_TYPE_DOUBLE,  sizeof(double),    NULL    },
        { offsetof(SaveValues, mMoonMineUnlockState),               "NeonPowerupMoonMineUnlock",        SAVE_VALUE_TYPE_INTEGER, sizeof(u32),       NULL    },
        { offsetof(SaveValues, mMoonMineUpgradeLevel),              "NeonPowerupMoonMineUpgrade",       SAVE_VALUE_TYPE_INTEGER, sizeof(u32),       NULL    },
        // Pepperonium Accelerator
        { offsetof(SaveValues, mNumLordPizza),                      "NeonPowerupLordPizza",             SAVE_VALUE_TYPE_INTEGER, sizeof(u32),       NULL    },
        { offsetof(SaveValues, mNumLordPizzaGeneratedPizzas),       "NeonPowerupLordPizzaPizzas",       SAVE_VALUE_TYPE_DOUBLE,  sizeof(double),    NULL    },
        { offsetof(SaveValues, mLordPizzaUnlockState),              "NeonPowerupLordPizzaUnlock",       SAVE_VALUE_TYPE_INTEGER, sizeof(u32),       NULL    },
        { offsetof(SaveValues, mLordPizzaUpgradeLevel),             "NeonPowerupLordPizzaUpgrade",      SAVE_VALUE_TYPE_INTEGER, sizeof(u32),       NULL    },
        // Pizzamogrifier
        { offsetof(SaveValues, mNumPizzamogrifier),                 "NeonPowerupPizzamogrifier",        SAVE_VALUE_TYPE_INTEGER, sizeof(u32),       NULL    },
        { offsetof(SaveValues, mNumPizzamogrifierGeneratedPizzas),  "NeonPowerupPizzamogrifierPizzas",  SAVE_VALUE_TYPE_DOUBLE,  sizeof(double),    NULL    },
        { offsetof(SaveValues, mPizzamogrifierUnlockState),         "NeonPowerupPizzamogrifierUnlock",  SAVE_VALUE_TYPE_INTEGER, sizeof(u32),       NULL    },
        { offsetof(SaveValues, mPizzamogrifierUpgradeLevel),        "NeonPowerupPizzamogrifierUpgrade", SAVE_VALUE_TYPE_INTEGER, sizeof(u32),       NULL    },
    
        { offsetof(SaveValues, mBooster),                           "NeonBooster",                      SAVE_VALUE_TYPE_INTEGER, sizeof(u32),       NULL    },
        { offsetof(SaveValues, mNumLaunches),                       "NeonNumLaunches",                  SAVE_VALUE_TYPE_INTEGER, sizeof(u32),       NULL    },
        { offsetof(SaveValues, mNumManualItems),                    "NeonNumManualItems",               SAVE_VALUE_TYPE_INTEGER, sizeof(u32),       NULL    },
        { offsetof(SaveValues, mRatedGame),                         "NeonRatedGame",                    SAVE_VALUE_TYPE_INTEGER, sizeof(u32),       NULL    },
        { offsetof(SaveValues, mCrystalItemTutorial),               "NeonCrystalItemTutorial",          SAVE_VALUE_TYPE_INTEGER, sizeof(u32),       NULL    },
        { offsetof(SaveValues, mTimeOfFirstLaunch),                 "NeonTimeOfFirstLaunch",            SAVE_VALUE_TYPE_DOUBLE,  sizeof(double),    NULL    },
    };

@interface SaveSystem(Private)

-(int)GetPowerupBaseIndex:(PizzaPowerup)inPowerup;
-(int)GetPowerupUnlockIndex:(PizzaPowerup)inPowerup;
-(int)GetPowerupUpgradeIndex:(PizzaPowerup)inPowerup;

-(SaveEntry*)GetSaveEntryForPowerupUnlock:(PizzaPowerup)inPowerup;

@end

@implementation SaveSystem

-(SaveSystem*)Init
{
    mQueue = dispatch_queue_create("com.neongames.savesystem", NULL);

//#if IAP_DEVELOPER_MODE
    //[self LoadDeveloperSave];
//#else
    [self InitializeDefaultValues];
    [self ParseSaveFile];
//#endif

    mLastSynchronizeTime = CACurrentMediaTime();
    mDebugItemRegistered = FALSE;
    mLock = [[NSLock alloc] init];
    mState = SAVESYSTEM_STATE_IDLE;
    
    u32 numLaunches = [self GetNumLaunches];
    [self SetNumLaunches:(numLaunches + 1)];
    
    [GetGlobalMessageChannel() AddListener:self];
    
    return self;
}

-(void)dealloc
{
    dispatch_release(mQueue);
    [mLock release];
    
    [[DebugManager GetInstance] UnregisterDebugMenuItem:@"Clear Powerups"];
    [super dealloc];
}

+(void)CreateInstance
{
    NSAssert(sInstance == NULL, @"Attempting to create SaveSystem a second time");
    sInstance = [(SaveSystem*)[SaveSystem alloc] Init];
}

+(void)DestroyInstance
{
    NSAssert(sInstance != NULL, @"Attempting to destroy SaveSystem when it has not yet been created");
    
    [sInstance release];
    sInstance = NULL;
}

+(SaveSystem*)GetInstance
{
    return sInstance;
}

-(void)Update:(CFTimeInterval)inTimeStep
{
    if (!mDebugItemRegistered)
    {
        mDebugItemRegistered = TRUE;
        
        [[DebugManager GetInstance] RegisterDebugMenuItem:@"Clear Powerups" WithCallback:self];
    }
}

-(void)ProcessMessage:(Message*)inMessage
{
    switch(inMessage->mId)
    {
        case EVENT_APPLICATION_SUSPENDED:
        case EVENT_APPLICATION_WILL_TERMINATE:
        {
            NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
            [defaults synchronize];
            break;
        }
        
        case EVENT_APPLICATION_RESUMED:
        {
            u32 numLaunches = [self GetNumLaunches];
            [self SetNumLaunches:(numLaunches + 1)];
            break;
        }
    }
}

-(void)InitializeDefaultValues
{
    mSaveValues.mNumPizza = START_ITEMS;
    
    mSaveValues.mNumRollingPin = 0;
    mSaveValues.mNumRollingPinGeneratedPizzas = 0;
    mSaveValues.mRollingPinUnlockState = PIZZA_POWERUP_UNLOCKED;
    mSaveValues.mRollingPinUpgradeLevel = 0;
    
    mSaveValues.mNumMarinara = 0;
    mSaveValues.mNumMarinaraGeneratedPizzas = 0;
    mSaveValues.mMarinaraUnlockState = PIZZA_POWERUP_QUESTION;
    mSaveValues.mMarinaraUpgradeLevel = 0;
    
    mSaveValues.mNumCowPasture = 0;
    mSaveValues.mNumCowPastureGeneratedPizzas = 0;
    mSaveValues.mCowPastureUnlockState = PIZZA_POWERUP_INVISIBLE;
    mSaveValues.mCowPastureUpgradeLevel = 0;
    
    mSaveValues.mNumPizzaATM = 0;
    mSaveValues.mNumPizzaATMGeneratedPizzas = 0;
    mSaveValues.mPizzaATMUnlockState = PIZZA_POWERUP_INVISIBLE;
    mSaveValues.mPizzaATMUpgradeLevel = 0;
    
    mSaveValues.mNumPizzaPrinter = 0;
    mSaveValues.mNumPizzaPrinterGeneratedPizzas = 0;
    mSaveValues.mPizzaPrinterUnlockState = PIZZA_POWERUP_INVISIBLE;
    mSaveValues.mPizzaPrinterUpgradeLevel = 0;
    
    mSaveValues.mNumMoonMine = 0;
    mSaveValues.mNumMoonMineGeneratedPizzas = 0;
    mSaveValues.mMoonMineUnlockState = PIZZA_POWERUP_INVISIBLE;
    mSaveValues.mMoonMineUpgradeLevel = 0;
    
    mSaveValues.mNumLordPizza = 0;
    mSaveValues.mNumLordPizzaGeneratedPizzas = 0;
    mSaveValues.mLordPizzaUnlockState = PIZZA_POWERUP_INVISIBLE;
    mSaveValues.mLordPizzaUpgradeLevel = 0;
    
    mSaveValues.mNumPizzamogrifier = 0;
    mSaveValues.mNumPizzamogrifierGeneratedPizzas = 0;
    mSaveValues.mPizzamogrifierUnlockState = PIZZA_POWERUP_INVISIBLE;
    mSaveValues.mPizzamogrifierUpgradeLevel = 0;
    
    mSaveValues.mBooster = FALSE;
    mSaveValues.mNumLaunches = 0;
    mSaveValues.mNumManualItems = 0;
    mSaveValues.mRatedGame = FALSE;
    mSaveValues.mCrystalItemTutorial = FALSE;
    
    NSDate* curDate = [[NSDate alloc] init];
    mSaveValues.mTimeOfFirstLaunch = (double)[curDate timeIntervalSince1970];
    [curDate release];
}

-(void)ParseSaveFile
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    for (int i = 0; i < SAVE_VALUE_NUM; i++)
    {
        id obj = [defaults objectForKey:[NSString stringWithUTF8String:sSaveEntries[i].mKey]];
        
        if (obj == NULL)
        {
            [self WriteEntry:i];
        }
        else
        {
            [self LoadEntryFromObject:obj withIndex:i];
        }
    }
}

-(void)WriteEntry:(int)inIndex
{
    [self WriteEntry:inIndex withOffset:0 numEntries:0];
}

-(void)WriteEntry:(int)inIndex withOffset:(int)inOffset numEntries:(int)numEntries
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];

    SaveEntry* saveEntryInfo = &sSaveEntries[inIndex];
    
    NSObject* writeObj = NULL;
    
    char* dataLocation = ((char*)&mSaveValues) + saveEntryInfo->mOffset;
    
    NSAssert((inOffset == 0) || (saveEntryInfo->mType == SAVE_VALUE_TYPE_DATA), @"Can't specify a save entry offset, unless the save value type is data");

    switch(saveEntryInfo->mType)
    {
        case SAVE_VALUE_TYPE_INTEGER:
        {
            int intVal = *(int*)dataLocation;
            [defaults setInteger:intVal forKey:[NSString stringWithUTF8String:saveEntryInfo->mKey]];

            writeObj = [NSNumber numberWithInt:intVal];
            break;
        }
        
        case SAVE_VALUE_TYPE_LONG_INTEGER:
        {
            writeObj = [NSData dataWithBytes:dataLocation length:sizeof(u64)];
            [defaults setObject:writeObj forKey:[NSString stringWithUTF8String:saveEntryInfo->mKey]];
            break;
        }
        
        case SAVE_VALUE_TYPE_DATA:
        {
            writeObj = [NSData dataWithBytes:dataLocation length:saveEntryInfo->mSize];
            [defaults setObject:writeObj forKey:[NSString stringWithUTF8String:saveEntryInfo->mKey]];
            break;
        }
        
        case SAVE_VALUE_TYPE_BOOL:
        {
            BOOL boolVal = *(BOOL*)(dataLocation);
            [defaults setBool:boolVal forKey:[NSString stringWithUTF8String:saveEntryInfo->mKey]];
            
            writeObj = [NSNumber numberWithBool:boolVal];
            break;
        }
            
        case SAVE_VALUE_TYPE_DOUBLE:
        {
            double dblVal = *(double*)dataLocation;
            [defaults setDouble:dblVal forKey:[NSString stringWithUTF8String:saveEntryInfo->mKey]];
            
            writeObj = [NSNumber numberWithDouble:dblVal];
            break;
        }
        
        case SAVE_VALUE_TYPE_STRING:
        {
            NSString* string = *(NSString**)dataLocation;
            [defaults setObject:string forKey:[NSString stringWithUTF8String:saveEntryInfo->mKey]];
            
            writeObj = string;
            break;
        }
        
        default:
        {
            NSAssert(FALSE, @"Unknown data type");
        }
    }
    
    [mLock lock];
    
    if (mState == SAVESYSTEM_STATE_IDLE)
    {
        mState = SAVESYSTEM_STATE_WAITING_TO_SYNC;
        
        CFTimeInterval delta = CACurrentMediaTime() - mLastSynchronizeTime;
        
        dispatch_block_t saveBlock = ^
            {
                [defaults synchronize];
                
                [mLock lock];
                mState = SAVESYSTEM_STATE_IDLE;
                [mLock unlock];
            };

        if (delta < MIN_SYNCHRONIZE_INTERVAL)
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delta * NSEC_PER_SEC), mQueue, saveBlock);
        }
        else
        {
            dispatch_async(mQueue, saveBlock);
        }
        
        mLastSynchronizeTime = CACurrentMediaTime();
    }
    
    [mLock unlock];
}

-(void)LoadEntryFromObject:(id)inObject withIndex:(int)inIndex
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];

    SaveEntry* saveEntryInfo = &sSaveEntries[inIndex];
    
    char* dataLocation = ((char*)&mSaveValues) + saveEntryInfo->mOffset;
        
    switch(saveEntryInfo->mType)
    {
        case SAVE_VALUE_TYPE_INTEGER:
        {
            NSInteger integer = [defaults integerForKey:[NSString stringWithUTF8String:saveEntryInfo->mKey]];
            int intVal = (int)integer;
            
            *(int*)dataLocation = intVal;
            
            break;
        }
        
        case SAVE_VALUE_TYPE_DATA:
        case SAVE_VALUE_TYPE_LONG_INTEGER:
        {
            NSData* data = [defaults dataForKey:[NSString stringWithUTF8String:saveEntryInfo->mKey]];
            NSAssert([data length] == saveEntryInfo->mSize, @"Difference between received and expected size");
            
            memcpy(dataLocation, [data bytes], saveEntryInfo->mSize);
            break;
        }
        
        case SAVE_VALUE_TYPE_BOOL:
        {
            BOOL boolVal = [defaults boolForKey:[NSString stringWithUTF8String:saveEntryInfo->mKey]];
            *(BOOL*)dataLocation = boolVal;
            
            break;
        }
            
        case SAVE_VALUE_TYPE_DOUBLE:
        {
            double dblVal = [defaults doubleForKey:[NSString stringWithUTF8String:saveEntryInfo->mKey]];
            *(double*)dataLocation = dblVal;
            
            break;
        }
        
        case SAVE_VALUE_TYPE_STRING:
        {
            NSString* string = [defaults stringForKey:[NSString stringWithUTF8String:saveEntryInfo->mKey]];
            *(NSString**)dataLocation = string;
            [string retain];
            
            break;
        }
        
        default:
        {
            NSAssert(FALSE, @"Unknown data type");
        }
    }
}

-(SaveValues*)GetSaveValues
{
    return &mSaveValues;
}

-(void)Reset
{
    NSAssert(FALSE, @"Currently unimplemented");
}

// Debug values for development
-(void)LoadDeveloperSave
{
    NSAssert( IAP_DEVELOPER_MODE, @"Cannot Load Developer Save while not in IAP_DEVELOPER_MODE");
    NSAssert(FALSE, @"Haven't implemented this for PizzaSpinner");
    
    // Uncomment this to oblitierate any user defaults and save data to test fresh installs, or remove debug entries.
    // Or open Simulator -> iOS Simulator ( Top left menu ) -> Reset Content and Settings.
    /*
     NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
     [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
     */
    
    for ( u32 i = 0 ; i < SAVE_VALUE_NUM ; i++ )
    {
        [self WriteEntry:i];
    }
}

-(double)GetNumPizza
{
    return mSaveValues.mNumPizza;
}

-(void)SetNumPizza:(double)inNumPizza
{
    mSaveValues.mNumPizza = inNumPizza;
    
    [self WriteEntry:SAVE_VALUE_NUM_PIZZA];
}

-(void)SetNumPowerup:(PizzaPowerup)inPowerup numPowerup:(int)inNumPowerup
{
    int baseIndex = [self GetPowerupBaseIndex:inPowerup];
    
    SaveEntry* upgradeEntry = &sSaveEntries[baseIndex];
    int* numPowerup = (int*)((u8*)&mSaveValues + upgradeEntry->mOffset);

    *numPowerup = inNumPowerup;
    
    [self WriteEntry:baseIndex];
}

-(int)GetNumPowerup:(PizzaPowerup)inPowerup
{
    int baseIndex = [self GetPowerupBaseIndex:inPowerup];
    
    SaveEntry* upgradeEntry = &sSaveEntries[baseIndex];
    int* numPowerup = (int*)((u8*)&mSaveValues + upgradeEntry->mOffset);

    return *numPowerup;
}

-(void)SetNumPowerupGeneratedPizzas:(PizzaPowerup)inPizzaPowerup numPizzas:(double)inNumPizzas
{
    int index = [self GetPowerupBaseIndex:inPizzaPowerup] + 1;
    
    SaveEntry* generateEntry = &sSaveEntries[index];
    double* numPizzas = (double*)((u8*)&mSaveValues + generateEntry->mOffset);

    *numPizzas = inNumPizzas;
    
    [self WriteEntry:index];
}

-(double)GetNumPowerupGeneratedPizzas:(PizzaPowerup)inPizzaPowerup;
{
    int index = [self GetPowerupBaseIndex:inPizzaPowerup] + 1;
    
    SaveEntry* generateEntry = &sSaveEntries[index];
    double* numPizzas = (double*)((u8*)&mSaveValues + generateEntry->mOffset);

    return *numPizzas;
}

-(int)GetPowerupBaseIndex:(PizzaPowerup)inPowerup
{
    NSAssert(inPowerup >= PIZZA_POWERUP_FIRST && inPowerup < PIZZA_POWERUP_NUM, @"Invalid powerup");
    
    int numPowerupSaveValues = SAVE_VALUE_POWERUP_LAST - SAVE_VALUE_POWERUP_FIRST + 1;
    NSAssert( ((numPowerupSaveValues % PIZZA_POWERUP_NUM) == 0), @"There should be an even multiple of powerup save entries and powerups" );
    
    int numSaveValuesPerPowerup = numPowerupSaveValues / PIZZA_POWERUP_NUM;
    return SAVE_VALUE_POWERUP_FIRST + (numSaveValuesPerPowerup * inPowerup);
}

-(int)GetPowerupUnlockIndex:(PizzaPowerup)inPowerup
{
    return [self GetPowerupBaseIndex:inPowerup] + 2;
}

-(int)GetPowerupUpgradeIndex:(PizzaPowerup)inPowerup
{
    return [self GetPowerupBaseIndex:inPowerup] + 3;
}

-(SaveEntry*)GetSaveEntryForPowerupUnlock:(PizzaPowerup)inPowerup
{
    int powerupUnlockIndex = [self GetPowerupUnlockIndex:inPowerup];
    return &sSaveEntries[powerupUnlockIndex];
}

-(PizzaPowerupUnlockState)GetPowerupUnlockState:(PizzaPowerup)inPowerup
{
    SaveEntry* saveEntry = [self GetSaveEntryForPowerupUnlock:inPowerup];
    PizzaPowerupUnlockState* powerupUnlockState = (PizzaPowerupUnlockState*)((u8*)&mSaveValues + saveEntry->mOffset);
    return *powerupUnlockState;
}

-(void)SetPowerupUnlockState:(PizzaPowerup)inPowerup state:(PizzaPowerupUnlockState)inState
{
    SaveEntry* saveEntry = [self GetSaveEntryForPowerupUnlock:inPowerup];
    PizzaPowerupUnlockState* powerupUnlockState = (PizzaPowerupUnlockState*)((u8*)&mSaveValues + saveEntry->mOffset);
    *powerupUnlockState = inState;
    
    [self WriteEntry:[self GetPowerupUnlockIndex:inPowerup]];
}

-(int)GetUpgradeLevelForPowerup:(PizzaPowerup)inPowerup
{
    SaveEntry* upgradeEntry = &sSaveEntries[[self GetPowerupUpgradeIndex:inPowerup]];
    int* upgradeLevel = (int*)((u8*)&mSaveValues + upgradeEntry->mOffset);

    return *upgradeLevel;
}

-(void)SetUpgradeLevelForPowerup:(PizzaPowerup)inPowerup level:(int)inLevel
{
    SaveEntry* upgradeEntry = &sSaveEntries[[self GetPowerupUpgradeIndex:inPowerup]];
    int* upgradeLevel = (int*)((u8*)&mSaveValues + upgradeEntry->mOffset);

    *upgradeLevel = inLevel;
    
    [self WriteEntry:[self GetPowerupUpgradeIndex:inPowerup]];
}

-(BOOL)GetBooster
{
#if IAP_BYPASS_MANAGER
    return TRUE;
#endif
    return mSaveValues.mBooster;
}

-(void)SetBooster:(NSNumber*)inBooster
{
    mSaveValues.mBooster = [inBooster intValue];
    
    [self WriteEntry:SAVE_VALUE_BOOSTER];
}

-(void)SetRatedGame:(ReviewLevel)inRatedGame
{
    mSaveValues.mRatedGame = inRatedGame;
    
    [self WriteEntry:SAVE_VALUE_RATED_GAME];
}

-(ReviewLevel)GetRatedGame
{
    return (ReviewLevel)mSaveValues.mRatedGame;
}

-(void)DebugMenuItemPressed:(NSString*)inName
{
}

-(void)SetNumLaunches:(u32)inNumLaunches
{
    mSaveValues.mNumLaunches = inNumLaunches;
    
    [self WriteEntry:SAVE_VALUE_NUM_LAUNCHES];
}

-(u32)GetNumLaunches
{
    return mSaveValues.mNumLaunches;
}

-(void)SetNumManualItems:(u32)inNumManualItems
{
    mSaveValues.mNumManualItems = inNumManualItems;
    
    [self WriteEntry:SAVE_VALUE_NUM_MANUAL_ITEMS];
}

-(u32)GetNumManualItems
{
    return mSaveValues.mNumManualItems;
}

-(int)GetCrystalItemTutorial
{
    return mSaveValues.mCrystalItemTutorial;
}

-(void)SetCrystalItemTutorial:(BOOL)inCrystalItemTutorial
{
    mSaveValues.mCrystalItemTutorial = inCrystalItemTutorial;
    
    [self WriteEntry:SAVE_VALUE_CRYSTAL_ITEM_TUTORIAL];
}

-(CFTimeInterval)GetTimeOfFirstLaunch
{
    return mSaveValues.mTimeOfFirstLaunch;
}

-(void)SetVaultLevel:(u32)inVaultLevel
{
    mSaveValues.mVaultLevel = inVaultLevel;
    
    
}

-(u32)GetVaultLevel
{
    return mSaveValues.mVaultLevel;
}

@end
