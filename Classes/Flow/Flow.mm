//
//  Flow.m
//  Neon21
//
//  Copyright Neon Games 2008. All rights reserved.
//

#import "Flow.h"

#import "IncrementalGameState.h"

#import "FMVState.h"
#import "GameStateMgr.h"
#import "MainMenu.h"
#import "SaveSystem.h"
#import "TutorialScript.h"
#import "LevelDefinitions.h"
#import "PizzaPowerupInfo.h"
#import "FoodManager.h"
#import "SplitTestingSystem.h"

FlowStateParams	sFlowStateParams[] =    { {   @"MainMenu", TRUE  } };
														
static Flow* sInstance = NULL;

@implementation Flow

@synthesize LevelDefinitions = mLevelDefinitions;
@synthesize PizzaPowerupInfo = mPizzaPowerupInfo;

+(void)CreateInstance
{
    NSAssert(sInstance == NULL, @"Trying to create Flow when one already exists.");
    
    sInstance = [Flow alloc];
    [sInstance Init];
}

+(void)DestroyInstance
{
    NSAssert(sInstance != NULL, @"No Flow exists.");
    
    [sInstance release];
}

+(Flow*)GetInstance
{
    return sInstance;
}

-(void)Init
{
    mPrevLevel = LEVEL_INDEX_INVALID;
    mLevel = LEVEL_INDEX_INVALID;
    
    mGameModeType = GAMEMODE_TYPE_INVALID;
    mPrevGameModeType = GAMEMODE_TYPE_INVALID;

    mRequestedFacebookLogin = FALSE;
    mRatingAlertVisible = FALSE;
    
    mLevelDefinitions = [(LevelDefinitions*)[LevelDefinitions alloc] Init];
    mPizzaPowerupInfo = [[PizzaPowerupInfo alloc] Init];
    
    [GetGlobalMessageChannel() AddListener:self];
}

-(void)dealloc
{
    [super dealloc];
    
    [mLevelDefinitions release];
    [mPizzaPowerupInfo release];
}

-(GameModeType)GetGameMode
{
    return mGameModeType;
}

-(int)GetLevel
{
    return mLevel;
}

-(BOOL)IsInRun21
{
    return (mGameModeType == GAMEMODE_TYPE_WATERBALLOON_TOSS);
}
-(BOOL)IsInRainbow
{
    NSAssert(FALSE, @"This is deprecated");
    return FALSE;
}

-(void)AdvanceLevel
{
    [self EnterGameMode:mGameModeType level:(mLevel + 1)];
}

-(void)RestartLevel
{
    [self EnterGameMode:mGameModeType level:mLevel];
}

-(void)AppRate
{
    NSString* RateAppURL = NULL;
    
    if (SYSTEM_VERSION_LESS_THAN(@"7.0"))
    {
        RateAppURL = [NSString stringWithFormat:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%d", NEON_APP_ID];
    }
    else
    {
        RateAppURL = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%d", NEON_APP_ID];
    }
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:RateAppURL]];
    
    [[SaveSystem GetInstance] SetRatedGame:REVIEW_LEVEL_COMPLETED];
    [GetGlobalMessageChannel() SendEvent:EVENT_RATED_GAME withData:NULL];
    
    u64 numItems = [[FoodManager GetInstance] GetNumPizza];
    numItems *= 2;
    
    [[FoodManager GetInstance] SetNumPizza:numItems];
    
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NULL message:NSLocalizedString(@"LS_RatingAwardMessage", NULL) delegate:NULL cancelButtonTitle:NSLocalizedString(@"LS_OK", NULL) otherButtonTitles:NULL];
    [alertView show];
    [alertView release];
}

-(void)AppGift
{
    NSString *GiftAppURL    = [NSString stringWithFormat:@"itms-appss://buy.itunes.apple.com/WebObjects/MZFinance.woa/wa/giftSongsWizard?gift=1&salableAdamId=%d&productType=C&pricingParameter=STDQ&mt=8&ign-mscache=1", NEON_APP_ID];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:GiftAppURL]];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    
    if([title isEqualToString:NSLocalizedString(@"LS_Prompt_RateApp_Cancel", NULL)])
    {
        [[NeonMetrics GetInstance] logEvent:@"Rate App Declined" withParameters:NULL];
    }
    else if([title isEqualToString:NSLocalizedString(@"LS_Prompt_RateApp_OK", NULL)])
    {
        [[NeonMetrics GetInstance] logEvent:@"Rate App Accepted" withParameters:NULL];
        [self AppRate];
    }
    else if([title isEqualToString:NSLocalizedString(@"LS_Prompt_RateApp_Never", NULL)])
    {
        [[NeonMetrics GetInstance] logEvent:@"Rate App Never" withParameters:NULL];
        [[SaveSystem GetInstance] SetRatedGame:REVIEW_LEVEL_DONT_ASK];
    }
    else
    {
        NSLog(@"Unknown response from Rating Prompt");
    }
    
    mRatingAlertVisible = FALSE;
}

-(void)PromptForUserRatingTally
{
    if (([[SaveSystem GetInstance] GetRatedGame] >= REVIEW_LEVEL_DONT_ASK) || (mRatingAlertVisible))
        return;
    
    // Prompt user here.  LS_Prompt_RateApp_Message
    [UIApplication sharedApplication].statusBarOrientation = UIInterfaceOrientationLandscapeRight;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"LS_Prompt_RateApp_Title", NULL)
                                                    message:NULL
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"LS_Prompt_RateApp_Never", NULL)
                                          otherButtonTitles:NSLocalizedString(@"LS_Prompt_RateApp_OK", NULL),
                                                            NSLocalizedString(@"LS_Prompt_RateApp_Cancel", NULL),
                          nil];
    
    [[NeonMetrics GetInstance] logEvent:@"Rate App Presented" withParameters:NULL];
    
    mRatingAlertVisible = TRUE;
    
    [alert show];
}

-(void)EnterGameMode:(GameModeType)inGameModeType level:(int)inLevel
{
    mPrevLevel = mLevel;
    mPrevGameModeType = mGameModeType;
    
    mLevel = inLevel;
    mGameModeType = inGameModeType;
    
    [self SetupGame];
}

-(void)ExitGameMode
{
    [[GameStateMgr GetInstance] ResumeProcessing];

    int numPops = 1;
    
    GameState* curState = (GameState*)[[GameStateMgr GetInstance] GetActiveStateAfterOperations];
    
    while(true)
    {
        mPrevLevel = [curState GetLevel];
        mPrevGameModeType = [curState GetGameModeType];
        
        GameState* parentState = (GameState*)curState->mParentState;
        
        if (parentState == NULL)
        {
            mLevel = LEVEL_INDEX_INVALID;
            mGameModeType = GAMEMODE_TYPE_INVALID;
            
            break;
        }
        
        mLevel = [parentState GetLevel];
        mGameModeType = [parentState GetGameModeType];
        
        if (mGameModeType != mPrevGameModeType)
        {
            break;
        }

        curState = parentState;
        
        numPops++;
    }

    for (int i = 0; i < (numPops - 1); i++)
    {
        [[GameStateMgr GetInstance] PopTruncated:TRUE];
    }
    
    [[GameStateMgr GetInstance] Pop];
}

-(void)SetupGame
{
    [mLevelDefinitions StartLevel];
	
	// What type of mode are we in?
	switch (mGameModeType)
	{
		case GAMEMODE_TYPE_MENU:
        {
            FlowStateParams* params = &sFlowStateParams[mLevel];
            FlowStateParams* prevParams = NULL;
            
            if ((mPrevLevel != LEVEL_INDEX_INVALID) && (mPrevGameModeType == GAMEMODE_TYPE_MENU))
            {
                prevParams = &sFlowStateParams[mPrevLevel];
            }

            GameState* newState = [NSClassFromString(params->mStateName) alloc];
            
            if ((prevParams != NULL) && (prevParams->mKeepSuspended))
            {
                [[GameStateMgr GetInstance] Push:newState];
            }
            else
            {
                [[GameStateMgr GetInstance] ReplaceTop:newState];
            }
            
			break;
        }
			
        case GAMEMODE_TYPE_WATERBALLOON_TOSS:
        {            
            IncrementalGameState* newState = [IncrementalGameState alloc];
            
            switch(mPrevGameModeType)
            {
                case GAMEMODE_TYPE_WATERBALLOON_TOSS:
                {
                    GameState* pendingState = NULL;
                    
                    while(true)
                    {
                        pendingState = (GameState*)[[GameStateMgr GetInstance] GetActiveStateAfterOperations];
                        
                        if ((pendingState == NULL) || ([((GameState*)pendingState->mParentState) class] == [MainMenu class]) || ([pendingState class] == [MainMenu class]))
                        {
                            break;
                        }
                        else
                        {
                            [[GameStateMgr GetInstance] Pop];
                        }
                    }
                    
                    [[GameStateMgr GetInstance] ReplaceTop:newState];
                    break;
                }
                
                case GAMEMODE_TYPE_MENU:
                case GAMEMODE_TYPE_INVALID:
                {
                    [[GameStateMgr GetInstance] Push:newState];
                    break;
                }
                
                default:
                {
                    NSAssert(FALSE, @"Unknown game mode");
                }
            }
            
			break;
        }

		default:
			NSAssert(FALSE, @"Undefined Flow Type"); 
			break;	
	}
	
}

-(BOOL)UnlockNextLevel
{
    NSAssert(mGameModeType == GAMEMODE_TYPE_WATERBALLOON_TOSS, @"This function is only supported in Run21 mode");
        
    // FALSE, didn't show a dialog
    return FALSE;
}


-(CasinoID)GetCasinoId
{
    NSAssert(mGameModeType == GAMEMODE_TYPE_WATERBALLOON_TOSS, @"Invalid game mode type");
    
    return [mLevelDefinitions GetCasinoId:mLevel];
}

-(LevelDefinitions*)GetLevelDefinitions
{
    return mLevelDefinitions;
}

-(void)SetRequestedFacebookLogin:(BOOL)inRequested
{
    mRequestedFacebookLogin = inRequested;
}

-(BOOL)GetRequestedFacebookLogin
{
    return mRequestedFacebookLogin;
}

-(void)ProcessMessage:(Message*)inMsg
{
    switch(inMsg->mId)
    {
        case EVENT_INCREMENTAL_GAME_UNLOCK_STATE_CHANGED:
        {
            if ([(NSNumber*)inMsg->mData intValue] >= PIZZA_POWERUP_PIZZA_PRINTER)
            {
                [self PromptForUserRatingTally];
            }
            
            break;
        }
    }
}

@end