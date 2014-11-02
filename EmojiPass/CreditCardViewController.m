//
//  CreditCardViewController.m
//  EmojiPass
//
//  Created by Halko, Jaayden on 11/1/14.
//  Copyright (c) 2014 Mimee Xu. All rights reserved.
//

#import "CreditCardViewController.h"

@implementation CreditCardViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

}

- (IBAction)cvcFinished:(id)sender {
    CameraProcessingViewController *payCamera = [[CameraProcessingViewController alloc] init];
    [self presentViewController:payCamera animated:YES completion:nil];
}

@end
