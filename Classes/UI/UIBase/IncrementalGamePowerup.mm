//
//  IncrementalGamePowerup.m
//  PizzaSpinner
//
//  Created by Rishi Gupta on 6/23/14.
//  Copyright (c) 2014 Neon Games LLC. All rights reserved.
//

#import "IncrementalGamePowerup.h"
#import "ImageWell.h"
#import "TextBox.h"
#import "FoodManager.h"

@implementation IncrementalGamePowerupParams

@synthesize UIGroup = mUIGroup;
@synthesize IconTexture = mIconTexture;
@synthesize Name = mName;
@synthesize Background = mBackground;
@synthesize BackgroundPressed = mBackgroundPressed;
@synthesize UnlockState = mUnlockState;
@synthesize PizzaPowerup = mPizzaPowerup;

static NSString* sCurrencyFilenames[PIZZA_POWERUP_UPGRADE_NUM] = {  @"pepperoni_currency.papng",
                                                                     @"pepperoni_currency_bronze.papng",
                                                                     @"pepperoni_currency_silver.papng",
                                                                     @"pepperoni_currency_gold.papng" };

-(instancetype)Init
{
    mUIGroup = NULL;
    mIconTexture = NULL;
    mName = NULL;
    mBackground = NULL;
    mBackgroundPressed = NULL;
    mUnlockState = PIZZA_POWERUP_UNLOCKED;
    mPizzaPowerup = PIZZA_POWERUP_INVALID;
    
    return self;
}

@end

@implementation IncrementalGamePowerup

-(instancetype)InitWithParams:(IncrementalGamePowerupParams*)inParams
{
    NSAssert(inParams.UIGroup != NULL, @"A UIGroup is required");
    
    [super InitWithUIGroup:inParams.UIGroup];
    
    mPizzaPowerup = inParams.PizzaPowerup;
    
    // Create background
    
    ImageWellParams imageWellParams;
    [ImageWell InitDefaultParams:&imageWellParams];
    
    imageWellParams.mUIGroup = inParams.UIGroup;
    imageWellParams.mTextureName = inParams.Background;
    
    mBackground = [[ImageWell alloc] InitWithParams:&imageWellParams];
    [mBackground release];
    
    mBackground.Parent = self;
    
    // Create background for button when pressed
    
    imageWellParams.mTextureName = inParams.BackgroundPressed;
    
    mBackgroundPressed = [[ImageWell alloc] InitWithParams:&imageWellParams];
    [mBackgroundPressed release];
    
    [mBackgroundPressed SetVisible:FALSE];
    mBackgroundPressed.Parent = self;

    // Create icon
    imageWellParams.mTextureName = inParams.IconTexture;
    
    mIcon = [[ImageWell alloc] InitWithParams:&imageWellParams];
    [mIcon release];
    
    mIcon.Parent = self;
    
    [mIcon SetPositionX:10.0 Y:10.0 Z:0.0];
    
    // Currency
    for (int i = 0; i < PIZZA_POWERUP_UPGRADE_NUM; i++)
    {
        imageWellParams.mTextureName = sCurrencyFilenames[i];
        mCurrency[i] = [[ImageWell alloc] InitWithParams:&imageWellParams];
        
        mCurrency[i].Parent = self;
        [mCurrency[i] SetPositionX:10.0 Y:50 Z:0.0];
        [mCurrency[i] SetScaleX:0.75 Y:0.75 Z:1.0];
        
        [mCurrency[i] SetVisible:FALSE];
    }
    
    mLastUpgradeLevel = -1;
    
    [self EvaluateCurrencyIcon:FALSE];
    
    // Create name of this powerup
    TextBoxParams textBoxParams;
    [TextBox InitDefaultParams:&textBoxParams];
    
    mPowerupName = [inParams.Name retain];
    
    switch(inParams.UnlockState)
    {
        case PIZZA_POWERUP_QUESTION:
        case PIZZA_POWERUP_INVISIBLE:
        {
            textBoxParams.mString = @"???";
            break;
        }
        
        default:
        {
            textBoxParams.mString = inParams.Name;
            break;
        }
    }
    
    textBoxParams.mMutable = TRUE;
    textBoxParams.mUIGroup = inParams.UIGroup;
    textBoxParams.mFontSize = 18;
    textBoxParams.mWidth = 145;
    textBoxParams.mMaxWidth = 150;
    textBoxParams.mMaxHeight = 200;
    textBoxParams.mAlignment = kCTTextAlignmentCenter;
    
    SetColorFloat(&textBoxParams.mColor, 1.0, 1.0, 1.0, 0.6);
    SetColorFloat(&textBoxParams.mStrokeColor, 0.0, 0.0, 0.0, 1.0);
    
    textBoxParams.mStrokeSize = 2;
    
    mName = [[TextBox alloc] InitWithParams:&textBoxParams];
    [mName release];
    
    mName.Parent = self;
    
    // Textbox for the cost
    textBoxParams.mString = NeonFormatDoubleToLength([[FoodManager GetInstance] GetPowerupCost:mPizzaPowerup], false, 1);
    textBoxParams.mFontSize = 18;
    textBoxParams.mAlignment = kCTTextAlignmentLeft;
    mCost = [[TextBox alloc] InitWithParams:&textBoxParams];
    [mCost release];
    
    mCost.Parent = self;

    // Textbox for the quantity
    int quantity = [[FoodManager GetInstance] GetNumPowerup:mPizzaPowerup];
    
    SetColor(&textBoxParams.mBackgroundColor, 0, 0, 0, 0xA0);
    SetColorFloat(&textBoxParams.mColor, 1.0, 1.0, 1.0, 0.5);
    textBoxParams.mFontSize = 28;
    textBoxParams.mString = [NSString stringWithFormat:@"<B>%d</B>", quantity];
    mQuantity = [[TextBox alloc] InitWithParams:&textBoxParams];
    [mQuantity release];
    
    if (quantity == 0)
    {
        [mQuantity SetVisible:FALSE];
    }
    
    mQuantity.Parent = self;
    
    [UIObject PerformWhenAllLoaded:[NSMutableArray arrayWithObjects:mIcon, mCurrency[0], mCurrency[1], mCurrency[2], mCurrency[3], mCost, mBackground, NULL] queue:dispatch_get_main_queue() block:^
    {
        [mName SetPositionX:([mIcon GetWidth] + ([mBackground GetWidth] - [mIcon GetWidth]) / 2.0) Y:10.0 Z:0.0];
        
        for (int i = 0; i < PIZZA_POWERUP_UPGRADE_NUM; i++)
        {
            [mCurrency[i] SetPositionX:105 Y:60 Z:0.0];
        }
        
        Vector3 currencyPos;
        [mCurrency[0] GetPosition:&currencyPos];
        
        [mCost SetPositionX:(currencyPos.mVector[x] + [mCurrency[0] GetWidth] + 5) Y:currencyPos.mVector[y] Z:0];
        [mQuantity SetPositionX:5.0 Y:([mBackground GetHeight] - [mQuantity GetHeight] - 5.0) Z:0.0];
    } ];
    
    mIconColorPath = NULL;
    mBackgroundColorPath = NULL;
    
    switch(inParams.UnlockState)
    {
        case PIZZA_POWERUP_INVISIBLE:
        case PIZZA_POWERUP_QUESTION:
        {
            mBackground.ColorMultiplyEnabled = TRUE;
            SetColorFloat(&mBackground->mColorMultiply, 0.4, 0.4, 0.4, 1.0);
            
            mIcon.ColorMultiplyEnabled = TRUE;
            SetColorFloat(&mIcon->mColorMultiply, 0.0, 0.0, 0.0, 1.0);
            
            mIconColorPath = [[Path alloc] Init];
            mBackgroundColorPath = [[Path alloc] Init];
            break;
        }
    }
    
    return self;
}

-(void)dealloc
{
    [mIcon release];
    
    [super dealloc];
}

-(u32)GetWidth
{
    return [mBackground GetWidth];
}

-(u32)GetHeight
{
    return [mBackground GetHeight];
}

-(Texture*)GetUseTexture
{
    return [mBackground GetTexture];
}

-(void)Update:(CFTimeInterval)inTimeStep
{
    if ((mIconColorPath != NULL) && (![mIconColorPath Finished]))
    {
        [mIconColorPath Update:inTimeStep];
        
        Vector4 colorVal;
        [mIconColorPath GetValueVec4:&colorVal];
        
        SetColorFloat(&mIcon->mColorMultiply, colorVal.mVector[x], colorVal.mVector[y], colorVal.mVector[z], colorVal.mVector[w]);
    }
    
    if ((mBackgroundColorPath != NULL) && (![mBackgroundColorPath Finished]))
    {
        [mBackgroundColorPath Update:inTimeStep];
        
        Vector4 colorVal;
        [mBackgroundColorPath GetValueVec4:&colorVal];
        
        SetColorFloat(&mBackground->mColorMultiply, colorVal.mVector[x], colorVal.mVector[y], colorVal.mVector[z], colorVal.mVector[w]);
    }
    
    [self EvaluateCurrencyIcon:FALSE];
}

-(void)UpdateQuantity
{
    [mCost SetString:NeonFormatDoubleToLength([[FoodManager GetInstance] GetPowerupCost:mPizzaPowerup], false, 3)];
    [mQuantity SetString:[NSString stringWithFormat:@"<B>%d</B>", [[FoodManager GetInstance] GetNumPowerup:mPizzaPowerup]]];
    
    if (![mQuantity GetVisible])
    {
        [mQuantity Enable];
    }
}

-(void)StatusChanged:(UIObjectState)inState
{
    [super StatusChanged:inState];
    
    switch(inState)
    {
        case UI_OBJECT_STATE_HIGHLIGHTED:
        {
            [mBackgroundPressed SetVisible:TRUE];
            [mBackground SetVisible:FALSE];

            break;
        }
        
        default:
        {
            [mBackgroundPressed SetVisible:FALSE];
            [mBackground SetVisible:TRUE];
            
            break;
        }
    }
}

-(void)SetVisible:(BOOL)inVisible
{
    [super SetVisible:inVisible];
    
    // Hack to make sure mBackgroundPressed is invisible as appropriate.
    // Otherwise all the child objects are made visible when the IncrementalGamePowerup becomes visible.
    if (inVisible)
    {
        [self StatusChanged:[self GetState]];
        
        if ([[FoodManager GetInstance] GetNumPowerup:mPizzaPowerup] == 0)
        {
            [mQuantity SetVisible:FALSE];
        }
        
        // Re-evaluate currency icon.  Otherwise we always get the gold currency icon.
        [self EvaluateCurrencyIcon:TRUE];
    }
}

-(void)SetUnlockState:(PizzaPowerupUnlockState)inState
{
    switch(inState)
    {
        case PIZZA_POWERUP_UNLOCKED:
        {
            [mName SetString:mPowerupName];
            [mName SetPositionX:([mIcon GetWidth] + ([mBackground GetWidth] - [mIcon GetWidth]) / 2.0) Y:(([mIcon GetHeight] - [mName GetHeight]) / 2.0) Z:0.0];

            Vector4 start = { GetRedFloat(&mIcon->mColorMultiply), GetGreenFloat(&mIcon->mColorMultiply), GetBlueFloat(&mIcon->mColorMultiply), GetAlphaFloat(&mIcon->mColorMultiply) };
            [mIconColorPath AddNodeVec4:&start atTime:0.0];
            
            Vector4 end = { 1.0, 1.0, 1.0, 1.0 };
            [mIconColorPath AddNodeVec4:&end atTime:1.0];
            
            start.mVector[x] = GetRedFloat(&mBackground->mColorMultiply);
            start.mVector[y] = GetGreenFloat(&mBackground->mColorMultiply);
            start.mVector[z] = GetBlueFloat(&mBackground->mColorMultiply);
            start.mVector[w] = GetAlphaFloat(&mBackground->mColorMultiply);
            
            [mBackgroundColorPath AddNodeVec4:&start atTime:0.0];
            [mBackgroundColorPath AddNodeVec4:&end atTime:1.0];
            
            break;
        }
    }
}

-(void)EvaluateCurrencyIcon:(BOOL)inForce
{
    int upgradeLevel = [[SaveSystem GetInstance] GetUpgradeLevelForPowerup:mPizzaPowerup];
    NSAssert(upgradeLevel < PIZZA_POWERUP_UPGRADE_NUM, @"Upgrade level is out of bounds");
    
    if ((upgradeLevel != mLastUpgradeLevel) || (inForce))
    {
        if (inForce)
        {
            for (int i = 0; i < PIZZA_POWERUP_UPGRADE_NUM; i++)
            {
                [mCurrency[i] SetVisible:FALSE];
            }
        }

        [mCurrency[upgradeLevel] SetVisible:TRUE];
        
        if ((mLastUpgradeLevel != -1) && (!inForce))
        {
            [mCurrency[mLastUpgradeLevel] SetVisible:FALSE];
        }
        
        mLastUpgradeLevel = upgradeLevel;
    }
}

@end
