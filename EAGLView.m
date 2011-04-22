//
//  EAGLView.m
//  OddFingerOut
//
//  Created by cclaan on 5/24/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//



#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>

#import "EAGLView.h"

#define USE_DEPTH_BUFFER 0

// A class extension to declare private methods
@interface EAGLView ()

@property (nonatomic, retain) EAGLContext *context;
@property (nonatomic, assign) NSTimer *animationTimer;

- (BOOL) createFramebuffer;
- (void) destroyFramebuffer;

-(void) drawPointsCircleAtPoint:(CGPoint)p withRadius:(float) r;
-(void) drawCircleAtPoint:(CGPoint)p withRadius:(float) r;

@end


@implementation EAGLView

@synthesize context;
@synthesize animationTimer;
@synthesize animationInterval;

@synthesize useSuspensefulPick;

// You must implement this method
+ (Class)layerClass {
    return [CAEAGLLayer class];
}


//The GL view is stored in the nib file. When it's unarchived it's sent -initWithCoder:
- (id)initWithCoder:(NSCoder*)coder {
    
    if ((self = [super initWithCoder:coder])) {
        // Get the layer
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        
        eaglLayer.opaque = YES;
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
        
        context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
        
        if (!context || ![EAGLContext setCurrentContext:context]) {
            [self release];
            return nil;
        }
		
		
		glEnable(GL_BLEND);
		glEnable(GL_SMOOTH);
		
		glEnable(GL_POINT_SMOOTH);
		
		NSString* filePath = [[NSBundle mainBundle] pathForResource:@"chooseSound" ofType:@"wav"];
		
		chooseSound = [[Sound alloc] initWithContentsOfFile: filePath];
		
		filePath = [[NSBundle mainBundle] pathForResource:@"clickSound" ofType:@"wav"];
		
		clickSound = [[Sound alloc] initWithContentsOfFile: filePath];
		
		filePath = [[NSBundle mainBundle] pathForResource:@"tickSound" ofType:@"wav"];
		tickSound = [[Sound alloc] initWithContentsOfFile: filePath];
		
		filePath = [[NSBundle mainBundle] pathForResource:@"touchUpSound2" ofType:@"wav"];
		touchUpSound = [[Sound alloc] initWithContentsOfFile: filePath];
		
		bgTexture = [[Texture2D alloc] initWithImage:[UIImage imageNamed:@"bg.png"]];
		
		activeTouches = [[NSMutableArray array] retain];
        touchesSet = [[NSMutableSet set] retain];
        animationInterval = 1.0 / 60.0;
		
    }
    return self;
}

-(void) pickClicked {
	
	
	int counter = [touchesSet count];
	
	if ( counter == 0 ) {
		[touchUpSound play];
		return;
		
	}
	
	isPicking = YES;
	
	
	//
	
	
	
	int rander = arc4random() % counter;
	
	NSLog(@"random: %i " , rander  );
	
	finger = rander;
	
	if ( useSuspensefulPick ) {
		isSpinningSuspensefully = YES;
	} else {
		isSpinningSuspensefully = NO;
		[chooseSound play];
		AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
	}
	
	totalSpinCount = 0;
	currentSpinCount = 0;
	spinInterval = 3;
	
	//NSLog(@"pick");
	
}

float offset = 0;
float radius = 35.;

-(void) drawPointsCircleAtPoint:(CGPoint)p withRadius:(float) r {
	
	int numPoints = 20;
	
	GLfloat circle[numPoints*2];
	
	float step = M_PI * 2. / numPoints;
	int t=0;
	
	for ( int i = 0; i < numPoints; i++ ) {
		
		circle[t++] = p.x + r * cosf( offset + i*step );
		circle[t++] = p.y + r * sinf( offset + i*step );
		
	}
	float rad = (self.frame.size.width / 35.5);
	glPointSize(rad);
	glVertexPointer(2, GL_FLOAT, 0, circle);
	glEnableClientState(GL_VERTEX_ARRAY);
	glDrawArrays(GL_POINTS, 0, numPoints);
	
}

-(void) drawPointsCircleAtPoint2:(CGPoint)p withRadius:(float) r {
	
	int numPoints = 40;
	
	GLfloat circle[numPoints*2];
	
	float step = M_PI * 2. / numPoints;
	int t=0;
	
	for ( int i = 0; i < numPoints; i++ ) {
		
		circle[t++] = p.x + r * cosf( offset + i*step );
		circle[t++] = p.y + r * sinf( offset + i*step );
		
	}
	
	glPointSize(3.0);
	glVertexPointer(2, GL_FLOAT, 0, circle);
	glEnableClientState(GL_VERTEX_ARRAY);
	glDrawArrays(GL_POINTS, 0, numPoints);
	
}

-(void) drawCircleAtPoint:(CGPoint)p withRadius:(float) r {
	
	int numPoints = 20;
	
	GLfloat circle[numPoints*2];
	
	float step = M_PI * 2. / numPoints;
	int t=0;
	
	for ( int i = 0; i < numPoints; i++ ) {
		
		circle[t++] = p.x + r * cosf(  i*step );
		circle[t++] = p.y + r * sinf(  i*step );
		
	}
	
	glPointSize(5.0);
	glVertexPointer(2, GL_FLOAT, 0, circle);
	glEnableClientState(GL_VERTEX_ARRAY);
	glDrawArrays(GL_TRIANGLE_FAN, 0, numPoints);
	
}

float stepper;

- (void)drawView {
    
    // Replace the implementation of this method to do your own custom drawing
    stepper += 0.2;
	
	offset+=0.06;
	
	//radius = 41. + 10. * sinf(offset*1.1);
    radius = (self.frame.size.width/7.8) + 10. * sinf(offset*1.1);
	
    [EAGLContext setCurrentContext:context];
    
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
    glViewport(0, 0, backingWidth, backingHeight);
    
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    //glOrthof(0.0f, 320.0f, 0.0f, 480.0f, -1.0f, 1.0f);
	glOrthof(0.0f, self.frame.size.width, 0.0f, self.frame.size.height, -1.0f, 1.0f);
    glMatrixMode(GL_MODELVIEW);
    //glRotatef(3.0f, 0.0f, 0.0f, 1.0f);
    
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
	glEnable(GL_BLEND);
	glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	
	glEnable(GL_TEXTURE_2D);
	glDisableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	//[bgTexture drawInRect:[UIScreen mainScreen].bounds];
	
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_COLOR_ARRAY);
	
	//glPointSize(70.0);
	
	glColor4f(0.2, 0.5, 0.95 , 1.0);
	
	NSArray * ts  = [touchesSet allObjects];
	
	
	int rr = 0;
	
	
	
		
	if ( isSpinningSuspensefully  ) {
		
		if (currentSpinCount > spinInterval) {
			
			int total = [touchesSet count];
			
			currentFinger++;
			
			if ( currentFinger >= total ) {
				currentFinger = 0;
			}
			
			currentSpinCount = 0 ;
			spinInterval = spinInterval * 1.2;
			[tickSound play];
			
		}
		
		currentSpinCount ++;
		totalSpinCount ++;
		
		if ( spinInterval > 30.0 && currentFinger == finger ) {
		//if ( totalSpinCount > 200 && currentFinger == finger ) {
			isSpinningSuspensefully = NO;
			currentFinger = finger;
			[chooseSound play];
			AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
			
		}
		
	} else {
		
		currentFinger = finger;
		
	}
		
	
	for ( UITouch * t in ts ) {
		
		
		
	
		CGPoint p = [t locationInView:self];
		p.y = self.frame.size.height - p.y;
		
		
		if ( isPicking &&  rr == currentFinger )  {
			
			float alpha = 0.0;
			
			for ( float u=4; u>0; u-=0.15 ) {
				
				float r1;
				float r2;
				
				if ( ( (int)round(stepper) ) % 2 == 0 ) {
					r1 = 0.95;
					r2 = 0.4;
				} else {
					r2 = 0.95;
					r1 = 0.4;
				}
				
				if ( isSpinningSuspensefully ) {
					//glColor4f( r1 , 132./255., 132./255. , alpha );
					glColor4f( 1.0 , 0.7, 0.0 , alpha/4 );
				} else {
					glColor4f( r1 , 32./255., 32./255. , alpha );
				}
				[self drawCircleAtPoint:p withRadius: radius*u ];
				
				u-=0.15;
				
				if ( isSpinningSuspensefully ) {
					glColor4f( 1.0 , 0.6, 0.0 , alpha/4 );
				} else {
					glColor4f( r2 ,0,0 , alpha );
				}
				
				[self drawCircleAtPoint:p withRadius: radius*u ];
				
				alpha += 0.1;
				
			}
			
			
			
			
		} else {
			
			glColor4f( 0,0,0 , 1.0);
			[self drawCircleAtPoint:p withRadius: radius+5 ];
			
			glColor4f(38./255., 194./255., 49./255. , 1.0);
			[self drawCircleAtPoint:p withRadius: radius ];
			
		}
		
		
		
		
		if ( isPicking &&  rr == currentFinger )  {
			
			//glColor4f( 255.  , 186./255., 0 , 0.8);
			//[self drawPointsCircleAtPoint:p withRadius:70];
			
		} else  {
			
			float rad = (self.frame.size.width / 4.5);
			glColor4f( 86./255.  , 240./255.,  97./255. , 0.8);
			[self drawPointsCircleAtPoint:p withRadius:rad];
			
		}
		
		
		
		
		//if ( isPicking &&  rr == finger )  {
		if ( isPicking &&  rr == currentFinger )  {
			
			//glColor4f( 1. , 0.0 ,  0.0 , 0.4);
			//[self drawPointsCircleAtPoint2:p withRadius:65];
			
		} else  {
			
			float rad = (self.frame.size.width / 4.92);
			glColor4f( 86./255.  , 240./255.,  97./255. , 0.4);
			[self drawPointsCircleAtPoint2:p withRadius:rad];
			
			
		}
		
		
		
		rr ++;
	}
	
   
    

	
	
	
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
    [context presentRenderbuffer:GL_RENDERBUFFER_OES];
}




#pragma mark Touches ....

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	

	
	[clickSound play];
	
	isPicking = NO;
	isSpinningSuspensefully = NO;
	
	if ( hasExceededTouches ) {
		[touchesSet removeAllObjects];
		hasExceededTouches = NO;
	}
	
	//UITouch * touch = [touches anyObject];
	
	//CGPoint pos = [touch locationInView:self];
	
	
	//touchesSet = [touchesSet unionSet:touches];
	//touchesSet = [touches copy];
	
	//[touchesSet removeAllObjects];
	[touchesSet unionSet:touches];
	NSLog(@"Touches began ");
	
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	
	//if ( [[event allTouches] count] != 1 ) return;
	//touchesSet = [touches copy];
	//[touchesSet removeAllObjects];
	//[touchesSet unionSet:touches];
	
	
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	
	NSLog(@"Touches ended ");
	
	isPicking = NO;
	isSpinningSuspensefully = NO;
	
	[touchesSet minusSet:touches];
	
	[touchUpSound play];
	
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	
	NSLog(@"Touches cancelled %i " , [touches count] );
	
	if ( [touches count] == 5 ) {
		hasExceededTouches = YES;
		[self pickClicked];
	}
	
	/*
	if ( [touches count] == 5 ) {
			
		if ( [[NSUserDefaults standardUserDefaults] boolForKey:@"hasMaxTouched"] ) {
			
			[self pickClicked];
			
		} else {
			
			[self showMaxTouchAlert];
			
		}
		
		
	}
	
	//touchesSet = [touches copy];
	isPicking = NO;
	
	[touchesSet minusSet:touches];
	*/
	
}

-(void) showMaxTouchAlert {
	
	UIAlertView * al = [[UIAlertView alloc] initWithTitle:@"Maximum Fingers" message:@"Sorry, the iphone only supports 5 touches, so if have 5 fingers down, your next click will choose the odd finger no matter where you touch.\n\n(This only displays once.)" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
	[al show];
	[al release];
	
	[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasMaxTouched"];
	
}






- (void)layoutSubviews {
    [EAGLContext setCurrentContext:context];
    [self destroyFramebuffer];
    [self createFramebuffer];
    [self drawView];
}


- (BOOL)createFramebuffer {
    
    glGenFramebuffersOES(1, &viewFramebuffer);
    glGenRenderbuffersOES(1, &viewRenderbuffer);
    
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
    [context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:(CAEAGLLayer*)self.layer];
    glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, viewRenderbuffer);
    
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &backingWidth);
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &backingHeight);
    
    if (USE_DEPTH_BUFFER) {
        glGenRenderbuffersOES(1, &depthRenderbuffer);
        glBindRenderbufferOES(GL_RENDERBUFFER_OES, depthRenderbuffer);
        glRenderbufferStorageOES(GL_RENDERBUFFER_OES, GL_DEPTH_COMPONENT16_OES, backingWidth, backingHeight);
        glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_DEPTH_ATTACHMENT_OES, GL_RENDERBUFFER_OES, depthRenderbuffer);
    }
    
    if(glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES) {
        NSLog(@"failed to make complete framebuffer object %x", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
        return NO;
    }
    
    return YES;
}


- (void)destroyFramebuffer {
    
    glDeleteFramebuffersOES(1, &viewFramebuffer);
    viewFramebuffer = 0;
    glDeleteRenderbuffersOES(1, &viewRenderbuffer);
    viewRenderbuffer = 0;
    
    if(depthRenderbuffer) {
        glDeleteRenderbuffersOES(1, &depthRenderbuffer);
        depthRenderbuffer = 0;
    }
}


- (void)startAnimation {
    self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:animationInterval target:self selector:@selector(drawView) userInfo:nil repeats:YES];
}


- (void)stopAnimation {
    self.animationTimer = nil;
}


- (void)setAnimationTimer:(NSTimer *)newTimer {
    [animationTimer invalidate];
    animationTimer = newTimer;
}


- (void)setAnimationInterval:(NSTimeInterval)interval {
    
    animationInterval = interval;
    if (animationTimer) {
        [self stopAnimation];
        [self startAnimation];
    }
}


- (void)dealloc {
    
    [self stopAnimation];
    
    if ([EAGLContext currentContext] == context) {
        [EAGLContext setCurrentContext:nil];
    }
    
    [context release];  
    [super dealloc];
}

@end
