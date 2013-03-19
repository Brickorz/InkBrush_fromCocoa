//
//  testInkBrush1AppDelegate.h
//  testInkBrush1
//
//  Created by Brick on 17/3/13.
//  Copyright Brick 2013. All rights reserved.
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

