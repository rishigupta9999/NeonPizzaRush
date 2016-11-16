//
//  NeonList.m
//  PizzaSpinner
//
//  Created by Rishi Gupta on 6/23/14.
//  Copyright (c) 2014 Neon Games LLC. All rights reserved.
//

#import "NeonList.h"

static float PAN_GESTURE_VERTICAL_DISTANCE = 3;
static float TOUCH_DELAY_TIME = 0.25f;

@implementation NeonListParams

@synthesize UIGroup = mUIGroup;
@synthesize Height = mHeight;

-(instancetype)Init
{
    mUIGroup = NULL;
    mHeight = GetScreenVirtualHeight();
    
    return self;
}

@end

@interface NeonList(PrivateMethods)

-(UIObject*)ObjectAtLocationX:(float)inX y:(float)inY;
-(void)TouchObject:(UIObject*)inObject;

@end

@implementation NeonList

@synthesize Listener = mListener;

-(instancetype)InitWithParams:(NeonListParams*)inParams
{
    [super InitWithUIGroup:inParams.UIGroup];
    
    mUIObjects = [[NSMutableArray alloc] init];
    
    [[TouchSystem GetInstance] AddListener:self];
    
    mWidth = 0;
    mHeight = 0;
    mDisplayHeight = inParams.Height;
    
    SetVec2(&mStartTouchPosition, 0, 0);
    mStartTouchTime = 0;
    mTouchedObject = NULL;
    mListState = NEON_LIST_STATE_IDLE;
    
    mListener = NULL;
    
    mYOffset = 0;
    mTotalYOffset = 0;
    
    return self;
}

-(void)dealloc
{
    [mUIObjects release];
    
    [super dealloc];
}

-(void)Remove
{
    [[TouchSystem GetInstance] RemoveListener:self];
}

-(void)Update:(CFTimeInterval)inTimeStep
{
    switch(mListState)
    {
        case NEON_LIST_STATE_WAITING_TO_RECOGNIZE:
        {
            CFAbsoluteTime currentTime = CACurrentMediaTime();
            
            mTouchedObject = NULL;
            
            if ((currentTime - mStartTouchTime) >= TOUCH_DELAY_TIME)
            {
                UIObject* touchedObject = [self ObjectAtLocationX:mCurrentTouchPosition.mVector[x] y:mCurrentTouchPosition.mVector[y]];
                
                if (touchedObject != NULL)
                {
                    [self TouchObject:touchedObject];
                }
            }
        }
    }
    
    [super Update:inTimeStep];
}

-(void)AddObject:(UIObject*)inObject
{
    [mUIObjects addObject:inObject];
    
    inObject.Parent = self;
}

-(void)PositionObjects
{
    [UIObject PerformWhenAllLoaded:mUIObjects queue:dispatch_get_main_queue() block:^
    {
        [self PositionObjectsSync];
    } ];
}

-(void)PositionObjectsSync
{
    int totalHeight = 0;
    
    for (UIObject* curObject in mUIObjects)
    {
        [curObject SetPositionX:0.0 Y:(totalHeight + mTotalYOffset + mYOffset) Z:0.0];
        totalHeight += [curObject GetHeight];
        
        mWidth = NeonMax(mWidth, [curObject GetWidth]);
    }
    
    mHeight = totalHeight;
}

-(void)SetHeight:(int)inHeight
{
    NSAssert(mListState == NEON_LIST_STATE_IDLE, @"The list height can only be changed while the list is idle");
    
    mDisplayHeight = inHeight;
    
    if (mHeight > mDisplayHeight)
    {
        float newY = mTotalYOffset;
        
        // Apply constraint for bottom edge of list
        newY += mHeight;
        
        if (newY < mDisplayHeight)
        {
            mYOffset = mDisplayHeight - mTotalYOffset - mHeight;
            [self PositionObjects];
        }
    }
}

-(TouchSystemConsumeType)TouchEventWithData:(TouchData*)inData
{
    if (([self GetState] == UI_OBJECT_STATE_INACTIVE) || ([self GetState] == UI_OBJECT_STATE_DISABLED))
    {
        return TOUCHSYSTEM_CONSUME_NONE;
    }
    
    switch(inData->mTouchType)
    {
        case TOUCHES_BEGAN:
        {
            Vector3 currentPosition;
            [self GetPosition:&currentPosition];
            
            if (    (inData->mTouchLocation.x >= currentPosition.mVector[x]) && (inData->mTouchLocation.y >= currentPosition.mVector[y]) &&
                    (inData->mTouchLocation.x < (currentPosition.mVector[x] + mWidth)) && (inData->mTouchLocation.y < (currentPosition.mVector[y] + mHeight))   )
            {
                mListState = NEON_LIST_STATE_WAITING_TO_RECOGNIZE;
                
                SetVec2(&mStartTouchPosition, inData->mTouchLocation.x, inData->mTouchLocation.y);
                SetVec2(&mCurrentTouchPosition, inData->mTouchLocation.x, inData->mTouchLocation.y);
                
                mStartTouchTime = CACurrentMediaTime();
            }
            
            break;
        }

        case TOUCHES_MOVED:
        {
            Vector2 curPosition;
                    
            curPosition.mVector[x] = inData->mTouchLocation.x;
            curPosition.mVector[y] = inData->mTouchLocation.y;
            
            SetVec2(&mCurrentTouchPosition, curPosition.mVector[x], curPosition.mVector[y]);
            
            Vector2 diff;
            Sub2(&curPosition, &mStartTouchPosition, &diff);
            
            float distance = (diff.mVector[x] * diff.mVector[x]) + (diff.mVector[y] * diff.mVector[y]);
            distance = sqrt(distance);

            switch(mListState)
            {
                case NEON_LIST_STATE_WAITING_TO_RECOGNIZE:
                {
                    if (distance > PAN_GESTURE_VERTICAL_DISTANCE)
                    {
                        mListState = NEON_LIST_STATE_PANNING;
                        
                        if (mTouchedObject != NULL)
                        {
                            [self TouchObject:NULL];
                        }
                    }
                    
                    break;
                }
                
                case NEON_LIST_STATE_PANNING:
                {
                    // Only allow panning of the height of all cells is greater than the display height of the list
                    if (mHeight > mDisplayHeight)
                    {
                        UIObject* firstObject = [mUIObjects objectAtIndex:0];
                        Vector3 objPosition;
                        
                        [firstObject GetPosition:&objPosition];
                        
                        float newY = diff.mVector[y] + mTotalYOffset;
                        
                        // Apply constraint for top edge of list
                        if (newY <= 0)
                        {
                            mYOffset = diff.mVector[y];
                            [self PositionObjects];
                        }
                        else if (newY > 0)
                        {
                            mYOffset = -mTotalYOffset;
                            [self PositionObjects];
                        }
                        
                        // Apply constraint for bottom edge of list
                        newY += mHeight;
                        
                        if (newY < mDisplayHeight)
                        {
                            mYOffset = mDisplayHeight - mTotalYOffset - mHeight;
                            [self PositionObjects];
                        }
                    }
                    
                    break;
                }
            }
            
            break;
        }
        
        case TOUCHES_ENDED:
        {
            switch(mListState)
            {
                case NEON_LIST_STATE_WAITING_TO_RECOGNIZE:
                {
                    Vector2 touchPosition;
                            
                    touchPosition.mVector[x] = inData->mTouchLocation.x;
                    touchPosition.mVector[y] = inData->mTouchLocation.y;
                    
                    UIObject* touchedObject = [self ObjectAtLocationX:touchPosition.mVector[x] y:touchPosition.mVector[y]];
                    
                    if (touchedObject != NULL)
                    {
                        [self TouchObject:touchedObject];
                        [mListener NeonListEvent:NEON_LIST_EVENT_UP object:touchedObject];
                    }
                    
                    break;
                }
            }
            
            mListState = NEON_LIST_STATE_IDLE;
            
            mTotalYOffset += mYOffset;
            mYOffset = 0;
            
            break;
        }
    }
    
    return TOUCHSYSTEM_CONSUME_NONE;
}

-(UIObject*)ObjectAtLocationX:(float)inX y:(float)inY
{
    Vector3 listPosition;
    [self GetPosition:&listPosition];

    for (UIObject* curObject in mUIObjects)
    {
        Vector3 objPosition;
        [curObject GetPosition:&objPosition];
        
        Add3(&listPosition, &objPosition, &objPosition);
        
        if ((inX >= objPosition.mVector[x]) && (inY >= objPosition.mVector[y]) &&
            (inX < (objPosition.mVector[x] + [curObject GetWidth])) && (inY < (objPosition.mVector[y] + [curObject GetHeight])))
        {
            return curObject;
            break;
        }
    }
    
    return NULL;
}

-(u32)IndexOfObject:(UIObject*)inObject
{
    u64 index = [mUIObjects indexOfObject:inObject];
    NSAssert(index != NSNotFound, @"Item not found");
    
    return (u32)index;
}

-(void)TouchObject:(UIObject*)inObject
{
    if (inObject != NULL)
    {
        [inObject SetState:UI_OBJECT_STATE_HIGHLIGHTED];
        [inObject StatusChanged:UI_OBJECT_STATE_HIGHLIGHTED];
    }
    else
    {
        [mTouchedObject SetState:UI_OBJECT_STATE_ENABLED];
        [mTouchedObject StatusChanged:UI_OBJECT_STATE_ENABLED];

        mTouchedObject = NULL;
    }
    
    mTouchedObject = inObject;
}

-(void)UnhighlightActiveItem
{
    [self TouchObject:NULL];
}

-(u32)GetWidth
{
    return mWidth;
}

-(u32)GetHeight
{
    return mHeight;
}

@end
