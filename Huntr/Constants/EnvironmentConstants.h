//
//  EnvironmentConstants.h
//  Huntr
//
//  Created by Joy Tao on 4/21/16.
//  Copyright © 2016 SCS. All rights reserved.
//

#ifndef EnvironmentConstants_h
#define EnvironmentConstants_h

#define kAppWindow [[[UIApplication sharedApplication] delegate] window]

#define kDeviceUUID @"kDeviceUUID"

#define kApnsUserApproval @"kApnsUserApproval"

#define kApnsDeviceToken @"kDeviceTokenAPNS"
#define kApnsAlertEnabled @"kApnsAlertEnabled"
#define kApnsBadgeEnabled @"kApnsBadgeEnabled"
#define kApnsSoundEnabled @"kApnsSoundEnabled"

#define kJoinedGames @"kJoinedGames"

#define kCurrentGameId @"kCurrentGameId"
#define kCurrentTeamId @"kCurrentTeamId"

#define kPlayerGameDataStore @"kPlayerGameDataStore"

#define kCurrentPlayer @"kCurrentPlayer"
#define kCurrentPlayerName @"kCurrentPlayerName"
#define kCurrentPlayerId @"kCurrentPlayerId"

#define kGetCustomCamera @"kGetCustomCamera"

#define kGetTeamsSegueIdentifier @"GetTeamsSegueIdentifier"
#define kRegisterUserSegueIdentifier @"RegisterUserSegueIdentifier"
#define kUpdateUserSegueIdentifier @"UpdateUserSegueIdentifier"
#define kAddTeamSegueIdentifier @"AddTeamSegueIdentifier"
#define kGetGameSegueIdentifier @"GetGameSegueIdentifier"
#define kGetAnswerSegueIdentifer @"GetAnswerSegueIdentifer"
#define kGoToPicAnswerSegueIdentifier @"GoToPicAnswerSegueIdentifier"
#define kGoToLocAnswerSegueIdentifier @"GoToLocAnswerSegueIdentifier"

#define kGameProfileSegueIdentifier @"GameProfileSegueIdentifier"

/* Notification */
#define kDidRegisterForRemoteNotificationsWithDeviceToken @"DidRegisterForRemoteNotificationsWithDeviceToken"

#define SCSPushNotificationGameStatusUpdate @"SCSPushNotificationGameStatusUpdate"
#define SCSPushNotificationTeamStatusUpdate @"SCSPushNotificationTeamStatusUpdate"
#define SCSPushNotificationTeamStatusPlayerAdded @"SCSPushNotificationTeamStatusPlayerAdded"
#define SCSPushNotificationTeamStatusPlayerRemoved @"SCSPushNotificationTeamStatusPlayerRemoved"
#define SCSPushNotificationClueStatusUpdate @"SCSPushNotificationClueStatusUpdate"
#define SCSPushNotificationAnswerStatusUpdate @"SCSPushNotificationAnswerStatusUpdate"
#define SCSPushNotificationPlayerStatusUpdate @"SCSPushNotificationPlayerStatusUpdate"

#endif /* EnvironmentConstants_h */
