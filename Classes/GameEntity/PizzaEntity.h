//
//  PizzaEntity.h
//  PizzaSpinner
//
//  Created by Rishi Gupta on 6/17/14.
//  Copyright (c) 2014 Neon Games LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameObject.h"

@class RenderGroup;
@class Framebuffer;
@class PaintBrush;
@class UIGroup;
@class ImageWell;

typedef enum
{
    PIZZA_ENTITY_EMPTY,
    PIZZA_ENTITY_COMPLETE,
} PizzaEntityState;

@interface PizzaEntity : GameObject
{
    ImageWell*      mPizzaCrust;
    RenderGroup*    mPizzaRenderGroup;
    Framebuffer*    mPizzaFramebuffer;
    Texture*        mToppingsTexture;
    
    UIGroup*        mUIGroup;
    TextureAtlas*   mTextureAtlas;
}

@property(readonly) PaintBrush* PaintBrush;
@property           PizzaEntityState PizzaEntityState;

-(instancetype)Init;
-(void)dealloc;

-(TextureAtlas*)CreateTextureAtlas;
-(void)CreatePizzaRenderGroup;
-(void)TapAtTexcoordS:(float)inS t:(float)inT;

-(void)Reset;

@end
