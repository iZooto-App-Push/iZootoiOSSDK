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
    
    iZooto.notificationReceivedDelegate = self;
    iZooto.landingURLDelegate = self;
    iZooto.notificationOpenDelegate = self;
    return YES;
}
 
- (void)applicationDidBecomeActive:(UIApplication *)application
{
    application.applicationIconBadgeNumber = 0;
}
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    //Get Token from When enbale prompt allow
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
    
}
 
- (void)onNotificationOpenWithAction:(NSDictionary<NSString *,id> * _Nonnull)action {
    NSLog(@"NSString = %@", action);
 
}
 
 
- (void)onNotificationReceivedWithPayload:(Payload * _Nonnull)payload {
    NSLog(@"NSString = %@",payload);
 
}
 
@end
