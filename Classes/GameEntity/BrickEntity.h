//
//  BrickEntity.h
//  WaterBalloonToss
//
//  Created by Rishi Gupta on 6/13/14.
//  Copyright (c) 2014 Neon Games LLC. All rights reserved.
//


#import "GameObject.h"

@class SimpleModel;
@class Texture;

@interface BrickEntity : GameObject
{
    Texture* mBrickTexture;
}

-(instancetype)InitWithScaleX:(float)inX y:(float)inY z:(float)inZ;
-(void)dealloc;

@end
