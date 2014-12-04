//
//  ViewController.m
//  TestBeacon
//
//  Created by 亓鑫 on 14/12/2.
//  Copyright (c) 2014年 亓鑫. All rights reserved.
//

#import "ViewController.h"
#import <objc/runtime.h>

@import CoreLocation;
@import AudioToolbox;

@interface ViewController () <CLLocationManagerDelegate>
@property (strong, nonatomic) CLLocationManager *manager;
@property (strong, nonatomic) CLBeaconRegion *targetBeaconRegion;
@property (weak, nonatomic) IBOutlet UITextView *showResultView;
@property (weak, nonatomic) IBOutlet UIButton *gpsButton;
@end

@implementation ViewController







- (void)start
{
    //[self.manager startUpdatingLocation];
    [self.manager startRangingBeaconsInRegion:self.targetBeaconRegion];
    [self.gpsButton setTitle:@"取消定位" forState:UIControlStateNormal];
    self.gpsButton.selected = YES;
}

-(void)stop
{
    //[self.manager stopUpdatingLocation];
    [self.manager stopRangingBeaconsInRegion:self.targetBeaconRegion];
    [self.gpsButton setTitle:@"开始定位" forState:UIControlStateNormal];
    self.gpsButton.selected = NO;
}





- (IBAction)onClick:(UIButton *)sender
{
    if ([CLLocationManager locationServicesEnabled])
    {
        if (([CLLocationManager authorizationStatus]==kCLAuthorizationStatusAuthorizedWhenInUse ||
            [CLLocationManager authorizationStatus]==kCLAuthorizationStatusAuthorizedAlways) &&
            [self.manager respondsToSelector:@selector(requestAlwaysAuthorization)])
        {
            [self.manager requestAlwaysAuthorization];
            if (sender.selected)
            {
                [self stop];
            }
            else
            {
                [self start];
            }
        }
    }
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.manager = [[CLLocationManager alloc] init];
    self.manager.distanceFilter = 500;
    self.manager.desiredAccuracy = 100;
    self.manager.delegate = self;
    
    //GhostyuBeacon
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:@"E2C56DB5-DFFB-48D2-B060-D0F5A71096E0"];
    self.targetBeaconRegion =
    [[CLBeaconRegion alloc] initWithProximityUUID:uuid
                                       identifier:[uuid UUIDString]];
    self.targetBeaconRegion.notifyOnEntry = YES;
    self.targetBeaconRegion.notifyOnExit = YES;
    self.targetBeaconRegion.notifyEntryStateOnDisplay = YES;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}




#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    NSLog(@"定位失败!");
}

//MARK:定位回调
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations
{
    CLLocation *location = [locations lastObject];
    NSLog(@"longitude:%f  latitude:%f",location.coordinate.longitude,location.coordinate.latitude);
    CLGeocoder *geo = [[CLGeocoder alloc] init];
    [geo reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *place = [placemarks lastObject];

        NSMutableString *str = [[NSMutableString alloc] init];
        [str appendFormat:@"longitude:%f  latitude:%f\n",location.coordinate.longitude,location.coordinate.latitude];
        unsigned int count;
        objc_property_t *properties = class_copyPropertyList([CLPlacemark class], &count);
        for (int i=0; i<count; i++)
        {
            objc_property_t property = properties[i];
            NSString *key = [NSString stringWithCString:property_getName(property)
                                               encoding:NSUTF8StringEncoding];
            NSString *value = [place valueForKey:key];
            if ([value isKindOfClass:[NSString class]])
            {
                NSLog(@"%@=%@",key,value);
                [str appendFormat:@"%@=%@\n",key,value];
            }
        }
        self.showResultView.text = str;
    }];
}


//MARK: 定位授权变更
- (void)locationManager:(CLLocationManager *)manager
didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse ||
        status == kCLAuthorizationStatusAuthorizedAlways)
    {
        [self start];
    }
    else
    {
        [self stop];
    }
}








#pragma mark - Beacon
//MARK:Beacon回调
- (void)locationManager:(CLLocationManager *)manager
        didRangeBeacons:(NSArray *)beacons
               inRegion:(CLBeaconRegion *)region
{
    // Beacon found!
    NSLog(@"扫描Beacon!");
    CLBeacon *foundBeacon = [beacons firstObject];
    if (foundBeacon)
    {
        NSLog(@"扫描到Beacon!");
        // retrieve the beacon data from its properties
        NSString *uuid = foundBeacon.proximityUUID.UUIDString;
        NSString *major = [NSString stringWithFormat:@"%@", foundBeacon.major];
        NSString *minor = [NSString stringWithFormat:@"%@", foundBeacon.minor];
        NSString *accuracy = [NSString stringWithFormat:@"%lf",foundBeacon.accuracy];
        NSString *proximity = [NSString stringWithFormat:@"%ld",foundBeacon.proximity];
        NSString *rssi = [NSString stringWithFormat:@"%ld",(long)foundBeacon.rssi];
        self.showResultView.text = [NSString stringWithFormat:@"uuid=%@\nmajor=%@\nminor=%@\naccuracy=%@\nproximity=%@\nrssi=%@",uuid,major,minor,accuracy,proximity,rssi];
        if (foundBeacon.proximity==CLProximityImmediate)
        {
            NSLog(@"近距离Beacon!!!");
            [self stop];
            NSString *showText = [NSString stringWithFormat:@"uuid=%@\nmajor=%@\nminor=%@\naccuracy=%@\nproximity=%@\nrssi=%@",uuid,major,minor,accuracy,proximity,rssi];
            AudioServicesPlaySystemSound(1051);
            
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Found Beacon" message:showText delegate:nil cancelButtonTitle:@"Done" otherButtonTitles:nil, nil];
            [alertView show];
            
            [self setLocalPush];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager
rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region
              withError:(NSError *)error
{
    //Beacon定位失败->可能是没开蓝牙
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Found Beacon" message:[error description] delegate:nil cancelButtonTitle:@"Done" otherButtonTitles:nil, nil];
    [alertView show];
}






//MARK:Region里面/外面
- (void)locationManager:(CLLocationManager *)manager
      didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    NSLog(@"didDetermineState=%ld",state);
}



#pragma mark - Region
- (void)locationManager:(CLLocationManager *)manager
         didEnterRegion:(CLRegion *)region
{
    NSLog(@"EnterRegion");
}

- (void)locationManager:(CLLocationManager *)manager
          didExitRegion:(CLRegion *)region
{
    NSLog(@"ExitRegion");
}
















- (void)setLocalPush
{
    //先干掉其他
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    UIApplication *app = [UIApplication sharedApplication];
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:1];
    UILocalNotification *noti = [[UILocalNotification alloc] init];
    if (noti)
    {
        noti.category = @"Beacon";
        noti.fireDate = date;
        noti.timeZone = [NSTimeZone defaultTimeZone];
        noti.repeatInterval = 0;
        noti.soundName = UILocalNotificationDefaultSoundName;
        noti.alertBody = @"您到家了,是否开门?";
        [app scheduleLocalNotification:noti];
    }
}


@end
