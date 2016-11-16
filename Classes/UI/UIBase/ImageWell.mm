//
//  ImageWell.m
//  Neon21
//
//  Copyright Neon Games 2009. All rights reserved.

#import "ImageWell.h"
#import "TextureManager.h"
#import "Color.h"

static const char IMAGE_WELL_IDENTIFIER[] = "ImageWell_Image";

@implementation ImageWell

-(ImageWell*)InitWithParams:(ImageWellParams*)inParams
{
    [super InitWithUIGroup:inParams->mUIGroup];
        
    mOrtho = TRUE;
    
    if (inParams->mTextureName != NULL)
    {
        NSAssert(inParams->mTextureName != NULL, @"Trying to create and ImageWell with no texture, this doesn't make sense");
        
        UIObjectTextureLoadParams params;
        [UIObject InitDefaultTextureLoadParams:&params];
        
        params.mTexDataLifetime = TEX_DATA_DISPOSE;
        params.mTextureName = inParams->mTextureName;
        
        mTexture = [self LoadTextureWithParams:&params];
    }
    else
    {
        mTexture = inParams->mTexture;
    }
    
    [mTexture retain];

    
    return self;
}

-(ImageWell*)InitWithImageWell:(ImageWell*)inImageWell
{
    [super InitWithUIGroup:(UIGroup*)inImageWell->mGameObjectBatch];
    
    mTexture = inImageWell->mTexture;
    [mTexture retain];
    
    return self;
}

-(void)dealloc
{
    [mTexture release];
    [super dealloc];
}

+(void)InitDefaultParams:(ImageWellParams*)outParams
{
    outParams->mTextureName = NULL;
    outParams->mTexture = NULL;
    outParams->mUIGroup = NULL;
}

-(void)DrawOrtho
{
    QuadParams  quadParams;
    
    [UIObject InitQuadParams:&quadParams];
    
    quadParams.mColorMultiplyEnabled = TRUE;
    quadParams.mBlendEnabled = TRUE;
    quadParams.mTexture = mTexture;
    
    for (int i = 0; i < 4; i++)
    {
        float rMultiply = 1.0;
        float gMultiply = 1.0;
        float bMultiply = 1.0;
        float aMultiply = 1.0;
        
        if (mColorMultiplyEnabled)
        {
            rMultiply = GetRedFloat(&mColorMultiply);
            gMultiply = GetGreenFloat(&mColorMultiply);
            bMultiply = GetBlueFloat(&mColorMultiply);
            aMultiply = GetAlphaFloat(&mColorMultiply);
        }
        
        SetColorFloat(&quadParams.mColor[i], rMultiply, gMultiply, bMultiply, [self GetCombinedAlpha] * aMultiply);
    }
    
    [self DrawQuad:&quadParams];
    
    [super DrawOrtho];
}

-(u32)GetWidth
{
    u32 width = 0;
    
    if (mTexture != NULL)
    {
        width = [mTexture GetEffectiveWidth];
    }
    else
    {
        width = [super GetWidth];
    }
    
    Vector3 scale;
    [self GetScale:&scale];
    
    width = (float)width * scale.mVector[x];
    
    return width;
}

-(u32)GetHeight
{
    u32 height = 0;
    
    if (mTexture != NULL)
    {
        height = [mTexture GetEffectiveHeight];
    }
    else
    {
        height = [super GetHeight];
    }
    
    Vector3 scale;
    [self GetScale:&scale];
    
    height = (float)height * scale.mVector[y];

    return height;
}

-(Texture*)GetTexture
{
    return mTexture;
}

-(Texture*)GetUseTexture
{
    return [self GetTexture];
}

@end