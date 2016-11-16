//
//  Run21Environment.m
//  Neon21
//
//  Copyright Neon Games 2011. All rights reserved.
//

#import "WaterBalloonEnvironment.h"
#import "GameObjectManager.h"
#import "LightManager.h"
#import "TextureManager.h"
#import "EllipseMeshBuilder.h"

@implementation WaterBalloonEnvironmentParams

-(instancetype)Init
{
    [super Init];
    return self;
}

@end

#define Light_Mini_Att_C  0.0f
#define Light_Mini_Att_L  0.15f
#define Light_Mini_Att_Q  0.25f


@implementation WaterBalloonEnvironment

-(instancetype)InitWithParams:(GameEnvironmentParams*)inParams
{
	[super InitWithParams:inParams];
        
    // Create lights
    mUnderLight = [[LightManager GetInstance] CreateLight];
    
    LightParams* underLightParams = [mUnderLight GetParams];
    underLightParams->mDirectional = FALSE;
    Set(&underLightParams->mVector, 0, 2, 0);
    Set(&underLightParams->mSpotDirection, 0.0f, -1.0f, 0.0f);
    underLightParams->mConstantAttenuation      = Light_Mini_Att_C;
    underLightParams->mLinearAttenuation        = Light_Mini_Att_L;
    underLightParams->mQuadraticAttenuation     = Light_Mini_Att_Q;
    underLightParams->mSpotCutoff = 90.0f;

    
    Set(&underLightParams->mDiffuseRGB, 1.0, 1.0, 1.0);
    Set(&underLightParams->mAmbientRGB, 1.0, 1.0, 1.0);

    
	return self;
}

@end