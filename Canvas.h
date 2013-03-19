//
//  Canvas.h
//  testInkBrush1
//
//  Created by Chen Li on 9/2/10.
//  Copyright 2010 Chen Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBConnect.h"
#import "ShareViewController.h"

@class ColorPickerController;

@interface Canvas : UIView 
<FBRequestDelegate,FBDialogDelegate,FBSessionDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate, ShareViewControllerDelegate> {
	NSMutableArray* arrayStrokes;
	NSMutableArray* arrayAbandonedStrokes;
	UIColor* currentColor;
	float currentSize;
	UIImage* pickedImage;
	UIImage* screenImage;
	
	IBOutlet UISlider* sliderSize;
	IBOutlet UIButton* buttonColor;
	IBOutlet UIToolbar* toolBar;
	IBOutlet UILabel* labelSize;
	
	ColorPickerController* colorPC;
	UIPopoverController* colorPopoverController;
	ShareViewController* shareVC;
	UIPopoverController* sharePopoverController;
	UIImagePickerController* imagePC;
	UIPopoverController* imagePopoverController;
	UIActivityIndicatorView* activityIndicator;
	
	Facebook* facebook;
	NSArray* permissions;
	BOOL isLoggedIn;
	
	id owner;
}

@property (retain) UIImage* pickedImage;
@property (retain) UIImage* screenImage;
@property (retain) NSMutableArray* arrayStrokes;
@property (retain) NSMutableArray* arrayAbandonedStrokes;
@property (retain) UIColor* currentColor;
@property float currentSize;

@property (nonatomic,retain) IBOutlet UISlider* sliderSize;
@property (nonatomic,retain) IBOutlet UIButton* buttonColor;
@property (nonatomic,retain) IBOutlet UIToolbar* toolBar;
@property (nonatomic,retain) IBOutlet UILabel* labelSize;

@property (assign) id owner;

-(void) viewJustLoaded;

-(IBAction) didClickChoosePhoto;
-(IBAction) setBrushSize:(UISlider*)sender;
-(void) setColor:(UIColor*)theColor;
-(IBAction) eraser;
-(IBAction) undo;
-(IBAction) redo;
-(IBAction) clearCanvas;
-(IBAction) savePic;
-(void) saveToPhoto;

- (IBAction) didClickColorButton;
- (void) pickedColor:(UIColor*)color;

-(IBAction) didClickShare;
-(void) logIn;
-(void) logOut;

@end
