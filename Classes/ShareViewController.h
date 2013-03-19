//
//  ShareViewController.h
//  testInkBrush1
//
//  Created by Chen Li on 9/4/10.
//  Copyright 2010 Chen Li. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ShareViewControllerDelegate

-(void) didClickEmail;
-(void) didClickLog;
-(void) didClickUpload;
-(void) didClickCancel;

@end

@interface ShareViewController : UIViewController {
	id<ShareViewControllerDelegate> delegate;
	IBOutlet UIButton* buttonLog;
	IBOutlet UIButton* buttonUpload;
}	

@property (nonatomic,retain) IBOutlet UIButton* buttonLog;
@property (nonatomic,retain) IBOutlet UIButton* buttonUpload;
@property (assign) id delegate;

-(IBAction) didClickEmail;
-(IBAction) didClickLog;
-(IBAction) didClickUpload;
-(IBAction) didClickCancel;

@end
