//
//  IncrementalGameBoosterPane.m
//  PizzaSpinner
//
//  Created by Rishi Gupta on 7/8/14.
//  Copyright (c) 2014 Neon Games LLC. All rights reserved.
//

#import "IncrementalGameBoosterPane.h"
#import "ImageWell.h"
#import "TextBox.h"
#import "TextureButton.h"
#import "InAppPurchaseManager.h"

@implementation IncrementalGameBoosterPaneParams

@synthesize UIGroup = mUIGroup;
@synthesize Background = mBackground;

-(instancetype)Init
{
    mUIGroup = NULL;
    mBackground = NULL;

    return self;
}

@end

@implementation IncrementalGameBoosterPane

@synthesize State = mState;

@synthesize CloseButton = mCloseButton;
@synthesize BuyButton = mBuyButton;
@synthesize RestoreButton = mRestoreButton;

@synthesize Price = mPrice;

-(instancetype)InitWithParams:(IncrementalGameBoosterPaneParams*)inParams
{
    [super InitWithUIGroup:inParams.UIGroup];
    
    // Background
    ImageWellParams imageWellParams;
    [ImageWell InitDefaultParams:&imageWellParams];
    
    imageWellParams.mUIGroup = inParams.UIGroup;
    imageWellParams.mTextureName = inParams.Background;
    
    mBackground = [[ImageWell alloc] InitWithParams:&imageWellParams];
    [mBackground release];
    
    mBackground.Parent = self;
    
    // Description
    TextBoxParams textBoxParams;
    [TextBox InitDefaultParams:&textBoxParams];
    
    textBoxParams.mString = NSLocalizedString(@"LS_BoosterDescription", NULL);
    textBoxParams.mWidth = 220;
    textBoxParams.mFontSize = 15;
    textBoxParams.mStrokeSize = 8;
    SetColorFloat(&textBoxParams.mColor, 1.0, 1.0, 1.0, 1.0);
    SetColorFloat(&textBoxParams.mStrokeColor, 0.0, 0.0, 0.0, 1.0);
    textBoxParams.mUIGroup = inParams.UIGroup;
    
    TextBox* description = [[TextBox alloc] InitWithParams:&textBoxParams];
    [description release];
    
    [description SetPositionX:10 Y:10 Z:0];
    
    description.Parent = self;
    
    // Buy Button
    TextureButtonParams textureButtonParams;
    [TextureButton InitDefaultParams:&textureButtonParams];
    
    textureButtonParams.mButtonTexBaseName = @"buy_booster.papng";
    textureButtonParams.mButtonTexHighlightedName = @"buy_booster_pressed.papng";
    
    textureButtonParams.mUIGroup = inParams.UIGroup;
    
    mBuyButton = [[TextureButton alloc] InitWithParams:&textureButtonParams];
    [mBuyButton release];
    
    mBuyButton.Parent = self;
    
    // Restore Button
    textureButtonParams.mButtonTexBaseName = @"restore.papng";
    textureButtonParams.mButtonTexHighlightedName = @"restore_pressed.papng";
    textureButtonParams.mButtonTexDisabledName = NULL;
    
    mRestoreButton = [[TextureButton alloc] InitWithParams:&textureButtonParams];
    [mRestoreButton release];
    
    mRestoreButton.Parent = self;
    
    // Close Button
    textureButtonParams.mButtonTexBaseName = @"close.papng";
    textureButtonParams.mButtonTexHighlightedName = @"close_pressed.papng";
    textureButtonParams.mButtonTexDisabledName = NULL;
    
    mCloseButton = [[TextureButton alloc] InitWithParams:&textureButtonParams];
    [mCloseButton release];
    
    mCloseButton.Parent = self;
    
    // Connecting Text
    textBoxParams.mString = NSLocalizedString(@"LS_Connecting", NULL);
    mConnecting = [[TextBox alloc] InitWithParams:&textBoxParams];
    [mConnecting release];
    
    [mConnecting SetVisible:FALSE];
    
    mConnecting.Parent = self;
    
    // Price
    
    SKProduct* boosterProduct = [[InAppPurchaseManager GetInstance] GetProduct:IAP_PRODUCT_BOOSTER];
    
    if (boosterProduct == NULL)
    {
        textBoxParams.mString = @"---";
    }
    else
    {
        textBoxParams.mString = [[InAppPurchaseManager GetInstance] GetLocalizedPrice:boosterProduct];
    }
    
    textBoxParams.mMutable = TRUE;
    textBoxParams.mMaxWidth = 100;
    textBoxParams.mMaxHeight = 100;
    textBoxParams.mFontSize = 12;
    SetColorFloat(&textBoxParams.mColor, 0, 0, 0, 1);
    textBoxParams.mStrokeSize = 0;
    
    mPrice = [[TextBox alloc] InitWithParams:&textBoxParams];
    [mPrice release];
    
    mPrice.Parent = self;
    
    [UIObject PerformWhenAllLoaded:[NSMutableArray arrayWithObjects:mBackground, mBuyButton, mRestoreButton, mConnecting, NULL] queue:dispatch_get_main_queue() block:^
    {
        int backgroundWidth = [mBackground GetWidth];
        int buyButtonWidth = [mBuyButton GetWidth];
        int restoreButtonWidth = [mRestoreButton GetWidth];
        
        int buyButtonX = ((backgroundWidth - buyButtonWidth) / 2);
        [mBuyButton SetPositionX:buyButtonX Y:100 Z:0];
        [mRestoreButton SetPositionX:((backgroundWidth - restoreButtonWidth) / 2) Y:180 Z:0.0];
        [mCloseButton SetPositionX:10 Y:(GetScreenVirtualHeight() - [mCloseButton GetHeight] - 10) Z:0.0];
        [mConnecting SetPositionX:((backgroundWidth - [mConnecting GetWidth]) / 2) Y:160 Z:0.0];
        
        [mPrice SetPositionX:(buyButtonX + 15) Y:122 Z:0.0];
    }];
    
    mState = BOOSTER_PANE_STATE_NORMAL;
    
    return self;
}

-(void)dealloc
{
    [super dealloc];
}

-(int)GetWidth
{
    return [mBackground GetWidth];
}

-(int)GetHeight
{
    return [mBackground GetHeight];
}

-(void)Update:(CFTimeInterval)inTimeStep
{
    [super Update:inTimeStep];
    
    switch(mState)
    {
        case BOOSTER_PANE_STATE_CONNECTING:
        {
            if ([[InAppPurchaseManager GetInstance] GetIAPState] == IAP_STATE_IDLE)
            {
                self.State = BOOSTER_PANE_STATE_NORMAL;
            }
            
            break;
        }
    }
}

-(IncrementalGameBoosterPaneState)State
{
    return mState;
}

-(void)setState:(IncrementalGameBoosterPaneState)inState
{
    mState = inState;
    
    switch(inState)
    {
        case BOOSTER_PANE_STATE_CONNECTING:
        {
            [mBuyButton Disable];
            [mRestoreButton Disable];
            [mPrice Disable];
            
            [mConnecting Enable];
            break;
        }
        
        case BOOSTER_PANE_STATE_NORMAL:
        {
            [mBuyButton Enable];
            [mRestoreButton Enable];
            [mPrice Enable];
            
            [mConnecting Disable];
            break;
        }
    }
}

@end
