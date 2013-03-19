//
//  ColorPickerController.h
//  testInkBrush1
//
//  Created by Chen Li on 9/3/10.
//  Copyright 2010 Chen Li. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ColorPickerController : UIViewController {
	IBOutlet UIImageView* imgView;
	UIColor* lastColor;
	id pickedColorDelegate;
}

@property (nonatomic,retain) IBOutlet UIImageView* imgView;
//@property (nonatomic, retain) UIColor* lastColor;
@property (assign) id pickedColorDelegate;

- (UIColor*) getPixelColorAtLocation:(CGPoint)point;
- (CGContextRef) createARGBBitmapContextFromImage:(CGImageRef)inImage;

@end
