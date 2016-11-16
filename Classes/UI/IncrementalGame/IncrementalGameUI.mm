//
//  WaterBalloonTossUI.m
//  WaterBalloonToss
//
//  Created by Rishi Gupta on 5/13/14.
//  Copyright (c) 2014 Neon Games LLC. All rights reserved.
//

#import "IncrementalGameUI.h"
#import "Fader.h"
#import "AppDelegate.h"
#import "EAGLView.h"
#import "BalloonLaunchIndicator.h"
#import "UIGroup.h"
#import "MeshBuilder.h"
#import "SimpleModel.h"
#import "IncrementalGameState.h"
#import "PizzaEntity.h"
#import "CameraStateMgr.h"
#import "IncrementalGameState.h"
#import "NeonList.h"
#import "PizzaPowerupInfo.h"
#import "IncrementalGamePowerup.h"
#import "IncrementalGamePowerupDescription.h"
#import "TextBox.h"
#import "FoodManager.h"
#import "Button.h"
#import "StringCloud.h"
#import "HintSystem.h"
#import "AdvertisingManager.h"
#import "SplitTestingSystem.h"
#import "IncrementalGameIAP.h"
#import "CrystalItem.h"
#import "CrystalItemMeter.h"
#import "InGameNotificationManager.h"

#define GetStateMachine()  ((IncrementalGameUIStateMachine*)mStateMachine)

static const int LIST_OFFSET = 50;

// IncrementalGameUIStateMachine.  Manages the state that the current incremental game UI is in
@interface IncrementalGameUIStateMachine : StateMachine<ButtonListenerProtocol>
{
}

@property(assign) IncrementalGameUI*    IncrementalGameUI;

-(instancetype)InitWithUI:(IncrementalGameUI*)inIncrementalGameUI;
-(BOOL)ButtonEvent:(ButtonEvent)inEvent Button:(Button*)inButton;

@end

// IncrementalGameUIBaseState.  Base state of the UI (list on the side showing powerups)
@interface IncrementalGameUIBaseState : State<NeonListListener, ButtonListenerProtocol>
{
}

-(void)Startup;
-(void)Shutdown;
-(void)Resume;
-(void)Suspend;

-(void)NeonListEvent:(NeonListEvent)inEvent object:(UIObject*)inObject;
-(BOOL)ButtonEvent:(ButtonEvent)inEvent Button:(Button*)inButton;

@end

// IncrementalGameUIShowDescriptionState.  When the description bar is over the Powerup List
@interface IncrementalGameUIShowDescriptionState : State<ButtonListenerProtocol>
{
    IncrementalGamePowerupDescription*   mActiveDescription;
}

-(void)Startup;
-(void)Shutdown;
-(void)Resume;
-(void)Suspend;

-(BOOL)ButtonEvent:(ButtonEvent)inEvent Button:(Button*)inButton;

@end

// IncrementalGameUIShowBoosterPaneState.  When the booster pane is over the Powerup List
@interface IncrementalGameUIShowBoosterPaneState : State<ButtonListenerProtocol, MessageChannelListener>
{
    BOOL mStringCloudVisible;
}

-(void)Startup;
-(void)Shutdown;
-(void)Resume;
-(void)Suspend;

-(void)Close;

-(void)ProcessMessage:(Message*)inMsg;
-(BOOL)ButtonEvent:(ButtonEvent)inEvent Button:(Button*)inButton;

@end

// IncrementalGameUIStateMachine implementation
@implementation IncrementalGameUIStateMachine

@synthesize IncrementalGameUI = mIncrementalGameUI;

-(instancetype)InitWithUI:(IncrementalGameUI*)inIncrementalGameUI
{
    [super Init];
    
    self.IncrementalGameUI = inIncrementalGameUI;
    
    [mIncrementalGameUI.GlobalCloseButton SetListener:self];
    
    return self;
}

-(BOOL)ButtonEvent:(ButtonEvent)inEvent Button:(Button*)inButton
{
    if (inEvent == BUTTON_EVENT_UP)
    {
        if (inButton == mIncrementalGameUI.GlobalCloseButton)
        {
            [self Pop];
        }
    }
    
    return TRUE;
}

@end

// IncrementalGameUIBaseState
@implementation IncrementalGameUIBaseState

-(void)Startup
{
    [super Startup];
    
    GetStateMachine().IncrementalGameUI.List.Listener = self;
    [GetStateMachine().IncrementalGameUI.BoosterButton SetListener:self];
}

-(void)Shutdown
{
    [super Shutdown];
    
    GetStateMachine().IncrementalGameUI.List.Listener = NULL;
    [GetStateMachine().IncrementalGameUI.BoosterButton SetListener:NULL];
}

-(void)Resume
{
    [super Resume];
    
    [GetStateMachine().IncrementalGameUI.List SetActive:TRUE];
    [GetStateMachine().IncrementalGameUI.List UnhighlightActiveItem];
}

-(void)Suspend
{
    [GetStateMachine().IncrementalGameUI.List SetActive:FALSE];
    [super Suspend];
}

-(BOOL)ButtonEvent:(ButtonEvent)inEvent Button:(Button*)inButton
{
    if ([GetStateMachine() GetActiveState] == self)
    {
        if (inEvent == BUTTON_EVENT_UP)
        {
            [mStateMachine Push:[IncrementalGameUIShowBoosterPaneState alloc]];
        }
    }

    return TRUE;
}

-(void)NeonListEvent:(NeonListEvent)inEvent object:(UIObject*)inObject
{
    switch(inEvent)
    {
        case NEON_LIST_EVENT_UP:
        {
            int index = [GetStateMachine().IncrementalGameUI.List IndexOfObject:inObject];
            
            PizzaPowerupUnlockState powerupUnlockState = [[SaveSystem GetInstance] GetPowerupUnlockState:(PizzaPowerup)index];
            
            if (powerupUnlockState == PIZZA_POWERUP_UNLOCKED)
            {
                [mStateMachine Push:[IncrementalGameUIShowDescriptionState alloc] withParams:[NSNumber numberWithInt:index]];
            }
            
            break;
        }
    }
}
@end

// IncrementalGameUIShowDescriptionState
@implementation IncrementalGameUIShowDescriptionState

-(void)Startup
{
    [super Startup];
    
    int objectIndex = [(NSNumber*)mParams intValue];
    IncrementalGamePowerupDescription* description = [GetStateMachine().IncrementalGameUI GetDescriptionAtIndex:objectIndex];
    mActiveDescription = description;
    
    Path* path = [[Path alloc] Init];
    [path AddNodeX:-[description GetWidth] y:0 z:0 atTime:0];
    [path AddNodeX:0 y:0 z:0 atTime:0.3];
    
    [description AnimateProperty:GAMEOBJECT_PROPERTY_POSITION withPath:path];
    [path release];
    
    [description.CloseButton SetListener:self];
    [description.BuyButton SetListener:self];
    
    mActiveDescription.Displayed = TRUE;
}

-(void)Shutdown
{
    [super Shutdown];
    
    [mActiveDescription.CloseButton SetListener:NULL];
    [mActiveDescription.BuyButton SetListener:NULL];
    
    mActiveDescription.Displayed = FALSE;
}

-(void)Resume
{
    [super Resume];
}

-(void)Suspend
{
    [super Suspend];
}

-(BOOL)ButtonEvent:(ButtonEvent)inEvent Button:(Button*)inButton
{
    switch(inEvent)
    {
        case BUTTON_EVENT_UP:
        {
            if (inButton == mActiveDescription.CloseButton)
            {
                Path* path = [[Path alloc] Init];
                [path AddNodeX:0 y:0 z:0 atTime:0];
                [path AddNodeX:-[mActiveDescription GetWidth] y:0 z:0 atTime:0.3];
                
                [mActiveDescription AnimateProperty:GAMEOBJECT_PROPERTY_POSITION withPath:path];
                [path release];

                [mActiveDescription.CloseButton SetListener:NULL];
                
                [mStateMachine Pop];
            }
            else if (inButton == mActiveDescription.BuyButton)
            {
                [[FoodManager GetInstance] AddPowerup:(PizzaPowerup)[(NSNumber*)mParams intValue]];
                [mActiveDescription UpdatePrice];
                [[GetStateMachine().IncrementalGameUI GetPowerupAtIndex:[(NSNumber*)mParams intValue]] UpdateQuantity];
                
                [mActiveDescription EvaluateUpgradeButton];
                
                PizzaPowerupInfo* pizzaPowerupInfo = [Flow GetInstance].PizzaPowerupInfo;
                
                int objectIndex = [(NSNumber*)mParams intValue];
                PizzaPowerupStats* stats = [pizzaPowerupInfo GetStatsForPowerup:(PizzaPowerup)objectIndex];
                
                [[NeonMetrics GetInstance] logEvent:@"Buy Building" withParameters:[NSDictionary dictionaryWithObject:stats.Name forKey:@"Building Type"]];
            }
            
            break;
        }
    }
    
    return TRUE;
}

@end

// IncrementalGameUIShowBoosterPaneState
@implementation IncrementalGameUIShowBoosterPaneState

-(void)Startup
{
    [super Startup];
    
    NeonList* iapList = GetStateMachine().IncrementalGameUI.IAPList;
    NeonList* powerupList = GetStateMachine().IncrementalGameUI.List;
    
    // Animate in IAP list
    Path* path = [[Path alloc] Init];
    
    Vector3 position;
    [iapList GetPosition:&position];
    
    [path AddNodeX:position.mVector[x] y:0 z:0 atTime:0];
    [path AddNodeX:0 y:0 z:0 atTime:0.3];
    
    [iapList AnimateProperty:GAMEOBJECT_PROPERTY_POSITION withPath:path];
    [path release];
    
    // Animate out the building list
    path = [[Path alloc] Init];
    
    [powerupList GetPosition:&position];
    
    [path AddNodeX:0 y:position.mVector[y] z:0 atTime:0];
    [path AddNodeX:-(int)[powerupList GetWidth] y:position.mVector[y] z:0.0 atTime:0.3];
    
    [powerupList AnimateProperty:GAMEOBJECT_PROPERTY_POSITION withPath:path];
    
    [path release];
    
    // Animate out the extras button
    path = [[Path alloc] Init];
    
    [GetStateMachine().IncrementalGameUI.BoosterButton GetPosition:&position];
    
    [path AddNodeX:0 y:position.mVector[y] z:0 atTime:0];
    [path AddNodeX:-(int)[powerupList GetWidth] y:position.mVector[y] z:0.0 atTime:0.3];
    
    [GetStateMachine().IncrementalGameUI.BoosterButton AnimateProperty:GAMEOBJECT_PROPERTY_POSITION withPath:path];
    
    // Hide StringCloud if necessary
    StringCloud* stringCloud = GetStateMachine().IncrementalGameUI.BoosterStringCloud;
    
    mStringCloudVisible = [stringCloud GetVisible];
    [stringCloud SetVisible:FALSE];
    
    [GetGlobalMessageChannel() AddListener:self];
    
    [[NeonMetrics GetInstance] logEvent:@"Open Extras Menu" withParameters:NULL];
}

-(void)Resume
{
    [super Resume];
}

-(void)Shutdown
{
    [self Close];
    [GetGlobalMessageChannel() RemoveListener:self];
    
    NeonList* powerupList = GetStateMachine().IncrementalGameUI.List;
    
    Path* path = [[Path alloc] Init];
    
    Vector3 position;
    [powerupList GetPosition:&position];
    
    [path AddNodeX:position.mVector[x] y:position.mVector[y] z:0 atTime:0];
    [path AddNodeX:0 y:position.mVector[y] z:0 atTime:0.3];
    
    [powerupList AnimateProperty:GAMEOBJECT_PROPERTY_POSITION withPath:path];
    [path release];
    
    // Animate in the extras button
    path = [[Path alloc] Init];
    
    [GetStateMachine().IncrementalGameUI.BoosterButton GetPosition:&position];
    [path AddNodeX:position.mVector[x] y:position.mVector[y] z:0 atTime:0];
    [path AddNodeX:0 y:0 z:0 atTime:0.3];
    
    [GetStateMachine().IncrementalGameUI.BoosterButton AnimateProperty:GAMEOBJECT_PROPERTY_POSITION withPath:path];
    
    // Show StringCloud if necessary
    StringCloud* stringCloud = GetStateMachine().IncrementalGameUI.BoosterStringCloud;
    [stringCloud SetVisible:mStringCloudVisible];

    
    [super Shutdown];
}

-(void)Suspend
{
    [super Suspend];
}

-(void)Close
{
    NeonList* iapList = GetStateMachine().IncrementalGameUI.IAPList;

    Path* path = [[Path alloc] Init];
    [path AddNodeX:0 y:0 z:0 atTime:0];
    [path AddNodeX:-(int)[iapList GetWidth] y:0 z:0 atTime:0.3];
    
    [iapList AnimateProperty:GAMEOBJECT_PROPERTY_POSITION withPath:path];
    [path release];
}

-(BOOL)ButtonEvent:(ButtonEvent)inEvent Button:(Button*)inButton
{
    return TRUE;
}

-(void)ProcessMessage:(Message*)inMsg
{
    switch(inMsg->mId)
    {
        case EVENT_IAP_DELIVER_CONTENT:
        {
            break;
        }
    }
}

@end

@implementation IncrementalGameUI

@synthesize List = mNeonList;
@synthesize IAPList = mIAPList;
@synthesize BoosterButton = mBoosterButton;
@synthesize BuyBoosterButton = mBuyBoosterButton;
@synthesize ReviewButton = mReviewButton;
@synthesize GlobalCloseButton = mGlobalCloseButton;
@synthesize BoosterStringCloud = mBoosterStringCloud;
@synthesize BackgroundButton = mBackgroundButton;

-(instancetype)InitWithEnvironment:(WaterBalloonEnvironment*)inEnvironment gameState:(IncrementalGameState*)inGameState
{
    [self InitInterfaceGroups];
    
    mGameState = inGameState;
    
    // Fade in when initializing WaterBalloonToss state
    FaderParams faderParams;
    [Fader InitDefaultParams:&faderParams];

    faderParams.mDuration = 0.5f;
    faderParams.mFadeType = FADE_FROM_BLACK;
    faderParams.mFrameDelay = 2;
    faderParams.mCancelFades = TRUE;

    [[Fader GetInstance] StartWithParams:&faderParams];
    
    [self CreatePowerupList];
    [self CreateBoosterButton];
    [self CreateIAPList];
    [self CreatePowerupDescriptions];
    [self CreateQuantity];
    [self CreateHintFinger];
    
    // Crystal Item
    CrystalItemParams* crystalItemParams = [[CrystalItemParams alloc] Init];
    
    crystalItemParams.UIGroup = mUserInterface[UIGROUP_2D];
    crystalItemParams.ImageName = @"crystal_pizza.papng";
    
    mCrystalItem = [[CrystalItem alloc] InitWithParams:crystalItemParams];
    [mCrystalItem SetVisible:FALSE];
    
    // Background crystal item
    crystalItemParams.UIGroup = mUserInterface[UIGROUP_BACKGROUND];
    crystalItemParams.PizzaVisible = FALSE;
    mCrystalItemBG = [[CrystalItem alloc] InitWithParams:crystalItemParams];
    [mCrystalItemBG SetVisible:FALSE];
    [mCrystalItemBG release];
    
    [mCrystalItemBG SetPositionX:425 Y:150 Z:0.0];
    [mCrystalItemBG SetScaleX:2.5 Y:3.0 Z:1.0];
    
    // Crystal Item Meter
    mCrystalItemMeter = [[CrystalItemMeter alloc] InitWithUIGroup:mUserInterface[UIGROUP_2D]];
    [mCrystalItemMeter retain];
    
    [mCrystalItemMeter SetPositionX:(GetScreenAbsoluteWidth() - 4) Y:0 Z:0];
    
    // Put all UI creation before here
    [mUserInterface[UIGROUP_2D] Finalize];
    [[GameObjectManager GetInstance] Add:mUserInterface[UIGROUP_2D]];
    [mUserInterface[UIGROUP_2D] release];
    
    [mUserInterface[UIGROUP_BACKGROUND] Finalize];
    [[GameObjectManager GetInstance] Add:mUserInterface[UIGROUP_BACKGROUND] withRenderBin:RENDERBIN_UNDER_UI];
    [mUserInterface[UIGROUP_BACKGROUND] release];
    
    mStateMachine = [[IncrementalGameUIStateMachine alloc] InitWithUI:self];
    [mStateMachine Push:[IncrementalGameUIBaseState alloc]];
    
    [[TouchSystem GetInstance] AddListener:self];
    [GetGlobalMessageChannel() AddListener:self];
    
    [[[GameStateMgr GetInstance] GetMessageChannel] AddListener:self];
    
    dispatch_async(dispatch_get_main_queue(), ^
    {
        [[GameStateMgr GetInstance] SendEvent:EVENT_INCREMENTAL_GAME_START withData:NULL];
    });
    
    return self;
}

-(void)dealloc
{
    [mStateMachine release];
    [mQuantityBlackBar Remove];
    
    [super dealloc];
}

-(void)Remove
{
    [[[GameStateMgr GetInstance] GetMessageChannel] RemoveListener:self];
    [self release];
}

-(void)Update:(CFTimeInterval)inTimeStep
{
    u64 numPizza = [[FoodManager GetInstance] GetNumPizza];
    
    if (numPizza != mLastNumPizza)
    {
        mLastNumPizza = numPizza;
        
        [mQuantityTextBox SetString:[self CreateNumPizzaString]];
        [self PositionPizzaStrings];
    }
    
    double regenRate = [[FoodManager GetInstance] GetTotalRegenRate];
    
    if (regenRate != mLastRegenRate)
    {
        mLastRegenRate = regenRate;
        
        if ([[FoodManager GetInstance] GetCrystalItemPercentRemaining] > 0.0)
        {
            [mRegenRateTextBox SetString:[NSString stringWithFormat:@"<color=0xFF0000>%@</color>", [self CreateRegenRateString]]];
        }
        else
        {
            [mRegenRateTextBox SetString:[self CreateRegenRateString]];
        }
        
        [self PositionPizzaStrings];
    }
    
    if (([[SaveSystem GetInstance] GetRatedGame] == REVIEW_LEVEL_COMPLETED) || ([[FoodManager GetInstance] GetBooster]))
    {
        [mBoosterStringCloud SetVisible:FALSE];
    }
    else
    {
        if (![mBoosterStringCloud GetVisible])
        {
            CFTimeInterval timeOfLaunch = [[SaveSystem GetInstance] GetTimeOfFirstLaunch];
            
            NSDate* curDate = [[NSDate alloc] init];
            CFTimeInterval curTime = (double)[curDate timeIntervalSince1970];
            [curDate release];

            if ((curTime - timeOfLaunch) > (24 * 60 * 60))
            {
                [mBoosterStringCloud SetVisible:TRUE];
            }
        }
    }
}

-(void)InitInterfaceGroups
{
    [super uiAlloc];
	
	GameObjectBatchParams uiGroupParams;
    [GameObjectBatch InitDefaultParams:&uiGroupParams];
    uiGroupParams.mUseAtlas = TRUE;
    
    mUserInterface[UIGROUP_2D] = [(UIGroup*)[UIGroup alloc] InitWithParams:&uiGroupParams];
    mUserInterface[UIGROUP_BACKGROUND] = [(UIGroup*)[UIGroup alloc] InitWithParams:&uiGroupParams];
}

-(TouchSystemConsumeType)TouchEventWithData:(TouchData*)inData
{
    SimpleModel* pizzaModel = (SimpleModel*)[mGameState.PizzaEntity GetPuppet];
    Vector3 rayPosition, rayDirection;
    
    [[CameraStateMgr GetInstance] GetPosition:&rayPosition];
    SetVec3From4(&rayDirection, &inData->mRayWorldSpaceLocation);
    
    // Transform rayPosition and rayDirection into Pizza entity object space
    // 1) Get the required transform
    Matrix44 ltwTransform;
    [mGameState.PizzaEntity GetLocalToWorldTransform:&ltwTransform];
    
    Matrix44 inverseTransform;
    Inverse(&ltwTransform, &inverseTransform);
    
    // 2) Transform rayPosition
    Vector4 homoRayPosition, homoRayTransformedPosition;
    SetVec4From3(&homoRayPosition, &rayPosition, 1);
    
    TransformVector4x4(&inverseTransform, &homoRayPosition, &homoRayTransformedPosition);
    
    // 3) Transform rayDirection
    Vector4 homoRayDirection, homoRayTransformedDirection;
    SetVec4From3(&homoRayDirection, &rayDirection, 0);
    
    TransformVector4x4(&inverseTransform, &homoRayDirection, &homoRayTransformedDirection);
    
    SetVec3From4(&rayPosition, &homoRayTransformedPosition);
    SetVec3From4(&rayDirection, &homoRayTransformedDirection);
    
    RayIntersectionInfo intersectionInfo;
    BOOL intersect = [pizzaModel RayIntersectsMesh:&rayPosition direction:&rayDirection intersectionInfo:&intersectionInfo];
    
    if (intersect)
    {
        int useIndex = (intersectionInfo.mT[0] < intersectionInfo.mT[1]) ? 0 : 1;
        Vector2* texcoord = &intersectionInfo.mIntersectionTexcoord[useIndex];
        
        [mGameState.PizzaEntity TapAtTexcoordS:texcoord->mVector[x] t:texcoord->mVector[y]];
    }
    
    return intersect ? TOUCHSYSTEM_CONSUME_ALL : TOUCHSYSTEM_CONSUME_NONE;
}

-(BOOL)ButtonEvent:(ButtonEvent)inEvent Button:(Button*)inButton
{
    switch(inEvent)
    {
    }
    
    return TRUE;
}

-(void)ProcessMessage:(Message*)inMsg
{
    switch(inMsg->mId)
    {
        case EVENT_IAP_DELIVER_CONTENT:
        {
            NSString* identifier = (NSString*)inMsg->mData;
            IapProduct product = [[InAppPurchaseManager GetInstance] GetIAPWithIdentifier:identifier];
            
            if (product == IAP_PRODUCT_BOOSTER)
            {
                [mBoosterStringCloud Disable];
            }
            
            break;
        }
        
        case EVENT_IAP_PRICES_RECEIVED:
        {
            SKProduct* boosterProduct = [[InAppPurchaseManager GetInstance] GetProduct:IAP_PRODUCT_BOOSTER];
           
            [mBuyBoosterButton.Price SetString:[NSString stringWithFormat:@"<B>%@</B>", [[InAppPurchaseManager GetInstance] GetLocalizedPrice:boosterProduct]]];
            break;
        }
        
        case EVENT_INCREMENTAL_GAME_ITEM_CLICKED:
        {
            StringCloudParams* stringCloudParams = [[StringCloudParams alloc] init];
            
            stringCloudParams->mOneShot = TRUE;
            stringCloudParams->mFontSize = 16;
            stringCloudParams->mDistanceMultiplier = 2;
            stringCloudParams->mFadeIn = FALSE;
            stringCloudParams->mDuration = 2;
            
            double numPizzasPerSpin = [[FoodManager GetInstance] GetNumPizzasPerSpin];
            [stringCloudParams->mStrings addObject:[NSString stringWithFormat:@"+%.0f", numPizzasPerSpin]];
            
            StringCloud* newStringCloud = [[StringCloud alloc] initWithParams:stringCloudParams];
            [[GameObjectManager GetInstance] Add:newStringCloud];
            [stringCloudParams release];
            [newStringCloud release];
            
            float xBase = 310;
            float yBase = 100;
            
            if ([[AdvertisingManager GetInstance] ShouldShowBannerAds])
            {
                yBase -= 30;
            }
            
            [newStringCloud SetPositionX:(xBase + arc4random_uniform(30)) Y:yBase Z:0.0];
            
            if ([mHintFinger GetVisible])
            {
                [mHintFinger Disable];
            }
            
            break;
        }
        
        case EVENT_INCREMENTAL_GAME_UNLOCK_STATE_CHANGED:
        {
            PizzaPowerup powerup = (PizzaPowerup)[(NSNumber*)inMsg->mData intValue];
            PizzaPowerupUnlockState unlockState = [[SaveSystem GetInstance] GetPowerupUnlockState:powerup];
            
            [mPowerups[powerup] SetUnlockState:unlockState];
            
            switch(unlockState)
            {
                case PIZZA_POWERUP_QUESTION:
                {
                    [mPowerups[powerup] SetVisible:TRUE];
                    [mNeonList AddObject:mPowerups[powerup]];
                    [mNeonList PositionObjectsSync];
                    
                    break;
                }
            }
            
            break;
        }

        case EVENT_HINT_TRIGGERED:
        {
            NSNumber* hintId = (NSNumber*)inMsg->mData;
            
            if ([hintId intValue] == HINT_ID_PERFORM_SPIN)
            {
                [mHintFinger SetVisible:TRUE];
                
                Path* animationPath = [[Path alloc] Init];
                
                float rawXMin = 330.0;
                float rawXMax = 480.0;
                float rawYMin = 200.0;
                float rawYMax = 250.0;
                
                if ([[AdvertisingManager GetInstance] ShouldShowBannerAds])
                {
                    float aspect = GetScreenAbsoluteWidth() / GetScreenAbsoluteHeight();
                    float scaleX = (GetScreenAbsoluteWidth() + ((float)aspect * (float)ADVERTISING_MANAGER_TOP_BANNER_OFFSET)) / (float)GetScreenAbsoluteWidth();
                    float scaleY = (GetScreenAbsoluteHeight() + ADVERTISING_MANAGER_TOP_BANNER_OFFSET) / (float)GetScreenAbsoluteHeight();

                    rawXMin *= scaleX;
                    rawXMax *= scaleX;
                    
                    rawYMin -= ADVERTISING_MANAGER_TOP_BANNER_OFFSET;
                    rawYMax -= ADVERTISING_MANAGER_TOP_BANNER_OFFSET;
                    
                    rawYMin *= scaleY;
                    rawYMax *= scaleY;
                }
                
                float xMin = (rawXMin / 568.0) * GetScreenAbsoluteWidth();
                float xMax = (rawXMax / 568.0) * GetScreenAbsoluteWidth();
                
                [animationPath AddNodeX:xMin y:rawYMin z:0.0 atTime:0.0];
                [animationPath AddNodeX:xMax y:rawYMin z:0.0 atTime:0.75];
                [animationPath AddNodeX:xMin y:rawYMax z:0.0 atTime:1.5];
                [animationPath AddNodeX:xMax y:rawYMax z:0.0 atTime:2.25];
                
                [animationPath SetPeriodic:TRUE];
                
                [mHintFinger AnimateProperty:GAMEOBJECT_PROPERTY_POSITION withPath:animationPath];
                
                [animationPath release];
            }
            
            break;
        }
        
        case EVENT_CRYSTAL_ITEM_SPAWN:
        {
            int xBase = [mPowerups[0] GetWidth];
            int xRange = GetScreenAbsoluteWidth() - xBase - [mCrystalItem GetWidth];
            int yRange = GetScreenAbsoluteHeight() - [mCrystalItem GetHeight];
            
            float xPos = xBase + arc4random_uniform(xRange);
            float yPos = arc4random_uniform(yRange);
            
            [mCrystalItem SetPositionX:xPos Y:yPos Z:0.0];
            [mCrystalItem Enable];
            
            break;
        }
        
        case EVENT_CRYSTAL_ITEM_TAPPED:
        {
            [mCrystalItemBG SetVisible:TRUE];
            break;
        }
        
        case EVENT_CRYSTAL_ITEM_EXPIRED:
        {
            [mCrystalItemBG SetVisible:FALSE];
            break;
        }
        
        case EVENT_CRYSTAL_ITEM_AUTO_EXPIRED:
        {
            [mCrystalItem Disable];
            break;
        }
    }
}

-(void)CreateIAPList
{
    NeonListParams* listParams = [[NeonListParams alloc] Init];
    
    listParams.UIGroup = mUserInterface[UIGROUP_2D];
    listParams.Height = GetScreenVirtualHeight();
    
    mIAPList = [[NeonList alloc] InitWithParams:listParams];
    [mIAPList release];
    [listParams release];
    
    mBuyBoosterButton = [[IncrementalGameBuyBoosterButton alloc] InitWithUIGroup:mUserInterface[UIGROUP_2D]];
    [mBuyBoosterButton release];
    
    [mIAPList AddObject:mBuyBoosterButton];

    [mBuyBoosterButton PerformWhenLoaded:dispatch_get_main_queue() block:^
    {
        [mIAPList SetPositionX:-(s32)[mBuyBoosterButton GetWidth] Y:0 Z:0.0];
    }];
    
    // Review Button
    mReviewButton = [[IncrementalGameReviewButton alloc] InitWithUIGroup:mUserInterface[UIGROUP_2D]];
    [mReviewButton release];
    
    [mIAPList AddObject:mReviewButton];
    
    // Make pizzas in background
    mBackgroundButton = [[IncrementalGameBackgroundButton alloc] InitWithUIGroup:mUserInterface[UIGROUP_2D]];
    [mBackgroundButton release];
    
    [mIAPList AddObject:mBackgroundButton];
    
    [mIAPList PositionObjects];
    
    // Create close button (external to the list)
    TextureButtonParams textureButtonParams;
    [TextureButton InitDefaultParams:&textureButtonParams];
    
    [TextureButton InitDefaultParams:&textureButtonParams];
    textureButtonParams.mButtonTexBaseName = @"close.papng";
    textureButtonParams.mButtonTexHighlightedName = @"close_pressed.papng";
    
    textureButtonParams.mUIGroup = mUserInterface[UIGROUP_2D];
    
    mGlobalCloseButton = [[TextureButton alloc] InitWithParams:&textureButtonParams];
    [mGlobalCloseButton release];
    
    mGlobalCloseButton.Parent = mIAPList;
    
    [mGlobalCloseButton PerformWhenLoaded:dispatch_get_main_queue() block:^
    {
        [mGlobalCloseButton SetPositionX:5 Y:(GetScreenVirtualHeight() - [mGlobalCloseButton GetHeight] - 5) Z:0.0];
    } ];
}

-(void)CreatePowerupList
{
    NeonListParams* listParams = [[NeonListParams alloc] Init];
    
    listParams.UIGroup = mUserInterface[UIGROUP_2D];
    
    listParams.Height = GetScreenVirtualHeight() - LIST_OFFSET;
    
    mNeonList = [[NeonList alloc] InitWithParams:listParams];
    [mNeonList release];
    [listParams release];
    
    for (int i = 0; i < PIZZA_POWERUP_NUM; i++)
    {
        IncrementalGamePowerupParams* params = [[IncrementalGamePowerupParams alloc] Init];
        PizzaPowerupStats* powerupInfo = [[Flow GetInstance].PizzaPowerupInfo GetStatsForPowerup:(PizzaPowerup)i];
        
        params.UIGroup = mUserInterface[UIGROUP_2D];
        params.IconTexture = powerupInfo.IconTexture;
        params.Name = powerupInfo.Name;
        params.Background = @"PowerupBackground.papng";
        params.BackgroundPressed = @"PowerupBackgroundPressed.papng";
        params.UnlockState = [[SaveSystem GetInstance] GetPowerupUnlockState:(PizzaPowerup)i];
        params.PizzaPowerup = (PizzaPowerup)i;
        
        mPowerups[i] = [[IncrementalGamePowerup alloc] InitWithParams:params];
        [mPowerups[i] release];
        [params release];
        
        switch ([[SaveSystem GetInstance] GetPowerupUnlockState:(PizzaPowerup)i])
        {
            case PIZZA_POWERUP_UNLOCKED:
            case PIZZA_POWERUP_QUESTION:
            {
                [mNeonList AddObject:mPowerups[i]];
                break;
            }
            
            case PIZZA_POWERUP_INVISIBLE:
            {
                [mPowerups[i] SetVisible:FALSE];
                break;
            }
        }
    }
    
    [mNeonList PositionObjects];
    
    float yPos = LIST_OFFSET;
    [mNeonList SetPositionX:0.0 Y:yPos Z:0.0];
}

-(void)CreatePowerupDescriptions
{
    for (int i = 0; i < PIZZA_POWERUP_NUM; i++)
    {
        IncrementalGamePowerupDescriptionParams* params = [[IncrementalGamePowerupDescriptionParams alloc] Init];
        
        params.PizzaPowerup = (PizzaPowerup)i;
        params.UIGroup = mUserInterface[UIGROUP_2D];
        params.Background = @"PowerupDescriptionBackground.papng";
        
        mDescriptions[i] = [[IncrementalGamePowerupDescription alloc] InitWithParams:params];
        [mDescriptions[i] release];
        
        [mDescriptions[i] PerformWhenLoaded:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) block:^
        {
            int width = [mDescriptions[i] GetWidth];
            [mDescriptions[i] SetPositionX:(-width) Y:0 Z:0];
        } ];
        
        [params release];
    }
}

-(void)CreateBoosterButton
{
    TextureButtonParams textureButtonParams;
    [TextureButton InitDefaultParams:&textureButtonParams];
    
    textureButtonParams.mButtonTexBaseName = @"booster.papng";
    textureButtonParams.mButtonTexHighlightedName = @"booster_pressed.papng";
    textureButtonParams.mUIGroup = mUserInterface[UIGROUP_2D];
    textureButtonParams.mFontColor = 0xFFD500FF;
    textureButtonParams.mFontStrokeColor = 0x000000FF;
    textureButtonParams.mFontStrokeSize = 8;
    textureButtonParams.mFontType = NEON_FONT_NORMAL;
    textureButtonParams.mButtonText = NSLocalizedString(@"LS_Extras", NULL);

    SetRelativePlacement(&textureButtonParams.mTextPlacement, PLACEMENT_ALIGN_CENTER, PLACEMENT_ALIGN_CENTER);
    
    mBoosterButton = [[TextureButton alloc] InitWithParams:&textureButtonParams];
    [mBoosterButton release];
    
    // Create "Buy More" StringCloud
    
    StringCloudParams* stringCloudParams = [[StringCloudParams alloc] init];
    
    stringCloudParams->mUIGroup = mUserInterface[UIGROUP_2D];
    
    [stringCloudParams->mStrings addObject:@"Free Stuff"];
    [stringCloudParams->mStrings addObject:@"More Pizza"];
    [stringCloudParams->mStrings addObject:@"<B><color=0xFFD500>Tap Here</color></B>"];
    
    mBoosterStringCloud = [[StringCloud alloc] initWithParams:stringCloudParams];
    [stringCloudParams release];
    [mBoosterStringCloud release];
    
    [mBoosterStringCloud SetPositionX:10 Y:5 Z:0.0];
    [mBoosterStringCloud SetVisible:FALSE];
}

-(void)CreateHintFinger
{
    ImageWellParams imageWellParams;
    [ImageWell InitDefaultParams:&imageWellParams];
    
    imageWellParams.mUIGroup = mUserInterface[UIGROUP_2D];
    imageWellParams.mTextureName = @"PointingFinger.papng";
    
    mHintFinger = [[ImageWell alloc] InitWithParams:&imageWellParams];
    [mHintFinger release];
    
    [mHintFinger SetVisible:FALSE];
}

-(IncrementalGamePowerupDescription*)GetDescriptionAtIndex:(int)inIndex
{
    return mDescriptions[inIndex];
}

-(IncrementalGamePowerup*)GetPowerupAtIndex:(int)inIndex
{
    return mPowerups[inIndex];
}

-(void)CreateQuantity
{
    TextureButtonParams textureButtonParams;
    
    [TextureButton InitDefaultParams:&textureButtonParams];
    SetColorFloat(&textureButtonParams.mColor, 0.0, 0.0, 0.0, 0.6);
    
    mQuantityBlackBar = [(TextureButton*)[TextureButton alloc] InitWithParams:&textureButtonParams];
    [[GameObjectManager GetInstance] Add:mQuantityBlackBar];
    [mQuantityBlackBar release];
    
    TextBoxParams textBoxParams;
    [TextBox InitDefaultParams:&textBoxParams];
    
    textBoxParams.mMutable = TRUE;
    textBoxParams.mMaxWidth = 200;
    textBoxParams.mMaxHeight = 100;
    textBoxParams.mStrokeSize = 4;
    textBoxParams.mWidth = 200;
    textBoxParams.mFontSize = 20;
    textBoxParams.mString = [self CreateNumPizzaString];
    textBoxParams.mUIGroup = mUserInterface[UIGROUP_2D];
    textBoxParams.mAlignment = kCTTextAlignmentCenter;
    
    SetColorFloat(&textBoxParams.mColor, 1.0, 1.0, 1.0, 1.0);
    SetColorFloat(&textBoxParams.mStrokeColor, 0.0, 0.0, 0.0, 1.0);
    
    mLastNumPizza = [[FoodManager GetInstance] GetNumPizza];
    
    mQuantityTextBox = [[TextBox alloc] InitWithParams:&textBoxParams];
    [mQuantityTextBox release];
    
    textBoxParams.mFontSize = 16;
    textBoxParams.mString = [self CreateRegenRateString];
    
    mLastRegenRate = [[FoodManager GetInstance] GetTotalRegenRate];
    
    mRegenRateTextBox = [[TextBox alloc] InitWithParams:&textBoxParams];
    [mRegenRateTextBox release];
    
    [mDescriptions[0] PerformWhenLoaded:dispatch_get_main_queue() block:^
    {
        [mQuantityBlackBar SetPositionX:[mDescriptions[0] GetWidth] Y:20 Z:0.0];
        
        float xOffset = 0;
        
        if ([[AdvertisingManager GetInstance] ShouldShowBannerAds])
        {
            xOffset = ((float)ADVERTISING_MANAGER_TOP_BANNER_OFFSET * GetScreenAbsoluteAspect());
        }
        
        [mQuantityBlackBar SetScaleX:(GetScreenAbsoluteWidth() + xOffset - [mDescriptions[0] GetWidth]) Y:50 Z:1.0];
        [self PositionPizzaStrings];
        
        [[InGameNotificationManager GetInstance] SetLeftCoord:([mDescriptions[0] GetWidth] + 10) width:(GetScreenAbsoluteWidth() - [mDescriptions[0] GetWidth] - 20)];
    }];
}

-(NSString*)CreateNumPizzaString
{
    NSString* pizzaString = NULL;
    u64 numPizza = [[FoodManager GetInstance] GetNumPizza];
    
    if (numPizza == 1)
    {
        pizzaString = NSLocalizedString(@"LS_Pizza", NULL);
    }
    else
    {
        pizzaString = NSLocalizedString(@"LS_Pizzas", NULL);
    }
    
    NSString* formattedString = NeonFormatLongToLength(numPizza);
    
    return [NSString stringWithFormat:@"%@ %@", formattedString, pizzaString];
}

-(NSString*)CreateRegenRateString
{
    double totalRegen = [[FoodManager GetInstance] GetTotalRegenRate];
    
    NSString* formattedString = NeonFormatDoubleToLength(totalRegen, true, 3);
    
    return [NSString stringWithFormat:NSLocalizedString(@"LS_TotalRegenRate", NULL), formattedString];
}

-(void)PositionPizzaStrings
{
    int blackBarWidth = [mQuantityBlackBar GetWidth];
    int blackBarHeight = [mQuantityBlackBar GetHeight];
    int textWidth = [mQuantityTextBox GetWidth];
    int totalHeight = [mQuantityTextBox GetHeight] + [mRegenRateTextBox GetHeight] + 5;
    
    Vector3 position;
    [mQuantityBlackBar GetPosition:&position];
    
    int yPos = (position.mVector[y] + ((blackBarHeight - totalHeight) / 2));
    [mQuantityTextBox SetPositionX:(position.mVector[x] + (blackBarWidth / 2)) Y:yPos Z:0.0];
    
    textWidth = [mRegenRateTextBox GetWidth];
    yPos += [mQuantityTextBox GetHeight];
    [mRegenRateTextBox SetPositionX:(position.mVector[x] + (blackBarWidth / 2)) Y:yPos Z:0.0];
}

@end
