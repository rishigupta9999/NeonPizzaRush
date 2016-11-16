//
//  ModelManagerTypes.h
//  Neon21
//
//  Copyright Neon Games 2013. All rights reserved.
//

@class GameObjectManager;
@class GameObject;

typedef struct
{
    NSString*   mFilename;
    GameObject* mOwnerObject;
    BOOL        mReflective;
} ModelParams;

typedef enum
{
    ModelManagerCondition_GreaterThan,
    ModelManagerCondition_GreaterThanEquals,
    ModelManagerCondition_LessThanEquals,
    ModelManagerCondition_Equals
} ModelManagerCondition;

typedef enum
{
    MODELMANAGER_VIEWPORT_ORTHO,
    MODELMANAGER_VIEWPORT_UI,
    MODELMANAGER_VIEWPORT_3D,
    MODELMANAGER_VIEWPORT_INVALID
} ModelManagerViewport;

typedef struct
{
    GameObjectManager*      mGameObjectManager;
    int                     mPriority;
    int                     mPriorityTwo;
    ModelManagerCondition   mCondition;
    ModelManagerCondition   mConditionTwo;
    BOOL                    mOrtho;
    BOOL                    mProjected;
} ModelManagerDrawParams;

typedef enum
{
    ModelManagerDrawingMode_All,                // Draw all visible objects
    ModelManagerDrawingMode_ActiveGameState,    // Draw objects corresponding to the active GameState only
} ModelManagerDrawingMode;
