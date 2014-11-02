//
//  CreditCardViewController.m
//  EmojiPass
//
//  Created by Halko, Jaayden on 11/1/14.
//  Copyright (c) 2014 Mimee Xu. All rights reserved.
//

#import "CreditCardViewController.h"
#import "MercuryClient.h"

@interface CreditCardViewController ()

@property (strong, nonatomic, readwrite) UIButton *continueButton;

@end

@implementation CreditCardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background2.jpg"]];
    bgImageView.frame = self.view.bounds;
    [self.view addSubview:bgImageView];
    [self.view sendSubviewToBack:bgImageView];
    
    CGRect insetBounds = self.view.bounds;
    
    // Initialize buttons
    
    self.continueButton = [[UIButton alloc] initWithFrame:CGRectMake(insetBounds.origin.x, 250, insetBounds.size.width, 80)];
    self.continueButton.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:26];
    self.continueButton.backgroundColor = [UIColor grayColor];
    self.continueButton.alpha = 0.65f;
    [self.continueButton setTitle:@"Continue" forState:UIControlStateNormal];
    
    // Add button actions
    [self.continueButton addTarget:self action:@selector(continueButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    // Add to view
    [self.view addSubview:self.continueButton];
    self.continueButton.hidden = YES;

}

- (void)continueButtonPressed {
    CalibrateViewController *calibrateViewController =  [self.storyboard instantiateViewControllerWithIdentifier:@"calibrateView"];
    [self.navigationController pushViewController:calibrateViewController animated:YES];
    
    return;
}

- (void)processCreditAuth {

    NSString *creditCard = self.creditCard.text;
    NSString *expData = self.expiry.text;

    [[MercuryClient sharedClient] setupCreditCard:creditCard
                                       andExpDate:expData
                                           withSuccess:^(AFHTTPRequestOperation *operation, id response) {
                                               NSLog(@"JSON: %@", response);
                                               self.continueButton.hidden = NO;
                                               
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

- (IBAction)cvcText:(id)sender {
    UITextField *cvc = (UITextField*)sender;
    
    if (cvc.text.length >= 3) {
        
        [self processCreditAuth];

        [self.view endEditing:YES];
    }
}
@end
