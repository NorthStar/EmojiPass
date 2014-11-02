//
//  CalibrateViewController.m
//  EmojiPass
//
//  Created by Halko, Jaayden on 11/2/14.
//  Copyright (c) 2014 Mimee Xu. All rights reserved.
//

#import "CalibrateViewController.h"

@interface CalibrateViewController ()

@property (strong, nonatomic, readwrite) UIButton *calibrateButton;

@end

@implementation CalibrateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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

- (void)calibrateButtonPressed {
    CameraProcessingViewController *calibrateCamera = [[CameraProcessingViewController alloc] init];
    [self presentViewController:calibrateCamera animated:YES completion:nil];
    
    return;
}

@end
