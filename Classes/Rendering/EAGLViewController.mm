//
//  EAGLViewController.m
//  CarnivalHorseRacing
//
//  Created by Rishi Gupta on 4/28/14.
//  Copyright (c) 2014 Neon Games LLC. All rights reserved.
//

#import "EAGLViewController.h"
#import "NeonUtilities.h"
#import "AppDelegate.h"

@interface EAGLViewController ()

@end

@implementation EAGLViewController

@synthesize glView = mGLView;

- (id)initWithCoder:(NSCoder*)decoder
{
    self = [super initWithCoder:decoder];
    
    GetAppDelegate().glViewController = self;
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)dealloc {
    [mGLView release];
    [super dealloc];
}
@end
