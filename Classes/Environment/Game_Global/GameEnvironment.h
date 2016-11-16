//
//  GameEnvironment.h
//  Neon21
//
//  Copyright Neon Games 2011. All rights reserved.
//

@class Skybox;

@interface GameEnvironmentParams : NSObject
{
    @public
        NSMutableArray* mSkyboxFilenames;
}

-(instancetype)Init;
-(void)dealloc;
-(void)SetSkyboxFilename:(NSString*)inString atIndex:(int)inIndex;
-(NSString*)GetSkyboxFilenameAtIndex:(int)inIndex;

@end

@interface GameEnvironment : NSObject
{
    Skybox* mSkybox;
}

-(instancetype)InitWithParams:(GameEnvironmentParams*)inParams;
-(void)dealloc;

@end