//
//  AppDelegate_iPad.m
//  TapRoulette
//
//  Created by Chris Laan on 4/3/11.
//  Copyright 2011 Laan Labs. All rights reserved.
//
#import "AppDelegate_iPad.h"
#import "EAGLView.h"

@implementation AppDelegate_iPad

@synthesize window;
@synthesize glView;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
    
	glView.animationInterval = 1.0 / 60.0;
	[glView startAnimation];
	
	

	if ( ![[NSUserDefaults standardUserDefaults] boolForKey:@"launchedApp"] ) {
		
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"useSuspensefulPick"];
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"launchedApp"];
		
	}
	
	//[self prefChanged];
	
	BOOL val = [[NSUserDefaults standardUserDefaults] boolForKey:@"useSuspensefulPick"];
	glView.useSuspensefulPick = val;
	
	[window makeKeyAndVisible];

	
	[self animateFingers];
	
	if ( ![[NSUserDefaults standardUserDefaults] boolForKey:@"hasShownIntro"] ) {
		
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasShownIntro"];
		[self performSelector:@selector(playVideo:) withObject:[[NSBundle mainBundle] pathForResource:@"demo" ofType:@"mov"] afterDelay:1.0];
		
	}
	
	
	
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
		[window addSubview:moviePlayer.view];
		
		
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
	
	
	[self performSelector:@selector(animateFingers) withObject:nil afterDelay:1.0];
	
	
}


-(void) animateFingers {
	
	[UIView beginAnimations:@"animateFingers" context:nil];
	[UIView setAnimationDuration:0.7];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(fingersAnimationDone)];
	CGPoint p = fingerImage1.center;
	p.x -= 250;
	p.y -= 250;
	fingerImage1.center = p;
	
	p = fingerImage2.center;
	p.x -= 250;
	p.y += 250;
	fingerImage2.center = p;
	
	p = fingerImage3.center;
	p.x += 240;
	p.y += 250;
	fingerImage3.center = p;
	
	p = fingerImage4.center;
	p.x += 300;
	//p.y -= 50;
	fingerImage4.center = p;
	
	p = fingerImage5.center;
	p.x += 240;
	p.y -= 250;
	fingerImage5.center = p;
	
	[UIView commitAnimations];
	
	
}

-(void) fingersAnimationDone {
	
	[fingerImage1 removeFromSuperview];
	[fingerImage2 removeFromSuperview];
	[fingerImage3 removeFromSuperview];
	[fingerImage4 removeFromSuperview];
	[fingerImage5 removeFromSuperview];
	
	//[fingerImage1 release];
	fingerImage1 = nil;
	fingerImage2 = nil;
	fingerImage3 = nil;
	fingerImage4 = nil;
	fingerImage5 = nil;
	
	
}

-(void) showIntroAlert {
	
	UIAlertView * al = [[UIAlertView alloc] initWithTitle:@"Welcome Message" message:@"To play, simply get each person to put a finger on the screen and use a free hand to click the pick finger button. The iPhone only supports 5 fingers! Sorry." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
	[al show];
	[al release];
	
	[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasShownIntro"];
	
}

-(IBAction) infoClicked {
	
	if ( !infoController ) {
		
		infoController = [[PFInfoController alloc] init];
		infoController.view.frame = window.bounds;
		infoController.delegate = self;
	}
	
	[self showInfo];
}

-(IBAction) closeInfoClicked {
	[self hideInfo];
	
}

-(void) pickClicked {
	
	[glView pickClicked];
	
	
}

//-(IBAction) prefChanged {

-(void) prefChangedWithIndex:(NSNumber*)ind {
	
	int val = [ind intValue];
	
	if ( val == 0 ) {
		glView.useSuspensefulPick = YES;
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"useSuspensefulPick"];
	} else {
		glView.useSuspensefulPick = NO;
		[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"useSuspensefulPick"];
	}
	//BOOL val = [[NSUserDefaults standardUserDefaults] boolForKey:@"useSuspensefulPick"];
	
}

-(void) showInfo {
	
	
	[UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.75];
    //[UIView setAnimationDelegate:self];
    //[UIView setAnimationDidStopSelector:@selector(transitionDidStop:finished:context:)];
	
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:window cache:YES];
	
	[glView removeFromSuperview];
	[window addSubview:infoController.view];
	
	[UIView commitAnimations];
	//mapViewIsVisible=!mapViewIsVisible;
}

-(void) hideInfo {
	
	
	[UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.75];
    //[UIView setAnimationDelegate:self];
    //[UIView setAnimationDidStopSelector:@selector(transitionDidStop:finished:context:)];
	
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:window cache:YES];
	
	[infoController.view removeFromSuperview];
	[window addSubview:glView];
	
	[UIView commitAnimations];
	
	
}



- (void)applicationWillResignActive:(UIApplication *)application {
	glView.animationInterval = 1.0 / 5.0;
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
	glView.animationInterval = 1.0 / 60.0;
}


- (void)dealloc {
	[window release];
	[glView release];
	[super dealloc];
}

@end