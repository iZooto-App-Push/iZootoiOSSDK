//
//  AppDelegate.m
//  ObjectiveCExample
//
//  Created by Amit on 28/06/21.
//

#import "AppDelegate.h"
@import iZootoiOSSDK;
@import UserNotifications;
@interface AppDelegate ()
@end
@implementation AppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  
    dispatch_async(dispatch_get_main_queue(), ^{
//define settings
       NSMutableDictionary *iZootooInitSetting = [[NSMutableDictionary alloc]init];
       [iZootooInitSetting setObject:@YES forKey:@"auto_prompt"];
       [iZootooInitSetting setObject:@YES forKey:@"nativeWebview"];
       [iZootooInitSetting setObject:@NO forKey:@"provisionalAuthorization"];
   // initalise the MoMagic SDK
   [iZooto initialisationWithIzooto_id:@"de1bdb0a32007eed602064192bb129b7e5e3cc32"  application:application iZootoInitSettings:iZootooInitSetting];
       
   });
    [iZooto setBadgeCountWithBadgeNumber:0];

   iZooto.notificationReceivedDelegate = self;
   iZooto.notificationOpenDelegate = self;
   
    
    NSDictionary *apnsBody = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    
  

    if(apnsBody)
    {
        [self ShowAlert:@"Amit"];
    }
    else
    {
        [self ShowAlert:@"Amit Kumar Gupta"];

    }
    
//    NSDictionary *apnsBody = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
//    if (apnsBody) {
//       // NSLog(@"%@",apnsBody['alert']['title']);
//
//        iZooto.landingURLDelegate = self;
//    }
//    else
//    {
//        NSLog(@"payload is : %@", apnsBody);
//        iZooto.landingURLDelegate = self;
//
//    }
   
    return YES;
}
- (void) ShowAlert:(NSString *)Message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:Message
                                                    message:@"More info..."
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Say Hello",nil];
    [alert show];
}






- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [iZooto setBadgeCountWithBadgeNumber:0];
    application.applicationIconBadgeNumber = 0;
}
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [iZooto getTokenWithDeviceToken:deviceToken];
}
 
-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler{
    NSLog(@"Received");
    [iZooto handleForeGroundNotificationWithNotification:notification displayNotification:@"NONE" completionHandler:completionHandler];
}
-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    
}
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void (^)(void))completionHandler
{
    [iZooto notificationHandlerWithResponse:response];
    completionHandler();
}
 
 
 
- (void)onHandleLandingURLWithUrl:(NSString * _Nonnull)url {
    NSLog(url);
    [self ShowAlert:@"Hello"];


    
}
 
- (void)onNotificationOpenWithAction:(NSDictionary<NSString *,id> * _Nonnull)action {
    NSLog(@"NSString = %@", action);
 
}
 
 
- (void)onNotificationReceivedWithPayload:(Payload * _Nonnull)payload {
    NSLog(@"NSString = %@",payload);
 
}
 
@end
