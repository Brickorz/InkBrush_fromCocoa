//
//  ShareViewController.m
//  testInkBrush1
//
//  Created by Chen Li on 9/4/10.
//  Copyright 2010 Chen Li. All rights reserved.
//

#import "ShareViewController.h"
#import "Canvas.h"


@implementation ShareViewController

@synthesize delegate;
@synthesize buttonLog,buttonUpload;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(IBAction) didClickEmail {
	[self.delegate didClickEmail];
}

-(IBAction) didClickLog {
	[self.delegate didClickLog];
}

-(IBAction) didClickUpload {
	[self.delegate didClickUpload];
}


-(IBAction) didClickCancel {
	[self.delegate didClickCancel];
}

- (void)dealloc {
	[buttonLog release];
	[buttonUpload release];
    [super dealloc];
}


@end
