//
//  IncrementalGameIAP.m
//  PizzaSpinner
//
//  Created by Rishi Gupta on 9/4/14.
//  Copyright (c) 2014 Neon Games LLC. All rights reserved.
//

#import "IncrementalGameIAP.h"
#import "ImageWell.h"
#import "TextureButton.h"
#import "TextBox.h"
#import "InAppPurchaseManager.h"
#import "FoodManager.h"

@implementation IncrementalGameBuyBoosterButton

@synthesize Price = mPrice;
@synthesize State = mState;

-(instancetype)InitWithUIGroup:(UIGroup*)inUIGroup
{
    [super InitWithUIGroup:inUIGroup];
    
    // Create background
    ImageWellParams imageWellParams;
    [ImageWell InitDefaultParams:&imageWellParams];
    
    imageWellParams.mUIGroup = inUIGroup;
    imageWellParams.mTextureName = @"extrasbackground.papng";
    
    mBackground = [[ImageWell alloc] InitWithParams:&imageWellParams];
    [mBackground release];
    
    mBackground.Parent = self;
    
    // Buy button
    TextureButtonParams textureButtonParams;
    [TextureButton InitDefaultParams:&textureButtonParams];
    
    textureButtonParams.mButtonTexBaseName = @"mozzarellabutton.papng";
    textureButtonParams.mButtonTexHighlightedName = @"mozzarellabutton_pressed.papng";
    textureButtonParams.mBoundingBoxCollision = TRUE;
    textureButtonParams.mBoundingBoxBorderSize.mVector[x] = 2;
    textureButtonParams.mBoundingBoxBorderSize.mVector[y] = 2;
    textureButtonParams.mButtonText = NSLocalizedString(@"LS_Buy", NULL);
    textureButtonParams.mFontType = NEON_FONT_NORMAL;
    textureButtonParams.mFontSize = 14;
    textureButtonParams.mFontColor = 0xFF;
    
    SetRelativePlacement(&textureButtonParams.mTextPlacement, PLACEMENT_ALIGN_CENTER, PLACEMENT_ALIGN_CENTER);
    
    textureButtonParams.mUIGroup = inUIGroup;
    
    mBuyButton = [[TextureButton alloc] InitWithParams:&textureButtonParams];
    [mBuyButton release];
    
    // Restore button
    textureButtonParams.mButtonText = NSLocalizedString(@"LS_Restore", NULL);
    mRestoreButton = [[TextureButton alloc] InitWithParams:&textureButtonParams];
    [mRestoreButton release];
    
    // Icon
    imageWellParams.mTextureName = @"booster_icon.papng";
    
    mIcon = [[ImageWell alloc] InitWithParams:&imageWellParams];
    [mIcon release];
    
    mIcon.Parent = self;
    
    // Title
    TextBoxParams textBoxParams;
    [TextBox InitDefaultParams:&textBoxParams];
    
    textBoxParams.mString = NSLocalizedString(@"LS_Booster", NULL);
    textBoxParams.mUIGroup = inUIGroup;
    SetColorFloat(&textBoxParams.mColor, 1.0, 1.0, 1.0, 1.0);
    SetColorFloat(&textBoxParams.mStrokeColor, 0.0, 0.0, 0.0, 1.0);
    textBoxParams.mFontSize = 18;
    textBoxParams.mStrokeSize = 8;
    
    mTitle = [[TextBox alloc] InitWithParams:&textBoxParams];
    [mTitle release];
    
    mTitle.Parent = self;
    
    // Description
    textBoxParams.mString = NSLocalizedString(@"LS_BoosterDescription", NULL);
    textBoxParams.mUIGroup = inUIGroup;
    SetColorFloat(&textBoxParams.mColor, 1.0, 1.0, 1.0, 1.0);
    SetColorFloat(&textBoxParams.mStrokeColor, 0.0, 0.0, 0.0, 1.0);
    textBoxParams.mFontSize = 13;
    textBoxParams.mStrokeSize = 8;
    
    mDescription = [[TextBox alloc] InitWithParams:&textBoxParams];
    [mDescription release];
    
    mDescription.Parent = self;
    
    // Connecting
    textBoxParams.mString = NSLocalizedString(@"LS_Connecting", NULL);

    mConnecting = [[TextBox alloc] InitWithParams:&textBoxParams];
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

    mPrice = [[TextBox alloc] InitWithParams:&textBoxParams];
    [mPrice release];
    
    mPrice.Parent = self;
    
    [UIObject PerformWhenAllLoaded:[NSMutableArray arrayWithObjects:mBuyButton, mBackground, mIcon, NULL] queue:dispatch_get_main_queue() block:^
    {
        [mIcon SetPositionX:10 Y:10 Z:0.0];
        [mTitle SetPositionX:(15 + [mIcon GetWidth]) Y:10 Z:0.0];
        
        Vector3 position;
        [mTitle GetPosition:&position];
        
        [mDescription SetPositionX:position.mVector[x] Y:(15 + [mTitle GetHeight]) Z:0.0];

        [mBuyButton SetPositionX:(15 + [mIcon GetWidth]) Y:([mBackground GetHeight] - [mBuyButton GetHeight] - 10) Z:0.0];
        [mBuyButton GetPosition:&position];
        
        [mPrice SetPositionX:10 Y:(15 + [mIcon GetHeight]) Z:0.0];
        
        [mRestoreButton SetPositionX:(position.mVector[x] + [mBuyButton GetWidth] + 10) Y:position.mVector[y] Z:0.0];
        
        [mConnecting SetPositionX:(([mBackground GetWidth] - [mConnecting GetWidth]) / 2) Y:(([mBackground GetHeight] - [mConnecting GetHeight]) / 2) Z:0.0];
    }];
    
    [mBuyButton SetListener:self];
    [mRestoreButton SetListener:self];
    
    mBuyButton.Parent = self;
    mRestoreButton.Parent = self;
    
    mState = BOOSTER_BUTTON_STATE_NORMAL;
    
    if ([[FoodManager GetInstance] GetBooster])
    {
        [self SetState:UI_OBJECT_STATE_INACTIVE];
    }
    
    [GetGlobalMessageChannel() AddListener:self];
    
    return self;
}

-(void)dealloc
{
    [super dealloc];
}

-(Texture*)GetUseTexture
{
    return [mBackground GetTexture];
}

-(u32)GetWidth
{
    return [[self GetUseTexture] GetEffectiveWidth];
}

-(u32)GetHeight
{
    return [[self GetUseTexture] GetEffectiveHeight];
}

-(void)Update:(CFTimeInterval)inTimeStep
{
    [super Update:inTimeStep];
    
    switch(mState)
    {
        case BOOSTER_BUTTON_STATE_CONNECTING:
        {
            if ([[InAppPurchaseManager GetInstance] GetIAPState] == IAP_STATE_IDLE)
            {
                self.State = BOOSTER_BUTTON_STATE_NORMAL;
            }
            
            break;
        }
    }

}

-(void)SetState:(UIObjectState)inState
{
    [super SetState:inState];
    
    switch(inState)
    {
        case UI_OBJECT_STATE_INACTIVE:
        {
            [mBackground SetAlpha:0.5];
            [mIcon SetAlpha:0.5];
            [mPrice SetAlpha:0.5];
            [mTitle SetAlpha:0.5];
            [mDescription SetAlpha:0.5];
            
            [mBuyButton Disable];
            [mRestoreButton Disable];

            break;
        }
    }
}

-(IncrementalGameBuyBoosterButtonState)State
{
    return mState;
}

-(void)setState:(IncrementalGameBuyBoosterButtonState)inState
{
    mState = inState;
    
    switch(inState)
    {
        case BOOSTER_BUTTON_STATE_CONNECTING:
        {
            [mBuyButton Disable];
            [mRestoreButton Disable];
            [mPrice Disable];
            [mDescription Disable];
            
            [mConnecting Enable];
            break;
        }
        
        case BOOSTER_BUTTON_STATE_NORMAL:
        {
            [mBuyButton Enable];
            [mRestoreButton Enable];
            [mPrice Enable];
            [mDescription Enable];
            
            [mConnecting Disable];
            break;
        }
    }
    
    // Re-evaluate UIObject state.  We may have to make some buttons invisible.
    [self SetState:[self GetState]];
}

-(BOOL)ButtonEvent:(ButtonEvent)inEvent Button:(Button*)inButton
{
    if (inEvent == BUTTON_EVENT_UP)
    {
        if (inButton == mBuyButton)
        {
            [[InAppPurchaseManager GetInstance] RequestProduct:IAP_PRODUCT_BOOSTER];
            self.State = BOOSTER_BUTTON_STATE_CONNECTING;
        }
        else if (inButton == mRestoreButton)
        {
            [[InAppPurchaseManager GetInstance] RestorePurchases];
            self.State = BOOSTER_BUTTON_STATE_CONNECTING;
        }
    }

    return TRUE;
}

-(void)ProcessMessage:(Message*)inMsg
{
    switch(inMsg->mId)
    {
        case EVENT_IAP_DELIVER_CONTENT:
        {
            [self SetState:UI_OBJECT_STATE_INACTIVE];
            break;
        }
    }
}

@end

@implementation IncrementalGameReviewButton

-(instancetype)InitWithUIGroup:(UIGroup*)inUIGroup
{
    [super InitWithUIGroup:inUIGroup];
    
    // Create background
    ImageWellParams imageWellParams;
    [ImageWell InitDefaultParams:&imageWellParams];
    
    imageWellParams.mUIGroup = inUIGroup;
    imageWellParams.mTextureName = @"extrasbackground.papng";
    
    mBackground = [[ImageWell alloc] InitWithParams:&imageWellParams];
    [mBackground release];
    
    mBackground.Parent = self;

    // Review button
    TextureButtonParams textureButtonParams;
    [TextureButton InitDefaultParams:&textureButtonParams];
    
    textureButtonParams.mButtonTexBaseName = @"mozzarellabutton.papng";
    textureButtonParams.mButtonTexHighlightedName = @"mozzarellabutton_pressed.papng";
    textureButtonParams.mBoundingBoxCollision = TRUE;
    textureButtonParams.mBoundingBoxBorderSize.mVector[x] = 2;
    textureButtonParams.mBoundingBoxBorderSize.mVector[y] = 2;
    textureButtonParams.mButtonText = NSLocalizedString(@"LS_Go", NULL);
    textureButtonParams.mFontType = NEON_FONT_NORMAL;
    textureButtonParams.mFontSize = 14;
    textureButtonParams.mFontColor = 0xFF;
    
    SetRelativePlacement(&textureButtonParams.mTextPlacement, PLACEMENT_ALIGN_CENTER, PLACEMENT_ALIGN_CENTER);
    
    textureButtonParams.mUIGroup = inUIGroup;
    
    mReviewButton = [[TextureButton alloc] InitWithParams:&textureButtonParams];
    [mReviewButton release];
    
    mReviewButton.Parent = self;
    
    // Icon
    imageWellParams.mTextureName = @"review_icon.papng";
    
    mIcon = [[ImageWell alloc] InitWithParams:&imageWellParams];
    [mIcon release];
    
    mIcon.Parent = self;
    
    // Title
    TextBoxParams textBoxParams;
    [TextBox InitDefaultParams:&textBoxParams];
    
    textBoxParams.mString = NSLocalizedString(@"LS_Review", NULL);
    textBoxParams.mUIGroup = inUIGroup;
    SetColorFloat(&textBoxParams.mColor, 1.0, 1.0, 1.0, 1.0);
    SetColorFloat(&textBoxParams.mStrokeColor, 0.0, 0.0, 0.0, 1.0);
    textBoxParams.mFontSize = 18;
    textBoxParams.mStrokeSize = 8;
    
    mTitle = [[TextBox alloc] InitWithParams:&textBoxParams];
    [mTitle release];
    
    mTitle.Parent = self;

    // Description
    textBoxParams.mString = NSLocalizedString(@"LS_ReviewDescription", NULL);
    textBoxParams.mUIGroup = inUIGroup;
    SetColorFloat(&textBoxParams.mColor, 1.0, 1.0, 1.0, 1.0);
    SetColorFloat(&textBoxParams.mStrokeColor, 0.0, 0.0, 0.0, 1.0);
    textBoxParams.mFontSize = 13;
    textBoxParams.mStrokeSize = 8;
    textBoxParams.mWidth = 150;
    
    mDescription = [[TextBox alloc] InitWithParams:&textBoxParams];
    [mDescription release];
    
    mDescription.Parent = self;
    
    [UIObject PerformWhenAllLoaded:[NSMutableArray arrayWithObjects:mReviewButton, mBackground, mIcon, NULL] queue:dispatch_get_main_queue() block:^
    {
        [mIcon SetPositionX:10 Y:10 Z:0.0];
        [mTitle SetPositionX:(15 + [mIcon GetWidth]) Y:10 Z:0.0];
        
        Vector3 position;
        [mTitle GetPosition:&position];
        
        [mDescription SetPositionX:position.mVector[x] Y:(15 + [mTitle GetHeight]) Z:0.0];

        [mReviewButton SetPositionX:(15 + [mIcon GetWidth] + 10 + [mReviewButton GetWidth]) Y:([mBackground GetHeight] - [mReviewButton GetHeight] - 10) Z:0.0];
        [mReviewButton GetPosition:&position];
    }];
    
    
    [mReviewButton SetListener:self];
    
    mReviewButton.Parent = self;
    
    if ([[SaveSystem GetInstance] GetRatedGame] == REVIEW_LEVEL_COMPLETED)
    {
        [self SetState:UI_OBJECT_STATE_INACTIVE];
    }
    
    [GetGlobalMessageChannel() AddListener:self];

    return self;
}

-(void)dealloc
{
    [super dealloc];
}

-(Texture*)GetUseTexture
{
    return [mBackground GetTexture];
}

-(u32)GetWidth
{
    return [[self GetUseTexture] GetEffectiveWidth];
}

-(u32)GetHeight
{
    return [[self GetUseTexture] GetEffectiveHeight];
}

-(BOOL)ButtonEvent:(ButtonEvent)inEvent Button:(Button*)inButton
{
    switch(inEvent)
    {
        case BUTTON_EVENT_UP:
        {
            if (inButton == mReviewButton)
            {
                [[Flow GetInstance] AppRate];
                break;
            }
            
            break;
        }
    }
    
    return TRUE;
}

-(void)ProcessMessage:(Message*)inMsg
{
    switch(inMsg->mId)
    {
        case EVENT_RATED_GAME:
        {
            [self SetState:UI_OBJECT_STATE_INACTIVE];
            break;
        }
    }
}

-(void)SetState:(UIObjectState)inState
{
    [super SetState:inState];
    
    switch(inState)
    {
        case UI_OBJECT_STATE_INACTIVE:
        {
            [mBackground SetAlpha:0.5];
            [mIcon SetAlpha:0.5];
            [mTitle SetAlpha:0.5];
            [mDescription SetAlpha:0.5];
            
            [mReviewButton Disable];

            break;
        }
    }
}

@end

@implementation IncrementalGameBackgroundButton

-(instancetype)InitWithUIGroup:(UIGroup*)inUIGroup
{
    [super InitWithUIGroup:inUIGroup];
    
    // Create background
    ImageWellParams imageWellParams;
    [ImageWell InitDefaultParams:&imageWellParams];
    
    imageWellParams.mUIGroup = inUIGroup;
    imageWellParams.mTextureName = @"extrasbackground.papng";
    
    mBackground = [[ImageWell alloc] InitWithParams:&imageWellParams];
    [mBackground release];
    
    mBackground.Parent = self;

    // Review button
    TextureButtonParams textureButtonParams;
    [TextureButton InitDefaultParams:&textureButtonParams];
    
    textureButtonParams.mButtonTexBaseName = @"mozzarellabutton.papng";
    textureButtonParams.mButtonTexHighlightedName = @"mozzarellabutton_pressed.papng";
    textureButtonParams.mBoundingBoxCollision = TRUE;
    textureButtonParams.mBoundingBoxBorderSize.mVector[x] = 2;
    textureButtonParams.mBoundingBoxBorderSize.mVector[y] = 2;
    textureButtonParams.mButtonText = NSLocalizedString(@"LS_Go", NULL);
    textureButtonParams.mFontType = NEON_FONT_NORMAL;
    textureButtonParams.mFontSize = 14;
    textureButtonParams.mFontColor = 0xFF;
    
    SetRelativePlacement(&textureButtonParams.mTextPlacement, PLACEMENT_ALIGN_CENTER, PLACEMENT_ALIGN_CENTER);
    
    textureButtonParams.mUIGroup = inUIGroup;
    
    // Icon
    imageWellParams.mTextureName = @"vault_icon.papng";
    
    mIcon = [[ImageWell alloc] InitWithParams:&imageWellParams];
    [mIcon release];
    
    mIcon.Parent = self;
    
    // Title
    TextBoxParams textBoxParams;
    [TextBox InitDefaultParams:&textBoxParams];
    
    textBoxParams.mString = NSLocalizedString(@"LS_Vault", NULL);
    textBoxParams.mUIGroup = inUIGroup;
    SetColorFloat(&textBoxParams.mColor, 1.0, 1.0, 1.0, 1.0);
    SetColorFloat(&textBoxParams.mStrokeColor, 0.0, 0.0, 0.0, 1.0);
    textBoxParams.mFontSize = 18;
    textBoxParams.mStrokeSize = 8;
    
    mTitle = [[TextBox alloc] InitWithParams:&textBoxParams];
    [mTitle release];
    
    mTitle.Parent = self;

    // Description
    textBoxParams.mString = NSLocalizedString(@"LS_ReviewDescription", NULL);
    textBoxParams.mUIGroup = inUIGroup;
    SetColorFloat(&textBoxParams.mColor, 1.0, 1.0, 1.0, 1.0);
    SetColorFloat(&textBoxParams.mStrokeColor, 0.0, 0.0, 0.0, 1.0);
    textBoxParams.mFontSize = 13;
    textBoxParams.mStrokeSize = 8;
    textBoxParams.mWidth = 150;
    
    mDescription = [[TextBox alloc] InitWithParams:&textBoxParams];
    [mDescription release];
    
    mDescription.Parent = self;
    
    [UIObject PerformWhenAllLoaded:[NSMutableArray arrayWithObjects:mBackground, mIcon, NULL] queue:dispatch_get_main_queue() block:^
    {
        [mIcon SetPositionX:10 Y:10 Z:0.0];
        [mTitle SetPositionX:(15 + [mIcon GetWidth]) Y:10 Z:0.0];
        
        Vector3 position;
        [mTitle GetPosition:&position];
        
        [mDescription SetPositionX:position.mVector[x] Y:(15 + [mTitle GetHeight]) Z:0.0];
    }];
    
    [GetGlobalMessageChannel() AddListener:self];

    return self;
}

-(void)dealloc
{
    [super dealloc];
}

-(Texture*)GetUseTexture
{
    return [mBackground GetTexture];
}

-(u32)GetWidth
{
    return [[self GetUseTexture] GetEffectiveWidth];
}

-(u32)GetHeight
{
    return [[self GetUseTexture] GetEffectiveHeight];
}

-(BOOL)ButtonEvent:(ButtonEvent)inEvent Button:(Button*)inButton
{
    switch(inEvent)
    {
        case BUTTON_EVENT_UP:
        {
            break;
        }
    }
    
    return TRUE;
}

-(void)ProcessMessage:(Message*)inMsg
{
    switch(inMsg->mId)
    {
        case EVENT_RATED_GAME:
        {
            [self SetState:UI_OBJECT_STATE_INACTIVE];
            break;
        }
    }
}

-(void)SetState:(UIObjectState)inState
{
    [super SetState:inState];
    
    switch(inState)
    {
        case UI_OBJECT_STATE_INACTIVE:
        {
            [mBackground SetAlpha:0.5];
            [mIcon SetAlpha:0.5];
            [mTitle SetAlpha:0.5];
            [mDescription SetAlpha:0.5];

            break;
        }
    }
}

@end
