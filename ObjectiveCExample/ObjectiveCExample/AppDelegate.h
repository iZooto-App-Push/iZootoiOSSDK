//
//  AppDelegate.h
//  ObjectiveCExample
//
//  Created by Amit on 28/06/21.
//

#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>
@import iZootoiOSSDK;
 
@interface AppDelegate : UIResponder <UIApplicationDelegate,UNUserNotificationCenterDelegate,iZootoLandingURLDelegate,iZootoNotificationOpenDelegate,iZootoNotificationReceiveDelegate>
@property (strong, nonatomic) UIWindow * window;
@property(nonatomic, weak)id <iZootoLandingURLDelegate> landingURLDelegate;
@property(nonatomic, weak)id <iZootoNotificationOpenDelegate> notificationOpenDelegate;
@property(nonatomic, weak)id <iZootoNotificationReceiveDelegate> notificationReceivedDelegate;
@end


