//
//  PizzaEntity.m
//  PizzaSpinner
//
//  Created by Rishi Gupta on 6/17/14.
//  Copyright (c) 2014 Neon Games LLC. All rights reserved.
//

#import "PizzaEntity.h"
#import "ModelManager.h"
#import "TextureManager.h"
#import "SimpleModel.h"
#import "ImageWell.h"
#import "Framebuffer.h"
#import "GameObjectCollection.h"
#import "CameraStateMachine.h"
#import "StaticOrthoCameraState.h"
#import "RenderGroup.h"
#import "RenderGroupManager.h"
#import "PaintBrush.h"
#import "ResourceManager.h"
#import "PVRTCTexture.h"
#import "GameObjectBatch.h"
#import "UIGroup.h"

@implementation PizzaEntity

@synthesize PaintBrush = mPaintBrush;
@synthesize PizzaEntityState = mPizzaEntityState;

-(instancetype)Init
{
    [super Init];
    
    mPuppet = [[ModelManager GetInstance] ModelWithName:@"Pizza.STM" owner:self];
    [mPuppet retain];
    
    mRenderBinId = RENDERBIN_COMPANIONS;
    
    mTextureAtlas = [self CreateTextureAtlas];
    
    GameObjectBatchParams uiGroupParams;
    [GameObjectBatch InitDefaultParams:&uiGroupParams];
    
    mUIGroup = [[UIGroup alloc] InitWithParams:&uiGroupParams];
    
    [mUIGroup SetTextureAtlas:mTextureAtlas];
    [self CreatePizzaRenderGroup];
    [mUIGroup release];
    
    [mPuppet SetTexture:[[mPizzaRenderGroup GetFramebuffer] GetColorAttachment]];
    
    mPizzaEntityState = PIZZA_ENTITY_EMPTY;
    
    mUsesLighting = TRUE;

    return self;
}

-(void)dealloc
{
    [mUIGroup Remove];

    [[RenderGroupManager GetInstance] RemoveRenderGroup:mPizzaRenderGroup];
    [mToppingsTexture release];
    [mTextureAtlas release];
    
    [mPaintBrush Remove];
    [mPaintBrush release];

    [mPuppet release];
    [super dealloc];
}

-(void)Draw
{
    [super Draw];
}

-(TextureAtlas*)CreateTextureAtlas
{
    TextureAtlasParams atlasParams;
    
    [TextureAtlas InitDefaultParams:&atlasParams];
    TextureAtlas* textureAtlas = [[TextureAtlas alloc] InitWithParams:&atlasParams];
    
    TextureParams params;
    
    [Texture InitDefaultParams:&params];
    
    params.mTexDataLifetime = TEX_DATA_DISPOSE;
    params.mMinFilter = GL_LINEAR_MIPMAP_LINEAR;
    params.mTextureAtlas = textureAtlas;
    
    NSNumber* toppingsTextureHandle = [[ResourceManager GetInstance] LoadAssetWithName:@"PizzaToppings.pvrtc"];
    NSData* toppingsTextureData = [[ResourceManager GetInstance] GetDataForHandle:toppingsTextureHandle];
    
    mToppingsTexture = [[PVRTCTexture alloc] InitWithData:toppingsTextureData textureParams:&params];
    
    [textureAtlas AddTexture:mToppingsTexture];
    [textureAtlas CreateAtlas];
    
    [[ResourceManager GetInstance] UnloadAssetWithHandle:toppingsTextureHandle];
    
    return textureAtlas;
}


-(void)CreatePizzaRenderGroup
{
    // Create ImageWell that contains the crust, this is always rendered as the background of the framebuffer
	ImageWellParams imageWellParams;
	[ImageWell InitDefaultParams:&imageWellParams];
    
	imageWellParams.mTextureName = @"PizzaCrust.pvrtc";
	mPizzaCrust = [(ImageWell*)[ImageWell alloc] InitWithParams:&imageWellParams];
    mPizzaCrust.MaxNumRenders = 1;
    
	// Create offscreen framebuffer for generating pizza texture
	FramebufferParams framebufferParams;
	[Framebuffer InitDefaultParams:&framebufferParams];
	
	framebufferParams.mWidth = [mToppingsTexture GetRealWidth];
	framebufferParams.mHeight = [mToppingsTexture GetRealHeight];
	framebufferParams.mColorFormat = GL_RGBA;
	framebufferParams.mColorType = GL_UNSIGNED_BYTE;
	
	mPizzaFramebuffer = [(Framebuffer*)[Framebuffer alloc] InitWithParams:&framebufferParams];
	
	// Create GameObjectCollection for storing game objects that will be rendered on the pizza texture
	GameObjectCollection* gameObjectCollection = [(GameObjectCollection*)[GameObjectCollection alloc] Init];
	
	// Create CameraStateMachine for storing the camera used for rendering pizza texture objects
	CameraStateMachine* cameraStateMachine = [(CameraStateMachine*)[CameraStateMachine alloc] Init];
	
	// We'll use the ortho camera state since this is just an orthographic projection of UI
	StaticOrthoCameraStateParams* orthoCameraParams = [(StaticOrthoCameraStateParams*)[StaticOrthoCameraStateParams alloc] Init];
	
	orthoCameraParams->mWidth = [mToppingsTexture GetRealWidth];
	orthoCameraParams->mHeight = [mToppingsTexture GetRealHeight];
	
	[cameraStateMachine Push:[StaticOrthoCameraState alloc] withParams:orthoCameraParams];
	
	[orthoCameraParams release];
	
	// Finally create the RenderGroup itself
	RenderGroupParams renderGroupParams;
	[RenderGroup InitDefaultParams:&renderGroupParams];
	
	renderGroupParams.mFramebuffer = mPizzaFramebuffer;
	renderGroupParams.mGameObjectCollection = gameObjectCollection;
	renderGroupParams.mCameraStateMachine = cameraStateMachine;
    renderGroupParams.mOneShotClear = TRUE;
	
	mPizzaRenderGroup = [(RenderGroup*)[RenderGroup alloc] InitWithParams:&renderGroupParams];
		
    [gameObjectCollection Add:mPizzaCrust];
    [mPizzaCrust release];
    
    PaintBrushParams* paintBrushParams = [[PaintBrushParams alloc] Init];
    paintBrushParams.UIGroup = mUIGroup;
    
    mPaintBrush = [[PaintBrush alloc] InitWithParams:paintBrushParams];
    
    mPaintBrush.Texture = mToppingsTexture;
    
    [gameObjectCollection Add:mUIGroup];
    
    [mPaintBrush release];
    [paintBrushParams release];
    
    // Scale crust image well to be full size (the toppings texture is larger)
    [mPizzaCrust SetScaleX:((float)framebufferParams.mWidth / (float)[mPizzaCrust GetWidth])
                         Y:((float)framebufferParams.mHeight / (float)[mPizzaCrust GetHeight])
                         Z:1.0];
			
	[[RenderGroupManager GetInstance] AddRenderGroup:mPizzaRenderGroup];
	[mPizzaRenderGroup release];
	
	[mPizzaFramebuffer release];
	[gameObjectCollection release];
	[cameraStateMachine release];
    
    [mPizzaRenderGroup SetDebugName:@"PizzaRenderGroup"];
}

-(void)TapAtTexcoordS:(float)inS t:(float)inT
{
    [mPaintBrush TapAtTexcoordS:inS t:inT];
}

-(void)Reset
{
    [mPaintBrush Reset];
    [mPizzaRenderGroup Reset];
    
    mPizzaCrust.NumRenders = 0;
    [mPizzaCrust SetVisible:TRUE];
}

@end
