//
//  NotificationManager.cpp
//  PizzaSpinner
//
//  Created by Rishi Gupta on 7/28/14.
//  Copyright (c) 2014 Neon Games LLC. All rights reserved.
//

#include "LocalNotificationManager.h"

#import "MessageChannel.h"
#import "Event.h"

LocalNotificationManager* LocalNotificationManager::sInstance = NULL;

LocalNotificationManager::LocalNotificationManager()
{
    [GetGlobalMessageChannel() AddListenerCPP:this];
    
    CancelNotifications();
}

LocalNotificationManager::~LocalNotificationManager()
{
    [GetGlobalMessageChannel() RemoveListenerCPP:this];
}

LocalNotificationManager* LocalNotificationManager::GetInstance()
{
    return sInstance;
}

void LocalNotificationManager::CreateInstance()
{
    NSCAssert(sInstance == NULL, @"Expected sInstance to be NULL");
    
    sInstance = new LocalNotificationManager;
}

void LocalNotificationManager::DestroyInstance()
{
    NSCAssert(sInstance != NULL, @"Expected sInstance to be non-NULL");
    
    delete sInstance;
    
    sInstance = NULL;
}

void LocalNotificationManager::CancelNotifications()
{
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

void LocalNotificationManager::ProcessMessage(Message* inMessage)
{
    switch(inMessage->mId)
    {
        case EVENT_APPLICATION_SUSPENDED:
        {
            int times[2] = { 2, 24 };
            
            for (int i = 0; i < 2; i++)
            {
                UILocalNotification* localNotification = [[UILocalNotification alloc] init];

                NSDate* fireDate = [NSDate dateWithTimeIntervalSinceNow:(times[i] * 60 * 60)];
                localNotification.fireDate = fireDate;
                
                localNotification.alertBody = NSLocalizedString(@"LS_24_Hour_Notification", NULL);

                localNotification.soundName = UILocalNotificationDefaultSoundName;
                localNotification.applicationIconBadgeNumber = 1;

                [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
                [localNotification release];
            }
            
            break;
        }
        
        case EVENT_APPLICATION_RESUMED:
        {
            CancelNotifications();
            break;
        }
    }
}