//
//  MercuryClient.h
//  EmojiPass
//
//  Created by Halko, Jaayden on 11/1/14.
//  Copyright (c) 2014 Mimee Xu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

@interface MercuryClient : NSObject

+ (MercuryClient *)sharedClient;

- (void)processPayment;
    

@end
