//
//  AppDelegate.h
//  Instrumants
//
//  Created by Damien Le Troher on 28/06/2014.
//  Copyright (c) 2014 Damien Le Troher. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ABSenderAudioEngine.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) ABSenderAudioEngine *audioEngine;

@end