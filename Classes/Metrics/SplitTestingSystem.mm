//
//  SplitTestingSystem.m
//  Neon21
//
//  Copyright (c) 2013 Neon Games.
//

#import "SplitTestingSystem.h"
#import "NeonMetrics.h"

static const char*  sVersionName = "App Version";

static SplitTestingSystem* sInstance = NULL;

@interface SplitTestInfo : NSObject
{
}

@property(retain)   NSString* SplitTestName;
@property           int       NumVariations; // Set to 2 for a split test.  Set to more for a multivariate test

-(instancetype)InitWithName:(NSString*)inName numVariations:(int)inNumVariations;
-(void)dealloc;

@end


@implementation SplitTestInfo

@synthesize SplitTestName = mSplitTestName;
@synthesize NumVariations = mNumVariations;

-(instancetype)InitWithName:(NSString*)inName numVariations:(int)inNumVariations
{
    mSplitTestName = inName;
    mNumVariations = 2;
    
    return self;
}

-(void)dealloc
{
    [mSplitTestName release];
    
    [super dealloc];
}

@end

@implementation SplitTestingSystem

-(SplitTestingSystem*)Init
{
    mFirstLaunch = FALSE;
    
    mSplitTestInfo = [[NSMutableArray alloc] initWithCapacity:SPLIT_TEST_NUM];
    
    SplitTestInfo* splitTestInfo = [[SplitTestInfo alloc] InitWithName:@"CrystalPizzaSpawnTimes" numVariations:3];
    [mSplitTestInfo addObject:splitTestInfo];
    
#if SPLIT_TEST_FORCE_BUCKETS
    BOOL useSplitTest = 0;
    int  testNumber = SPLIT_TEST_BANNER_ADS;
    
    mSplitTests = [[NSMutableDictionary alloc] initWithCapacity:SPLIT_TEST_NUM];
    
    for (int i = 0; i < SPLIT_TEST_NUM; i++)
    {
        NSNumber* number = [NSNumber numberWithInt:0];
        
        if (useSplitTest && (testNumber == i))
        {
            number = [NSNumber numberWithInt:1];
        }
        
        [mSplitTests setObject:number forKey:[NSString stringWithUTF8String:sSplitTestNames[i]]];
    }
    
    // Toggle this for testing first launch vs repeated launch functionality
    mFirstLaunch = FALSE;
#else
    static const char* sSplitTestBucketsFile = "SplitTestBuckets.plist";

    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsPath = [paths objectAtIndex:0];
    NSString* splitTestBucketsFilePath = [NSString stringWithFormat:@"%@/%s", documentsPath, sSplitTestBucketsFile];

    if ([[NSFileManager defaultManager] fileExistsAtPath:splitTestBucketsFilePath])
    {
        mSplitTests = (NSMutableDictionary*)[[NSDictionary alloc] initWithContentsOfFile:splitTestBucketsFilePath];
        BOOL valid = [self ValidateBuckets];
        
        if (!valid)
        {
            [mSplitTests writeToFile:splitTestBucketsFilePath atomically:YES];
        }
    }
    else
    {
        [self AssignBuckets];
        [mSplitTests writeToFile:splitTestBucketsFilePath atomically:YES];
        
        mFirstLaunch = TRUE;
    }
#endif
    
    [self DumpBuckets];
    
    return self;
}

-(void)dealloc
{
    [mSplitTests release];
    [mSplitTestInfo release];
    
    [super dealloc];
}

+(void)CreateInstance
{
    NSAssert(sInstance == NULL, @"SplitTestingSystem has already been created");
    
    sInstance = [(SplitTestingSystem*)[SplitTestingSystem alloc] Init];
}

+(void)DestroyInstance
{
    NSAssert(sInstance != NULL, @"SplitTestingSystem has already been destroyed");
    
    [sInstance release];
    sInstance = NULL;
}

+(SplitTestingSystem*)GetInstance
{
    return sInstance;
}

-(void)AssignBuckets
{
    if (SPLIT_TEST_NUM == 0)
    {
        return;
    }
    
    mSplitTests = [[NSMutableDictionary alloc] initWithCapacity:(SPLIT_TEST_NUM + 1)];
    
    for (int i = 0; i < SPLIT_TEST_NUM; i++)
    {
        NSNumber* bucketVal = [NSNumber numberWithBool:0];
        
        NSString* splitTestName = ((SplitTestInfo*)[mSplitTestInfo objectAtIndex:i]).SplitTestName;
        [mSplitTests setObject:bucketVal forKey:splitTestName];
    }
    
    arc4random_stir();
    
    // 50/50 chance that the user gets put into a split test group.  If they do, they get a randomly assigned split test
    BOOL getSplitTest = arc4random_uniform(2);
    
    if (getSplitTest != 0)
    {
        int splitTestNum = arc4random_uniform(SPLIT_TEST_NUM);
        SplitTestInfo* splitTestInfo = ((SplitTestInfo*)[mSplitTestInfo objectAtIndex:splitTestNum]);
        
        NSString* splitTestName = splitTestInfo.SplitTestName;
        
        // Randomly assign a variation other than zero
        int variation = arc4random_uniform(splitTestInfo.NumVariations) + 1;

        [mSplitTests setObject:[NSNumber numberWithInt:variation] forKey:splitTestName];
    }
    
    [mSplitTests setObject:[[NeonMetrics GetInstance] GetVersion] forKey:[NSString stringWithUTF8String:sVersionName]];
}

-(BOOL)ValidateBuckets
{
    BOOL valid = TRUE;

    NSArray* allKeys = [mSplitTests allKeys];
    
    // First check if we have any keys that aren't current.  If so, remove them
    
    int numKeys = (int)[allKeys count];
    
    for (int i = 0; i < numKeys; i++)
    {
        NSString* curKey = [allKeys objectAtIndex:i];
        BOOL keyFound = FALSE;
        
        if (strcmp([curKey UTF8String], sVersionName) == 0)
        {
            NSString* curVersion = [[NeonMetrics GetInstance] GetVersion];
            
            if ([(NSString*)[mSplitTests objectForKey:curKey] compare:curVersion] != NSOrderedSame)
            {
                [mSplitTests setObject:curVersion forKey:curKey];
                valid = FALSE;
                
                mFirstLaunch = TRUE;
            }
            
            continue;
        }
        
        for (int ref = 0; ref < SPLIT_TEST_NUM; ref++)
        {
            NSString* refName = ((SplitTestInfo*)[mSplitTestInfo objectAtIndex:ref]).SplitTestName;
            
            if ([curKey compare:refName] == NSOrderedSame)
            {
                keyFound = TRUE;
                break;
            }
        }
        
        if (!keyFound)
        {
            valid = FALSE;
            [mSplitTests removeObjectForKey:curKey];
        }
    }
    
    // Now add keys that don't exist
    for (int i = 0; i < SPLIT_TEST_NUM; i++)
    {
        NSString* curKey = ((SplitTestInfo*)[mSplitTestInfo objectAtIndex:i]).SplitTestName;
        
        // Users who already have a buckets file don't get put in split test groups
        if ([mSplitTests objectForKey:curKey] == NULL)
        {
            NSNumber* bucketVal = [NSNumber numberWithInt:0];
            [mSplitTests setObject:bucketVal forKey:curKey];
            
            valid = FALSE;
        }
    }
    
    return valid;
}

-(int)GetSplitTestValue:(SplitTest)inSplitTest
{
    NSAssert((inSplitTest >= 0) && (inSplitTest < SPLIT_TEST_NUM), @"Invalid split test");
    
    NSString* curKey = ((SplitTestInfo*)[mSplitTestInfo objectAtIndex:inSplitTest]).SplitTestName;
    
    NSNumber* value = [mSplitTests objectForKey:curKey];
    NSAssert(value != NULL, @"Split test key doesn't exist");
    
    return [value intValue];
}

-(NSString*)GetSplitTestString:(SplitTest)inSplitTest
{
    NSAssert((inSplitTest >= 0) && (inSplitTest < SPLIT_TEST_NUM), @"Invalid split test");
    
    return((SplitTestInfo*)[mSplitTestInfo objectAtIndex:inSplitTest]).SplitTestName;
}

-(void)DumpBuckets
{
#if !NEON_PRODUCTION
    for (int i = 0; i < SPLIT_TEST_NUM; i++)
    {
        NSString* keyName = ((SplitTestInfo*)[mSplitTestInfo objectAtIndex:i]).SplitTestName;
        NSNumber* keyValue = [mSplitTests objectForKey:keyName];
        
        NSLog(@"Split Test %@ = %@", keyName, keyValue);
    }
#endif
}

-(BOOL)GetFirstLaunch
{
    return mFirstLaunch;
}

@end