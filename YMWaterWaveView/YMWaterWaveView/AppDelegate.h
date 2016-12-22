//
//  AppDelegate.h
//  YMWaterWaveView
//
//  Created by Jack on 2016/12/22.
//  Copyright © 2016年 Jack. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

