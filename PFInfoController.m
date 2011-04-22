//
//  PFInfoController.m
//  OddFingerOut
//
//  Created by Chris Laan on 4/2/11.
//  Copyright 2011 Laan Labs. All rights reserved.
//

#import "PFInfoController.h"


@implementation PFInfoController

@synthesize delegate;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	BOOL val = [[NSUserDefaults standardUserDefaults] boolForKey:@"useSuspensefulPick"];
	
	if ( val ) {
		choiceSegment.selectedSegmentIndex = 0;
	} else {
		choiceSegment.selectedSegmentIndex = 1;
	}
	
}

-(IBAction) prefChanged {

	
	[delegate prefChangedWithIndex:[NSNumber numberWithInt:choiceSegment.selectedSegmentIndex]];
	
	
}


-(IBAction) closeInfoClicked {
	
	[delegate closeInfoClicked];
	
	
}


-(IBAction) playVideoClicked {
	
	[self playVideo:[[NSBundle mainBundle] pathForResource:@"demo" ofType:@"mov"]];
	
}

-(void) playVideo:(NSString*) name  {
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	if (  ![fileManager fileExistsAtPath:name] ) {
		
		NSLog(@"Cant find video file");
		return;
		
	}
	
	NSURL * fileUrl = [NSURL fileURLWithPath:name];
	
	if ( ([[[UIDevice currentDevice] systemVersion] floatValue] >= 4.0 ) ) {
		
		moviePlayer = [[MPMoviePlayerViewControllerL alloc] initWithContentURL:fileUrl];
		[self.view addSubview:moviePlayer.view];
		
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(myMovieFinishedCallback2:) 
													 name:MPMoviePlayerPlaybackDidFinishNotification 
												   object:moviePlayer.moviePlayer]; 
		
		//[[UIApplication sharedApplication] setStatusBarHidden:YES animated:YES];  
		
	} 
} 


// When the movie is done,release the controller. 
-(void)myMovieFinishedCallback2:(NSNotification*)aNotification 
{
	
	[moviePlayer.view removeFromSuperview];
	[moviePlayer release];
	moviePlayer = nil;
	
	[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
	
	
}



/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
