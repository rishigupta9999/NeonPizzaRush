//
//  NeonGL_C.h
//  PizzaSpinner
//
//  Created by Rishi Gupta on 6/21/14.
//  Copyright (c) 2014 Neon Games LLC. All rights reserved.
//

#ifndef PizzaSpinner_NeonGL_C_h
#define PizzaSpinner_NeonGL_C_h

#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */

void NeonGLEnable(GLenum inEnable);
void NeonGLDisable(GLenum inDisable);

void NeonGLBlendFunc(GLenum inSrcBlend, GLenum inDestBlend);

void NeonGLGetIntegerv(GLenum inEnum, int* outValue);

void NeonGLViewport(int inX, int inY, int inWidth, int inHeight);

void NeonGLActiveTexture(GLenum inTextureUnit);
void NeonGLBindTexture(GLenum inTarget, int inTexture);
void NeonGLDeleteTextures(int inNumTextures, u32* inTextureIds);

void NeonGLMatrixMode(GLenum inMatrixMode);

void NeonGLClearColor(float inR, float inG, float inB, float inA);

void NeonGLBindFramebuffer(GLenum inTarget, int inIdentifier);
void NeonGLDeleteFramebuffers(int inNumFramebuffers, u32* inIdentifiers);

#ifdef __cplusplus
}
#endif

#endif
