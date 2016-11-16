//
//  NeonList.h
//  PizzaSpinner
//
//  Created by Rishi Gupta on 6/23/14.
//  Copyright (c) 2014 Neon Games LLC. All rights reserved.
//

#import "UIObject.h"
#import "TouchSystem.h"

@class UIGroup;

typedef enum
{
    NEON_LIST_STATE_IDLE,
    NEON_LIST_STATE_WAITING_TO_RECOGNIZE,
    NEON_LIST_STATE_PANNING,
} NeonListState;

@interface NeonListParams : NSObject
{
}

@property(assign) UIGroup*  UIGroup;
@property(assign) int       Height;

-(instancetype)Init;

@end

typedef enum
{
    NEON_LIST_EVENT_UP
} NeonListEvent;

@protocol NeonListListener

-(void)NeonListEvent:(NeonListEvent)inEvent object:(UIObject*)inObject;

@end

@interface NeonList : UIObject<TouchListenerProtocol>
{
    NSMutableArray* mUIObjects;
    NeonListState   mListState;
    
    CFAbsoluteTime  mStartTouchTime;
    Vector2         mStartTouchPosition;
    Vector2         mCurrentTouchPosition;
    UIObject*       mTouchedObject;
    
    int mWidth;
    int mHeight;
    int mDisplayHeight;
    
    float   mYOffset;
    float   mTotalYOffset;
}

@property(retain) NSObject<NeonListListener>* Listener;

-(instancetype)InitWithParams:(NeonListParams*)inParams;
-(void)dealloc;
-(void)Remove;
-(void)Update:(CFTimeInterval)inTimeStep;

-(void)AddObject:(UIObject*)inObject;
-(void)PositionObjects;
-(void)PositionObjectsSync;
-(void)SetHeight:(int)inHeight;

-(u32)IndexOfObject:(UIObject*)inObject;

-(TouchSystemConsumeType)TouchEventWithData:(TouchData*)inData;

-(void)UnhighlightActiveItem;

-(u32)GetWidth;
-(u32)GetHeight;

@end
