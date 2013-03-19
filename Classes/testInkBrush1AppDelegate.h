//
//  testInkBrush1AppDelegate.h
//  testInkBrush1
//
//  Created by Chen Li on 9/2/10.
//  Copyright Chen Li 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class testInkBrush1ViewController;

@interface testInkBrush1AppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    testInkBrush1ViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet testInkBrush1ViewController *viewController;

@end

