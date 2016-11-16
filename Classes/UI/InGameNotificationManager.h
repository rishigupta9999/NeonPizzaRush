//
//  InGameNotificationManager.h
//  PizzaSpinner
//
//  Created by Rishi Gupta on 9/17/14.
//  Copyright (c) 2014 Neon Games LLC. All rights reserved.
//

#import "MessageChannel.h"

@class TextureButton;
@class TextBox;

@interface InGameNotificationManager : NSObject<MessageChannelListener>
{
    TextureButton*  mNotificationBackground;
    TextureButton*  mCloseButton;
    TextBox*        mTextBox;
    
    BOOL            mNotificationActive;
    int             mLeftCoord;
    int             mWidth;
}

-(instancetype)Init;
+(void)CreateInstance;
+(void)DestroyInstance;
+(instancetype)GetInstance;

-(void)SetLeftCoord:(int)inLeftCoord width:(int)inWidth;

-(void)ProcessMessage:(Message*)inMsg;
-(void)NotificationWithText:(NSString*)inString;

-(void)GetNotificationPosition:(Vector3*)outWidth;
-(void)GetNotificationScale:(Vector3*)outScale;

@end
