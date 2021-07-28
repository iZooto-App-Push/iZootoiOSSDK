#import "NotificationService.h"
 
@interface NotificationService ()
 
@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;
@property (nonatomic, strong) UNNotificationRequest *receivedRequest;
 
@end
 
@implementation NotificationService
 
- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
    self.contentHandler = contentHandler;
    self.receivedRequest = request;
    self.bestAttemptContent = [request.content mutableCopy];
    if (self.bestAttemptContent != nil)
    {
        [iZooto didReceiveNotificationExtensionRequestWithBundleName:@"com.iZooto.ObjectiveCExample" request:self.receivedRequest bestAttemptContent:self.bestAttemptContent contentHandler: self.contentHandler];
    }
}
 
- (void)serviceExtensionTimeWillExpire {
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    self.contentHandler(self.bestAttemptContent);
}
 
@end
