//
//  StringCloud.m
//  Neon21
//
//  Copyright Neon Games 2014. All rights reserved.

#import "StringCloud.h"
#import "TextTextureBuilder.h"
#import "UIGroup.h"

static const char STRING_CLOUD_IDENTIFIER[] = "StringCloud_Texture";

@interface StringCloudEntry : NSObject
{
    @public
        Path*       mColorPath;
        Path*       mPositionPath;
        StringCloud*    mStringCloud;
}

@property(retain) Texture*  Texture;

-(StringCloudEntry*)initWithOwner:(StringCloud*)inStringCloud;
-(void)dealloc;

@end

@implementation StringCloudEntry : NSObject

@synthesize Texture = mTexture;

-(StringCloudEntry*)initWithOwner:(StringCloud*)inStringCloud
{
    mStringCloud = inStringCloud;
    mTexture = NULL;
    mColorPath = [[Path alloc] Init];
    mPositionPath = [[Path alloc] Init];
    
    [mPositionPath SetPeriodic:!inStringCloud.OneShot];
    [mColorPath SetPeriodic:!inStringCloud.OneShot];
    
    return self;
}

-(void)dealloc
{
    [mTexture release];
    [mColorPath release];
    [mPositionPath release];
    
    [super dealloc];
}

@end

static const float STRING_CLOUD_DURATION = 4.0f;

@implementation StringCloudParams

-(StringCloudParams*)init
{
    mUIGroup = NULL;
    mStrings = [[NSMutableArray alloc] init];
    mFontSize = 12;
    mFontType = NEON_FONT_NORMAL;
    mOneShot = FALSE;
    mDistanceMultiplier = 1.0;
    mFadeIn = TRUE;
    mDuration = STRING_CLOUD_DURATION;
    
    return self;
}

-(void)dealloc
{
    [mStrings release];
    
    [super dealloc];
}

@end


@implementation StringCloud

@synthesize OneShot = mOneShot;

-(StringCloud*)initWithParams:(StringCloudParams*)inParams
{
    [super InitWithUIGroup:inParams->mUIGroup];
    
    int numStrings = (int)[inParams->mStrings count];
    
    mScaleFactor = GetTextScaleFactor();
    mOneShot = inParams->mOneShot;
    
    mStringCloudEntries = [[NSMutableArray alloc] initWithCapacity:numStrings];
    
    for (int i = 0; i < numStrings; i++)
    {
        TextTextureParams textParams;
        [TextTextureBuilder InitDefaultParams:&textParams];
        
        textParams.mTextureAtlas = (inParams->mUIGroup == NULL) ? (NULL) : ([inParams->mUIGroup GetTextureAtlas]);
        textParams.mPointSize = inParams->mFontSize * mScaleFactor;
        textParams.mFontType = inParams->mFontType;
        textParams.mString = [inParams->mStrings objectAtIndex:i];
        textParams.mStrokeSize = 12.0;
        textParams.mStrokeColor = 0xFF;
        textParams.mPremultipliedAlpha = TRUE;
        
        Texture* curTexture = [[TextTextureBuilder GetInstance] GenerateTextureWithParams:&textParams];
        [curTexture SetScaleFactor:mScaleFactor];
        curTexture->mPremultipliedAlpha = TRUE;
        
        StringCloudEntry* entry = [[StringCloudEntry alloc] initWithOwner:self];
        
        entry.Texture = curTexture;
        
        float totalDistance = numStrings * inParams->mFontSize * inParams->mDistanceMultiplier;
        [entry->mPositionPath AddNodeX:0.0 y:totalDistance z:0.0 atTime:0.0];
        [entry->mPositionPath AddNodeX:0.0 y:0.0 z:0.0 atTime:inParams->mDuration];
        
        float speed = totalDistance / inParams->mDuration;
        float entryDistance = i * inParams->mFontSize;
        float entryTime = (entryDistance / speed);
        
        [entry->mPositionPath SetTime:entryTime];
        
        [entry->mColorPath AddNodeScalar:((inParams->mFadeIn) ? 0.0 : 1.0) atTime:0.0];
        [entry->mColorPath AddNodeScalar:1.0 atTime:(inParams->mDuration / 2.0)];
        [entry->mColorPath AddNodeScalar:0.0 atTime:inParams->mDuration];
        
        [entry->mColorPath SetTime:entryTime];

        [mStringCloudEntries addObject:entry];
        [entry release];
        
        [self RegisterTexture:curTexture];
    }
    
    mOrtho = TRUE;

    return self;
}

-(void)dealloc
{
    [mStringCloudEntries release];
    [super dealloc];
}

-(void)Update:(CFTimeInterval)inTimeStep
{
    int numStrings = (int)[mStringCloudEntries count];
    
    for (int i = 0; i < numStrings; i++)
    {
        StringCloudEntry* curEntry = [mStringCloudEntries objectAtIndex:i];
        
        [curEntry->mPositionPath Update:inTimeStep];
        [curEntry->mColorPath Update:inTimeStep];
        
        if ((mOneShot) && ([curEntry->mPositionPath Finished]))
        {
            [mStringCloudEntries removeObject:curEntry];
            i--;
            numStrings--;
        }
    }
    
    if ((mOneShot) && (numStrings == 0))
    {
        [self Remove];
    }
    
    [super Update:inTimeStep];
}

-(void)DrawOrtho
{
    for (StringCloudEntry* curEntry in mStringCloudEntries)
    {
        QuadParams  quadParams;
        
        [UIObject InitQuadParams:&quadParams];
        
        quadParams.mColorMultiplyEnabled = TRUE;
        quadParams.mBlendEnabled = TRUE;
        quadParams.mTexture = curEntry.Texture;
        
        Vector3 position;
        [curEntry->mPositionPath GetValueVec3:&position];
        
        quadParams.mTranslation.mVector[x] = position.mVector[x];
        quadParams.mTranslation.mVector[y] = position.mVector[y];
        
        float color;
        [curEntry->mColorPath GetValueScalar:&color];
        
        quadParams.mColorMultiplyEnabled = TRUE;
        
        for (int i = 0; i < 4; i++)
        {
            SetColorFloat(&quadParams.mColor[i], 1.0, 1.0, 1.0, color * mAlpha);
        }
        
        [self DrawQuad:&quadParams];
    }

}

@end