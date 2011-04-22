//
//  AppDelegate_iPhone.h
//  TapRoulette
//
//  Created by Chris Laan on 4/3/11.
//  Copyright 2011 Laan Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InfoController.h"
#import "PFInfoController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "MPMoviePlayerViewControllerL.h"

@class EAGLView;

@interface AppDelegate_iPhone : NSObject <UIApplicationDelegate> {
    
	UIWindow *window;
    EAGLView *glView;
	
	PFInfoController * infoController;
	
	IBOutlet UIImageView * fingerImage1;
	IBOutlet UIImageView * fingerImage2;
	IBOutlet UIImageView * fingerImage3;
	IBOutlet UIImageView * fingerImage4;
	IBOutlet UIImageView * fingerImage5;
	
	MPMoviePlayerViewControllerL * moviePlayer;
	
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet EAGLView *glView;

-(IBAction) pickClicked;

-(IBAction) infoClicked;

-(IBAction) closeInfoClicked;

-(void) prefChangedWithIndex:(NSNumber*)ind;

@end

