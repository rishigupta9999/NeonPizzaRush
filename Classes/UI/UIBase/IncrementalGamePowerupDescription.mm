//
//  IncrementalGamePowerupDescription.m
//  PizzaSpinner
//
//  Created by Rishi Gupta on 6/25/14.
//  Copyright (c) 2014 Neon Games LLC. All rights reserved.
//

#import "IncrementalGamePowerupDescription.h"
#import "ImageWell.h"
#import "Flow.h"
#import "TextBox.h"
#import "TextureButton.h"
#import "FoodManager.h"

@implementation IncrementalGamePowerupDescriptionParams

@synthesize PizzaPowerup = mPizzaPowerup;
@synthesize UIGroup = mUIGroup;
@synthesize Background = mBackground;

@synthesize BuyButton = mBuyButton;
@synthesize BuyButtonPressed = mBuyButtonPressed;
@synthesize BuyButtonDisabled = mBuyButtonDisabled;

static NSString* sCurrencyFilenames[PIZZA_POWERUP_UPGRADE_NUM] = {   @"pepperoni_currency.papng",
                                                                     @"pepperoni_currency_bronze.papng",
                                                                     @"pepperoni_currency_silver.papng",
                                                                     @"pepperoni_currency_gold.papng" };

-(instancetype)Init
{
    mPizzaPowerup = PIZZA_POWERUP_INVALID;
    mUIGroup = NULL;
    mBackground = NULL;
    
    mBuyButton = NULL;
    mBuyButtonPressed = NULL;
    mBuyButtonDisabled = NULL;
    
    return self;
}

@end


@implementation IncrementalGamePowerupDescription

@synthesize CloseButton = mCloseButton;
@synthesize BuyButton = mBuyButton;
@synthesize Displayed = mDisplayed;

-(instancetype)InitWithParams:(IncrementalGamePowerupDescriptionParams*)inParams
{
    [super InitWithUIGroup:inParams.UIGroup];
    
    mPizzaPowerup = inParams.PizzaPowerup;
    
    PizzaPowerupStats* stats = [[Flow GetInstance].PizzaPowerupInfo GetStatsForPowerup:inParams.PizzaPowerup];
    PizzaUpgradeInfo* upgradeInfo = [[FoodManager GetInstance] GetNextUpgradeInfo:mPizzaPowerup];
    
    mDisplayedUpgradeLevel = [[SaveSystem GetInstance] GetUpgradeLevelForPowerup:mPizzaPowerup];
    
    NSAssert(inParams.UIGroup != NULL, @"A UIGroup is required");
    
    ImageWellParams imageWellParams;
    [ImageWell InitDefaultParams:&imageWellParams];
    
    imageWellParams.mUIGroup = inParams.UIGroup;
    imageWellParams.mTextureName = inParams.Background;
    
    mBackground = [[ImageWell alloc] InitWithParams:&imageWellParams];
    [mBackground release];
    
    mBackground.Parent = self;
    
    // Icon of the powerup
    imageWellParams.mTextureName = stats.IconTexture;
    mIcon = [[ImageWell alloc] InitWithParams:&imageWellParams];
    [mIcon release];
    
    [mIcon SetScaleX:0.5 Y:0.5 Z:1.0];
    
    mIcon.Parent = self;
    
    [mIcon SetPositionX:10 Y:10 Z:0.0];
    
    for (int i = 0; i < PIZZA_POWERUP_UPGRADE_NUM; i++)
    {
        // Currency image
        imageWellParams.mTextureName = sCurrencyFilenames[i];
        mCurrency[i] = [[ImageWell alloc] InitWithParams:&imageWellParams];
        [mCurrency[i] release];
        
        [mCurrency[i] SetVisible:FALSE];
        
        mCurrency[i].Parent = self;
        
        // Upgrade currency image
        mUpgradeCurrency[i] = [[ImageWell alloc] InitWithParams:&imageWellParams];
        [mUpgradeCurrency[i] release];
        
        if (upgradeInfo == NULL)
        {
            [mUpgradeCurrency[i] Disable];
        }
        else
        {
            [mUpgradeCurrency[i] SetVisible:FALSE];
        }
        
        mUpgradeCurrency[i].Parent = self;
    }
    
    mLastUpgradeLevel = -1;
    [self EvaluateCurrencyIcons];
    
    // Name of item
    TextBoxParams textBoxParams;
    [TextBox InitDefaultParams:&textBoxParams];
    
    textBoxParams.mUIGroup = inParams.UIGroup;
    textBoxParams.mString = [NSString stringWithFormat:@"<B>%@</B>", stats.Name];
    textBoxParams.mFontSize = 18;
    textBoxParams.mWidth = 180;
    textBoxParams.mAlignment = kCTTextAlignmentCenter;
    
    SetColorFloat(&textBoxParams.mColor, 1.0, 1.0, 1.0, 0.7);
    SetColorFloat(&textBoxParams.mStrokeColor, 0.0, 0.0, 0.0, 1.0);
    
    textBoxParams.mStrokeSize = 2;
    
    mName = [[TextBox alloc] InitWithParams:&textBoxParams];
    [mName release];
    
    mName.Parent = self;
    
    // Description of item
    textBoxParams.mString = stats.Description;
    textBoxParams.mFontSize = 14;
    textBoxParams.mWidth = 220;
    textBoxParams.mAlignment = kCTTextAlignmentLeft;
    
    mDescription = [[TextBox alloc] InitWithParams:&textBoxParams];
    [mDescription release];
    
    mDescription.Parent = self;

    // Buy button
    TextureButtonParams textureButtonParams;
    [TextureButton InitDefaultParams:&textureButtonParams];
    
    textureButtonParams.mButtonTexBaseName = @"buy.papng";
    textureButtonParams.mButtonTexHighlightedName = @"buy_pressed.papng";
    textureButtonParams.mButtonTexDisabledName = @"buy_disabled.papng";
    
    textureButtonParams.mUIGroup = inParams.UIGroup;
    
    mBuyButton = [[TextureButton alloc] InitWithParams:&textureButtonParams];
    [mBuyButton release];
    
    // Close button
    [TextureButton InitDefaultParams:&textureButtonParams];
    textureButtonParams.mButtonTexBaseName = @"close.papng";
    textureButtonParams.mButtonTexHighlightedName = @"close_pressed.papng";
    
    textureButtonParams.mUIGroup = inParams.UIGroup;
    
    mCloseButton = [[TextureButton alloc] InitWithParams:&textureButtonParams];
    [mCloseButton release];
    
    mCloseButton.Parent = self;
    
    // Upgrade button
    [TextureButton InitDefaultParams:&textureButtonParams];
    textureButtonParams.mButtonTexBaseName = @"upgrade.papng";
    textureButtonParams.mButtonTexHighlightedName = @"upgrade_pressed.papng";
    textureButtonParams.mButtonTexDisabledName = @"upgrade_disabled.papng";
    
    textureButtonParams.mUIGroup = inParams.UIGroup;
    
    mUpgradeButton = [[TextureButton alloc] InitWithParams:&textureButtonParams];
    [mUpgradeButton release];
    
    [mUpgradeButton SetListener:self];
    
    if (upgradeInfo == NULL)
    {
        [mUpgradeButton Disable];
    }
    
    mUpgradeButton.Parent = self;
    
    // Text showing regeneration rate
    textBoxParams.mMutable = TRUE;
    textBoxParams.mMaxWidth = 225;
    textBoxParams.mMaxHeight = 100;
    textBoxParams.mString = [self GetRegenRateString];
    
    mRegenRate = [[TextBox alloc] InitWithParams:&textBoxParams];
    [mRegenRate release];

    mRegenRate.Parent = self;
    
    // Text showing current quantity
    textBoxParams.mMaxWidth = 240;
    textBoxParams.mWidth = 235;
    textBoxParams.mString = [self GetQuantityString];
    textBoxParams.mFontSize = 12;
    
    mQuantity = [[TextBox alloc] InitWithParams:&textBoxParams];
    [mQuantity release];
    
    mQuantity.Parent = self;
    
    // Cost
    textBoxParams.mString = NeonFormatDoubleToLength([[FoodManager GetInstance] GetPowerupCost:mPizzaPowerup], false, 3);
    textBoxParams.mFontSize = 18;
    mCost = [[TextBox alloc] InitWithParams:&textBoxParams];
    [mCost release];
    
    mCost.Parent = self;
    
    // Upgrade cost
    if (upgradeInfo == NULL)
    {
        textBoxParams.mString = @"";
    }
    else
    {
        textBoxParams.mString = NeonFormatDoubleToLength(upgradeInfo->mUpgradeCost, false, 1);
    }
    
    mUpgradeCost = [[TextBox alloc] InitWithParams:&textBoxParams];
    [mUpgradeCost release];
    
    mUpgradeCost.Parent = self;
    
    // Upgrade min quantity
    if (upgradeInfo == NULL)
    {
        textBoxParams.mString = @"";
    }
    else
    {
        textBoxParams.mString = [NSString stringWithFormat:NSLocalizedString(@"LS_Upgrade_Min_Quantity", NULL), upgradeInfo->mMinQuantity, stats.Name];
    }
    
    textBoxParams.mAlignment = kCTTextAlignmentJustified;
    textBoxParams.mFontSize = 12;
    textBoxParams.mMaxWidth = 130;
    textBoxParams.mMaxHeight = 200;
    textBoxParams.mWidth = 120;
    
    mUpgradeLevel = [[TextBox alloc] InitWithParams:&textBoxParams];
    [mUpgradeLevel release];
    
    mUpgradeLevel.Parent = self;
    
    // Upgrade Description
    if (upgradeInfo == NULL)
    {
        textBoxParams.mString = @"";
    }
    else
    {
        textBoxParams.mString = [[FoodManager GetInstance] GetUpgradeStringForPowerup:mPizzaPowerup];
    }
    
    textBoxParams.mAlignment = kCTTextAlignmentJustified;
    textBoxParams.mFontSize = 12;
    textBoxParams.mMaxWidth = 100;
    textBoxParams.mMaxHeight = 200;
    textBoxParams.mWidth = 90;
    
    mUpgradeDescription = [[TextBox alloc] InitWithParams:&textBoxParams];
    [mUpgradeDescription release];
    
    mUpgradeDescription.Parent = self;
    
    if (upgradeInfo != NULL)
    {
        if (([[FoodManager GetInstance] GetNumPizza] < upgradeInfo->mUpgradeCost) || ([[FoodManager GetInstance] GetNumPowerup:mPizzaPowerup] < upgradeInfo->mMinQuantity))
        {
            [mUpgradeDescription Disable];
            [mUpgradeButton SetState:UI_OBJECT_STATE_DISABLED];
        }
        else
        {
            [mUpgradeLevel Disable];
        }
    }
    
    [UIObject PerformWhenAllLoaded:[NSMutableArray arrayWithObjects:mBackground, mIcon, mCurrency[0], mCurrency[1], mCurrency[2], mCurrency[3], mBuyButton, mCloseButton, mUpgradeButton, NULL] queue:dispatch_get_main_queue() block:^
    {
        float yPos = 10 + (((int)[mIcon GetHeight] - (int)[mName GetHeight]) / 2.0);
        
        [mName SetPositionX:([mIcon GetWidth] + ([mBackground GetWidth] - [mIcon GetWidth]) / 2.0) Y:yPos Z:0.0];
        [mDescription SetPositionX:10 Y:([mIcon GetHeight] + 10) Z:0.0];
        
        Vector3 position;
        [mDescription GetPosition:&position];
        
        [mRegenRate SetPositionX:10 Y:(position.mVector[y] + [mDescription GetHeight] + 10) Z:0.0];
        
        [mRegenRate GetPosition:&position];
        [mQuantity SetPositionX:10 Y:(position.mVector[y] + [mRegenRate GetHeight] + 5) Z:0.0];
        
        [mQuantity GetPosition:&position];
        
        for (int i = 0; i < PIZZA_POWERUP_UPGRADE_NUM; i++)
        {
            [mCurrency[i] SetPositionX:10 Y:(position.mVector[y] + [mQuantity GetHeight] + 15) Z:0.0];
        }
        
        [mCurrency[0] GetPosition:&position];

        for (int i = 0; i < PIZZA_POWERUP_UPGRADE_NUM; i++)
        {
            [mUpgradeCurrency[i] SetPositionX:10 Y:(position.mVector[y] + [mCurrency[0] GetHeight] + 10) Z:0.0];
        }
        
        [mCurrency[0] GetPosition:&position];
        [mCost SetPositionX:(position.mVector[x] + [mCurrency[0] GetWidth] + 10) Y:(position.mVector[y] + (([mCurrency[0] GetHeight] - [mCost GetHeight]) / 2)) Z:0.0];
        
        [mUpgradeCurrency[0] GetPosition:&position];
        [mUpgradeCost SetPositionX:(position.mVector[x] + [mUpgradeCurrency[0] GetWidth] + 10) Y:(position.mVector[y] + (([mCurrency[0] GetHeight] - [mCost GetHeight]) / 2)) Z:0.0];
        
        int yOffset = ((int)[mCurrency[0] GetHeight] - (int)[mBuyButton GetHeight]) / 2;
        int upgradeButtonOffset = ([mUpgradeButton GetWidth] - [mBuyButton GetWidth]) / 2;
        
        [mCurrency[0] GetPosition:&position];
        [mBuyButton SetPositionX:([mBackground GetWidth] - [mUpgradeButton GetWidth] + upgradeButtonOffset - 10) Y:(position.mVector[y] + yOffset) Z:0.0];
        [mBuyButton GetPosition:&position];
        
        [mUpgradeButton SetPositionX:([mBackground GetWidth] - [mUpgradeButton GetWidth] - 10) Y:(5 + position.mVector[y] + [mBuyButton GetHeight]) Z:0.0];
        [mUpgradeButton GetPosition:&position];
        
        [mUpgradeDescription SetPositionX:(position.mVector[x] + [mUpgradeButton GetWidth] - [mUpgradeDescription GetWidth]) Y:(position.mVector[y] + [mUpgradeButton GetHeight] + 5) Z:0.0];
        [mUpgradeLevel SetPositionX:(position.mVector[x] + [mUpgradeButton GetWidth] - [mUpgradeLevel GetWidth]) Y:(position.mVector[y] + [mUpgradeButton GetHeight] + 5) Z:0.0];
        
        [mCloseButton SetPositionX:10 Y:(GetScreenVirtualHeight() - [mCloseButton GetHeight] - 10) Z:0.0];
    } ];
        
    mBuyButton.Parent = self;
    
    mDisplayed = FALSE;
    
    [GetGlobalMessageChannel() AddListener:self];
    
    return self;
}

-(void)dealloc
{
    [super dealloc];
}

-(void)Remove
{
    [GetGlobalMessageChannel() RemoveListener:self];
}

-(int)GetWidth
{
    return [mBackground GetWidth];
}

-(int)GetHeight
{
    return [mBackground GetHeight];
}

-(Texture*)GetUseTexture
{
    return [mBackground GetTexture];
}

-(void)Update:(CFTimeInterval)inTimeStep
{
    PizzaPowerupStats* stats = [[Flow GetInstance].PizzaPowerupInfo GetStatsForPowerup:mPizzaPowerup];
    
    int numPowerup = [[FoodManager GetInstance] GetNumPowerup:mPizzaPowerup];
    float regenRate = [[FoodManager GetInstance] GetRegenRateForPowerup:mPizzaPowerup] * numPowerup;

    if (mLastRegenRate != regenRate)
    {
        [mQuantity SetString:[self GetQuantityString]];
    }
    
    double cost = [[FoodManager GetInstance] GetPowerupCost:mPizzaPowerup];
    double numPizza = [[FoodManager GetInstance] GetNumPizza];
    
    if (mDisplayed)
    {
        if ([[FoodManager GetInstance] GetNumPizzasForPowerup:mPizzaPowerup] != mLastPizzaQuantity)
        {
            [mQuantity SetString:[self GetQuantityString]];
        }
    }

    if (cost > numPizza)
    {
        if ([self.BuyButton GetState] != UI_OBJECT_STATE_DISABLED)
        {
            [self.BuyButton SetState:UI_OBJECT_STATE_DISABLED];
        }
    }
    else
    {
        if ([self.BuyButton GetState] == UI_OBJECT_STATE_DISABLED)
        {
            [self.BuyButton SetState:UI_OBJECT_STATE_ENABLED];
        }
    }
    
    [self EvaluateUpgradeButton];
    [self EvaluateCurrencyIcons];
    
    [super Update:inTimeStep];
}

-(void)ProcessMessage:(Message*)inMsg
{
    switch(inMsg->mId)
    {
        case EVENT_IAP_DELIVER_CONTENT:
        {
            [mRegenRate SetString:[self GetRegenRateString]];
            break;
        }
        
        case EVENT_INCREMENTAL_GAME_POWERUP_PURCHASED:
        {
            [mRegenRate SetString:[self GetRegenRateString]];
            break;
        }
    }
}

-(BOOL)ButtonEvent:(ButtonEvent)inEvent Button:(Button*)inButton
{
    if (inEvent == BUTTON_EVENT_UP)
    {
        if (inButton == mUpgradeButton)
        {
            [[FoodManager GetInstance] UpgradePowerup:mPizzaPowerup];
            [mRegenRate SetString:[self GetRegenRateString]];
            
            PizzaUpgradeInfo* upgradeInfo = [[FoodManager GetInstance] GetNextUpgradeInfo:mPizzaPowerup];
            
            if (upgradeInfo == NULL)
            {
                [mUpgradeDescription Disable];
                [mUpgradeButton Disable];
                
                for (int i = 0; i < PIZZA_POWERUP_UPGRADE_NUM; i++)
                {
                    [mUpgradeCurrency[i] Disable];
                }
                
                [mUpgradeCost Disable];
            }
            else
            {
                [self EvaluateUpgradeButton];
            }
            
            [GetGlobalMessageChannel() SendEvent:EVENT_INCREMENTAL_GAME_POWERUP_PURCHASED withData:[NSNumber numberWithInt:mPizzaPowerup]];
        }
    }
    
    return TRUE;
}

-(NSString*)GetRegenRateString
{
    return [NSString stringWithFormat:NSLocalizedString(@"LS_PizzasPerSecond", NULL), [[FoodManager GetInstance] GetRegenRateForPowerup:mPizzaPowerup]];
}

-(NSString*)GetQuantityString
{
    PizzaPowerupStats* stats = [[Flow GetInstance].PizzaPowerupInfo GetStatsForPowerup:mPizzaPowerup];
    
    int numPowerup = [[FoodManager GetInstance] GetNumPowerup:mPizzaPowerup];
    
    mLastRegenRate = [[FoodManager GetInstance] GetRegenRateForPowerup:mPizzaPowerup] * numPowerup;
    mLastPizzaQuantity = [[FoodManager GetInstance] GetNumPizzasForPowerup:mPizzaPowerup];
    
    NSString* pizzaQuantity = NeonFormatDoubleToLength(mLastPizzaQuantity, true, 3);
    NSString* regenRate = NeonFormatDoubleToLength(mLastRegenRate, true, 3);
    
    return [NSString stringWithFormat:NSLocalizedString(@"LS_Powerup_Quantity", NULL), numPowerup, [[SaveSystem GetInstance] GetUpgradeLevelForPowerup:mPizzaPowerup], regenRate, pizzaQuantity];
}

-(void)UpdatePrice
{
    [mCost SetString:NeonFormatDoubleToLength([[FoodManager GetInstance] GetPowerupCost:mPizzaPowerup], false, 3)];
}

-(void)EvaluateUpgradeButton
{
    double numPizza = [[FoodManager GetInstance] GetNumPizza];
    PizzaUpgradeInfo* upgradeInfo = [[FoodManager GetInstance] GetNextUpgradeInfo:mPizzaPowerup];
    
    if (upgradeInfo != NULL)
    {
        BOOL requiredQuantity = ([[FoodManager GetInstance] GetNumPowerup:mPizzaPowerup] >= upgradeInfo->mMinQuantity);
        BOOL upgradeEnabled = (numPizza >= upgradeInfo->mUpgradeCost) && (requiredQuantity);
        
        if ([mUpgradeButton GetState] == UI_OBJECT_STATE_DISABLED)
        {
            if (upgradeEnabled)
            {
                [mUpgradeButton SetState:UI_OBJECT_STATE_ENABLED];
            }
        }
        else if ([mUpgradeButton GetState] == UI_OBJECT_STATE_ENABLED)
        {
            if (!upgradeEnabled)
            {
                [mUpgradeButton SetState:UI_OBJECT_STATE_DISABLED];
            }
        }
        
        if ([mUpgradeLevel GetVisible])
        {
            if (requiredQuantity)
            {
                [mUpgradeDescription Enable];
                [mUpgradeLevel Disable];
            }
        }
        else
        {
            if (!requiredQuantity)
            {
                [mUpgradeDescription Disable];
                [mUpgradeLevel Enable];
            }
        }
        
        if (mDisplayedUpgradeLevel != [[SaveSystem GetInstance] GetUpgradeLevelForPowerup:mPizzaPowerup])
        {
            mDisplayedUpgradeLevel = [[SaveSystem GetInstance] GetUpgradeLevelForPowerup:mPizzaPowerup];
            
            PizzaPowerupStats* stats = [[Flow GetInstance].PizzaPowerupInfo GetStatsForPowerup:mPizzaPowerup];

            [mUpgradeDescription SetString:[[FoodManager GetInstance] GetUpgradeStringForPowerup:mPizzaPowerup]];
            [mUpgradeLevel SetString:[NSString stringWithFormat:NSLocalizedString(@"LS_Upgrade_Min_Quantity", NULL), upgradeInfo->mMinQuantity, stats.Name]];
            [mUpgradeCost SetString:NeonFormatDoubleToLength(upgradeInfo->mUpgradeCost, false, 1)];
        }
    }
}

-(void)EvaluateCurrencyIcons
{
    int upgradeLevel = [[SaveSystem GetInstance] GetUpgradeLevelForPowerup:mPizzaPowerup];
    NSAssert(upgradeLevel < PIZZA_POWERUP_UPGRADE_NUM, @"Upgrade level is out of bounds");
    
    if (upgradeLevel != mLastUpgradeLevel)
    {
        [mCurrency[upgradeLevel] SetVisible:TRUE];
        
        if ([[FoodManager GetInstance] GetNextUpgradeInfo:mPizzaPowerup] != NULL)
        {
            [mUpgradeCurrency[upgradeLevel] SetVisible:TRUE];
        }
        
        if (mLastUpgradeLevel != -1)
        {
            [mCurrency[mLastUpgradeLevel] SetVisible:FALSE];
            [mUpgradeCurrency[mLastUpgradeLevel] SetVisible:FALSE];
        }
        
        mLastUpgradeLevel = upgradeLevel;
    }

}

@end
