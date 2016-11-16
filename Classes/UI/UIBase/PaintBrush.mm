//
//  PaintBrush.m
//  PizzaSpinner
//
//  Created by Rishi Gupta on 6/19/14.
//  Copyright (c) 2014 Neon Games LLC. All rights reserved.
//

#import "PaintBrush.h"
#import "NeonMath.h"
#import <list>

static const float BRUSH_SIZE = 448;

@interface PaintBrushEntry : NSObject
{
    @public
        float   mS;
        float   mT;
        float   mLength;
    
        BOOL    mComplete;
}

-(instancetype)Init;

@end

@implementation PaintBrushEntry

-(instancetype)Init
{
    mS = 0;
    mT = 0;
    mLength = 0;
    
    mComplete = FALSE;
    
    return self;
}

@end


@implementation PaintBrushParams

@synthesize UIGroup = mUIGroup;

-(instancetype)Init
{
    mUIGroup = NULL;
    return self;
}

@end

@interface PaintBrush(PrivateMethods)

-(void)DrawQuadX:(float)inX y:(float)inY;

@end

@implementation PaintBrush

@synthesize Texture = mTexture;
@synthesize NumQuads = mNumQuads;

-(instancetype)InitWithParams:(PaintBrushParams*)inParams
{
    [super InitWithUIGroup:inParams.UIGroup];
    
    mEntries = [[NSMutableArray alloc] init];
    mOrtho = TRUE;
    
    return self;
}

-(void)dealloc
{
    [mEntries release];
    [mTexture release];
    
    [super dealloc];
}

-(void)Reset
{
    [mEntries removeAllObjects];
    mRectangles.clear();
}

void PaintBrushBresenhamCallback(int inX, int inY, void* inUserData)
{
    PaintBrush* paintBrush = (PaintBrush*)inUserData;
    [paintBrush DrawQuadX:inX y:inY];
}

-(void)DrawOrtho
{
    PaintBrushEntry* prevEntry = NULL;
    int prevX = 0;
    int prevY = 0;
    
    for (PaintBrushEntry* curEntry in mEntries)
    {
        QuadParams quadParams;
        [UIObject InitQuadParams:&quadParams];
        
        float texWidth = [mTexture GetRealWidth];
        
        float xPos = (curEntry->mS) * texWidth;
        float yPos = (curEntry->mT) * texWidth;
        
        xPos -= (BRUSH_SIZE / 2);
        yPos -= (BRUSH_SIZE / 2);
        
        [self DrawQuadX:xPos y:yPos];
        
        if (prevEntry != NULL)
        {
            Bresenham((int)prevX, (int)prevY, (int)xPos, (int)yPos, PaintBrushBresenhamCallback, (void*)self);
            
            prevEntry->mComplete = TRUE;
        }
        
        prevX = xPos;
        prevY = yPos;

        prevEntry = curEntry;
        
        Rect2D newRect;
        
        newRect.mXMin = xPos;
        newRect.mYMin = yPos;
        newRect.mXMax = xPos + BRUSH_SIZE;
        newRect.mYMax = yPos + BRUSH_SIZE;
        
        mRectangles.push_back(newRect);
    }
    
    u64 numEntries = [mEntries count];
    
    for (int i = 0; i < numEntries; i++)
    {
        PaintBrushEntry* curEntry = [mEntries objectAtIndex:i];
        
        // If there's only one entry, we didn't have to use the Bresenham line drawing algorithm.  Delete it anyway.
        if ((curEntry->mComplete) || (numEntries == 1))
        {
            [mEntries removeObjectAtIndex:i];
        }
        
        i--;
        numEntries--;
    }
}

-(void)DrawQuadX:(float)inX y:(float)inY
{
    QuadParams quadParams;
    [UIObject InitQuadParams:&quadParams];

    quadParams.mTexture = mTexture;
    
    quadParams.mTexCoordEnabled = TRUE;
    
    float s0, t0, s1, t1;
    
    float texWidth = [mTexture GetRealWidth];
    
    s0 = (float)inX / texWidth;
    t0 = (float)inY / texWidth;
    s1 = ((float)inX + BRUSH_SIZE) / texWidth;
    t1 = ((float)inY + BRUSH_SIZE) / texWidth;
    
    quadParams.mTexCoords[0] = s0;
    quadParams.mTexCoords[1] = t0;
    
    quadParams.mTexCoords[2] = s0;
    quadParams.mTexCoords[3] = t1;
    
    quadParams.mTexCoords[4] = s1;
    quadParams.mTexCoords[5] = t0;
    
    quadParams.mTexCoords[6] = s1;
    quadParams.mTexCoords[7] = t1;

    quadParams.mTranslation.mVector[x] = inX;
    quadParams.mTranslation.mVector[y] = inY;
    
    quadParams.mScaleType = QUAD_PARAMS_SCALE_BOTH;
    quadParams.mScale.mVector[x] = BRUSH_SIZE;
    quadParams.mScale.mVector[y] = BRUSH_SIZE;
    
    quadParams.mColorMultiplyEnabled = TRUE;
    
    for (int i = 0; i < 4; i++)
    {
        SetColorFloat(&quadParams.mColor[i], 1, 1, 1, 1);
    }
    
    [self DrawQuad:&quadParams];
    
    mNumQuads++;
}

-(void)TapAtTexcoordS:(float)inS t:(float)inT
{
    PaintBrushEntry* newEntry = [[PaintBrushEntry alloc] Init];
    newEntry->mS = inS;
    newEntry->mT = inT;
    
    [mEntries addObject:newEntry];
    [newEntry release];
}

struct NeonRange
{
    float less;
    float greater;

    NeonRange(float l, float g)
    {
        less = (l < g) ? l : g;
        greater = (l + g) - less;
    }

    bool IsOverlapping(const NeonRange& other)
    {
        return !(less > other.greater || other.less > greater);
    }

    void Merge(const NeonRange& other)
    {
        if(IsOverlapping(other))
        {
            less = (less < other.less) ? less : other.less;
            greater = (greater > other.greater) ? greater : other.greater;
        }
    }
};

bool operator < (const Rect2D& rect1, const Rect2D& rect2)
{
    return (rect1.mXMax < rect2.mXMax);
}

void GetAllX(const std::vector<Rect2D>& rects, std::vector<float>& xes)
{
    std::vector<Rect2D>::const_iterator iter = rects.begin();
    
    for(; iter != rects.end(); ++ iter)
    {
        xes.push_back(iter->mXMin);
        xes.push_back(iter->mXMax);
    }
}

void InsertRangeY(std::list<NeonRange>& rangesOfY, NeonRange& rangeY)
{
    using namespace std;
    
    list<NeonRange>::iterator iter = rangesOfY.begin();
    while(iter != rangesOfY.end())
    {
        if(rangeY.IsOverlapping(*iter))
        {
            rangeY.Merge(*iter);

            list<NeonRange>::iterator iterCopy = iter;
            ++ iter;
            rangesOfY.erase(iterCopy);
        }
        else
            ++ iter;
    }

    rangesOfY.push_back(rangeY);
}

void GetRangesOfY(const std::vector<Rect2D>& rects, std::vector<Rect2D>::const_iterator iterRect, const NeonRange& rangeX, std::list<NeonRange>& rangesOfY)
{
    for(; iterRect != rects.end(); ++ iterRect)
    {
        if(rangeX.less < iterRect->mXMax && rangeX.greater > iterRect->mXMin)
        {
            NeonRange tempRange = NeonRange(iterRect->mYMin, iterRect->mYMax);
            
            InsertRangeY(rangesOfY, tempRange);
        }
    }
}

float GetRectArea(const NeonRange& rangeX, const std::list<NeonRange>& rangesOfY)
{
    using namespace std;
    
    float width = rangeX.greater - rangeX.less;
   
    list<NeonRange>::const_iterator iter = rangesOfY.begin();
    int area = 0;
    for(; iter != rangesOfY.end(); ++ iter)
    {
        float height = iter->greater - iter->less;
        area += width * height;
    }

    return area;
}

-(float)GetTotalArea
{
    using namespace std;
    
    // sort rectangles according to x-value of right edges
    sort(mRectangles.begin(), mRectangles.end());

    vector<float> xes;
    GetAllX(mRectangles, xes);
    sort(xes.begin(), xes.end());

    float area = 0;
    vector<float>::iterator iterX1 = xes.begin();
    vector<Rect2D>::const_iterator iterRect = mRectangles.begin();
    
    for(; iterX1 != xes.end() && iterX1 != xes.end() - 1; ++ iterX1)
    {
        vector<float>::iterator iterX2 = iterX1 + 1;

        // filter out duplicated X-es
        if(*iterX1 < *iterX2)
        {
            NeonRange rangeX(*iterX1, *iterX2);

            while(iterRect->mXMax < *iterX1)
                ++iterRect;

            list<NeonRange> rangesOfY;
            GetRangesOfY(mRectangles, iterRect, rangeX, rangesOfY);
            area += GetRectArea(rangeX, rangesOfY);
        }
    }

    return area;
}

@end
