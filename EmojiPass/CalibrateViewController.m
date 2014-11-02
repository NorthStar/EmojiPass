//
//  CalibrateViewController.m
//  EmojiPass
//
//  Created by Halko, Jaayden on 11/2/14.
//  Copyright (c) 2014 Mimee Xu. All rights reserved.
//

#import "CalibrateViewController.h"
#import "AppDelegate.h"

@interface CalibrateViewController ()

@property (strong, nonatomic, readwrite) UIButton *calibrateButton;
@property (strong, nonatomic, readwrite) NSMutableDictionary *faceValue;

@end

@implementation CalibrateViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    
    //self.faceValue = [(AppDelegate *)[[UIApplication sharedApplication] delegate] faceValue];
    
    UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background2.jpg"]];
    bgImageView.frame = self.view.bounds;
    [self.view addSubview:bgImageView];
    [self.view sendSubviewToBack:bgImageView];
    
    CGRect insetBounds = self.view.bounds;
    
    // Initialize buttons
    
    self.calibrateButton = [[UIButton alloc] initWithFrame:CGRectMake(insetBounds.origin.x, 250, insetBounds.size.width, 80)];
    self.calibrateButton.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:26];
    self.calibrateButton.backgroundColor = [UIColor grayColor];
    self.calibrateButton.alpha = 0.65f;
    [self.calibrateButton setTitle:@"Scan Face" forState:UIControlStateNormal];
    
    // Add button actions
    [self.calibrateButton addTarget:self action:@selector(calibrateButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    // Add to view
    [self.view addSubview:self.calibrateButton];

}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([object isKindOfClass:[CameraProcessingViewController class]]) {
    if ([keyPath isEqualToString:@"masterProperty"]) {
        NSLog(@"camera processing view controller state: %@", change);
        
        if ([[object currentString] isEqualToString:@"!_!"]) {
            
            //self.faceValue = [NSMutableDictionary dictionaryWithDictionary:change];
            [((AppDelegate *)[[UIApplication sharedApplication] delegate]) setFaceValue:[NSMutableDictionary dictionaryWithDictionary:change]]; //setFaceValue:[NSMutableDictionary dictionaryWithDictionary:change]];
            @try {
                [object removeObserver:self forKeyPath:@"masterProperty"];
            }
            @catch (NSException * __unused exception) {}
        }
    }
    }
}

- (void)calibrateButtonPressed {
    CameraProcessingViewController *calibrateCamera = [[CameraProcessingViewController alloc] init];
    [calibrateCamera addObserver:self forKeyPath:@"masterProperty" options:NSKeyValueObservingOptionNew context:nil];
    [calibrateCamera setState:@"calibrate"];
    [self presentViewController:calibrateCamera animated:YES completion:nil];
    
    return;
}

@end
