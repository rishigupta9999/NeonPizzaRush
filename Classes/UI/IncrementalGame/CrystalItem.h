//
//  CrystalItem.h
//  PizzaSpinner
//
//  Created by Rishi Gupta on 9/17/14.
//  Copyright (c) 2014 Neon Games LLC. All rights reserved.
//

#import "UIObject.h"
#import "Button.h"

@class UIGroup;
@class ImageWell;

@interface CrystalItemParams : NSObject
{
}

@property(assign) UIGroup*  UIGroup;
@property(assign) NSString* ImageName;
@property BOOL PizzaVisible;

-(instancetype)Init;

@end

typedef enum
{
    CRYSTAL_ITEM_STATE_NORMAL,
    CRYSTAL_ITEM_STATE_GROWING
} CrystalItemUIState;

@interface CrystalItem : Button
{
    ImageWell*  mImage;
    Texture*    mTexture;
    
    Path*       mScalePath;
    
    NSMutableArray* mLightRays;
    
    CrystalItemUIState mCrystalItemState;
}

-(instancetype)InitWithParams:(CrystalItemParams*)inParams;
-(void)dealloc;

-(void)Enable;
-(void)CreateLightRays;

-(u32)GetWidth;
-(u32)GetHeight;

@end
