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
    
    UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background2.jpg"]];
    bgImageView.frame = self.view.bounds;
    [self.view addSubview:bgImageView];
    [self.view sendSubviewToBack:bgImageView];
    
    CGRect insetBounds = self.view.bounds;
    
    // Initialize buttons
    self.calibrateButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
    self.calibrateButton.frame = CGRectMake(insetBounds.origin.x, 80, insetBounds.size.width, 100);
    
    self.payButton = [[UIButton alloc] initWithFrame:CGRectMake(insetBounds.origin.x, 350, insetBounds.size.width, 100)];
    self.payButton.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:26];
    self.payButton.backgroundColor = [UIColor grayColor];
    self.payButton.alpha = 0.65f;
    [self.payButton setTitle:@"Submit Payment" forState:UIControlStateNormal];
    
    // Add button actions
    [self.calibrateButton addTarget:self action:@selector(calibrateButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.payButton addTarget:self action:@selector(processPayment) forControlEvents:UIControlEventTouchUpInside];
    
    // Add to view
    [self.view addSubview:self.calibrateButton];
    [self.view addSubview:self.payButton];
}

#pragma mark - Button Actions
- (void)calibrateButtonPressed {
    CameraProcessingViewController *calibrateCamera = [[CameraProcessingViewController alloc] init];
    [self presentViewController:calibrateCamera animated:YES completion:nil];
    
    return;
}
- (void)payButtonPressed {
    CameraProcessingViewController *payCamera = [[CameraProcessingViewController alloc] init];
    [payCamera setState:@"verify"];
    [self presentViewController:payCamera animated:YES completion:nil];
    return;
}

- (void)processPayment {
    [[MercuryClient sharedClient] processPaymentAmount:1.00
                                           withSuccess:^(AFHTTPRequestOperation *operation, id response) {
                                               NSLog(@"JSON: %@", response);
                                               UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success"
                                                                                               message:@"Success"
                                                                                              delegate:nil
                                                                                     cancelButtonTitle:@"OK"
                                                                                     otherButtonTitles:nil
                                                                     ];
                                               [alert show];
                                               
                                           } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                               NSLog(@"Error: %@", error);
                                               UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                                               message:[error localizedDescription]
                                                                                              delegate:nil
                                                                                     cancelButtonTitle:@"OK"
                                                                                     otherButtonTitles:nil
                                                                     ];
                                               [alert show];
                                           }
     ];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
