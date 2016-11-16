//
//  InGameNotificationSystem.mm
//  PizzaSpinner
//
//  Created by Rishi Gupta on 9/17/14.
//  Copyright (c) 2014 Neon Games LLC. All rights reserved.
//

#import "InGameNotificationManager.h"
#import "TextureButton.h"
#import "GameObjectManager.h"
#import "Event.h"
#import "TextBox.h"
#import "ImageWell.h"
#import "Button.h"

static const float ANIMATE_TIME = 0.2;

InGameNotificationManager* sInstance = NULL;

@interface InGameNotificationManager(Private)<ButtonListenerProtocol>

-(BOOL)ButtonEvent:(ButtonEvent)inEvent Button:(Button*)inButton;

@end

@implementation InGameNotificationManager

-(instancetype)Init
{
    TextureButtonParams textureButtonParams;
    [TextureButton InitDefaultParams:&textureButtonParams];
    
    SetColorFloat(&textureButtonParams.mColor, 0.0, 0.0, 0.0, 0.6);
    
    mNotificationBackground = [(TextureButton*)[TextureButton alloc] InitWithParams:&textureButtonParams];
    
    [[GameObjectManager GetInstance] Add:mNotificationBackground];
    [mNotificationBackground release];
    
    [TextureButton InitDefaultParams:&textureButtonParams];
    
    textureButtonParams.mBoundingBoxCollision = TRUE;
    textureButtonParams.mButtonTexBaseName = @"close_nobackground.papng";
    SetVec2(&textureButtonParams.mBoundingBoxBorderSize, 12, 12);
    
    mCloseButton = [[TextureButton alloc] InitWithParams:&textureButtonParams];
    [[GameObjectManager GetInstance] Add:mCloseButton];
    [mCloseButton release];
    
    [mCloseButton SetVisible:FALSE];
    [mCloseButton SetListener:self];
    
    mNotificationActive = FALSE;
    mLeftCoord = 0;
    mWidth = 0;
    
    [GetGlobalMessageChannel() AddListener:self];

    return self;
}

+(void)CreateInstance
{
    NSAssert(sInstance == NULL, @"Expected NULL");
    sInstance = [[InGameNotificationManager alloc] Init];
}

+(void)DestroyInstance
{
}

+(instancetype)GetInstance
{
    return sInstance;
}

-(void)ProcessMessage:(Message*)inMsg
{
    switch(inMsg->mId)
    {
        default:
        {
            break;
        }
    }
}

-(void)SetLeftCoord:(int)inLeftCoord width:(int)inWidth
{
    mLeftCoord = inLeftCoord;
    mWidth = inWidth;
    
    Vector3 position, scale;
    [self GetNotificationPosition:&position];
    [self GetNotificationScale:&scale];
    
    [mNotificationBackground SetPosition:&position];
    [mNotificationBackground SetScale:&scale];
        
    [mCloseButton SetVisible:TRUE];
    [mCloseButton SetPositionX:(GetScreenAbsoluteWidth() - [mCloseButton GetWidth] - 10) Y:(GetScreenAbsoluteHeight() + 5) Z:0.0];
}

static const int TOP_PADDING = 20;
static const int TEXT_TOP_OFFSET = 10;

-(void)NotificationWithText:(NSString*)inString
{
    TextBoxParams textBoxParams;
    [TextBox InitDefaultParams:&textBoxParams];

    Vector3 initialNotificationPosition, curNotificationPosition, scale, tempPosition;
    
    [self GetNotificationPosition:&initialNotificationPosition];
    [mNotificationBackground GetPosition:&curNotificationPosition];
    [mNotificationBackground GetScale:&scale];
    
    textBoxParams.mFontSize = 18;
    textBoxParams.mString = inString;
    textBoxParams.mWidth = scale.mVector[x] - 10;
    textBoxParams.mStrokeSize = 4;
    SetColorFloat(&textBoxParams.mStrokeColor, 0, 0, 0, 1);
    
    [mTextBox Disable];
    [mTextBox RemoveAfterOperations];
    
    mTextBox = [[TextBox alloc] InitWithParams:&textBoxParams];
    
    [mTextBox SetPositionX:(curNotificationPosition.mVector[x] + ((scale.mVector[x] - [mTextBox GetWidth]) / 2)) Y:(GetScreenAbsoluteHeight() + TEXT_TOP_OFFSET) Z:0.0];
    
    [[GameObjectManager GetInstance] Add:mTextBox];
    
    // Animate up black bar
    Path* path = [[Path alloc] Init];
    
    [path AddNodeVec3:&curNotificationPosition atTime:0.0];

    CloneVec3(&initialNotificationPosition, &tempPosition);
    tempPosition.mVector[y] -= ([mTextBox GetHeight] + TOP_PADDING);
    [path AddNodeVec3:&tempPosition atTime:ANIMATE_TIME];
    
    [mNotificationBackground AnimateProperty:GAMEOBJECT_PROPERTY_POSITION withPath:path];
    
    // Animate up text
    path = [[Path alloc] Init];
    
    [mTextBox GetPosition:&tempPosition];
    [path AddNodeVec3:&tempPosition atTime:0.0];
    
    tempPosition.mVector[y] = initialNotificationPosition.mVector[y] - ([mTextBox GetHeight] + TEXT_TOP_OFFSET);
    [path AddNodeVec3:&tempPosition atTime:ANIMATE_TIME];
    
    [mTextBox AnimateProperty:GAMEOBJECT_PROPERTY_POSITION withPath:path];
    
    // Animate up close button
    path = [[Path alloc] Init];
    
    [mCloseButton GetPosition:&tempPosition];
    [path AddNodeVec3:&tempPosition atTime:0.0];
    
    tempPosition.mVector[y] = initialNotificationPosition.mVector[y] - ([mTextBox GetHeight] + 15);
    [path AddNodeVec3:&tempPosition atTime:ANIMATE_TIME];
    
    [mCloseButton AnimateProperty:GAMEOBJECT_PROPERTY_POSITION withPath:path];
    
    mNotificationActive = TRUE;
}

-(BOOL)ButtonEvent:(ButtonEvent)inEvent Button:(Button*)inButton
{
    if (inEvent == BUTTON_EVENT_UP)
    {
        if (inButton == mCloseButton)
        {
            Vector3 position, scale;
            [mNotificationBackground GetPosition:&position];
            [mNotificationBackground GetScale:&scale];

            // Animate down black bar
            Path* path = [[Path alloc] Init];
            
            [path AddNodeVec3:&position atTime:0.0];
            
            position.mVector[y] = GetScreenVirtualHeight();
            [path AddNodeVec3:&position atTime:ANIMATE_TIME];
            
            [mNotificationBackground AnimateProperty:GAMEOBJECT_PROPERTY_POSITION withPath:path];
            
            // Animate down text
            path = [[Path alloc] Init];
            
            [mTextBox GetPosition:&position];
            [path AddNodeVec3:&position atTime:0.0];
            
            position.mVector[y] = GetScreenVirtualHeight();
            [path AddNodeVec3:&position atTime:ANIMATE_TIME];
            
            [mTextBox AnimateProperty:GAMEOBJECT_PROPERTY_POSITION withPath:path];
            [mTextBox RemoveAfterOperations];
            
            mTextBox = NULL;
            
            // Animate down close button
            path = [[Path alloc] Init];
            
            [mCloseButton GetPosition:&position];
            [path AddNodeVec3:&position atTime:0.0];
            
            position.mVector[y] = GetScreenAbsoluteHeight() + 5;
            [path AddNodeVec3:&position atTime:ANIMATE_TIME];
            
            [mCloseButton AnimateProperty:GAMEOBJECT_PROPERTY_POSITION withPath:path];
            
            mNotificationActive = FALSE;
        }
    }
    
    return TRUE;
}

-(void)GetNotificationPosition:(Vector3*)outWidth
{
    Set(outWidth, mLeftCoord, GetScreenAbsoluteHeight(), 0);
}

-(void)GetNotificationScale:(Vector3*)outScale
{
    Set(outScale, mWidth, GetScreenAbsoluteHeight(), 0);
}

@end
