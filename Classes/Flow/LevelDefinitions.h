//
//  LevelDefinitions.h
//  Neon21
//
//  Copyright Neon Games 2013. All rights reserved.
//

#import "Flow.h"

#define NUM_LEVELS_IN_ROOM      3

typedef enum
{
    WATERBALLOON_TOSS_LEVEL_1,
    WATERBALLOON_TOSS_LEVEL_LAST = WATERBALLOON_TOSS_LEVEL_1,
    WATERBALLOON_TOSS_LEVEL_NUM
} Run21Level;

typedef enum
{
    LEVELSELECT_ROOM_BRONZE,
    LEVELSELECT_ROOM_SILVER,
    LEVELSELECT_ROOM_GOLD,
    LEVELSELECT_ROOM_EMERALD,
    LEVELSELECT_ROOM_SAPPHIRE,
    LEVELSELECT_ROOM_RUBY,
    LEVELSELECT_ROOM_DIAMOND,
    LEVELSELECT_ROOM_LAST = LEVELSELECT_ROOM_DIAMOND,
    LEVELSELECT_ROOM_NUM
} LevelSelectRoom;

@interface LevelInfo : NSObject
{
}

@property CasinoID      CasinoID;
@property BOOL          Clubs;
@property BOOL          Spades;
@property BOOL          Diamonds;
@property BOOL          Hearts;
@property int           NumDecks;
@property int           NumCards;
@property int           NumJokers;
@property BOOL          PrioritizeHighCards;
@property BOOL          AddClubs;
@property BOOL          JokersAvailable;
@property BOOL          XrayAvailable;
@property BOOL          TornadoAvailable;
@property int           NumRunners;
@property int           XraysGranted;
@property int           TornadoesGranted;
@property int           TimeLimitSeconds;

-(LevelInfo*)init;

@end

@interface LevelDefinitions : NSObject
{
    TutorialScript* mTutorialScript;
}

-(LevelDefinitions*)Init;
-(void)dealloc;

-(void)StartLevel;

-(NSString*)GetBGMusicFilename;
-(TutorialScript*)GetTutorialScript;

-(NSString*)GetLevelDescription:(int)inLevel;

-(LevelInfo*)GetLevelInfo:(int)inLevel;

// Textures
-(NSString*)GetMinitableTextureFilename;
-(NSString*)GetScoreboardActiveTextureFilename;
-(NSString*)GetScoreboardInactiveTextureFilename;
-(NSString*)GetScoreboardBlankTextureFilename;
-(NSString*)GetTabletTextureFilename;

+(NSString*)GetCardTextureForLevel:(int)inLevel;

-(CasinoID)GetCasinoId:(int)inLevelIndex;

-(LevelSelectRoom)GetRoomForLevel:(int)inLevel;

@end