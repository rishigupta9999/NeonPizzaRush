//
//  WaterBalloonEntity.h
//  WaterBalloonToss
//
//  Created by Rishi Gupta on 5/15/14.
//  Copyright (c) 2014 Neon Games LLC. All rights reserved.
//

#import "GameObject.h"

class WaterBalloonCollisionCallback;

@interface WaterBalloonEntity : GameObject
{
    WaterBalloonCollisionCallback* mCollisionCallback;
    float*                         mPhysicsVertexBuffer;
    NSLock*                        mLock;
}

-(instancetype)InitWithPosition:(Vector3*)inPosition;
-(void)dealloc;

-(void)ResetSoftBodyWithBlock:(dispatch_block_t)inBlock;

-(void)Update:(CFTimeInterval)inTimeStep;
-(void)Draw;

@end
