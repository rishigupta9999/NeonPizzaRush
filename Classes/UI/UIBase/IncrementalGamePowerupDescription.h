//
//  IncrementalGamePowerupDescription.h
//  PizzaSpinner
//
//  Created by Rishi Gupta on 6/25/14.
//  Copyright (c) 2014 Neon Games LLC. All rights reserved.
//

#import "UIObject.h"
#import "PizzaPowerupInfo.h"
#import "TextureButton.h"

@interface IncrementalGamePowerupDescriptionParams : NSObject
{
}

@property PizzaPowerup          PizzaPowerup;
@property(assign) UIGroup*      UIGroup;
@property(assign) NSString*     Background;
@property(assign) NSString*     BuyButton;
@property(assign) NSString*     BuyButtonPressed;
@property(assign) NSString*     BuyButtonDisabled;

-(instancetype)Init;

@end

@class ImageWell;
@class TextBox;

@interface IncrementalGamePowerupDescription : UIObject<MessageChannelListener, ButtonListenerProtocol>
{
    ImageWell*  mBackground;
    ImageWell*  mIcon;
    ImageWell*  mCurrency[PIZZA_POWERUP_UPGRADE_NUM];
    ImageWell*  mUpgradeCurrency[PIZZA_POWERUP_UPGRADE_NUM];
    
    TextBox*    mName;
    TextBox*    mDescription;
    TextBox*    mRegenRate;
    TextBox*    mQuantity;
    TextBox*    mCost;
    TextBox*    mUpgradeCost;
    TextBox*    mUpgradeDescription;
    TextBox*    mUpgradeLevel;
    
    TextureButton*  mUpgradeButton;
    
    PizzaPowerup    mPizzaPowerup;
    
    float       mLastRegenRate;
    double      mLastPizzaQuantity;
    int         mDisplayedUpgradeLevel;
    int         mLastUpgradeLevel;
}

@property(readonly) TextureButton* CloseButton;
@property(readonly) TextureButton* BuyButton;
@property           BOOL           Displayed;

-(instancetype)InitWithParams:(IncrementalGamePowerupDescriptionParams*)inParams;
-(void)dealloc;
-(void)Remove;

-(int)GetWidth;
-(int)GetHeight;
-(Texture*)GetUseTexture;

-(void)Update:(CFTimeInterval)inTimeStep;
-(void)ProcessMessage:(Message*)inMsg;

-(NSString*)GetRegenRateString;
-(NSString*)GetQuantityString;

-(void)UpdatePrice;
-(void)EvaluateUpgradeButton;
-(void)EvaluateCurrencyIcons;

@end
