//
//  MessageChannel.m
//  Neon21
//
//  Copyright Neon Games 2009. All rights reserved.
//

#import "MessageChannel.h"

#define INITIAL_NUM_MESSAGES    (5)
#define INITIAL_NUM_LISTENERS   (3)

bool MessageChannelListener::operator==(MessageChannelListener* inRight) const
{
    return this == inRight;
}

@implementation MessageChannel

-(MessageChannel*)Init
{
    mListeners = [[NSMutableArray alloc] initWithCapacity:INITIAL_NUM_LISTENERS];
    mRemoveQueue = [[NSMutableArray alloc] initWithCapacity:INITIAL_NUM_LISTENERS];
    mAddQueue = [[NSMutableArray alloc] initWithCapacity:INITIAL_NUM_LISTENERS];
    
    mProcessingCount = 0;
    
    return self;
}

-(void)dealloc
{
    [mListeners release];
    [mRemoveQueue release];
    [mAddQueue release];
    
    [super dealloc];
}

-(void)SendEvent:(u32)inMsgId withData:(void*)inData
{
    Message msg;
    
    msg.mId = inMsgId;
    msg.mData = inData;
    
    [self BroadcastMessageSync:&msg];
}

-(void)BroadcastMessageSync:(Message*)inMsg
{
    mProcessingCount++;
    
    int numListeners = (int)[mListeners count];
    
    for (int i = 0; i < numListeners; i++)
    {
        NSObject<MessageChannelListener>* curListener = [mListeners objectAtIndex:i];
        
        [curListener ProcessMessage:inMsg];
    }
    
    for (std::vector<MessageChannelListener*>::iterator it = mListenersCPP.begin(); it != mListenersCPP.end(); it++)
    {
        (*it)->ProcessMessage(inMsg);
    }
    
    mProcessingCount--;
    
    if (mProcessingCount == 0)
    {
        for (NSObject<MessageChannelListener>* curListener in mRemoveQueue)
        {
            [self RemoveListener:curListener];
        }
        
        [mRemoveQueue removeAllObjects];
        
        
        for (std::vector<MessageChannelListener*>::iterator it = mRemoveQueueCPP.begin(); it != mRemoveQueueCPP.end(); it++)
        {
            [self RemoveListenerCPP:(*it)];
        }
        
        mRemoveQueueCPP.clear();
        
        
        for (NSObject<MessageChannelListener>* curListener in mAddQueue)
        {
            [self AddListener:curListener];
        }
        
        [mAddQueue removeAllObjects];
        
        
        for (std::vector<MessageChannelListener*>::iterator it = mAddQueueCPP.begin(); it != mAddQueueCPP.end(); it++)
        {
            [self AddListenerCPP:(*it)];
        }
        
        mAddQueueCPP.clear();

    }
}

-(void)AddListener:(NSObject<MessageChannelListener>*)inListener
{
    if (mProcessingCount == 0)
    {
        [mListeners addObject:inListener];
    }
    else
    {
        [mAddQueue addObject:inListener];
    }
}

-(void)AddListenerCPP:(MessageChannelListener*)inListener
{
    if (mProcessingCount == 0)
    {
        mListenersCPP.push_back(inListener);
    }
    else
    {
        mAddQueueCPP.push_back(inListener);
    }
}

-(void)RemoveListener:(NSObject<MessageChannelListener>*)inListener
{
    if (mProcessingCount == 0)
    {
        [mListeners removeObject:inListener];
    }
    else
    {
        [mRemoveQueue addObject:inListener];
    }
}

-(void)RemoveListenerCPP:(MessageChannelListener*)inListener
{
    if (mProcessingCount == 0)
    {
        std::vector<MessageChannelListener*>::iterator it = std::find(mListenersCPP.begin(), mListenersCPP.end(), inListener);
        
        if (it != mListenersCPP.end())
        {
            mListenersCPP.erase(it);
        }
    }
    else
    {
        mRemoveQueueCPP.push_back(inListener);
    }
}

@end