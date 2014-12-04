iBeacon-Demo
============

苹果SDK增加CoreLocation增加扫描Beacon的方法,做个Demo记录下


注意事项
------------

1.@import CoreLocation;

2.info.plist定位授权
增加NSLocationWhenInUseUsageDescription,NSLocationAlwaysUsageDescription

3.确定手机蓝牙是开启状态(非常重要)



创建一个要扫描的Beacon
-------------

    //测试的设备是GhostyuBeacon
    //这个UUID必须要与iBeacon设备的uuid一致,否则扫描不到,identifier填一个自己喜欢的
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:@"E2C56DB5-DFFB-48D2-B060-D0F5A71096E0"];
    self.targetBeaconRegion =
    [[CLBeaconRegion alloc] initWithProximityUUID:uuid
                                       identifier:[uuid UUIDString]];
    self.targetBeaconRegion.notifyOnEntry = YES;//进入beacon范围是否有通知
    self.targetBeaconRegion.notifyOnExit = YES;//离开beacon范围是否有通知
    self.targetBeaconRegion.notifyEntryStateOnDisplay = YES;//在屏幕点亮时,是否有通知(开启这个可以在锁屏界面扫描beacon,不信去看log)


扫描Beacon
---------------

    self.manager = [[CLLocationManager alloc] init];
    self.manager.distanceFilter = 500;
    self.manager.desiredAccuracy = 100;
    self.manager.delegate = self;
    [self.manager startRangingBeaconsInRegion:self.targetBeaconRegion];



判断定位授权,适配iOS8
----------------

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



Beacon代理回调
------------------------

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
          }
    }
