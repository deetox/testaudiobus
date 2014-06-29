//
//  AppDelegate.m
//  Instrumants
//
//  Created by Damien Le Troher on 28/06/2014.
//  Copyright (c) 2014 Damien Le Troher. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    
    self.audioEngine = [ABSenderAudioEngine new];
    
    
    return YES;
}
@end
