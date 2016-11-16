//
//  NotificationManager.h
//  PizzaSpinner
//
//  Created by Rishi Gupta on 7/28/14.
//  Copyright (c) 2014 Neon Games LLC. All rights reserved.
//

#ifndef __PizzaSpinner__NotificationManager__
#define __PizzaSpinner__NotificationManager__

#include "MessageChannel.h"

class LocalNotificationManager : public MessageChannelListener
{
    public:
        LocalNotificationManager();
        ~LocalNotificationManager();
    
        static LocalNotificationManager* GetInstance();
        static void CreateInstance();
        static void DestroyInstance();
    
        void ProcessMessage(Message* inMessage);
    
    private:
        void CancelNotifications();
        
        static LocalNotificationManager* sInstance;
};

#endif /* defined(__PizzaSpinner__NotificationManager__) */
