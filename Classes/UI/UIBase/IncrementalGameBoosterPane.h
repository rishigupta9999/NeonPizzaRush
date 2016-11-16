//
//  IncrementalGameBoosterPane.h
//  PizzaSpinner
//
//  Created by Rishi Gupta on 7/8/14.
//  Copyright (c) 2014 Neon Games LLC. All rights reserved.
//

#import "UIObject.h"

@interface IncrementalGameBoosterPaneParams : NSObject
{
}

@property(assign) UIGroup*      UIGroup;
@property(assign) NSString*     Background;

-(instancetype)Init;

@end

@class ImageWell;
@class TextBox;
@class TextureButton;

typedef enum
{
    BOOSTER_PANE_STATE_NORMAL,
    BOOSTER_PANE_STATE_CONNECTING
} IncrementalGameBoosterPaneState;

@interface IncrementalGameBoosterPane : UIObject
{
    ImageWell*  mBackground;
    TextBox*    mDescription;
    TextBox*    mPrice;
    TextBox*    mConnecting;
}

@property           IncrementalGameBoosterPaneState State;
@property(readonly) TextureButton* CloseButton;
@property(readonly) TextureButton* BuyButton;
@property(readonly) TextureButton* RestoreButton;
@property(readonly) TextBox*       Price;

-(instancetype)InitWithParams:(IncrementalGameBoosterPaneParams*)inParams;
-(void)dealloc;

-(int)GetWidth;
-(int)GetHeight;

-(void)Update:(CFTimeInterval)inTimeStep;

@end
