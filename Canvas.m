//
//  Canvas.m
//  testInkBrush1
//
//  Created by Chen Li on 9/2/10.
//  Copyright 2010 Chen Li. All rights reserved.
//

// For the purpose of demo, I just made this view working. 
// However, in terms of design, we can improve this by better seperate M&V, 
// which means the data such as arrayStrokes should be managed by a model class. 

#import "testInkBrush1ViewController.h"
#import "Canvas.h"
#import "ColorPickerController.h"
#import "FBConnect.h"
#import "FBRequest.h"

static NSString* kAppId = @"111832852208394";

#pragma mark Canvas
@implementation Canvas

@synthesize pickedImage,screenImage,arrayStrokes,arrayAbandonedStrokes,currentColor,currentSize;
@synthesize sliderSize,buttonColor,toolBar,labelSize;
@synthesize owner;

-(BOOL)isMultipleTouchEnabled {
	return NO;
}

-(void) viewJustLoaded {
	NSLog(@"viewJustLoaded");
	
	// color picker and popover
	colorPC = [[ColorPickerController alloc] init];
	colorPC.pickedColorDelegate = self;
	colorPopoverController = [[UIPopoverController alloc] initWithContentViewController:colorPC];
	[colorPopoverController setPopoverContentSize:colorPC.view.frame.size];
	
	// share view controller and popover
	shareVC = [[ShareViewController alloc] init];
	shareVC.delegate = self;
	sharePopoverController = [[UIPopoverController alloc] initWithContentViewController:shareVC];
	[sharePopoverController setPopoverContentSize:shareVC.view.frame.size];
	
	// image picker and popover
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
		imagePC = [[UIImagePickerController alloc] init];
		imagePC.delegate = self;
		imagePC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
		imagePopoverController = [[UIPopoverController alloc] initWithContentViewController:imagePC];
		//[imagePopoverController setPopoverContentSize:imagePC.view.frame.size];
	}
	
	self.arrayStrokes = [NSMutableArray array];
	self.arrayAbandonedStrokes = [NSMutableArray array];
	self.currentSize = 5.0;
	self.labelSize.text = @"Size: 5";
	[self setColor:[UIColor blackColor]];
	activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	activityIndicator.center = CGPointMake(512, 384);
	
	facebook = [[Facebook alloc] init];
	permissions =  [[NSArray arrayWithObjects: 
                      @"read_stream", @"offline_access",nil] retain];
	isLoggedIn = NO;
	//shareVC.buttonLog.titleLabel.text = @"Facebook Log In";
	[shareVC.buttonLog setTitle:@"Facebook Log In" forState:UIControlStateNormal];
	[shareVC.buttonLog setTitle:@"Facebook Log In" forState:UIControlStateHighlighted | UIControlStateSelected];
	shareVC.buttonUpload.enabled = NO;
	shareVC.buttonUpload.hidden = YES;
}

-(IBAction) setBrushSize:(UISlider*)sender {
	currentSize = sender.value;
	self.labelSize.text = [NSString stringWithFormat:@"Size: %.0f",sender.value];
}

-(void) setColor:(UIColor*)theColor {
	self.buttonColor.backgroundColor = theColor;
	self.currentColor = theColor;
}

// The implementation of eraser is dirty here: simply use a white pen
-(IBAction) eraser {
	[self setColor:[UIColor whiteColor]];
}

- (IBAction) didClickColorButton {
	[colorPopoverController presentPopoverFromRect:CGRectMake(435, 700, 30, 30) inView:self permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void) pickedColor:(UIColor*)color {
	NSLog(@"pickedColor");
	[colorPopoverController dismissPopoverAnimated:YES];
	[self setColor:color];
}

// Start new dictionary for each touch, with points and color
- (void) touchesBegan:(NSSet *) touches withEvent:(UIEvent *) event
{
	
	NSMutableArray *arrayPointsInStroke = [NSMutableArray array];
	NSMutableDictionary *dictStroke = [NSMutableDictionary dictionary];
	[dictStroke setObject:arrayPointsInStroke forKey:@"points"];
	[dictStroke setObject:self.currentColor forKey:@"color"];
	[dictStroke setObject:[NSNumber numberWithFloat:self.currentSize] forKey:@"size"];
	
	CGPoint point = [[touches anyObject] locationInView:self];
	[arrayPointsInStroke addObject:NSStringFromCGPoint(point)];
	
	[self.arrayStrokes addObject:dictStroke];
}

// Add each point to points array
- (void) touchesMoved:(NSSet *) touches withEvent:(UIEvent *) event
{
	CGPoint point = [[touches anyObject] locationInView:self];
	CGPoint prevPoint = [[touches anyObject] previousLocationInView:self];
	NSMutableArray *arrayPointsInStroke = [[self.arrayStrokes lastObject] objectForKey:@"points"];
	[arrayPointsInStroke addObject:NSStringFromCGPoint(point)];
	
	CGRect rectToRedraw = CGRectMake(\
									 ((prevPoint.x>point.x)?point.x:prevPoint.x)-currentSize,\
									 ((prevPoint.y>point.y)?point.y:prevPoint.y)-currentSize,\
									 fabs(point.x-prevPoint.x)+2*currentSize,\
									 fabs(point.y-prevPoint.y)+2*currentSize\
									 );
	[self setNeedsDisplayInRect:rectToRedraw];
	//[self setNeedsDisplay];
}

// Send over new trace when the touch ends
- (void) touchesEnded:(NSSet *) touches withEvent:(UIEvent *) event
{
	[self.arrayAbandonedStrokes removeAllObjects];
}

// Draw all points, foreign and domestic, to the screen
- (void) drawRect: (CGRect) rect
{	
	int width = self.pickedImage.size.width;
	int height = self.pickedImage.size.height;
	CGRect rectForImage = CGRectMake(512-width/2, 384-height/2, width, height);
	[self.pickedImage drawInRect:rectForImage];
	
	if (self.arrayStrokes)
	{
		int arraynum = 0;
		// each iteration draw a stroke
		// line segments within a single stroke (path) has the same color and line width
		for (NSDictionary *dictStroke in self.arrayStrokes)
		{
			NSArray *arrayPointsInstroke = [dictStroke objectForKey:@"points"];
			UIColor *color = [dictStroke objectForKey:@"color"];
			float size = [[dictStroke objectForKey:@"size"] floatValue];
			[color set];		// equivalent to both setFill and setStroke
			
//			// won't draw a line which is too short
//			if (arrayPointsInstroke.count < 3)	{
//				arraynum++; 
//				continue;		// if continue is executed, the program jumps to the next dictStroke
//			}
			
			// draw the stroke, line by line, with rounded joints
			UIBezierPath* pathLines = [UIBezierPath bezierPath];
			CGPoint pointStart = CGPointFromString([arrayPointsInstroke objectAtIndex:0]);
			[pathLines moveToPoint:pointStart];
			for (int i = 0; i < (arrayPointsInstroke.count - 1); i++)
			{
				CGPoint pointNext = CGPointFromString([arrayPointsInstroke objectAtIndex:i+1]);
				[pathLines addLineToPoint:pointNext];
			}
			pathLines.lineWidth = size;
			pathLines.lineJoinStyle = kCGLineJoinRound;
			pathLines.lineCapStyle = kCGLineCapRound;
			[pathLines stroke];
			
			arraynum++;
		}
	}
}

-(IBAction) didClickChoosePhoto {
	[imagePopoverController presentPopoverFromRect:CGRectMake(490, 700, 30, 30)\
											inView:self permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

-(void) imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary*)info {
	self.pickedImage = [info valueForKey:@"UIImagePickerControllerOriginalImage"];
	
	[imagePopoverController dismissPopoverAnimated:YES];
	
	[self setNeedsDisplay];
}

-(IBAction) undo {
	if ([arrayStrokes count]>0) {
		NSMutableDictionary* dictAbandonedStroke = [arrayStrokes lastObject];
		[self.arrayAbandonedStrokes addObject:dictAbandonedStroke];
		[self.arrayStrokes removeLastObject];
		[self setNeedsDisplay];
	}
}

-(IBAction) redo {
	if ([arrayAbandonedStrokes count]>0) {
		NSMutableDictionary* dictReusedStroke = [arrayAbandonedStrokes lastObject];
		[self.arrayStrokes addObject:dictReusedStroke];
		[self.arrayAbandonedStrokes removeLastObject];
		[self setNeedsDisplay];
	}
}

-(IBAction) clearCanvas {
	self.pickedImage = nil;
	[self.arrayStrokes removeAllObjects];
	[self.arrayAbandonedStrokes removeAllObjects];
	[self setNeedsDisplay];
}

-(IBAction) savePic {
	// remove toolbar temporarily
	[self.toolBar removeFromSuperview];
	
	UIGraphicsBeginImageContext(self.bounds.size);
	[self.layer renderInContext:UIGraphicsGetCurrentContext()];
	self.screenImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	// add toolbar back
	[self addSubview:toolBar];
	[self bringSubviewToFront:self.labelSize];
	
	// add activityIndicator
	[self addSubview:activityIndicator];
	[activityIndicator startAnimating];
	
	[self performSelector:@selector(saveToPhoto) withObject:nil afterDelay:0.0];
}

-(void) saveToPhoto {
	// save to photo album
	UIImageWriteToSavedPhotosAlbum(self.screenImage, nil, nil, nil);
	
	// stop activityIndicator
	[activityIndicator stopAnimating];
	[activityIndicator removeFromSuperview];
	
	// show alert
	UIAlertView* alertSheet = [[UIAlertView alloc] initWithTitle:nil message:@"Image Saved" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alertSheet show];
	[alertSheet release];
}

-(IBAction) didClickShare {
	[sharePopoverController presentPopoverFromRect:CGRectMake(960, 700, 30, 30) inView:self permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

-(void) didClickEmail {
	if ([MFMailComposeViewController canSendMail]) {
		MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
		picker.mailComposeDelegate = owner;
		
		[picker setSubject:@"My own paintings with iPad! "];
		
		[toolBar removeFromSuperview];
		UIGraphicsBeginImageContext(self.bounds.size);
		[self.layer renderInContext:UIGraphicsGetCurrentContext()];
		UIImage *imageScreen = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		[self addSubview:toolBar];
		[self bringSubviewToFront:self.labelSize];
		
		// Attach an image to the email
		NSData* imageData = UIImageJPEGRepresentation(imageScreen, 0.8);
		[picker addAttachmentData:imageData mimeType:@"image/png" fileName:@"rainy"];
		
		NSString *emailBody = @"Hey, <br /> <br /> \
		I painted this image with an iPad app called \"Draw Pad\"!";
		[picker setMessageBody:emailBody isHTML:YES];
		
		[owner presentModalViewController:picker animated:YES];
		[picker release];
	}
}

-(void) didClickLog {
	if (!isLoggedIn) {
		[self logIn];
	}
	else {
		[self logOut];
	}
}

-(void) logIn {
	[self addSubview:activityIndicator];
	[activityIndicator startAnimating];
	[facebook authorize:kAppId permissions:permissions delegate:self];
}

-(void) logOut {
	[facebook logout:self];
}

-(void) didClickUpload {
	[toolBar removeFromSuperview];
	UIGraphicsBeginImageContext(self.bounds.size);
	[self.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *imageScreen = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	[self addSubview:toolBar];
	[self bringSubviewToFront:self.labelSize];
	
	[self addSubview:activityIndicator];
	[activityIndicator startAnimating];
	
	NSMutableDictionary * params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
									imageScreen, @"Doodle Pad HD picture",
									nil];
	[facebook requestWithMethodName: @"photos.upload" 
						  andParams: params
					  andHttpMethod: @"POST" 
						andDelegate: self]; 
}

-(void) fbDidLogin {
	NSLog(@"fbDidLogin");
	[activityIndicator stopAnimating];
	[activityIndicator removeFromSuperview];
	isLoggedIn = YES;
	//shareVC.buttonLog.titleLabel.text = @"Facebook Log Out";
	[shareVC.buttonLog setTitle:@"Facebook Log Out" forState:UIControlStateNormal];
	[shareVC.buttonLog setTitle:@"Facebook Log Out" forState:UIControlStateHighlighted | UIControlStateSelected];
	shareVC.buttonUpload.enabled = YES;
	shareVC.buttonUpload.hidden = NO;
}

-(void) fbDidLogout {
	NSLog(@"fbDidLogout");
	isLoggedIn = NO;
	//shareVC.buttonLog.titleLabel.text = @"Facebook Log In";
	[shareVC.buttonLog setTitle:@"Facebook Log In" forState:UIControlStateNormal];
	[shareVC.buttonLog setTitle:@"Facebook Log In" forState:UIControlStateHighlighted | UIControlStateSelected];
	shareVC.buttonUpload.enabled = NO;
	shareVC.buttonUpload.hidden = YES;
}

-(void) didClickCancel {
	[sharePopoverController dismissPopoverAnimated:YES];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// FBRequestDelegate

/**
 * Callback when a request receives Response
 */ 
- (void)request:(FBRequest*)request didReceiveResponse:(NSURLResponse*)response{
	NSLog(@"received response");
	[activityIndicator stopAnimating];
	[activityIndicator removeFromSuperview];
};

/**
 * Called when an error prevents the request from completing successfully.
 */
- (void)request:(FBRequest*)request didFailWithError:(NSError*)error{
	NSLog([NSString stringWithFormat:@"%@",[error localizedDescription]]);
};

/**
 * Called when a request returns and its response has been parsed into an object.
 * The resulting object may be a dictionary, an array, a string, or a number, depending
 * on thee format of the API response.
 */
- (void)request:(FBRequest*)request didLoad:(id)result {
	if ([result isKindOfClass:[NSArray class]]) {
		result = [result objectAtIndex:0]; 
	}
	if ([result objectForKey:@"owner"]) {
		NSLog(@"Photo upload Success");
		UIAlertView* alertSheet = [[UIAlertView alloc] initWithTitle:nil message:@"Image Uploaded to Facebook!"\
															delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alertSheet show];
		[alertSheet release];
	} else {
		NSLog([NSString stringWithFormat:@"%@",[result objectForKey:@"name"]]);
	}
};

-(void)dealloc {
	[pickedImage release];
	[screenImage release];
	[arrayStrokes release];
	[arrayAbandonedStrokes release];
	[currentColor release];
	[sliderSize release];
	[buttonColor release];
	[toolBar release];
	[labelSize release];
	[colorPC release];
	[colorPopoverController release];
	[shareVC release];
	[sharePopoverController release];
	[imagePC release];
	[imagePopoverController release];
	[activityIndicator release];
	[facebook release];
	[permissions release];
	[super dealloc];
}

@end
