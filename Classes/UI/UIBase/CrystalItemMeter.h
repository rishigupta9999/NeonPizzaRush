//
//  CrystalItemMeter.h
//  PizzaSpinner
//
//  Created by Rishi Gupta on 9/22/14.
//  Copyright (c) 2014 Neon Games LLC. All rights reserved.
//

#import "UIObject.h"

@class Texture;

@interface CrystalItemMeter : UIObject
{
    Texture*    mTexture;
}

-(instancetype)InitWithUIGroup:(UIGroup*)inUIGroup;
-(void)dealloc;

-(void)DrawOrtho;

-(Texture*)GetTexture;
-(Texture*)GetUseTexture;

@end
