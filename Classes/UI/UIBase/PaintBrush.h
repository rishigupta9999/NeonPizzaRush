//
//  PaintBrush.h
//  PizzaSpinner
//
//  Created by Rishi Gupta on 6/19/14.
//  Copyright (c) 2014 Neon Games LLC. All rights reserved.
//

#import "UIObject.h"

#undef max
#undef min
#import <vector>

@interface PaintBrushParams : NSObject
{
}

@property(assign) UIGroup*  UIGroup;

-(instancetype)Init;


@end

@class PaintBrushEntry;

@interface PaintBrush : UIObject
{
    @public
        NSMutableArray*     mEntries;
        std::vector<Rect2D> mRectangles;
}

@property(retain)   Texture*  Texture;
@property(readonly) int       NumQuads;

-(instancetype)InitWithParams:(PaintBrushParams*)inParams;
-(void)dealloc;
-(void)Reset;

-(void)TapAtTexcoordS:(float)inS t:(float)inT;
-(float)GetTotalArea;

@end
