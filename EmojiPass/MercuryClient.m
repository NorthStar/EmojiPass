//
//  MercuryClient.m
//  EmojiPass
//
//  Created by Halko, Jaayden on 11/1/14.
//  Copyright (c) 2014 Mimee Xu. All rights reserved.
//

#import "MercuryClient.h"

#define MERCURY_BASE_URL [NSURL URLWithString:@"https://w1.mercurycert.net/PaymentsAPI"]

@implementation MercuryClient

+ (MercuryClient *)sharedFSClient
{
    static dispatch_once_t once;
    static MercuryClient *sharedFSClient;
    dispatch_once(&once, ^{
        sharedFSClient = [[MercuryClient alloc] init];
    });
    return sharedFSClient;
}

@end
