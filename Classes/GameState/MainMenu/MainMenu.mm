//
//  MainMenu.m
//  Neon21
//
//  Copyright Neon Games 2008. All rights reserved.
//

#import "MainMenu.h"
#import "TextTextureBuilder.h"

#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

#import "ResourceManager.h"
#import "ModelManager.h"
#import "TextureManager.h"
#import "GameObjectManager.h"
#import "SaveSystem.h"

#import "InAppPurchaseManager.h"
#import "AchievementManager.h"

#import "Texture.h"
#import "NeonButton.h"
#import "ImageWell.h"
#import "TextBox.h"
#import "NeonArrow.h"
#import "Flow.h"

#import "SoundPlayer.h"
#import "NeonMusicPlayer.h"
#import "UINeonEngineDefines.h"
#import "AppDelegate.h"

#import <sys/utsname.h>
#import "IAPStore.h"
#import "SplitTestingSystem.h"
#import "StringCloud.h"

#import "HintSystem.h"
#import "OverlayState.h"
#import "TutorialScript.h"
#import "AdvertisingManager.h"

#define LOG_MAINMENU            1

#define BUTTON_FADE_SPEED		(7.0)
#define NUM_MENU_SLOTS			5

#define BIGSTAR_ORIGIN_X 89
#define BIGSTAR_ORIGIN_Y 60
#define BIGSTAR_ORIGIN_Z 0

#define BIGSTAR_OFFSET_X 82

#define iAD_Shift_SmallY 16
#define iAD_Shift_LargeY 32

#define GAME_ORIENTATION                UIInterfaceOrientationLandscapeRight

// Previously used the same colors as the buttons backgrounds, switching to white for readability.
static const u32    mainMenuButtonFontColors[CARDSUIT_NumSuits]			= { 0xFFFFFFFF,	// 0x158dfaFF
																			0xFFFFFFFF, // 0xee2929FF
																			0xFFFFFFFF, // 0xe1df24FF
																			0xFFFFFFFF};// 0x33f08fFF
                                                                            
static const u32    mainMenuButtonFontBorderColors[CARDSUIT_NumSuits]   = { 0x0d52dfFF,
																			0x7f1010FF,
																			0xa9a616FF,
																			0x20c55aFF};

static const char*  mainMenuButtonTextureLogo						= { "bg_run21_nomarathon.papng" };

static const char*  levelselectBGImage[LEVELSELECT_ROOM_NUM]        = { "bg_ls_bronze.papng",
                                                                        "bg_ls_silver.papng",
                                                                        "bg_ls_gold.papng",
                                                                        "bg_ls_emerald.papng",
                                                                        "bg_ls_sapphire.papng",
                                                                        "bg_ls_ruby.papng",
                                                                        "bg_ls_diamond.papng"};

static const char*  levelselectRoomNames[LEVELSELECT_ROOM_NUM]      = { "LS_Room_Bronze",
                                                                        "LS_Room_Silver",
                                                                        "LS_Room_Gold",
                                                                        "LS_Room_Emerald",
                                                                        "LS_Room_Sapphire",
                                                                        "LS_Room_Ruby",
                                                                        "LS_Room_Diamond"};

static const char*  fullStarIconNames[LEVELSELECT_ROOM_NUM]         = { "bronzestar_full.papng",
                                                                        "silverstar_full.papng",
                                                                        "goldstar_full.papng",
                                                                        "emeraldstar_full.papng",
                                                                        "sapphirestar_full.papng",
                                                                        "rubystar_full.papng",
                                                                        "shootingstar_full.papng" };

static const char*  emptyStarIconName                               = "star_empty.papng";

static Vector3		sLogoPosition										= {0, 0, 0};
static Vector3		sLevelSelectSmallStarOffset							= {4, 4, 0};
static Vector3		sLS_RoomNameLoc										= {240, 38 - iAD_Shift_SmallY, 0};
static const int    sLSCardWidth                                        = 60;
static const int    sLSStarWidth                                        = 14;

static Vector3		sLS_LevelPos[NUM_LEVELS_IN_ROOM]                    = { { 113, 120 - iAD_Shift_LargeY, 0 }, { 204, 120 - iAD_Shift_LargeY, 0}, { 295, 120 - iAD_Shift_LargeY, 0} };

static const char*  MMOff[MMButton_Num]                                 = { "menu_marathon.papng",                      // MMButton_Marathon
                                                                            "menu_run21.papng",                         // MMButton_Run21
                                                                            "menu_cog_closed.papng",                    // MMButton_Rainbow
                                                                            "neongames.papng",                          // MMButton_NeonWeb
                                                                            "menu_cog_closed.papng",                    // MMButton_Options
                                                                            "menu_music_off.papng",                     // MMButton_BGM
                                                                            "menu_sfx_off.papng",                       // MMButton_SFX
                                                                            "menu_deletesave_off.papng",                // MMButton_ClearData
                                                                            "menu_iap.papng",                           // MMButton_IAP_NoAds
                                                                            "menu_neon.papng",                          // MMButton_Contact_Us
                                                                            "menu_facebook.papng",                      // MMButton_Facebook
                                                                            "menu_gamecenter.papng",                    // MMButton_GameCenter
                                                                            "menu_levelselect_xray.papng",
                                                                            "menu_levelselect_tornado.papng",
                                                                            "menu_levelselect_lives.papng"};


static const char*  MMUnlit[MMButton_Num]                               = { "menu_marathon.papng",                      // MMButton_Marathon
                                                                            "menu_run21.papng",                         // MMButton_Run21
                                                                            "menu_cog_closed.papng",                    // MMButton_Rainbow
                                                                            "neongames.papng",                          // MMButton_NeonWeb
                                                                            "menu_cog_closed.papng",                    // MMButton_Options
                                                                            "menu_music_on.papng",                      // MMButton_BGM
                                                                            "menu_sfx_on.papng",                        // MMButton_SFX
                                                                            "menu_deletesave_on.papng",                 // MMButton_ClearData
                                                                            "menu_iap.papng",                           // MMButton_IAP_NoAds
                                                                            "menu_neon.papng",                          // MMButton_Contact_Us
                                                                            "menu_facebook.papng",                      // MMButton_Facebook
                                                                            "menu_gamecenter.papng",                    // MMButton_GameCenter
                                                                            "menu_levelselect_xray.papng",
                                                                            "menu_levelselect_tornado.papng",
                                                                            "menu_levelselect_lives.papng"};

static const char*  MMLit[MMButton_Num]                                 = { "menu_marathon_glow.papng",                 // MMButton_Marathon
                                                                            "menu_run21_glow.papng",                    // MMButton_Run21
                                                                            "menu_cog_glow.papng",                      // MMbuttton_Rainbow
                                                                            "neongames_glow.papng",                     // MMButton_NeonWeb
                                                                            "menu_cog_glow.papng",                      // MMButton_Options
                                                                            "menu_options_glow.papng",                  // MMButton_BGM
                                                                            "menu_options_glow.papng",                  // MMButton_SFX
                                                                            "menu_options_glow.papng",                  // MMButton_ClearData
                                                                            "menu_iap_glow.papng",                      // MMButton_IAP_NoAds
                                                                            "menu_options_glow.papng",                  // MMButton_Contact_Us
                                                                            "menu_options_glow.papng",                  // MMButton_Facebook
                                                                            "menu_options_glow.papng",                  // MMButton_GameCenter
                                                                            "menu_levelselect_xray_glow.papng",
                                                                            "menu_levelselect_tornado_glow.papng",
                                                                            "menu_levelselect_lives_glow.papng"};


#define TOPBAR_IMAGE_EXT        480
#define TOPBAR_IMAGE_WIDTH      29
#define TOPBAR_IMAGE_MARGIN     30
#define TOPBAR_LOC_Y            10

#define ATLAS_PADDING_SIZE          (4)

static const float topbar_y               = 10;
static const float topbar_left            = TOPBAR_IMAGE_MARGIN;
static const float topbar_center          = ((TOPBAR_IMAGE_EXT - TOPBAR_IMAGE_WIDTH) / 2 );
static const float topbar_right           = TOPBAR_IMAGE_EXT - TOPBAR_IMAGE_MARGIN - TOPBAR_IMAGE_WIDTH;
static const float topbar_leftcenter      = (( topbar_center - topbar_left ) / 2) + topbar_left;
static const float topbar_rightcenter     = (( topbar_right - topbar_center) / 2) + topbar_center;

static Vector3		MMPos[MMButton_Num]                                 = {
                                                                            { 0 , 201, 0	},                      // MMButton_Marathon
                                                                            { 310, 201, 0	},                      // MMButton_Run21
                                                                            { 200, 100, 0   },                      // MMButton_Rainbow
                                                                            { 0 , 0  , 0	},                      // MMButton_NeonWeb
                                                                            { 425, 0  , 0	},                      // MMButton_Options
                                                                            { topbar_rightcenter,   topbar_y , 0},  // MMButton_BGM
                                                                            { topbar_right,         topbar_y , 0},  // MMButton_SFX
                                                                            { 230, 10 , 0	},                      // MMButton_ClearData
                                                                            { 165, 201 , 0	},                      // MMButton_IAP_NoAds
                                                                            { topbar_leftcenter,    topbar_y, 0 },  // MMButton_Contact_Us
                                                                            { topbar_left,          topbar_y, 0 },  // MMButton_Facebook
                                                                            { topbar_center,        topbar_y, 0 },  // MMButton_GameCenter
                                                                            { 380, 292, 0   },                      // MMButton_Powerup_XRay
                                                                            { 305, 292, 0   },                      // MMButton_Powerup_Tornado
                                                                            { 225, 292, 0   }};                     // MMButton_Powerup_Lives

static const char*  levelSelectButtonTextureLitName[LSButton_Num]		= { "levelSelect_back_glow.papng"	,"levelSelect_play_glow.papng"  ,"levelSelect_room_prev_glow.papng" ,"levelSelect_room_next_glow.papng"};
static const char*  levelSelectButtonTextureUnlitName[LSButton_Num]		= { "levelSelect_back.papng"		,"levelSelect_play.papng"       ,"levelSelect_room_prev.papng"      ,"levelSelect_room_next.papng"};
static const char*  levelSelectButtonTextureOffName[LSButton_Num]		= { "levelSelect_back.papng"		,"levelSelect_play.papng"       ,"levelSelect_room_prev.papng"      ,"levelSelect_room_next.papng"};
static Vector3		slevelSelectButtonPositions[LSButton_Num]			= { { 214, 269 - iAD_Shift_LargeY, 0	}   , { 0, 0, 0	}                   , { 16, 0, 0	}                   , { 419, 0, 0	}   };

static const char*  levelSelectBottomBarName    = "menu_bottombar.papng";
static const char*  levelUpMeterHolderName      = "menu_levelup_holder.papng";
static const char*  levelUpMeterContentsName    = "menu_levelup_meter.papng";
static const char*  defaultProfilePicture       = "defaultUser.papng";

static Vector3      sLevelSelectBottomBarPosistion  = {  0, 290, 0 };
static Vector3      sLeveupHolderPosistion          = { 14, 292, 0 };
static Vector3      sLeveupMeterPosistion           = { 74, 297, 0 };
static Vector3      sProfilePicturePosition         = { 14, 290, 0 };
//static Vector3      sProfilePictureScale            = { 32.0f / 50.0f, 32.0f / 50.0f, 1.0f };

static const int    sTopBarMenuPadding = 5;
static const int    sTopBarButtonWidth = 29;

typedef enum
{
    USERDATA_TYPE_FLOW,
    USERDATA_TYPE_MENU,
    USERDATA_TYPE_POP,
    USERDATA_TYPE_PUSH,
    USERDATA_MAX,
    USERDATA_INVALID = USERDATA_MAX
} UserDataType;

typedef struct
{
    UserDataType mType;
    u32          mData;
    u32          mDataTwo;
} UserData;

static UserData sUserData;

NSString* machineName()
{
    struct utsname systemInfo;
    uname(&systemInfo);
    
    return [NSString stringWithCString:systemInfo.machine
                              encoding:NSUTF8StringEncoding];
}

@implementation MainMenuParams

-(MainMenuParams*)Init
{
    mMainMenuMode = MAIN_MENU_MODE_INVALID;
    return self;
}

@end

@implementation MainMenu

-(void)Startup
{
    [super Startup];
    
    GameObjectBatchParams groupParams;
    
    [GameObjectBatch InitDefaultParams:&groupParams];
    
    groupParams.mUseAtlas = TRUE;
    
	mActiveMenu.uiObjects = [(UIGroup*)[UIGroup alloc] InitWithParams:&groupParams];
    mActiveMenu.secondaryObjects = [(UIGroup*)[UIGroup alloc] InitWithParams:&groupParams];
    
    [[mActiveMenu.secondaryObjects GetTextureAtlas] SetPaddingSize:ATLAS_PADDING_SIZE];
    
    [[GameObjectManager GetInstance] Add:mActiveMenu.uiObjects];
    [[GameObjectManager GetInstance] Add:mActiveMenu.secondaryObjects];
    
    flowPtr =  [ Flow GetInstance];
    flowPtr->mMenuToLoad = NeonMenu_Main;
    
    mNumButtons = 0;
    mSentTerminateMessage = FALSE;

    sUserData.mType = USERDATA_INVALID;
    sUserData.mData = 0;
    
    memset(levelSelect.mLevelButton, 0, sizeof(levelSelect.mLevelButton));
    
    for (int i = 0; i < WATERBALLOON_TOSS_LEVEL_NUM; i++)
    {
        levelSelect.mLevelButton[i].stars = [[NSMutableArray alloc] initWithCapacity:0];
    }

    mMenuTerminateDelay = 0;
    
    mNextRoomButton = NULL;
    mPrevRoomButton = NULL;
    mRoomUnlockDescription = NULL;

    // Change level based on flow state.
    
	// KK->RG : We need to EvaluateMusicForState in the Music Manager in the event we're returning to the main menu.
    [self SetStingerSpawner:NULL];

#if (UNLOCK_LEVELS > 0)
    [[SaveSystem GetInstance] SetMaxLevel:UNLOCK_LEVELS];
    [[SaveSystem GetInstance] SetMaxLevelStarted:(UNLOCK_LEVELS - 1)];
    
    LevelSelectRoom room = [[[Flow GetInstance] GetLevelDefinitions] GetRoomForLevel:UNLOCK_LEVELS];
    
    [[SaveSystem GetInstance] SetMaxRoomUnlocked:[NSNumber numberWithInt:room]];
    
    for (int level = 0; level < UNLOCK_LEVELS; level++)
    {
        [[SaveSystem GetInstance] SetStarsForLevel:level withStars:1];
    }
#endif
    
    {
        sUserData.mType = USERDATA_TYPE_FLOW;
        sUserData.mData = WATERBALLOON_TOSS_LEVEL_1;
        sUserData.mDataTwo = GAMEMODE_TYPE_WATERBALLOON_TOSS;
        
        Message msg;
        
        msg.mId = EVENT_MAIN_MENU_PENDING_TERMINATE;
        msg.mData = NULL;
        
        [[[GameStateMgr GetInstance] GetMessageChannel] BroadcastMessageSync:&msg];
        
        mSentTerminateMessage = TRUE;
        mMenuTerminateDelay = 2;
    }
    
    mCommunityDelegate      = [[CommunityDelegate       alloc] init];
    mFacebookDelegate       = [[FacebookUIDelegate      alloc] init];
    mRefillLivesDelegate    = [[RefillLivesDelegate     alloc] init];
    
    mHintDisabledObjects = [[NSMutableArray alloc] init];
    
    [[[GameStateMgr GetInstance] GetMessageChannel] AddListener:self];
    
    [[NeonMetrics GetInstance] logEvent:@"Main Menu Startup" withParameters:NULL];
}

-(void)Resume
{
    if (mSuspendType == MAINMENU_SUSPEND_FULL)
    {
        mNumButtons				= 0;
        mSentTerminateMessage	= FALSE;
        
        // Deactivate all level select cards
        
        /*for ( int nCard = 0; nCard < NUM_LEVELS_IN_LEVELSELECT; nCard++ )
        {
            [levelSelect.mLevelButton[nCard].button SetActiveIndex:LSSTATUS_AVAILABLE];
        }*/
        
        Flow *gameFlow = [ Flow GetInstance ];
        
        [[GameObjectManager GetInstance] Add:mActiveMenu.uiObjects];
        [[GameObjectManager GetInstance] Add:mActiveMenu.secondaryObjects];
        
        FaderParams faderParams;
        [Fader InitDefaultParams:&faderParams];
        
        faderParams.mFadeType = FADE_FROM_BLACK;
        faderParams.mFrameDelay = 2;
        faderParams.mCancelFades = TRUE;
        
        [[Fader GetInstance] StartWithParams:&faderParams];
    }
    else
    {
        [self SetCurrentMenuActive:TRUE];
        
        BOOL showUnlockButton = [self ShouldShowBottomBarRoomUnlockButton];
        
        if (!showUnlockButton)
        {
            [bottomBar.mRoomUnlockButton SetVisible:FALSE];
            [bottomBar.mRoomUnlockStringCloud SetVisible:FALSE];
        }
        
        if (![[AdvertisingManager GetInstance] ShouldShowAds])
        {
            [bottomBar.mRemoveAds SetVisible:FALSE];
            [bottomBar.mArrow SetVisible:FALSE];
        }
    }
    
    [[NeonMetrics GetInstance] logEvent:@"Main Menu Resume" withParameters:NULL];
}

-(void)Shutdown
{
	[ self LeaveMenu ];
    
    for (int i = 0; i < WATERBALLOON_TOSS_LEVEL_NUM; i++)
    {
        [levelSelect.mLevelButton[i].stars release];
    }
    
    [mActiveMenu.uiObjects removeAllObjects];
    [mActiveMenu.secondaryObjects removeAllObjects];
    
    [[GameObjectManager GetInstance] Remove:mActiveMenu.uiObjects];
    [[GameObjectManager GetInstance] Remove:mActiveMenu.secondaryObjects];
    
    [[GameObjectManager GetInstance] Remove:mRoomUnlockDescription];
    
    [mCommunityDelegate         release];
    [mFacebookDelegate          release];
    [mRefillLivesDelegate       release];
    
    [mHintDisabledObjects release];
    
    [[[GameStateMgr GetInstance] GetMessageChannel] RemoveListener:self];
}

-(void)Suspend
{
    Class nextClass = [[[GameStateMgr GetInstance] GetActiveState] class];
    
    if ((nextClass != [IAPStore class]) && (nextClass != [OverlayState class]))
    {
        Flow *gameFlow = [ Flow GetInstance ];
        gameFlow->mMenuToLoad = mActiveMenu.menuID;

        [self LeaveMenu];
    
        [mActiveMenu.uiObjects removeAllObjects];
        [mActiveMenu.secondaryObjects removeAllObjects];
        
        [[GameObjectManager GetInstance] Remove:mActiveMenu.uiObjects];
        [[GameObjectManager GetInstance] Remove:mActiveMenu.secondaryObjects];
        
        [[GameObjectManager GetInstance] Remove:mRoomUnlockDescription];
        
        mSuspendType = MAINMENU_SUSPEND_FULL;
    }
    else
    {
        if (nextClass == [IAPStore class])
        {
            [self SetCurrentMenuActive:FALSE];
        }
        
        mSuspendType = MAINMENU_SUSPEND_PARTIAL;
    }
}

-(void)UpdateBottomBar
{
    // The bottom bar is active and init'ed in every menu but Main.
    if ( mActiveMenu.menuID != NeonMenu_Main && [mActiveMenu.uiObjects GroupCompleted] )
    {
    }
}

-(void)Update:(CFTimeInterval)inTimeStep
{
    if ([[InAppPurchaseManager GetInstance] GetIAPState] == IAP_STATE_PENDING)
    {
        return;
    }
    
    [self UpdateBottomBar];
    
    if ((sUserData.mType == USERDATA_TYPE_FLOW) && (!mSentTerminateMessage))
    {
        mSentTerminateMessage = TRUE;
        
        Message msg;
        
        msg.mId = EVENT_MAIN_MENU_PENDING_TERMINATE;
        msg.mData = NULL;
        
        [[[GameStateMgr GetInstance] GetMessageChannel] BroadcastMessageSync:&msg];
    }
    
    if (mMenuTerminateDelay > 0)
    {
        mMenuTerminateDelay--;
    }
    
    if ([mActiveMenu.uiObjects GroupCompleted] && [mActiveMenu.secondaryObjects GroupCompleted] && (mMenuTerminateDelay == 0))
    {
        if (sUserData.mType != USERDATA_INVALID)
        {
            [mActiveMenu.uiObjects removeAllObjects];
            [mActiveMenu.secondaryObjects removeAllObjects];

            UserDataType userDataType = sUserData.mType;
            
            sUserData.mType = USERDATA_INVALID;
            
            switch(userDataType)
            {
                case USERDATA_TYPE_FLOW:
                {
                    int level = sUserData.mData;
                    GameModeType gameMode = (GameModeType)sUserData.mDataTwo;
                    
                    NSAssert((level >= 0) && (level < WATERBALLOON_TOSS_LEVEL_NUM), @"Invalid user data");
                    [[Flow GetInstance] EnterGameMode:GAMEMODE_TYPE_WATERBALLOON_TOSS level:level];
                
                    break;
                }
                
                case USERDATA_TYPE_MENU:
                {
                    break;
                }
                
                case USERDATA_TYPE_POP:
                {
                    [[GameStateMgr GetInstance] Pop];
                    break;
                }
                    
                case USERDATA_TYPE_PUSH:
                {
                    switch ( sUserData.mData )
                    {
                        case PUSH_MENU_IAPSTORE:
                        {
                            [[GameStateMgr GetInstance] Push:[IAPStore alloc]];
                            break;
                        } 
                        default:
                        {
                            NSAssert(FALSE, @"Unknown USERDATA_TYPE_PUSH mData type.");
                            break;
                        }
                            
                    }
                    break;
                }
                
                default:
                {
                    NSAssert(FALSE, @"Unknown user data type");
                    break;
                }
            }
        }
    }
    
    if (([mConnectingTextBox GetVisible]) || ([bottomBar.mConnectingTextBox GetVisible]))
    {
        if ([[InAppPurchaseManager GetInstance] GetIAPState] == IAP_STATE_IDLE)
        {
            [mConnectingTextBox SetVisible:FALSE];
            [bottomBar.mConnectingTextBox SetVisible:FALSE];
            
            if ([[AdvertisingManager GetInstance] ShouldShowAds])
            {
                [bottomBar.mRoomUnlockButton SetActive:TRUE];
                [bottomBar.mRoomUnlockStringCloud SetVisible:TRUE];
            }
        }
    }
    
    [super Update:inTimeStep];
}

-(void)OutOfLivesAlert
{
}

-(void)ButtonEvent:(ButtonEvent)inEvent Button:(Button*)inButton
{
    if ([[GameStateMgr GetInstance] GetActiveState] != self)
    {
        return;
    }
    
    if (inEvent == BUTTON_EVENT_UP)
    {
        BOOL audioOptionSelected = FALSE;
        
        if (audioOptionSelected)
        {
            return;
        }

        BOOL leaveMenu = TRUE;
        
		if ((mActiveMenu.menuID == Run21_Main_LevelSelect || mActiveMenu.menuID == Rainbow_Main_LevelSelect) )
		{
			if ( inButton->mIdentifier >= LSID_LevelButtonBase)
			{
				int nLevelButtonSelected	= (u32)inButton->mIdentifier - LSID_LevelButtonBase;	// 0-Based index of Level
				
				// Is this level unlocked?
				if ( LSSTATUS_LOCKED != [levelSelect.mLevelButton[nLevelButtonSelected].button GetActiveIndex] )
				{
                    // Play this level.
                    sUserData.mType = USERDATA_TYPE_FLOW; // kk
                    sUserData.mData = nLevelButtonSelected;
                    sUserData.mDataTwo = GAMEMODE_TYPE_WATERBALLOON_TOSS;
                    
                    leaveMenu = TRUE;
				}
				else
				{
					// Do nothing, user cannot access locked levels.
                    return;
				}
			}
			
			if (leaveMenu)
			{
				[self LeaveMenu];
			}
			
			return;
		}
		
        switch ( inButton->mIdentifier )
        {
            case NeonMenu_Main_Options:
            {
                leaveMenu = FALSE;
                // Toggle the status of the Options Buttons.
                // We need to make the SFX, BGM, and Clear Data Buttons Visible
                int  numObjects = (int)[mActiveMenu.uiObjects count];
                NeonButton *inButtonNeon = (NeonButton*)inButton;
                BOOL bOptionsButtonWasOn = [ inButtonNeon GetToggleOn ];
                
                for (int i = 0; i < numObjects; i++)
                {
                    UIObject *nObject = [ mActiveMenu.uiObjects objectAtIndex:i ];
                    
                    switch ( nObject->mIdentifier )
                    {
                        case OPTIONS_GRADIENT_ID:
                        {
                            ImageWell*  nImage = (ImageWell*)nObject;
                            BOOL        bVisible = TRUE;
                            
                            if ( bOptionsButtonWasOn )
                                bVisible = FALSE;
                            
                            [ nImage SetVisible:bVisible ];
                            break;
                        }
   
                        case NeonMenu_Main_Options_Music:
                        case NeonMenu_Main_Options_Sound:
                        case NeonMenu_Main_Options_ClearData:
                        {
                            NeonButton *nButton = (NeonButton*)nObject;
                            
                            if ( bOptionsButtonWasOn )
                            {
                                [nButton SetListener:NULL];
                                [nButton Disable];
                                [nButton SetVisible:FALSE];
                            }
                            else
                            {
                                [nButton SetListener:self];
                                [nButton Enable];
                                [nButton SetVisible:TRUE];
                            }
                            break;
                        }
                            
                    }
                }
                
                break;
            }
                
            case NeonMenu_NeonLogo:
			case NeonMenu_Main_Extras_Website:
            {
				leaveMenu = FALSE;
				NeonButton *webbutton = (NeonButton*)inButton;
				[webbutton SetToggleOn:TRUE];

				UIApplication *neonApp	= [ UIApplication sharedApplication ];
				NSURL *neonGamesUS		= [ NSURL URLWithString:@"http://neongam.es/"];
				[ neonApp openURL:neonGamesUS ];

                break;
            }
				
			case NeonMenu_Main_Extras_Contact_Us:
            {
                [UIApplication sharedApplication].statusBarOrientation = GAME_ORIENTATION;

                UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"LS_Community",NULL)
                                                                message: NULL
                                                               delegate: mCommunityDelegate
                                                      cancelButtonTitle: NSLocalizedString(@"LS_Back", NULL)
                                                      otherButtonTitles: NSLocalizedString(@"LS_Email_Us",NULL),
                                                                         NSLocalizedString(@"LS_WebComic",NULL),nil];
                [alert show];

                leaveMenu = FALSE;
                break;
            }
            case NeonMenu_Main_Extras_IAP_Store:
            {
                [[GameStateMgr GetInstance] Push:[IAPStore alloc] ];
                leaveMenu = FALSE;
                break;
            }
#if !NEON_SOLITAIRE_21
            case NeonMenu_Main_Extras_IAP_Lives:
            {
                [[GameStateMgr GetInstance] Push:[[IAPStore alloc] InitWithTab:IAPSTORE_TAB_LIVES]];
                break;
            }
#endif
			case NeonMenu_Main_Extras_RateAppOrOtherGames:
            {
                leaveMenu = FALSE;
                NeonButton *webbutton = (NeonButton*)inButton;
				[webbutton SetToggleOn:TRUE];
                [[Flow GetInstance] AppRate];
                break;
            }
                
            case NeonMenu_Main_Options_ClearData_No:
            {
                sUserData.mType = USERDATA_TYPE_MENU;
                sUserData.mData = NeonMenu_Main_Options;
                break;
            }
            case Run21_Main_Marathon:
            {
                sUserData.mType = USERDATA_TYPE_MENU;
                sUserData.mData = Run21_Main_Marathon;
                break;
            }
#if !NEON_SOLITAIRE_21
            case Run21_Marathon_Leaderboard:
            {
                [[AchievementManager GetInstance] ShowLeaderboard:LEADERBOARD_RUN21_MARATHON];
                leaveMenu = FALSE;
                break;
            }
            case Run21_Marathon_Achievements:
            {
                [[AchievementManager GetInstance] ShowAchievements];
                leaveMenu = FALSE;
                break;
            }
#endif
            case Run21_Main_LevelSelect:
            {
                sUserData.mType = USERDATA_TYPE_MENU;
                sUserData.mData = Run21_Main_LevelSelect;
                
                Message msg;
                
                msg.mId = EVENT_MAIN_MENU_LEVEL_SELECT_PENDING;
                msg.mData = NULL;
                
                [[[GameStateMgr GetInstance] GetMessageChannel] BroadcastMessageSync:&msg];

                break;
            }
            case Rainbow_Main_LevelSelect:
            {
                sUserData.mType = USERDATA_TYPE_MENU;
                sUserData.mData = Rainbow_Main_LevelSelect;
                NSAssert(FALSE, @"Need to use new flow functions");
                //levelSelectGameOffset = Tutorial_Rainbow_HowToPlay;
                break;
            }
				
            case NeonMenu_Main_NewGame_OverwriteNo:
            {
                sUserData.mType = USERDATA_TYPE_MENU;
                sUserData.mData = NeonMenu_Main;
                break;
            }
				            
            case NeonMenu_Main_Extras_Facebook:
            {
                break;
            }
#if !NEON_SOLITAIRE_21
            case NeonMenu_Main_Extras_GameCenter:
            {
                [[AchievementManager GetInstance] ShowAchievements];
                leaveMenu = FALSE;
                break;
            }
#endif
            default:
            {
                u32 buttonID = (ENeonMenu)inButton->mIdentifier;
                
                sUserData.mType = USERDATA_TYPE_MENU;
                sUserData.mData = buttonID;
                
                break;
            }
        }
        
        if (leaveMenu)
        {
            [self LeaveMenu];
        }
    }
}

-(void)ProcessMessage:(Message*)inMsg
{
}

-(void)LeaveMenu
{
    int  numObjects = (int)[mActiveMenu.uiObjects count];
    
    for (int i = 0; i < numObjects; i++)
    {
        UIObject *nObject = [ mActiveMenu.uiObjects objectAtIndex:i ];
        
        [nObject RemoveAfterOperations];
        [nObject Disable];
    }
    
    numObjects = (int)[mActiveMenu.secondaryObjects count];
    
    for (int i = 0; i < numObjects; i++)
    {
        UIObject *nObject = [ mActiveMenu.secondaryObjects objectAtIndex:i ];
        
        [nObject RemoveAfterOperations];
        [nObject Disable];
    }
    
    [mProfilePicture RemoveAfterOperations];
    [mProfilePicture Disable];
    
    mProfilePicture = NULL;
    
    memset(&bottomBar, 0, sizeof(bottomBar));
    
    // If there are no UIObjects, we're transitioning INTO a menu, so sUserData.mType could be invalid.
    // It's also okay to have no destination state if we're leaving the state (hence the second check)
    if ((numObjects != 0) && ([[GameStateMgr GetInstance] GetActiveState] == self))
    {
        //NSAssert(sUserData.mType != USERDATA_INVALID, @"Trying to leave a menu but no destination was set");
    }
    
    [mRoomUnlockDescription RemoveAfterOperations];
    [mRoomUnlockDescription Disable];
    
    mRoomUnlockDescription = NULL;
    
    mConnectingTextBox = NULL;
}

-(void)InitMenu:(ENeonMenu)menuID
{
    [ self LeaveMenu ];
	mActiveMenu.menuID		= menuID;
}

-(void)InitLSRoom:(LevelSelectRoom)inRoomIndex
{
    int colorText = 0xFFFFFFFF;
    int colorStroke = NEON_BLA;
    
    switch (inRoomIndex)
    {
        case LEVELSELECT_ROOM_DIAMOND:
            colorText   = NEON_BLU;
            break;
            
        case LEVELSELECT_ROOM_SAPPHIRE:
            colorText = 0x21FFF0FF;
            break;
            
        case LEVELSELECT_ROOM_EMERALD:
            colorText = 0x2DFF07FF;
            break;
            
        case LEVELSELECT_ROOM_RUBY:
            colorText = 0xFDA3A2FF;
            break;
            
        case LEVELSELECT_ROOM_GOLD:
            colorText   = NEON_YEL;
            break;
            
        case LEVELSELECT_ROOM_SILVER:
            colorText   = NEON_WHI;
            break;
   
        case LEVELSELECT_ROOM_BRONZE:
        default:
            colorText   = NEON_ORA;
            break;
    }
    
    PlacementValue placementValue;
    SetRelativePlacement(&placementValue, PLACEMENT_ALIGN_CENTER, PLACEMENT_ALIGN_CENTER);
    
    // Display message asking user to confirm they want to start a new game
    TextBoxParams tbParams;
    [TextBox InitDefaultParams:&tbParams];
    SetColorFromU32(&tbParams.mColor,		colorText);
    SetColorFromU32(&tbParams.mStrokeColor, colorStroke);
    
    tbParams.mStrokeSize	= 2;
    tbParams.mString		= NSLocalizedString([NSString stringWithUTF8String:levelselectRoomNames[inRoomIndex]], NULL);
    tbParams.mFontSize		= 24;
    tbParams.mFontType		= NEON_FONT_STYLISH;
    tbParams.mWidth			= 320;	// Gutter the left and right border of screen
    tbParams.mUIGroup		= mActiveMenu.uiObjects;
    
    levelSelect.mRoomName[inRoomIndex]   = [(TextBox*)[TextBox alloc] InitWithParams:&tbParams];
    [levelSelect.mRoomName[inRoomIndex]  SetVisible:FALSE];
    //[levelSelect.mRoomName[starType]  Enable];
    [levelSelect.mRoomName[inRoomIndex]  SetPlacement:&placementValue];
    [levelSelect.mRoomName[inRoomIndex]  SetPosition: &sLS_RoomNameLoc];
    [levelSelect.mRoomName[inRoomIndex]  release];    // May not need this.
}

-(void)InitLevelSelectBG
{
    for (int i = 0; i < LEVELSELECT_ROOM_NUM; i++)
    {
        ImageWellParams					imageWellparams;
        [ImageWell InitDefaultParams:	&imageWellparams];
        imageWellparams.mUIGroup		= mActiveMenu.uiObjects;
        imageWellparams.mTextureName	= [ NSString stringWithUTF8String:levelselectBGImage[i] ];
        
        
        levelSelect.mBG[i]=     [(ImageWell*)[ImageWell alloc] InitWithParams:&imageWellparams];
        [levelSelect.mBG[i]     SetPosition:&sLogoPosition];
        [levelSelect.mBG[i]     SetVisible:FALSE];
        [levelSelect.mBG[i]     release];
        
        [self InitLSRoom:(LevelSelectRoom)i];
    }
    
	// Hack to trick the system into not setting up the layout or bg.
	mNumButtons = 1;
}

-(void)InitLogo
{
	ImageWell						*logoImage;
	
	ImageWellParams					imageWellparams;
	[ImageWell InitDefaultParams:	&imageWellparams];
	imageWellparams.mUIGroup		= mActiveMenu.uiObjects;
    
    imageWellparams.mTextureName = [ NSString stringWithUTF8String:mainMenuButtonTextureLogo ];
		
	logoImage	=	[(ImageWell*)[ImageWell alloc] InitWithParams:&imageWellparams];
	[logoImage		SetPosition:&sLogoPosition];
	[logoImage		SetVisible:TRUE];
	[logoImage		release];
}

-(void)InitOptionsGradient
{
    ImageWell						*logoImage;
	
	ImageWellParams					imageWellparams;
	[ImageWell InitDefaultParams:	&imageWellparams];
	imageWellparams.mUIGroup		= mActiveMenu.uiObjects;
	imageWellparams.mTextureName	= @"menu_option_header.papng";
    
	logoImage	=	[(ImageWell*)[ImageWell alloc] InitWithParams:&imageWellparams];
    
    Vector3	optionsPos	= { 0, 0, 0};
    logoImage->mIdentifier = OPTIONS_GRADIENT_ID;
	[logoImage		SetPosition:&optionsPos];
	[logoImage		SetVisible:TRUE];
	[logoImage		release];
}

-(NeonButton*)InitMainMenuButton:(ENeonMenu)linkMenuID MMID:(MainMenuButtons)mmButtonID visible:(BOOL)bVisible on:(BOOL)bToggledOn enabled:(BOOL)bEnabled uiGroup:(UIGroup*)inUIGroup
{
    return [self InitMainMenuButton:linkMenuID MMID:mmButtonID visible:bVisible on:bToggledOn enabled:bEnabled uiGroup:inUIGroup position:&MMPos[mmButtonID]];
}

-(NeonButton*)InitMainMenuButton:(ENeonMenu)linkMenuID MMID:(MainMenuButtons)mmButtonID visible:(BOOL)bVisible on:(BOOL)bToggledOn enabled:(BOOL)bEnabled uiGroup:(UIGroup*)inUIGroup position:(Vector3*)inPosition
{
	NeonButton*         curButton;
	NeonButtonParams    buttonParams;
	
	// Init the Logo FIRST, so it is in the BG
	if ( mNumButtons == 0 )
		[ self InitLogo ];
	
	// TODO: Probably should verify that there is no menu already with this suit.
	
	[NeonButton InitDefaultParams:&buttonParams];
    
    buttonParams.mTexName					= [NSString stringWithUTF8String:MMOff[mmButtonID]];
    buttonParams.mPregeneratedGlowTexName	= [NSString stringWithUTF8String:MMLit[mmButtonID]];
	buttonParams.mToggleTexName				= [NSString stringWithUTF8String:MMUnlit[mmButtonID]];
	buttonParams.mTextSize					= 18;
    buttonParams.mBorderSize				= 1;
    buttonParams.mQuality					= NEON_BUTTON_QUALITY_HIGH;
    buttonParams.mFadeSpeed					= BUTTON_FADE_SPEED;
    buttonParams.mUIGroup					= inUIGroup;
	buttonParams.mUISoundId					= SFX_MENU_BUTTON_PRESS;
    buttonParams.mBoundingBoxCollision		= TRUE;
    SetVec2(&buttonParams.mBoundingBoxBorderSize, 5, 5);
	SetColorFromU32(&buttonParams.mBorderColor	, NEON_BLA);
	SetColorFromU32(&buttonParams.mTextColor	, NEON_WHI);
    
	if ( !bEnabled )
	{
		SetColorFromU32(&buttonParams.mBorderColor	, NEON_BLA);
		SetColorFromU32(&buttonParams.mTextColor	, NEON_GRAY);
	}
	
	SetRelativePlacement(&buttonParams.mTextPlacement, PLACEMENT_ALIGN_CENTER, PLACEMENT_ALIGN_CENTER);
    
	curButton = [(NeonButton*)[NeonButton alloc] InitWithParams:&buttonParams];
	[curButton SetToggleOn:bToggledOn];
	curButton->mIdentifier = linkMenuID;
    
	[curButton Enable];
	
	if ( bEnabled )
	{
		[curButton SetListener:self];
	}
	else
	{
		
		[curButton SetListener:NULL];
		//[curButton SetPulseAmount:0.0f time:0.25f];
		[curButton SetActive:FALSE];
	}
    

    [curButton SetVisible:bVisible];

	
	[curButton SetPosition:inPosition];
	
	[curButton release];
    mNumButtons++;
    
    return curButton;
}

-(void)ActivateMainMenu
{
    [self InitMainMenuButton:Run21_Main_LevelSelect	MMID:MMButton_Run21 visible:TRUE on:TRUE enabled:TRUE uiGroup:mActiveMenu.uiObjects];
    // Don't display Neon Logo
    //[self InitMainMenuButton:NeonMenu_NeonLogo      withMMID:MMButton_NeonWeb   withVisible:TRUE withOn:TRUE withEnabled:TRUE];
 
    #if ENABLE_SKU_RAINBOW
        [self InitMainMenuButton:Rainbow_Main_LevelSelect withMMID:MMButton_Rainbow withVisible:TRUE withOn:TRUE withEnabled:TRUE];
    #endif
    
    int usableSpace = GetScreenVirtualWidth() - (2 * sTopBarMenuPadding);
    
    int curX = sTopBarMenuPadding;
    int numButtons = 2;
#if !NEON_SOLITAIRE_21
    numButtons += 3;
#endif
    int spacing = usableSpace / numButtons;
    
    curX += ((spacing - sTopBarButtonWidth) / 2);
    
    Vector3 curPosition;
    
    curPosition.mVector[x] = curX;
    curPosition.mVector[y] = topbar_y;
    curPosition.mVector[z] = 0;
    
#if !NEON_SOLITAIRE_21
    curPosition.mVector[x] += spacing;
    [self InitMainMenuButton:NeonMenu_Main_Extras_GameCenter MMID:MMButton_GameCenter visible:TRUE on:TRUE enabled:TRUE uiGroup:mActiveMenu.uiObjects position:&curPosition];
    
    curPosition.mVector[x] += spacing;
    [self InitMainMenuButton:NeonMenu_Main_Extras_Contact_Us MMID:MMButton_Contact_Us visible:TRUE on:TRUE enabled:TRUE uiGroup:mActiveMenu.uiObjects position:&curPosition];
#endif

    [self InitMainMenuButton:NeonMenu_Main_Extras_IAP_Store MMID:MMButton_IAP_NoAds visible:TRUE on:TRUE enabled:TRUE uiGroup:mActiveMenu.uiObjects];
#if USE_MARATHON
    [self InitMainMenuButton:Run21_Main_Marathon	MMID:MMButton_Marathon  visible:TRUE on:TRUE enabled:TRUE uiGroup:mActiveMenu.uiObjects];
#endif
	return;
}


-(void)ActivateTextBox:(NSString*)prompt
{
    // Display message asking user to confirm they want to start a new game
    TextBoxParams tbParams;
    
    [TextBox InitDefaultParams:&tbParams];
    
    SetColorFromU32(&tbParams.mColor,		NEON_WHI);
    SetColorFromU32(&tbParams.mStrokeColor, NEON_BLA);
    
    tbParams.mStrokeSize	= 2;
    tbParams.mString		= NSLocalizedString(prompt, NULL);
    tbParams.mFontSize		= 18;
    tbParams.mFontType		= NEON_FONT_STYLISH;
    tbParams.mWidth			= 320;	// Gutter the left and right border of screen
    tbParams.mUIGroup		= mActiveMenu.uiObjects;
    
    TextBox* textBox		= [(TextBox*)[TextBox alloc] InitWithParams:&tbParams];
    [textBox SetVisible:FALSE];
    [textBox Enable];
    
    PlacementValue placementValue;
    SetRelativePlacement(&placementValue, PLACEMENT_ALIGN_CENTER, PLACEMENT_ALIGN_CENTER);
    
    [textBox SetPlacement:&placementValue];
    [textBox SetPositionX:320 Y:90 Z:0];
    
    [textBox release];
}


-(void)ActivateLevelSelectCard:(int)cardID
{
	NSString				*textureString;
	
	NSMutableArray			*textureFilenames = [[NSMutableArray alloc] initWithCapacity:LSSTATUS_NUM];
	
	MultiStateButtonParams  buttonParams;
	[MultiStateButton		InitDefaultParams:&buttonParams];
	
	textureString = @"r21level_locked.papng";	// Locked cards are not individually created, we use a global one.
	[ textureFilenames insertObject:textureString atIndex:LSSTATUS_LOCKED ];
	
	textureString = [LevelDefinitions GetCardTextureForLevel:cardID];
	[ textureFilenames insertObject:textureString atIndex:LSSTATUS_AVAILABLE ];
	
	buttonParams.mButtonTextureFilenames	= textureFilenames;
	buttonParams.mBoundingBoxCollision		= TRUE;
	buttonParams.mUIGroup					= mActiveMenu.secondaryObjects;
	
	levelSelect.mLevelButton[cardID].button	= [(MultiStateButton*)[MultiStateButton alloc] InitWithParams:&buttonParams];
	MultiStateButton	*curButton			= levelSelect.mLevelButton[cardID].button;
    [curButton release];
	
	curButton->mIdentifier					= LSID_LevelButtonBase + cardID;
	[curButton								SetVisible:FALSE];
	[curButton								SetListener:self];
	[curButton								SetProjected:FALSE];
    
    int locOffset = cardID % NUM_LEVELS_IN_ROOM;
    
	[ curButton								SetPosition:&sLS_LevelPos[locOffset]	];
    
    TextBoxParams tbParams;
    [TextBox InitDefaultParams:&tbParams];
    SetColorFromU32(&tbParams.mColor,          NEON_WHI);
    SetColorFromU32(&tbParams.mStrokeColor,    NEON_BLA);
    
    tbParams.mStrokeSize	= 8;
    tbParams.mString		= [[Flow GetInstance].LevelDefinitions GetLevelDescription:cardID];
    tbParams.mFontSize		= 14;
    tbParams.mFontType		= NEON_FONT_NORMAL;
    tbParams.mAlignment     = kCTTextAlignmentCenter;
    tbParams.mUIGroup		= mActiveMenu.uiObjects;
    
    levelSelect.mLevelDescription[cardID] = [(TextBox*)[TextBox alloc] InitWithParams:&tbParams];
    
    [levelSelect.mLevelDescription[cardID] SetVisible:FALSE];
    [levelSelect.mLevelDescription[cardID] SetPositionX:sLS_LevelPos[locOffset].mVector[x] + 35 Y:sLS_LevelPos[locOffset].mVector[y] + 112 Z:0.0];
    [levelSelect.mLevelDescription[cardID] release];

	[textureFilenames release];
	mNumButtons++;
}

-(NeonButton*)InitLevelSelectBottomButton:(LevelSelectButtons)linkMenuID levelSelectID:(LevelSelectIDs)lsID
{
	NeonButton*         curButton;
	NeonButtonParams    buttonParams;
	//int                 nButtonIndex	= [mActiveMenu.uiObjects count];
	
	//NSAssert(nButtonIndex >= 0 && nButtonIndex < LSButton_Num , @"Invalid Button Index in InitButton");
    //NSAssert(mNumButtons >= 0 && mNumButtons < LSButton_Num, @"Invalid number of buttons already created");
    
	[NeonButton InitDefaultParams:&buttonParams];
    
    buttonParams.mTexName					= [NSString stringWithUTF8String:levelSelectButtonTextureOffName[linkMenuID]];
    buttonParams.mPregeneratedGlowTexName	= [NSString stringWithUTF8String:levelSelectButtonTextureLitName[linkMenuID]];
	buttonParams.mToggleTexName				= [NSString stringWithUTF8String:levelSelectButtonTextureUnlitName[linkMenuID]];
    buttonParams.mBorderSize				= 1;
    buttonParams.mQuality					= NEON_BUTTON_QUALITY_HIGH;
    buttonParams.mFadeSpeed					= BUTTON_FADE_SPEED;
    buttonParams.mUIGroup					= mActiveMenu.uiObjects;
	buttonParams.mUISoundId					= SFX_MENU_BUTTON_PRESS;
    buttonParams.mBoundingBoxCollision		= TRUE;
    SetVec2(&buttonParams.mBoundingBoxBorderSize, 0, 4);
	
	curButton = [(NeonButton*)[NeonButton alloc] InitWithParams:&buttonParams];
    [curButton release];
	
	curButton->mIdentifier = lsID;	// Might want to change this
    [curButton SetVisible:FALSE];
    
    [curButton Enable];
	[curButton SetPosition:&slevelSelectButtonPositions[linkMenuID] ];
	[curButton SetListener:self];
    
    switch ( linkMenuID )
    {
        case LSButton_Back:
            levelSelect.mBackButton = curButton;
            break;
            
        case LSButton_Next:
            levelSelect.mNextButton = curButton;
            break;
            
        case LSButton_Prev:
            levelSelect.mPrevButton = curButton;
            break;
    }

    mNumButtons++;
    
    return curButton;
}

-(void)LeaveLevelSelectMenu
{
	[levelSelect.mBackButton release];
    [levelSelect.mNextButton release];
    [levelSelect.mPrevButton release];
    
    bottomBar.mTornadoAmount = NULL;
    bottomBar.mXRayAmount = NULL;
    
	return;
}

-(void)ActivateLevelSelectTitle
{
    TextBoxParams tbParams;
    [TextBox InitDefaultParams:&tbParams];
    SetColorFromU32(&tbParams.mColor,          NEON_WHI);
    SetColorFromU32(&tbParams.mStrokeColor,    NEON_BLA);
    
    tbParams.mStrokeSize	= 8;
    tbParams.mString		= NSLocalizedString(@"LS_ChooseLevel", NULL);
    tbParams.mFontSize		= 20;
    tbParams.mFontType		= NEON_FONT_STYLISH;
    tbParams.mUIGroup		= mActiveMenu.uiObjects;
    
    TextBox* title = [(TextBox*)[TextBox alloc] InitWithParams:&tbParams];
    
    [title    SetVisible:TRUE];
    [title    SetPositionX:160 Y:55 Z:0.0];
    [title    release];
}

-(void)TutorialComplete
{
    [super TutorialComplete];
    
    for (UIObject* curObject in mHintDisabledObjects)
    {
        [curObject SetActive:TRUE];
        curObject.FadeWhenInactive = TRUE;
    }
    
    [mHintDisabledObjects removeAllObjects];
}

-(void)ActivatePlayTutorial:(ENeonMenu)menuID
{
	[ self InitBackButton:NeonMenu_Main];
}

-(void)InitBackButton:(ENeonMenu)menuID
{
    NeonButtonParams	button;
    [NeonButton InitDefaultParams:&button ];
	
	if ( mNumButtons == 0 )
		[ self InitLogo ];
    
	button.mTexName					= [NSString stringWithUTF8String:levelSelectButtonTextureUnlitName[LSButton_Back]];
    button.mToggleTexName			= [NSString stringWithUTF8String:levelSelectButtonTextureUnlitName[LSButton_Back]];
    button.mPregeneratedGlowTexName	= [NSString stringWithUTF8String:levelSelectButtonTextureLitName[LSButton_Back]];
    button.mText					= NULL;
	button.mTextSize				= 18;
    button.mBorderSize				= 1;
    button.mQuality					= NEON_BUTTON_QUALITY_HIGH;
    button.mFadeSpeed				= BUTTON_FADE_SPEED;
	button.mUIGroup                 = mActiveMenu.uiObjects;
    button.mBoundingBoxCollision    = TRUE;
	button.mUISoundId				= SFX_MENU_BACK;
	SetColorFromU32(&button.mBorderColor	, NEON_BLA);
    SetColorFromU32(&button.mTextColor		, NEON_WHI);
    SetRelativePlacement(&button.mTextPlacement, PLACEMENT_ALIGN_CENTER, PLACEMENT_ALIGN_CENTER);
    SetVec2(&button.mBoundingBoxBorderSize, 2, 2);
    
    NeonButton* backButton = [ (NeonButton*)[NeonButton alloc] InitWithParams:&button ];
    backButton->mIdentifier = menuID;
    [backButton SetVisible:FALSE];
    [backButton Enable];
    [backButton SetPositionX:Sbar_Y1 Y:Sbar_Y1 Z:0.0];
	[backButton SetPosition:&slevelSelectButtonPositions[LSButton_Back] ];
    [backButton SetListener:self];
    [backButton release];
}

-(void)Draw
{
	
}

-(void)DrawOrtho
{
}

-(void)ProcessEvent:(EventId)inEventId withData:(void*)inData
{
    switch ( inEventId )
    {
        case EVENT_MAIN_MENU_ACTIVATE_VIP:
        {
            //if the player has just bought VIP, we need to setup the main menu again
            sUserData.mType = USERDATA_TYPE_MENU;
            sUserData.mData = NeonMenu_Main;
            [self LeaveMenu];
            break;
        }
        
        case EVENT_MAIN_MENU_LEAVE_MENU:
        {
            sUserData.mType = USERDATA_TYPE_FLOW;
            sUserData.mData = 0;
            sUserData.mDataTwo = GAMEMODE_TYPE_WATERBALLOON_TOSS;
            [self LeaveMenu];
            break;
        }
        
        case EVENT_IAP_DELIVER_CONTENT:
        {
            NSString* identifier = (NSString*)inData;
            IapProduct product = [[InAppPurchaseManager GetInstance] GetIAPWithIdentifier:identifier];
            
            if (mActiveMenu.menuID == Run21_Main_LevelSelect)
            {
                [bottomBar.mArrow Disable];
                [bottomBar.mRemoveAds Disable];
            }
            
            break;
        }
        
        case EVENT_RATED_GAME:
        {
            [self UpdateBottomBar];
            break;
        }
        
        default:
            break;
    }
    
    [super ProcessEvent:inEventId withData:inData];
}

-(BOOL)ShouldShowBottomBarRoomUnlockButton
{
    BOOL showRoomUnlockButton = FALSE;
    
    {
        showRoomUnlockButton = TRUE;
    }
    
    return showRoomUnlockButton;
}

-(void)SetCurrentMenuActive:(BOOL)inActive
{
    int numObjects = (int)[mActiveMenu.uiObjects count];
        
    for (int i = 0; i < numObjects; i++)
    {
        UIObject* curObject = (UIObject*)[mActiveMenu.uiObjects objectAtIndex:i];
        
        if ([curObject GetVisible])
        {
            [curObject SetActive:inActive];
        }
    }
    
    numObjects = (int)[mActiveMenu.secondaryObjects count];
    
    for (int i = 0; i < numObjects; i++)
    {
        UIObject* curObject = (UIObject*)[mActiveMenu.secondaryObjects objectAtIndex:i];
        
        if ([curObject GetVisible])
        {
            [curObject SetActive:inActive];
        }
    }
}

-(LevelSelectMenu*)GetLevelSelect
{
    return &levelSelect;
}

-(void)FadeComplete:(NSObject*)inObject;
{
    if (inObject == NULL)
    {
        [[GameStateMgr GetInstance] Push:[IAPStore alloc] ];
    }
    else if ([inObject class] == [MainMenu class])
    {
        NSLog(@"Application Load Time is %f", NeonEndTimer());
    }
    else
    {
        NSAssert(FALSE, @"Unknown fade path");
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        UITextField* redemptionCode = [alertView textFieldAtIndex:0];
        NSString* text = [redemptionCode text];
    }
}

+(NSString*)emptyStarFilename
{
    return [NSString stringWithUTF8String:emptyStarIconName];
}

+(NSString*)fullStarFilenameForRoom:(LevelSelectRoom)inRoom
{
    return [NSString stringWithUTF8String:fullStarIconNames[inRoom]];
}

+(NSString*)fullStarFilenameForLevel:(int)inLevel
{
    LevelSelectRoom room = [[Flow GetInstance].LevelDefinitions GetRoomForLevel:inLevel];

    return [NSString stringWithUTF8String:fullStarIconNames[room]];
}

@end

@implementation FacebookUIDelegate

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString        *title      = [alertView buttonTitleAtIndex:buttonIndex];
    UserMenuAction  uma         = UMA_NUM;
    BOOL            bVisitWeb   = FALSE;
    
    if ([title isEqualToString:NSLocalizedString(@"LS_Login",NULL)])
    {
        uma = UMA_Facebook_Login;
    }
    else if ([title isEqualToString:NSLocalizedString(@"LS_Logout",NULL)])
    {
        uma = UMA_Facebook_Logout;
        //[[NeonAccountManager GetInstance] Logout];
        
    }
    else if ([title isEqualToString:NSLocalizedString(@"LS_Community",NULL)])
    {
        uma         = UMA_Facebook_Community;
        bVisitWeb   = TRUE;
    }
    else
    {
        uma         = UMA_Facebook_Cancel;
        // No-op
    }
        
    if ( bVisitWeb )
    {
        UIApplication *neonApp      = [ UIApplication sharedApplication ];
        NSURL *facebookNativeSite   = [ NSURL URLWithString:@"fb://profile/172787159547068"];                               // FB Page's profile_owner ID, verify with: https://facebook.com/172787159547068
        NSURL *facebookBrowserSite  = [ NSURL URLWithString:@"https://www.facebook.com/SolitaireVsBlackjackCommunity"];     // Browser URL
        
        if ( [neonApp canOpenURL:facebookNativeSite] )
        {
            [ neonApp openURL:facebookNativeSite ];
        }
        else
        {
            [ neonApp openURL:facebookBrowserSite ];
        }
    }
        
}
@end

@implementation CommunityDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString        *title      = [alertView buttonTitleAtIndex:buttonIndex];
    UserMenuAction  uma         = UMA_NUM;
    BOOL            bVisitWeb   = FALSE;
    BOOL            bEmail      = FALSE;
    
    if ([title isEqualToString:NSLocalizedString(@"LS_Email_Us",NULL)])
    {
        uma = UMA_NeonCommunity_ContactUs;
        bEmail = TRUE;
    }
    else if ([title isEqualToString:NSLocalizedString(@"LS_WebComic",NULL)])
    {
        uma         = UMA_NeonCommunity_WebComic;
        bVisitWeb   = TRUE;
    }
    else
    {
        // No-op
        uma         = UMA_NeonCommunity_Cancel;
    }
    
    if ( bVisitWeb )
    {
        UIApplication *neonApp      = [ UIApplication sharedApplication ];
        NSURL *comicSite  = [ NSURL URLWithString:@"http://comic.neongam.es"];
        [ neonApp openURL:comicSite ]; 
    }
    if ( bEmail )
    {
        NSLog(@"NeonMenu_Main_Extras_Contact_Us - Does not Show on Simulator");
        
        NSDictionary *gameInfo = [[NSBundle mainBundle] infoDictionary];
        
        NSString *GameName      = [gameInfo objectForKey:@"CFBundleDisplayName"];
        NSString *GameVersion   = [gameInfo objectForKey:@"CFBundleVersion"];
        NSString *address       = @"support@neongames.us";
        NSString *subject       = [NSString stringWithFormat:@"%@ Feedback",GameName];
        NSString *body          = [NSString stringWithFormat:@"Type your message here\n\n--\n\n%@\nGame Version:%@\n%@ with iOS %@",GameName,GameVersion,machineName(), [[UIDevice currentDevice] systemVersion]];
        
        NSString *URLString     = [NSString stringWithFormat:@"mailto:%@?subject=%@&body=%@",address,subject,body];
        URLString               = [URLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:URLString]];
    }
    
}
@end

@implementation RefillLivesDelegate

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
#if !NEON_SOLITAIRE_21
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    
    if ([title isEqualToString:NSLocalizedString(@"LS_Wait",NULL)])
    {
        NSLog(@"Player out of lives popup, canceled purchase");
    }
    else if ([title isEqualToString:NSLocalizedString(@"LS_FillLives",NULL)])
    {
        [[GameStateMgr GetInstance] Push:[[IAPStore alloc] InitWithTab:IAPSTORE_TAB_LIVES]];
    }
#endif
}
//This function is required to call facebook web dialog
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString:NSLocalizedString(@"LS_AskAFriend",NULL)])
    {
    #if FACEBOOK_ASK_FOR_LIVES
        [[NeonAccountManager GetInstance] FB_SendLifeRequest];
    #endif
    }
}

@end