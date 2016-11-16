//
//  IncrementalGamePowerup.h
//  PizzaSpinner
//
//  Created by Rishi Gupta on 6/23/14.
//  Copyright (c) 2014 Neon Games LLC. All rights reserved.
//

#import "UIObject.h"
#import "PizzaPowerupInfo.h"

@class UIGroup;
@class ImageWell;
@class TextBox;

@interface IncrementalGamePowerupParams : NSObject
{
}

@property(assign) UIGroup*  UIGroup;
@property(assign) NSString* IconTexture;
@property(assign) NSString* Name;
@property(assign) NSString* Background;
@property(assign) NSString* BackgroundPressed;
@property PizzaPowerupUnlockState UnlockState;
@property PizzaPowerup PizzaPowerup;

-(instancetype)Init;

@end

@interface IncrementalGamePowerup : UIObject
{
    ImageWell*  mBackground;
    ImageWell*  mBackgroundPressed;
    ImageWell*  mIcon;
    ImageWell*  mCurrency[PIZZA_POWERUP_UPGRADE_NUM];
    TextBox*    mCost;
    TextBox*    mName;
    TextBox*    mQuantity;
    
    NSString*   mPowerupName;
    Path*       mIconColorPath;
    Path*       mBackgroundColorPath;
    
    PizzaPowerup    mPizzaPowerup;
    
    int         mLastUpgradeLevel;
}

-(instancetype)InitWithParams:(IncrementalGamePowerupParams*)inParams;
-(void)dealloc;

-(u32)GetWidth;
-(u32)GetHeight;
-(Texture*)GetUseTexture;

-(void)Update:(CFTimeInterval)inTimeStep;
-(void)UpdateQuantity;

-(void)StatusChanged:(UIObjectState)inState;
-(void)SetVisible:(BOOL)inVisible;
-(void)SetUnlockState:(PizzaPowerupUnlockState)inState;

-(void)EvaluateCurrencyIcon:(BOOL)inForce;

@end
