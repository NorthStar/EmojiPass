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
//@property (strong, nonatomic, readwrite) UIButton *addCardButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    CGRect insetBounds = self.view.bounds;
    
    // Initialize buttons
    self.calibrateButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
    self.calibrateButton.frame = CGRectMake(insetBounds.origin.x, insetBounds.size.height/3, insetBounds.size.width, 100);
    
    self.payButton = [[UIButton alloc] initWithFrame:CGRectMake(insetBounds.origin.x, 250, insetBounds.size.width, 100)];
    self.payButton.backgroundColor = [UIColor blueColor];
    
    [self.payButton setTitle:@"PAY" forState:UIControlStateNormal];
    
    
//    self.addCardButton = [[UIButton alloc] initWithFrame:CGRectMake(insetBounds.origin.x, 360, insetBounds.size.width, 100)];
//    self.addCardButton.backgroundColor = [UIColor blueColor];
//    [self.addCardButton setTitle:@"Add Credit Card" forState:UIControlStateNormal];
    
    // Add button actions
    [self.calibrateButton addTarget:self action:@selector(calibrateButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.payButton addTarget:self action:@selector(processPayment) forControlEvents:UIControlEventTouchUpInside];
    //[self.addCardButton addTarget:self action:@selector(addCreditCard) forControlEvents:UIControlEventTouchUpInside];
    
    // Add to view
    [self.view addSubview:self.calibrateButton];
    [self.view addSubview:self.payButton];
    //[self.view addSubview:self.addCardButton];
    
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

- (void)addCreditCard {
    CreditCardViewController *creditCardViewController = [[CreditCardViewController alloc] init];

    [self presentViewController:creditCardViewController animated:YES completion:nil];
}

//- (IBAction)testbutton:(id)sender {
//        [self performSegueWithIdentifier:@"setupUser" sender:self];
//}

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
