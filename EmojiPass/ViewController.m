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

@property (strong, nonatomic, readwrite) UIButton *successButton;
@property (strong, nonatomic, readwrite) UIButton *payButton;
@property (strong, nonatomic, readwrite) NSMutableDictionary *faceValue;
@property (nonatomic, assign) BOOL success;
@property (strong, nonatomic, readwrite) UIAlertController *successController;
@property (strong, nonatomic, readwrite) UIAlertController *failureController;

@end

@implementation ViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    self.success = nil;
    _successController = [UIAlertController
                                          alertControllerWithTitle:@"Successful Payment"
                                          message:@"Successful Payment"
                                          preferredStyle:UIAlertControllerStyleAlert];
    
                            UIAlertAction *okAction = [UIAlertAction
                                                       actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                                                       style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction *action)
                                                       {
                                                           NSLog(@"OK action");
                                                       }];
    
    [_successController addAction:okAction];
    
    _failureController = [UIAlertController
                                          alertControllerWithTitle:@"Failure"
                                          message:@"Failure"
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background2.jpg"]];
    bgImageView.frame = self.view.bounds;
    [self.view addSubview:bgImageView];
    [self.view sendSubviewToBack:bgImageView];
    
    CGRect insetBounds = self.view.bounds;
    
    // Initialize buttons
    self.successButton = [[UIButton alloc] initWithFrame:CGRectMake(insetBounds.origin.x, 100, insetBounds.size.width, 150)];
    self.successButton.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:26];
    self.successButton.hidden = YES;
    
    self.payButton = [[UIButton alloc] initWithFrame:CGRectMake(insetBounds.origin.x, 350, insetBounds.size.width, 100)];
    self.payButton.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:26];
    self.payButton.backgroundColor = [UIColor grayColor];
    self.payButton.alpha = 0.65f;
    [self.payButton setTitle:@"Submit Payment" forState:UIControlStateNormal];
    
    // Add button actions
    [self.successButton addTarget:self action:@selector(calibrateButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    [self.payButton addTarget:self action:@selector(payButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    // Add to view
    [self.view addSubview:self.successButton];
    [self.view addSubview:self.payButton];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    
    if (self.success == YES) {
        [self presentViewController:_successController animated:YES completion:nil];
    }
//    } else if (self.success == NO) {
//        [self presentViewController:_failureController animated:YES completion:nil];
//    }
    
    _success = nil;
    NSLog(@"camera processing view controller state");
}

- (void)calibrateButtonPressed {
    [self.successButton setBackgroundColor:[UIColor greenColor]];
}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([object isKindOfClass:[CameraProcessingViewController class]]) {
        if ([keyPath isEqualToString:@"masterProperty"]) {
            NSLog(@"camera processing view controller state: %@", change);
            
            if ([[object currentString] isEqualToString:@"!_!"]) {
                @try {
                    [object removeObserver:self forKeyPath:@"masterProperty"];
                }
                @catch (NSException * __unused exception) {}
                
                self.faceValue = [(AppDelegate *)[[UIApplication sharedApplication] delegate] faceValue];
                
//                self.faceValue = [NSMutableDictionary dictionaryWithDictionary:change];
                if ([self compare:self.faceValue with:[NSMutableDictionary dictionaryWithDictionary:change]]) {

                    self.success = YES;
                    [self processPayment];
                    //                    self.successButton.hidden = NO;
//                    self.successButton.titleLabel.text = @"Success";
//                    self.successButton.backgroundColor = [UIColor greenColor];
                } else {
                    //dispatch_sync(dispatch_get_main_queue(), ^{

                        
//                        UIAlertAction *okAction = [UIAlertAction
//                                                   actionWithTitle:NSLocalizedString(@"OK", @"OK action")
//                                                   style:UIAlertActionStyleDefault
//                                                   handler:^(UIAlertAction *action)
//                                                   {
//                                                       NSLog(@"OK action");
//                                                   }];
                        
                        //[alertController addAction:okAction];
                        self.success = NO;
                        //[self presentViewController:alertController animated:YES completion:nil];
                   // });

//                    self.successButton.hidden = NO;
//                    self.successButton.titleLabel.text = @"Failure";
//                    self.successButton.backgroundColor = [UIColor redColor];
                }

            }
        }
    }
}

- (BOOL)compare: (NSMutableDictionary *)left with: (NSMutableDictionary *)right{
    left = [left objectForKey:@"new"];
    right = [right objectForKey:@"new"];
    for (NSString *key in @[@"!_!"]) {//@[@":-)",@";-P",@":-D"]) {
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
- (void)successButtonPressed {
    self.successButton.hidden = YES;
    
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
//                                               UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Successful Payment"
//                                                                                               message:@"Successful Payment"
//                                                                                              delegate:nil
//                                                                                     cancelButtonTitle:@"OK"
//                                                                                     otherButtonTitles:nil
//                                                                     ];
//                                               [alert show];
                                               
                                           } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                               NSLog(@"Error: %@", error);
//                                               UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
//                                                                                               message:[error localizedDescription]
//                                                                                              delegate:nil
//                                                                                     cancelButtonTitle:@"OK"
//                                                                                     otherButtonTitles:nil
//                                                                     ];
//                                               [alert show];
                                           }
     ];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
