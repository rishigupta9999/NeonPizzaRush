//
//  WaterBalloonTossUI.h
//  WaterBalloonToss
//
//  Created by Rishi Gupta on 5/13/14.
//  Copyright (c) 2014 Neon Games LLC. All rights reserved.
//

#import "GlobalUI.h"
#import "TouchSystem.h"
#import "TextureButton.h"
#import "PizzaPowerupInfo.h"
#import "MessageChannel.h"

@class WaterBalloonEnvironment;
@class IncrementalGameState;
@class NeonList;
@class PizzaPowerupInfo;
@class IncrementalGamePowerup;
@class IncrementalGamePowerupDescription;
@class IncrementalGameUIStateMachine;
@class TextBox;
@class StringCloud;
@class IncrementalGameBuyBoosterButton;
@class IncrementalGameReviewButton;
@class IncrementalGameBackgroundButton;
@class CrystalItem;
@class CrystalItemMeter;

@interface IncrementalGameUI : GlobalUI<TouchListenerProtocol, ButtonListenerProtocol, MessageChannelListener>
{
    IncrementalGameState*   mGameState;
    IncrementalGamePowerupDescription*  mDescriptions[PIZZA_POWERUP_NUM];
    IncrementalGamePowerup* mPowerups[PIZZA_POWERUP_NUM];
    
    TextureButton*          mQuantityBlackBar;
    TextBox*                mQuantityTextBox;
    TextBox*                mRegenRateTextBox;
    
    IncrementalGameUIStateMachine*  mStateMachine;
    
    u64                     mLastNumPizza;
    double                  mLastRegenRate;
    
    CrystalItem*            mCrystalItem;
    CrystalItem*            mCrystalItemBG;
    CrystalItemMeter*       mCrystalItemMeter;
    
    ImageWell*              mHintFinger;
}

@property(readonly) NeonList*   List;
@property(readonly) NeonList*   IAPList;
@property(readonly) TextureButton* BoosterButton;
@property(readonly) IncrementalGameBuyBoosterButton*    BuyBoosterButton;
@property(readonly) IncrementalGameReviewButton*        ReviewButton;
@property(readonly) IncrementalGameBackgroundButton*    BackgroundButton;
@property(readonly) TextureButton* GlobalCloseButton;
@property(readonly) StringCloud* BoosterStringCloud;

-(instancetype)InitWithEnvironment:(WaterBalloonEnvironment*)inEnvironment gameState:(IncrementalGameState*)inGameState;
-(void)dealloc;
-(void)Remove;

-(void)Update:(CFTimeInterval)inTimeStep;

-(void)InitInterfaceGroups;

-(TouchSystemConsumeType)TouchEventWithData:(TouchData*)inData;

-(BOOL)ButtonEvent:(ButtonEvent)inEvent Button:(Button*)inButton;

-(void)ProcessMessage:(Message*)inMsg;

-(void)CreateIAPList;
-(void)CreatePowerupList;
-(void)CreatePowerupDescriptions;
-(void)CreateBoosterButton;
-(void)CreateHintFinger;
-(void)CreateQuantity;

-(IncrementalGamePowerupDescription*)GetDescriptionAtIndex:(int)inIndex;
-(IncrementalGamePowerup*)GetPowerupAtIndex:(int)inIndex;

-(NSString*)CreateNumPizzaString;
-(NSString*)CreateRegenRateString;
-(void)PositionPizzaStrings;

@end
