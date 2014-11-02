//
//  ViewController.m
//  EmojiPass
//
//  Created by Mimee Xu on 11/1/14.
//  Copyright (c) 2014 Mimee Xu. All rights reserved.
//
#import "ViewController.h"
#import "MercuryClient.h"

@interface ViewController ()

@property (strong, nonatomic, readwrite) UIButton *calibrateButton;
@property (strong, nonatomic, readwrite) UIButton *payButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    CGRect insetBounds = self.view.bounds;
    
    MercuryClient *client = [MercuryClient sharedClient];

    // Initialize buttons
    self.calibrateButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
    self.calibrateButton.frame = CGRectMake(insetBounds.origin.x, insetBounds.size.height/3, insetBounds.size.width, 100);
    
    self.payButton = [[UIButton alloc] initWithFrame:CGRectMake(insetBounds.origin.x, insetBounds.size.height*2/3, insetBounds.size.width, 100)];
    self.payButton.backgroundColor = [UIColor blueColor];
    [self.payButton setTitle:@"PAY" forState:UIControlStateNormal];
    
    // Add button actions
    [self.calibrateButton addTarget:self action:@selector(calibrateButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.payButton addTarget:client action:@selector(processPayment) forControlEvents:UIControlEventTouchUpInside];
    
    
    // Add to view
    [self.view addSubview:self.calibrateButton];
    [self.view addSubview:self.payButton];
    
    // Do any additional setup after loading the view, typically from a nib.
}



#pragma mark - Button Actions
- (void)calibrateButtonPressed {
    CameraProcessingViewController *calibrateCamera = [[CameraProcessingViewController alloc] init];
    [self presentViewController:calibrateCamera animated:YES completion:nil];
    
    return;
}
- (void)payButtonPressed {
    CameraProcessingViewController *payCamera = [[CameraProcessingViewController alloc] init];
    [self presentViewController:payCamera animated:YES completion:nil];
    return;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
