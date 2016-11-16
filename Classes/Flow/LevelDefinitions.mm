//
//  LevelDefinitions.m
//  Neon21
//
//  Copyright Neon Games 2013. All rights reserved.
//

#import "LevelDefinitions.h"
#import "TutorialScript.h"
#import "SplitTestingSystem.h"
#import "SaveSystem.h"

static const char* MUSIC_BG_MAINMENU				= "BG_MainMenu.mp3";
static const char* MUSIC_BG_ICHACHING				= "BG_IChaChing.m4a";
static const char* MUSIC_BG_FJORDKNOX				= "BG_FjordKnox.m4a";
static const char* MUSIC_BG_GUMMYSLOTS				= "BG_GummySlots.m4a";

#define NUM_SKYBOXES							(6)

static const char* SKYBOX_GUMMYSLOTS[NUM_SKYBOXES]	= {    "gummyslots_plus_x.pvrtc",	"gummyslots_minus_x.pvrtc", NULL, "gummyslots_minus_y.pvrtc",	"gummyslots_plus_z.pvrtc",	"gummyslots_minus_z.pvrtc"   };
static const char* SKYBOX_ICHACHING[NUM_SKYBOXES]	= {    "ichaching_plus_x.pvrtc",	"ichaching_minus_x.pvrtc",	NULL, "ichaching_minus_y.pvrtc",	"ichaching_plus_z.pvrtc",	"ichaching_minus_z.pvrtc"    };
static const char* SKYBOX_FJORDKNOX[NUM_SKYBOXES]	= {    "fjordknox_plus_x.pvrtc",	"fjordknox_minus_x.pvrtc",	NULL, "fjordknox_minus_y.pvrtc",	"fjordknox_plus_z.pvrtc",	"fjordknox_minus_z.pvrtc"    };

static const char* MINIGAME_UV_RUN21				= "Run21.pvrtc";

#if NEON_SOLITAIRE_21
static const char* LCD_RUN21_ACTIVE					= "Solitaire21_LCD_Active.pvrtc";
static const char* LCD_RUN21_INACTIVE               = "Solitaire21_LCD_Inactive.pvrtc";
#else
static const char* LCD_RUN21_ACTIVE					= "Run21_LCD_Active.pvrtc";
static const char* LCD_RUN21_INACTIVE				= "Run21_LCD_Inactive.pvrtc";
#endif

static const char* LCD_RUN21_BLANK					= "Run21_LCD_Blank.pvrtc"	;
static const char* LCD_RUN21_TABLET                 = "Run21_Tablet_Blank.pvrtc";

LevelInfo*  sLevelInfo[WATERBALLOON_TOSS_LEVEL_NUM];

@implementation LevelInfo

@synthesize CasinoID = mCasinoID;
@synthesize Clubs = mClubs;
@synthesize Spades = mSpades;
@synthesize Diamonds = mDiamonds;
@synthesize Hearts = mHearts;
@synthesize NumDecks = mNumDecks;
@synthesize NumCards = mNumCards;
@synthesize NumJokers = mNumJokers;
@synthesize PrioritizeHighCards = mPrioritizeHighCards;
@synthesize AddClubs = mAddClubs;
@synthesize JokersAvailable = mJokersAvailable;
@synthesize XrayAvailable = mXrayAvailable;
@synthesize TornadoAvailable = mTornadoAvailable;
@synthesize NumRunners = mNumRunners;
@synthesize XraysGranted = mXraysGranted;
@synthesize TornadoesGranted = mTornadoesGranted;
@synthesize TimeLimitSeconds = mTimeLimitSeconds;

-(LevelInfo*)init
{
    mCasinoID = CasinoID_GummySlots;
    
    mClubs = FALSE;
    mSpades = FALSE;
    mDiamonds = FALSE;
    mHearts = FALSE;
    
    mNumDecks = 1;
    mNumCards = 0;
    mNumJokers = 2;
    
    mPrioritizeHighCards = FALSE;
    
    mAddClubs = FALSE;
    mJokersAvailable = TRUE;
    mXrayAvailable = TRUE;
    mTornadoAvailable = TRUE;
    
    mNumRunners = 4;
    mXraysGranted = 0;
    mTornadoesGranted = 0;
    
    mTimeLimitSeconds = 0;
    
    return self;
}

@end


@implementation LevelDefinitions

-(LevelDefinitions*)Init
{
    mTutorialScript = NULL;
    
    for (int level = 0; level < WATERBALLOON_TOSS_LEVEL_NUM; level++)
    {
        LevelInfo* curLevel = [[LevelInfo alloc] init];
        sLevelInfo[level] = curLevel;
    }
    
    return self;
}

-(void)dealloc
{
    for (int level = 0; level < WATERBALLOON_TOSS_LEVEL_NUM; level++)
    {
        [sLevelInfo[level] release];
    }
    
    [mTutorialScript release];
    [super dealloc];
}

-(void)StartLevel
{
    GameModeType gameMode = [[Flow GetInstance] GetGameMode];
    int level = [[Flow GetInstance] GetLevel];
    
    if (mTutorialScript != NULL)
    {
        [mTutorialScript release];
        mTutorialScript = NULL;
    }
    
    switch(gameMode)
    {
        case GAMEMODE_TYPE_WATERBALLOON_TOSS:
        {
            switch(level)
            {
                default:
                {
                    [mTutorialScript release];
                    mTutorialScript = NULL;
                    break;
                }
            }
            
            break;
        }
    }
}

-(NSString*)GetBGMusicFilename
{
    GameModeType    gameMode    = [[Flow GetInstance] GetGameMode];
    
	if (gameMode == GAMEMODE_TYPE_WATERBALLOON_TOSS)
	{
        return [NSString stringWithUTF8String:MUSIC_BG_ICHACHING];
    }
    else if (gameMode == GAMEMODE_TYPE_MENU)
    {
        return [NSString stringWithUTF8String:MUSIC_BG_MAINMENU];
    }
    
	return NULL;
}

-(TutorialScript*)GetTutorialScript
{
    return mTutorialScript;
}

-(NSString*)GetLevelDescription:(int)inLevel
{
    switch(inLevel)
    {
        default:
        {
            return [NSString stringWithFormat:@"%@ %d", NSLocalizedString(@"LS_Level", NULL), (inLevel + 1)];
            break;
        }
    }
}

-(BOOL)GetHearts
{
    int levelIndex = [[Flow GetInstance] GetLevel];
    
    return sLevelInfo[levelIndex].Hearts;
}

-(BOOL)GetSpades
{
    int levelIndex = [[Flow GetInstance] GetLevel];
    
    return sLevelInfo[levelIndex].Spades;
}

-(BOOL)GetClubs
{
    int levelIndex = [[Flow GetInstance] GetLevel];
    
    return sLevelInfo[levelIndex].Clubs;
}

-(BOOL)GetDiamonds
{
    int levelIndex = [[Flow GetInstance] GetLevel];
    
    return sLevelInfo[levelIndex].Diamonds;
}

-(BOOL)GetAddClubs
{
    int levelIndex = [[Flow GetInstance] GetLevel];
    
    return sLevelInfo[levelIndex].AddClubs;
}

-(int)GetNumDecks
{
    int levelIndex = [[Flow GetInstance] GetLevel];
    
    return sLevelInfo[levelIndex].NumDecks;
}

-(int)GetNumCards
{
    int levelIndex = [[Flow GetInstance] GetLevel];
    
    return sLevelInfo[levelIndex].NumCards;
}

-(int)GetNumJokers
{
    int levelIndex = [[Flow GetInstance] GetLevel];
    
    return sLevelInfo[levelIndex].NumJokers;
}

-(BOOL)GetJokersAvailable
{
    int levelIndex = [[Flow GetInstance] GetLevel];
    
    return sLevelInfo[levelIndex].JokersAvailable;
}

-(BOOL)GetXrayAvailable
{
    int levelIndex = [[Flow GetInstance] GetLevel];
    
    return sLevelInfo[levelIndex].XrayAvailable;
}

-(BOOL)GetTornadoAvailable
{
    int levelIndex = [[Flow GetInstance] GetLevel];
    
    return sLevelInfo[levelIndex].TornadoAvailable;
}

-(LevelInfo*)GetLevelInfo:(int)inLevel
{
    return sLevelInfo[inLevel];
}

-(NSString*)GetMinitableTextureFilename
{
    return [NSString stringWithUTF8String:MINIGAME_UV_RUN21];
}


-(NSString*)GetScoreboardActiveTextureFilename
{
    return [NSString stringWithUTF8String:LCD_RUN21_ACTIVE];
}

-(NSString*)GetScoreboardInactiveTextureFilename
{
    return [NSString stringWithUTF8String:LCD_RUN21_INACTIVE];
}

-(NSString*)GetScoreboardBlankTextureFilename
{
    return [NSString stringWithUTF8String:LCD_RUN21_BLANK];
}

-(NSString*)GetTabletTextureFilename
{
    return [NSString stringWithUTF8String:LCD_RUN21_TABLET];
}

+(NSString*)GetCardTextureForLevel:(int)inLevel
{
	return [NSString stringWithFormat:@"r21_level_%d_available.papng", (inLevel + 1)];
}

-(CasinoID)GetCasinoId:(int)inLevelIndex
{
    NSAssert((inLevelIndex >= 0) && (inLevelIndex < WATERBALLOON_TOSS_LEVEL_NUM), @"Invalid level index");
    
    return sLevelInfo[inLevelIndex].CasinoID;
}

-(LevelSelectRoom)GetRoomForLevel:(int)inLevel
{
    return LEVELSELECT_ROOM_BRONZE;
}

-(int)GetNumRunners
{
    NSAssert(([[Flow GetInstance] GetGameMode] == GAMEMODE_TYPE_WATERBALLOON_TOSS), @"Invalid game mode for getting number of runners");
    int levelIndex = [[Flow GetInstance] GetLevel];

    return sLevelInfo[levelIndex].NumRunners;
}

-(int)GetNumRunnersForGameMode:(GameModeType)inGameModeType level:(int)inLevel
{
    NSAssert((inGameModeType == GAMEMODE_TYPE_WATERBALLOON_TOSS), @"Invalid game mode for getting number of runners");
    
    return sLevelInfo[inLevel].NumRunners;
}

-(int)GetTimeLimitSeconds
{
    int levelIndex = [[Flow GetInstance] GetLevel];

    return sLevelInfo[levelIndex].TimeLimitSeconds;
}

-(BOOL)GetMainMenuUnlocked
{
    return TRUE;
}

-(int)GetRoomsUnlockLevel
{
    return ((LEVELSELECT_ROOM_SILVER + 1) * NUM_LEVELS_IN_ROOM) - 1;
}

@end