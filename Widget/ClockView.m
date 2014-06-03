//
//  ClockView.m
//  clock
//
//  Created by Ignacio Enriquez Gutierrez on 1/31/11.
//  Copyright 2011 Nacho4D. All rights reserved.
//  See the file License.txt for copying permission.
//

#import "ClockView.h"


@implementation ClockView

#pragma mark - Public Methods

- (void)start
{
	timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateClock:) userInfo:nil repeats:YES];
}

- (void)stop
{
	[timer invalidate];
	timer = nil;
}

- (void)setDate:(NSDate *)date {
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:(NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:date];
	NSInteger seconds = [dateComponents second];
	NSInteger minutes = [dateComponents minute];
	NSInteger hours = [dateComponents hour];
	//NSLog(@"raw: hours:%d min:%d secs:%d", hours, minutes, seconds);
	if (hours > 12) hours -=12; //PM
    
	//set angles for each of the hands
	CGFloat secAngle = Degrees2Radians(seconds/60.0*360);
	CGFloat minAngle = Degrees2Radians(minutes/60.0*360);
	CGFloat hourAngle = Degrees2Radians(hours/12.0*360) + minAngle/12.0;
	
	//reflect the rotations + 180 degres since CALayers coordinate system is inverted
	secHand.transform = CATransform3DMakeRotation (secAngle+M_PI, 0, 0, 1);
    [secHand setHidden:YES];
	minHand.transform = CATransform3DMakeRotation (minAngle+M_PI, 0, 0, 1);
	hourHand.transform = CATransform3DMakeRotation (hourAngle+M_PI, 0, 0, 1);
    
    
    NSDateFormatter *f = [[NSDateFormatter alloc] init];
    [f setDateFormat:@"HH:mm"];
    NSLog(@"Time: %@",[f stringFromDate:date]);
    [timeLabel setText:[f stringFromDate:date]];
    
}

//customize appearence
- (void)setHourHandImage:(CGImageRef)image
{
	if (image == NULL) {
		hourHand.backgroundColor = [UIColor blackColor].CGColor;
		hourHand.cornerRadius = 3;
	}else{
		hourHand.backgroundColor = [UIColor clearColor].CGColor;
		hourHand.cornerRadius = 0.0;
		
	}
	hourHand.contents = (__bridge id)image;
}

- (void)setMinHandImage:(CGImageRef)image
{
	if (image == NULL) {
		minHand.backgroundColor = [UIColor grayColor].CGColor;
	}else{
		minHand.backgroundColor = [UIColor clearColor].CGColor;
	}
	minHand.contents = (__bridge id)image;
}

- (void)setSecHandImage:(CGImageRef)image
{
	if (image == NULL) {
		secHand.backgroundColor = [UIColor whiteColor].CGColor;
		secHand.borderWidth = 1.0;
		secHand.borderColor = [UIColor grayColor].CGColor;
	}else{
		secHand.backgroundColor = [UIColor clearColor].CGColor;
		secHand.borderWidth = 0.0;
		secHand.borderColor = [UIColor clearColor].CGColor;
	}
	secHand.contents = (__bridge id)image;
}

- (void)setClockBackgroundImage:(CGImageRef)image
{
	if (image == NULL) {
		containerLayer.borderColor = [UIColor whiteColor].CGColor;
		containerLayer.borderWidth = 1.0;
		containerLayer.cornerRadius = self.frame.size.height/2;
	}else{
		containerLayer.borderColor = [UIColor whiteColor].CGColor;
		containerLayer.borderWidth = 1.0;
		containerLayer.cornerRadius = self.frame.size.height/2;
	}
	containerLayer.contents = (__bridge id)image;
}

#pragma mark - Private Methods

//Default sizes of hands:
//in percentage (0.0 - 1.0)
#define HOURS_HAND_LENGTH 0.55
#define MIN_HAND_LENGTH 0.75
#define SEC_HAND_LENGTH 0.8
//in pixels
#define HOURS_HAND_WIDTH 2
#define MIN_HAND_WIDTH 2
#define SEC_HAND_WIDTH 4

float Degrees2Radians(float degrees) { return degrees * M_PI / 180; }

//timer callback
- (void) updateClock:(NSTimer *)theTimer{
	
	NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:(NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:[NSDate date]];
	NSInteger seconds = [dateComponents second];
	NSInteger minutes = [dateComponents minute];
	NSInteger hours = [dateComponents hour];
	//NSLog(@"raw: hours:%d min:%d secs:%d", hours, minutes, seconds);
	if (hours > 12) hours -=12; //PM

	//set angles for each of the hands
	CGFloat secAngle = Degrees2Radians(seconds/60.0*360);
	CGFloat minAngle = Degrees2Radians(minutes/60.0*360);
	CGFloat hourAngle = Degrees2Radians(hours/12.0*360) + minAngle/12.0;
	
	//reflect the rotations + 180 degres since CALayers coordinate system is inverted
	secHand.transform = CATransform3DMakeRotation (secAngle+M_PI, 0, 0, 1);
	minHand.transform = CATransform3DMakeRotation (minAngle+M_PI, 0, 0, 1);
	hourHand.transform = CATransform3DMakeRotation (hourAngle+M_PI, 0, 0, 1);
}

-(void)defaultSetup
{
    containerLayer = [CALayer layer];
    hourHand = [CALayer layer];
    minHand = [CALayer layer];
    secHand = [CALayer layer];
    
    //default appearance
    [self setClockBackgroundImage:NULL];
    [self setHourHandImage:NULL];
    [self setMinHandImage:NULL];
    [self setSecHandImage:NULL];
    
    //add all created sublayers
    [containerLayer addSublayer:hourHand];
    [containerLayer addSublayer:minHand];
    [containerLayer addSublayer:secHand];
    [self.layer addSublayer:containerLayer];
}

#pragma mark - Overrides

- (void) layoutSubviews
{
	[super layoutSubviews];

	containerLayer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);

	float length = MIN(self.frame.size.width, self.frame.size.height)/2;
	CGPoint c = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
	hourHand.position = minHand.position = secHand.position = c;

	CGFloat w, h;
	CGFloat scale = 1;
	if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
		scale = [UIScreen mainScreen].scale;
	}
	
	if (hourHand.contents == NULL){
		w = HOURS_HAND_WIDTH;
		h = length*HOURS_HAND_LENGTH;
	}else{
		w = CGImageGetWidth((__bridge CGImageRef)hourHand.contents)/scale;
		h = CGImageGetHeight((__bridge CGImageRef)hourHand.contents)/scale;
	}
	hourHand.bounds = CGRectMake(0,0,w,h);
    [hourHand setBackgroundColor:[UIColor colorWithRed:0.502 green:0.718 blue:0.098 alpha:1.000].CGColor];
	
	if (minHand.contents == NULL){
		w = MIN_HAND_WIDTH;
		h = length*MIN_HAND_LENGTH;
	}else{
		w = CGImageGetWidth((__bridge CGImageRef)minHand.contents)/scale;
		h = CGImageGetHeight((__bridge CGImageRef)minHand.contents)/scale;
	}
	minHand.bounds = CGRectMake(0,0,w,h);
    [minHand setCornerRadius:2];
	
	if (secHand.contents == NULL){
		w = SEC_HAND_WIDTH;
		h = length*SEC_HAND_LENGTH;
	}else{
		w = CGImageGetWidth((__bridge CGImageRef)secHand.contents)/scale;
		h = CGImageGetHeight((__bridge CGImageRef)secHand.contents)/scale;
	}
	secHand.bounds = CGRectMake(0,0,w,h);

	hourHand.anchorPoint = CGPointMake(0.5,0.0);
	minHand.anchorPoint = CGPointMake(0.5,0.0);
	secHand.anchorPoint = CGPointMake(0.5,0.0);
//    UIView *anchor = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width/2 - 5,self.frame.size.height/2 - 5, 10, 10)];
//    [anchor setBackgroundColor:[UIColor whiteColor]];
//    [anchor.layer setCornerRadius:5];
//    [self addSubview:anchor];
	containerLayer.anchorPoint = CGPointMake(0.5, 0.5);
//    
//    timeLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.frame.size.width - 50)/2  ,self.frame.size.height - 50, 50, 20)];
//    [timeLabel setTextColor:[UIColor whiteColor]];
//    [timeLabel setTextAlignment:NSTextAlignmentCenter];
//    [timeLabel setBackgroundColor:[UIColor clearColor]];
//    [self addSubview:timeLabel];
//    [self sendSubviewToBack:timeLabel];

}

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
        
		[self defaultSetup];
        
	}
	return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self defaultSetup];
}

- (void)removeFromSuperview
{
	[self stop];
	[super removeFromSuperview];
}

- (void)dealloc
{
	[self stop];
}

@end