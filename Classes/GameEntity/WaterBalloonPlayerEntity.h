//
//  WaterBalloonPlayerEntity.h
//  WaterBalloonToss
//
//  Created by Rishi Gupta on 5/13/14.
//  Copyright (c) 2014 Neon Games LLC. All rights reserved.
//

#import "GameObject.h"

typedef enum
{
    WATERBALLOON_PLAYER_FIRST,
    WATERBALLOON_PLAYER_SECOND,
    WATERBALLOON_PLAYER_NUM
} WaterBalloonPlayer;

@class SimpleModel;

@interface WaterBalloonPlayerEntity : GameObject
{
    SimpleModel*    mPhysicsMesh;
}

-(instancetype)Init;
-(void)dealloc;
-(void)Remove;

-(void)GetHandsPosition:(Vector3*)outHandPosition;

@end
