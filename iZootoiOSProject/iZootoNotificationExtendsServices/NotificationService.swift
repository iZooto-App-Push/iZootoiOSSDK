import UserNotifications
import iZootoiOSSDK
class NotificationService: UNNotificationServiceExtension {
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    var receivedRequest: UNNotificationRequest!
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
           self.receivedRequest = request;
           self.contentHandler = contentHandler
           bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
           if let bestAttemptContent = bestAttemptContent {
           iZooto.didReceiveNotificationExtensionRequest(request: receivedRequest, bestAttemptContent: bestAttemptContent,contentHandler: contentHandler)
           // bestAttemptContent.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "pikachu.mp3"))

       }

       }
       override func serviceExtensionTimeWillExpire() {
           if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
           // iZooto.didReceiveNotificationExtensionRequest(request: receivedRequest, bestAttemptContent: bestAttemptContent,contentHandler: contentHandler)
               contentHandler(bestAttemptContent)
           }
       }

}
