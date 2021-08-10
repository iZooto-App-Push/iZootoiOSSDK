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
    NSMutableDictionary *iZootooInitSetting = [[NSMutableDictionary alloc]init];
    [iZootooInitSetting setObject:@YES forKey:@"auto_prompt"];
    [iZootooInitSetting setObject:@YES forKey:@"nativeWebview"];
    [iZootooInitSetting setObject:@NO forKey:@"provisionalAuthorization"];

    if (launchOptions != nil)
       {
           // opened from a push notification when the app is closed
           NSDictionary* userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
           if (userInfo != nil)
           {
                NSLog(@"userInfo->%@", [userInfo objectForKey:@"aps"]);
               [iZooto initialisationWithIzooto_id:@"9ea93ba1e02e25e33cd708fb11359bd47e67d9db"  application:application iZootoInitSettings:iZootooInitSetting];
                    iZooto.landingURLDelegate = self ;
               
           }
       }
    dispatch_async(dispatch_get_main_queue(), ^{
   // initalise the iZooto SDK
   [iZooto initialisationWithIzooto_id:@"9ea93ba1e02e25e33cd708fb11359bd47e67d9db"  application:application iZootoInitSettings:iZootooInitSetting];
        iZooto.landingURLDelegate = self ;
       iZooto.notificationReceivedDelegate = self;
       iZooto.notificationOpenDelegate = self;
       
   });
   
    return YES;
}
- (void) ShowAlert:(NSString *)Message {
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:Message
//                                                    message:@"More info..."
//                                                   delegate:self
//                                          cancelButtonTitle:@"Cancel"
//                                          otherButtonTitles:@"Say Hello",nil];
//    [alert show];
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:Message message:Message preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

        }]];

        [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:alertController animated:YES completion:^{
        }];
    });
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
    NSLog(@"%@", url);
    [self ShowAlert:url];


    
}
 
- (void)onNotificationOpenWithAction:(NSDictionary<NSString *,id> * _Nonnull)action {
    NSLog(@"NSString = %@", action);
    [self ShowAlert:action];

 
}
 
 
- (void)onNotificationReceivedWithPayload:(Payload * _Nonnull)payload {
    NSLog(@"NSString = %@",payload);
 
}
 
@end
