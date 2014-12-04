//
//  AppDelegate.m
//  TestBeacon
//
//  Created by 亓鑫 on 14/12/2.
//  Copyright (c) 2014年 亓鑫. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //1.创建消息上面要添加的动作(按钮的形式显示出来)
    UIMutableUserNotificationAction *action = [[UIMutableUserNotificationAction alloc] init];
    action.identifier = @"action";//按钮的标示
    action.title=@"芝麻开门";//按钮的标题
    action.activationMode = UIUserNotificationActivationModeBackground;//当点击的时候启动程序
    
    UIMutableUserNotificationAction *action2 = [[UIMutableUserNotificationAction alloc] init];
    action2.identifier = @"action2";
    action2.title=@"芝麻不开";
    action2.activationMode = UIUserNotificationActivationModeBackground;//当点击的时候不启动程序，在后台处理
    
    
    //2.创建动作(按钮)的类别集合
    UIMutableUserNotificationCategory *categorys = [[UIMutableUserNotificationCategory alloc] init];
    categorys.identifier = @"Beacon";//这组动作的唯一标示,推送通知的时候也是根据这个来区分
    [categorys setActions:@[action,action2]
               forContext:UIUserNotificationActionContextDefault];
    
    
    
    UIUserNotificationSettings *notiSettings =
    [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge | UIUserNotificationTypeAlert | UIUserNotificationTypeSound)
                                      categories:[NSSet setWithObjects:categorys, nil]];
    
    [[UIApplication sharedApplication] registerUserNotificationSettings:notiSettings];

    
    return YES;
}


@end
