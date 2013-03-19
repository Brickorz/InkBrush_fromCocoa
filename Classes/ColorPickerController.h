//
//  ColorPickerController.h
//  testInkBrush1
//
//  Created by Brick on 18/3/13.
//  Copyright 2013 Brick. All rights reserved.
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
