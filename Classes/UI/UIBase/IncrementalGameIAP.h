//
//  IncrementalGameIAP.h
//  PizzaSpinner
//
//  Created by Rishi Gupta on 9/4/14.
//  Copyright (c) 2014 Neon Games LLC. All rights reserved.
//

#import "UIObject.h"
#import "TextureButton.h"

@class ImageWell;
@class TextBox;
@class TextureButton;

typedef enum
{
    BOOSTER_BUTTON_STATE_NORMAL,
    BOOSTER_BUTTON_STATE_CONNECTING
} IncrementalGameBuyBoosterButtonState;

@interface IncrementalGameBuyBoosterButton : UIObject<ButtonListenerProtocol, MessageChannelListener>
{
    ImageWell*      mBackground;
    
    ImageWell*      mIcon;
    TextBox*        mTitle;
    TextBox*        mDescription;
    TextBox*        mConnecting;
    
    TextureButton*  mBuyButton;
    TextureButton*  mRestoreButton;
}

@property(readonly) TextBox* Price;
@property           IncrementalGameBuyBoosterButtonState State;

-(instancetype)InitWithUIGroup:(UIGroup*)inUIGroup;
-(void)dealloc;

-(Texture*)GetUseTexture;

-(u32)GetWidth;
-(u32)GetHeight;

-(BOOL)ButtonEvent:(ButtonEvent)inEvent Button:(Button*)inButton;
-(void)ProcessMessage:(Message*)inMsg;

@end

@interface IncrementalGameReviewButton : UIObject<ButtonListenerProtocol, MessageChannelListener>
{
    ImageWell*      mBackground;
    ImageWell*      mIcon;
    TextBox*        mTitle;
    TextBox*        mDescription;
    
    TextureButton*  mReviewButton;
}

-(instancetype)InitWithUIGroup:(UIGroup*)inUIGroup;
-(void)dealloc;

-(Texture*)GetUseTexture;

-(u32)GetWidth;
-(u32)GetHeight;

-(BOOL)ButtonEvent:(ButtonEvent)inEvent Button:(Button*)inButton;
-(void)ProcessMessage:(Message*)inMsg;

@end

@interface IncrementalGameBackgroundButton : UIObject<ButtonListenerProtocol, MessageChannelListener>
{
    ImageWell*      mBackground;
    ImageWell*      mIcon;
    TextBox*        mTitle;
    TextBox*        mDescription;
}

-(instancetype)InitWithUIGroup:(UIGroup*)inUIGroup;
-(void)dealloc;

-(Texture*)GetUseTexture;

-(u32)GetWidth;
-(u32)GetHeight;

-(BOOL)ButtonEvent:(ButtonEvent)inEvent Button:(Button*)inButton;
-(void)ProcessMessage:(Message*)inMsg;

@end