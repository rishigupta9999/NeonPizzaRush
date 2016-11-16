//
//  MessageChannel.h
//  Neon21
//
//  Copyright Neon Games 2009. All rights reserved.
//

#include <vector>

typedef struct
{
    u32     mId;
    void*   mData;
} Message;

@protocol MessageChannelListener

-(void)ProcessMessage:(Message*)inMsg;

@end

class MessageChannelListener
{
    public:
        virtual void ProcessMessage(Message* inMsg) = 0;
        bool operator==(MessageChannelListener* inRight) const;
};

@interface MessageChannel : NSObject
{
    NSMutableArray*                         mListeners;
    std::vector<MessageChannelListener*>    mListenersCPP;
    int                                     mProcessingCount;
    
    NSMutableArray*                         mRemoveQueue;
    std::vector<MessageChannelListener*>    mRemoveQueueCPP;
    
    NSMutableArray*                         mAddQueue;
    std::vector<MessageChannelListener*>    mAddQueueCPP;
}

-(MessageChannel*)Init;
-(void)dealloc;

-(void)BroadcastMessageSync:(Message*)inMsg;
-(void)SendEvent:(u32)inMsgId withData:(void*)inData;

-(void)AddListener:(NSObject<MessageChannelListener>*)inListener;
-(void)AddListenerCPP:(MessageChannelListener*)inListener;

-(void)RemoveListener:(NSObject<MessageChannelListener>*)inListener;
-(void)RemoveListenerCPP:(MessageChannelListener*)inListener;

@end