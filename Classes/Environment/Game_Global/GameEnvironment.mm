//
//  GameEnvironment.m
//  Neon21
//
//  Copyright Neon Games 2011. All rights reserved.
//

#import "GameEnvironment.h"
#import "Skybox.h"
#import "Flow.h"
#import "GameObjectManager.h"

@implementation GameEnvironmentParams

-(instancetype)Init
{
    mSkyboxFilenames = [[NSMutableArray alloc] initWithCapacity:SKYBOX_NUM];
    return self;
}

-(void)dealloc
{
    [mSkyboxFilenames release];
    
    [super dealloc];
}

-(void)SetSkyboxFilename:(NSString*)inString atIndex:(int)inIndex
{
    [mSkyboxFilenames insertObject:inString atIndex:inIndex];
}

-(NSString*)GetSkyboxFilenameAtIndex:(int)inIndex
{
    return [mSkyboxFilenames objectAtIndex:inIndex];
}

@end

@implementation GameEnvironment

-(instancetype)InitWithParams:(GameEnvironmentParams*)inParams
{
    if ([inParams->mSkyboxFilenames count] == 0)
    {
        mSkybox = NULL;
        return self;
    }
    
    // Create Skybox
    SkyboxParams skyboxParams;
    
    [Skybox InitDefaultParams:&skyboxParams];
    
    for (int curTex = 0; curTex < SKYBOX_NUM; curTex++)
    {
        NSString* curFilename = [inParams GetSkyboxFilenameAtIndex:curTex];
        
        if (curFilename != NULL)
        {
            skyboxParams.mFiles[curTex] = curFilename;
        }
        else
        {
            skyboxParams.mFiles[curTex] = NULL;
        }
        
        skyboxParams.mTranslateFace[curTex] = FALSE;
    }
    
    mSkybox = [(Skybox*)[Skybox alloc] InitWithParams:&skyboxParams];
    [[GameObjectManager GetInstance] Add:mSkybox];
    [mSkybox release];
    
    [mSkybox SetPositionX:0.0 Y:0.0 Z:0.0];

    return self;
}

-(void)dealloc
{
    [[GameObjectManager GetInstance] Remove:mSkybox];
    [super dealloc];
}

@end