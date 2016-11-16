//
//  Flow.h
//  Neon21
//
//  Copyright Neon Games 2008. All rights reserved.
//

#import "MenuFlowTypes.h"
#import "FlowTypes.h"
#import "MessageChannel.h"

#define LEVEL_INDEX_INVALID (-1)

typedef enum
{
	Difficulty_21Sq_A234,
	Difficulty_21Sq_2345,
	Difficulty_21Sq_3456,
	Difficulty_21Sq_4567,
	Difficulty_21Sq_5678,
	Difficulty_21Sq_6789,
	Difficulty_21Sq_789T,
	Difficulty_21Sq_89TJ,
	Difficulty_21Sq_9TJQ,
	Difficulty_21Sq_TJQK,
	Difficulty_21Sq_JQKE,	// Eleven of Clubs
	Difficulty_21Sq_MAX
} Difficulty_21Sq_Enum;

// Family 2
typedef enum
{
    Difficulty_Rainbow_Level1,
    Difficulty_Rainbow_Level2,
    Difficulty_Rainbow_Level3,
    Difficulty_Rainbow_Level4,
    Difficulty_Rainbow_Level5,
    Difficulty_Rainbow_Level6,
    Difficulty_Rainbow_Level7,
    Difficulty_Rainbow_Level8,
    Difficulty_Rainbow_Level9,
    Difficulty_Rainbow_Level10,
	Difficulty_Rainbow_MAX
} Difficulty_Rainbow_Enum;

typedef enum
{
	CasinoID_None,
	CasinoID_Family1_Start,
	CasinoID_IChaChing = CasinoID_Family1_Start,
	CasinoID_FjordKnox,
	CasinoID_GummySlots,
	CasinoID_Family1_Last = CasinoID_GummySlots,
	CasinoID_MAX
} CasinoID;

typedef struct
{
    NSString*       mStateName;
    BOOL            mKeepSuspended;
} FlowStateParams;


@class TutorialScript;
@class LevelDefinitions;
@class PizzaPowerupInfo;

@interface Flow : NSObject<MessageChannelListener>
{
    @public
		ENeonMenu					mMenuToLoad;
    @private
        GameModeType                mGameModeType;
        GameModeType                mPrevGameModeType;
    
        int                         mLevel;
        int                         mPrevLevel;
	   
        LevelDefinitions*           mLevelDefinitions;
        PizzaPowerupInfo*           mPizzaPowerupInfo;
    
        BOOL                        mRequestedFacebookLogin;
        BOOL                        mRatingAlertVisible;
}

@property(readonly) LevelDefinitions* LevelDefinitions;
@property(readonly) PizzaPowerupInfo* PizzaPowerupInfo;

+(void)CreateInstance;
+(void)DestroyInstance;
+(Flow*)GetInstance;

-(void)Init;

-(GameModeType)GetGameMode;
-(int)GetLevel;

-(void)PromptForUserRatingTally;
-(void)AppRate;
-(void)AppGift;

-(void)SetupGame;

// Progress Flow
-(BOOL)UnlockNextLevel;
-(void)AdvanceLevel;
-(void)RestartLevel;

-(void)EnterGameMode:(GameModeType)inGameModeType level:(int)inLevel;
-(void)ExitGameMode;

-(BOOL)IsInRun21;
-(BOOL)IsInRainbow;

-(CasinoID)GetCasinoId;

-(void)SetRequestedFacebookLogin:(BOOL)inRequested;
-(BOOL)GetRequestedFacebookLogin;

-(void)ProcessMessage:(Message*)inMsg;

@end