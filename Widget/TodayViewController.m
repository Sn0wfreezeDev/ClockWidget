//
//  TodayViewController.m
//  Widget
//
//  Created by Alexander Heinrich on 02/06/14.
//  Copyright (c) 2014 Sn0wfreeze Development UG. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>
#import "ClockView.h"

@interface TodayViewController () <NCWidgetProviding>
@property (weak, nonatomic) IBOutlet UILabel *firstCity;
@property (weak, nonatomic) IBOutlet UILabel *firstTime;
@property (weak, nonatomic) IBOutlet UILabel *secondCity;
@property (weak, nonatomic) IBOutlet UILabel *secondTime;

@property (weak, nonatomic) IBOutlet ClockView *firstClock;
@property (weak, nonatomic) IBOutlet ClockView *secondClock;

@end

@implementation TodayViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        NSLog(@"Initilization");
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [_firstCity setTextColor:[UIColor whiteColor]];
    [_firstTime setTextColor:[UIColor whiteColor]];
    [_secondCity setTextColor:[UIColor whiteColor]];
    [_secondTime setTextColor:[UIColor whiteColor]];
    [self updateTime:nil]; 
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTime:) userInfo:nil repeats:YES];
    
   }


- (void)updateTime:(NSTimer *)timer {
    NSDateFormatter *first = [[NSDateFormatter alloc] init];
    [first setDateFormat:@"HH:mm"];
    NSTimeZone *tz = [NSTimeZone timeZoneWithName:@"Europe/Paris"];
    [first setTimeZone:tz];
    
    [_firstTime setText:[first stringFromDate:[NSDate date]]];
    
    NSDateFormatter *secondZone = [[NSDateFormatter alloc] init];
    [secondZone setDateFormat:@"HH:mm"];
    NSTimeZone *secTz = [NSTimeZone timeZoneWithName:@"America/Los_Angeles"];
    [secondZone setTimeZone:secTz];
    
    [_secondTime setText:[secondZone stringFromDate:[NSDate date]]];
    
    NSDateFormatter *formatter =  [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];
    
    NSDate *firstToday = [formatter dateFromString:_firstTime.text];
    [_firstClock setDate:firstToday];
    NSLog(@"Date1: %@",firstToday);
    NSDate * secondToday = [formatter dateFromString:_secondTime.text];
    [_secondClock setDate:secondToday];
    NSLog(@"Date2 %@", secondToday); 

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encoutered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData

    completionHandler(NCUpdateResultNewData);
}

@end
