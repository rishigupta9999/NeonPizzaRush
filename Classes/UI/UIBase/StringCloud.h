//
//  StringCloud.h
//  Neon21
//
//  Copyright Neon Games 2014. All rights reserved.

#import "UIObject.h"
#import "TextBox.h"

@interface StringCloudParams : NSObject
{
    @public
        UIGroup*        mUIGroup;
        NSMutableArray* mStrings;
    
        float           mFontSize;
        NeonFontType    mFontType;
    
        float           mDistanceMultiplier;
        CFTimeInterval  mDuration;
    
        BOOL            mFadeIn;
    
        BOOL            mOneShot;
}

-(StringCloudParams*)init;
-(void)dealloc;

@end

@interface StringCloud : UIObject
{
    NSMutableArray* mStringCloudEntries;
    float           mScaleFactor;
    BOOL            mOneShot;
}

@property(readonly) BOOL OneShot;

-(StringCloud*)initWithParams:(StringCloudParams*)inParams;
-(void)dealloc;

-(void)Update:(CFTimeInterval)inTimeStep;
-(void)DrawOrtho;

@end