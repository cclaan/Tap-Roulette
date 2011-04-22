//
//  PFInfoController.h
//  OddFingerOut
//
//  Created by Chris Laan on 4/2/11.
//  Copyright 2011 Laan Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <MediaPlayer/MediaPlayer.h>
#import "MPMoviePlayerViewControllerL.h"


@interface PFInfoController : UIViewController {
	
	IBOutlet UISegmentedControl * choiceSegment;
	MPMoviePlayerViewControllerL * moviePlayer;
	
}

@property (nonatomic, assign) id delegate;

-(IBAction) prefChanged;
-(IBAction) closeInfoClicked;
-(IBAction) playVideoClicked;

@end
