//
//  CreditCardViewController.h
//  EmojiPass
//
//  Created by Halko, Jaayden on 11/1/14.
//  Copyright (c) 2014 Mimee Xu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CalibrateViewController.h"

@interface CreditCardViewController : UIViewController
@property (strong, nonatomic) IBOutlet UITextField *creditCard;
@property (strong, nonatomic) IBOutlet UITextField *expiry;
@property (strong, nonatomic) IBOutlet UITextField *cvc;

- (IBAction)cvcText:(id)sender;

@end
