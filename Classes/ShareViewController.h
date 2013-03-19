//
//  ShareViewController.h
//  testInkBrush1
//
//  Created by Brick on 18/3/13.
//  Copyright 2013 Brick. All rights reserved.
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
