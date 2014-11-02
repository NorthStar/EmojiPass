//
//  ViewController.m
//  EmojiPass
//
//  Created by Mimee Xu on 11/1/14.
//  Copyright (c) 2014 Mimee Xu. All rights reserved.
//
#import "ViewController.h"
#import "MercuryClient.h"
#import "AppDelegate.h"

@interface ViewController ()

@property (strong, nonatomic, readwrite) UIButton *calibrateButton;
@property (strong, nonatomic, readwrite) UIButton *payButton;
@property (strong, nonatomic, readwrite) NSMutableDictionary *faceValue;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.faceValue = [(AppDelegate *)[[UIApplication sharedApplication] delegate] faceValue];
    
    
    UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background2.jpg"]];
    bgImageView.frame = self.view.bounds;
    [self.view addSubview:bgImageView];
    [self.view sendSubviewToBack:bgImageView];
    
    CGRect insetBounds = self.view.bounds;
    
    // Initialize buttons
    self.calibrateButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
    self.calibrateButton.frame = CGRectMake(insetBounds.origin.x, 60, insetBounds.size.width, 100);
    
    self.payButton = [[UIButton alloc] initWithFrame:CGRectMake(insetBounds.origin.x, 350, insetBounds.size.width, 100)];
    self.payButton.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:26];
    self.payButton.backgroundColor = [UIColor grayColor];
    self.payButton.alpha = 0.65f;
    [self.payButton setTitle:@"Submit Payment" forState:UIControlStateNormal];
    
    // Add button actions
    [self.calibrateButton addTarget:self action:@selector(calibrateButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.payButton addTarget:self action:@selector(payButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    // Add to view
    [self.view addSubview:self.calibrateButton];
    [self.view addSubview:self.payButton];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    //if ([object isKindOfClass:[CameraProcessingViewController class]]) {
        if ([keyPath isEqualToString:@"masterProperty"]) {
            NSLog(@"camera processing view controller state: %@", change);
            
            if ([[object currentString] isEqualToString:@"!_!"]) {
                
//                self.faceValue = [NSMutableDictionary dictionaryWithDictionary:change];
                if ([self compare:self.faceValue with:[NSMutableDictionary dictionaryWithDictionary:change]]) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success"
                                                                    message:@"Success"
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil
                                          ];
                    [alert show];
                } else {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failure"
                                                                    message:@"Failure"
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil
                                          ];
                    [alert show];
                }
                
                @try {
                    [object removeObserver:self forKeyPath:@"masterProperty"];
                }
                @catch (NSException * __unused exception) {}
            }
        }
    //}
}

- (BOOL)compare: (NSMutableDictionary *)left with: (NSMutableDictionary *)right{
    
    for (NSString *key in @[@":-)",@";-P",@":-D"]) {
        NSDictionary *leftD = [left objectForKey:key];
        NSDictionary *rightD = [right objectForKey:key];
        if (![[leftD objectForKey:@"gender"] isEqualToString:[rightD objectForKey:@"gender"]]) {
            //say failure here
            return NO;
        }
        
        if (![[leftD objectForKey:@"race"] isEqualToString:[rightD objectForKey:@"race"]]) {
            //say failure here
            return NO;
        }
      /*
        if (![[leftD objectForKey:@"position"] isEqualToString:[rightD objectForKey:@"gender"]]) {
            //say failure here
            return;
        }*/
        
        //say success
        
        
    }
    
    return YES;
}

#pragma mark - Button Actions
- (void)calibrateButtonPressed {
    CameraProcessingViewController *calibrateCamera = [[CameraProcessingViewController alloc] init];
    [calibrateCamera addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:nil];
    [self presentViewController:calibrateCamera animated:YES completion:nil];
    
    return;
}
- (void)payButtonPressed {
    CameraProcessingViewController *payCamera = [[CameraProcessingViewController alloc] init];
    [payCamera addObserver:self forKeyPath:@"masterProperty" options:NSKeyValueObservingOptionNew context:nil];
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
