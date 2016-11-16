//
//  CameraStateMachine.h
//  Neon Engine
//
//  c. Neon Games LLC - 2011, All rights reserved.

#import "StateMachine.h"

@class CameraState;

@interface CameraStateMachine : StateMachine
{
    Matrix44    mViewMatrix;
    Matrix44    mProjectionMatrix;
    Matrix44    mScreenRotationMatrix;
    Matrix44    mPostProjectionMatrix;
    
    Matrix44    mInverseViewMatrix;
    Matrix44    mInverseProjectionMatrix;
    Matrix44    mInverseScreenRotationMatrix;
    Matrix44    mInversePostProjectionMatrix;
    
    Vector3     mPosition;
    Vector3     mLookAt;
    float       mFov;
    float       mFar;
    float       mNear;
}

-(CameraStateMachine*)Init;
-(void)dealloc;

-(void)Update:(CFAbsoluteTime)inTimeStep;
-(void)CacheCameraParameters;

-(void)GetViewMatrix:(Matrix44*)outViewMatrix;
-(void)SetViewMatrix:(Matrix44*)inViewMatrix;
-(void)GetProjectionMatrix:(Matrix44*)outProjectionMatrix;
-(void)GetScreenRotationMatrix:(Matrix44*)outScreenRotation;
-(void)GetPostProjectionMatrix:(Matrix44*)outPostProjectionMatrix;

-(void)GetInverseViewMatrix:(Matrix44*)outInverseViewMatrix;
-(void)GetInverseProjectionMatrix:(Matrix44*)outInverseProjectionMatrix;
-(void)GetInverseScreenRotationMatrix:(Matrix44*)outInverseScreenRotationMatrix;
-(void)GetInversePostProjectionMatrix:(Matrix44*)outInversePostProjectionMatrix;

-(void)GetPosition:(Vector3*)outPosition;
-(void)GetLookAt:(Vector3*)outLookAt;
-(void)GetHFov:(float*)outHFov;
-(void)GetFar:(float*)outFar;
-(void)GetNear:(float*)outNear;

+(float)GetRequiredHFovForRect:(Rect3D*)inRect position:(Vector3*)inPosition lookAt:(Vector3*)inLookAt;

-(CameraState*)GetActiveState;

@end