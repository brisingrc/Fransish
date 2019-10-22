//
//  AppDelegate.m
//  LearnLanguage
//
//  Created by Nguyen The Hung on 4/22/14.
//  Copyright (c) 2014 Nguyen The Hung. All rights reserved.
//

#import "AppDelegate.h"
#import "GlobalConstants.h"
#import "InitialViewController.h"

@implementation AppDelegate{
    NSMutableArray *arrayOfCatalogue;
    int bottomSpace;
}



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.

    
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    UINavigationController *navVC = [[UINavigationController alloc]init];
    navVC.navigationBarHidden = YES;
   
    bottomSpace = 0;
    
    [self makeArrayOfCatalogue];
    InitialViewController *view = [[InitialViewController alloc] init];
    view.arrayOfCatalogue = arrayOfCatalogue;
    [navVC setViewControllers:[NSArray arrayWithObject:view]];
    [self.window setRootViewController:navVC];
    
    
    return YES;
}


-(void)makeArrayOfCatalogue{
    arrayOfCatalogue = [[NSMutableArray alloc]init];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"catalogue" ofType:@"txt"];
    NSString *myText = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    NSArray *myArray = [myText componentsSeparatedByString:@"\n"];
    for (int i = 0; i < myArray.count; i++) {
        [arrayOfCatalogue addObject:myArray[i]];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}



- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
