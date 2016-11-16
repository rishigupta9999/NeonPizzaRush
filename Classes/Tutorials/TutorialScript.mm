//
//  TutorialScript.h
//  Neon21
//
//  Copyright Neon Games 2011. All rights reserved.
//

#import "TutorialScript.h"
#import "Flow.h"
#import "ResourceManager.h"
#import "Streamer.h"
#import "LevelDefinitions.h"
#import "SplitTestingSystem.h"


@implementation SpinnerEntry

-(SpinnerEntry*)InitWithPositionX:(float)inPosX positionY:(float)inPosY sizeX:(float)inSizeX sizeY:(float)inSizeY
{
    mPosition.mVector[x] = inPosX;
    mPosition.mVector[y] = inPosY;
    
    mSize.mVector[x] = inSizeX;
    mSize.mVector[y] = inSizeY;
    
    return self;
}

@end

@implementation TutorialPhaseInfo

@synthesize AnyButton = mAnyButton;

-(TutorialPhaseInfo*)Init
{
    mDialogueKey = NULL;
    mDialogueFontSize = 12.0f;
    mDialogueFontName = NULL;
    mDialogueFontAlignment = kCTTextAlignmentLeft;
    
    SetVec2(&mDialogueOffset, 0.0f, 0.0f);
    
    mButtonIdentifier = NULL;
    mAnyButton = FALSE;
    
    mTriggerState = NULL;
    mTriggerCount = 0;
    
    mCameraPositionOverride = FALSE;
    mCameraLookAtOverride = FALSE;
    mCameraFovOverride = FALSE;
    
    mRestoreCamera = FALSE;
    
    mSpinnerEntries = [[NSMutableArray alloc] init];
    
    SetColorFloat(&mDialogueFontColor, 1.0, 1.0, 1.0, 1.0);
    
    mTerminateEvent = EVENT_EMPTY;
    
    return self;
}

-(void)dealloc
{
    [mDialogueKey release];
    [mDialogueFontName release];
    [mButtonIdentifier release];
    [mTriggerState release];
    [mSpinnerEntries release];
    
    [super dealloc];
}

-(void)SetDialogueOffsetX:(float)inX y:(float)inY
{
    mDialogueOffset.mVector[x] = inX;
    mDialogueOffset.mVector[y] = inY;
}

-(void)SetDialogueFontSize:(float)inFontSize
{
    mDialogueFontSize = inFontSize;
}

-(void)SetDialogueFontName:(NSString*)inFontName
{
    mDialogueFontName = [inFontName retain];
}

-(void)SetDialogueFontColorR:(float)inR g:(float)inG b:(float)inB a:(float)inA
{
    SetColorFloat(&mDialogueFontColor, inR, inG, inB, inA);
}

-(void)SetCameraPositionX:(float)inX y:(float)inY z:(float)inZ
{
    mCameraPositionOverride = TRUE;
    
    mCameraPosition.mVector[x] = inX;
    mCameraPosition.mVector[y] = inY;
    mCameraPosition.mVector[z] = inZ;
}

-(void)SetCameraLookAtX:(float)inX y:(float)inY z:(float)inZ
{
    mCameraLookAtOverride = TRUE;
    
    mCameraLookAt.mVector[x] = inX;
    mCameraLookAt.mVector[y] = inY;
    mCameraLookAt.mVector[z] = inZ;
}

-(void)SetCameraFov:(float)inFov
{
    mCameraFovOverride = TRUE;
    
    if (GetDeviceiPhoneTall())
    {
        mCameraFov = inFov / 1.18;
    }
    else
    {
        mCameraFov = inFov;
    }
}

-(void)RestoreCamera
{
    mRestoreCamera = TRUE;
}

-(void)SetSpinnerPositionX:(float)inX positionY:(float)inY sizeX:(float)inSizeX sizeY:(float)inSizeY
{
    if (!GetDeviceiPhoneTall())
    {
        SpinnerEntry* spinnerEntry = [(SpinnerEntry*)[SpinnerEntry alloc] InitWithPositionX:inX positionY:inY sizeX:inSizeX sizeY:inSizeY];
        [mSpinnerEntries addObject:spinnerEntry];
        [spinnerEntry release];
    }
}

-(void)SetTallSpinnerPositionX:(float)inX positionY:(float)inY sizeX:(float)inSizeX sizeY:(float)inSizeY
{
    if (GetDeviceiPhoneTall())
    {
        SpinnerEntry* spinnerEntry = [(SpinnerEntry*)[SpinnerEntry alloc] InitWithPositionX:inX positionY:inY sizeX:inSizeX sizeY:inSizeY];
        [mSpinnerEntries addObject:spinnerEntry];
        [spinnerEntry release];
    }
}

-(BOOL)HasSpinners
{
    return ([mSpinnerEntries count] > 0);
}

-(int)GetNumSpinners
{
    return (int)[mSpinnerEntries count];
}

-(SpinnerEntry*)GetSpinnerEntry:(int)inIndex
{
    return [mSpinnerEntries objectAtIndex:inIndex];
}

-(void)SetDialogueAlignment:(CTTextAlignment)inFontAlignment
{
    mDialogueFontAlignment = inFontAlignment;
}
@end

@implementation TutorialScript

@synthesize Indeterminate = mIndeterminate;
@synthesize EnableUI = mEnableUI;

-(TutorialScript*)InitDynamic
{
    mPhaseInfo = [[NSMutableArray alloc] init];
    mShoeEntries = [[NSMutableArray alloc] init];
    
    mIndeterminate = FALSE;
    mEnableUI = FALSE;
    
    return self;
}

-(void)dealloc
{
    [mActiveScript release];
    [mShoeEntries release];
    [mPhaseInfo release];
    
    [super dealloc];
}

-(void)AddPhase:(TutorialPhaseInfo*)inPhaseInfo
{
    [mPhaseInfo addObject:inPhaseInfo];
}

-(void)SetIndeterminate:(BOOL)inIndeterminate
{
    mIndeterminate = inIndeterminate;
}

-(TutorialPhaseInfo*)GetTutorialPhase:(int)inPhaseIndex
{
    TutorialPhaseInfo* retPhaseInfo = NULL;
    
    if (inPhaseIndex < [mPhaseInfo count])
    {
        retPhaseInfo = [mPhaseInfo objectAtIndex:inPhaseIndex];
    }
    
    return retPhaseInfo;
}

-(int)GetNumPhases
{
    return (int)[mPhaseInfo count];
}

@end