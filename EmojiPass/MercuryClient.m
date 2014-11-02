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

+ (MercuryClient *)sharedClient
{
    static dispatch_once_t once;
    static MercuryClient *sharedFSClient;
    dispatch_once(&once, ^{
        sharedFSClient = [[MercuryClient alloc] init];
    });
    return sharedFSClient;
}

- (void)processPayment {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //NSDictionary *parameters = @{@"foo": @"bar"};
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:@"Basic MDIzMzU4MTUwNTExNjY2Onh5eg==" forHTTPHeaderField:@"Authorization"];
    
    NSMutableDictionary *parameters =
    [NSMutableDictionary dictionaryWithDictionary:@{
                                                    @"InvoiceNo":@"1",
                                                    @"RefNo":@"1",
                                                    @"Memo":@"emojipass Money2020",
                                                    @"Purchase":@"1.00",
                                                    @"Frequency":@"OneTime",
                                                    @"RecordNo":@"OdDOgYVlrkVeir9/q9lDtjinQwZ7rUsh8tua5x1YYSMiEgUQCSIQCI1B",
                                                    @"OperatorID":@"money2020"
                                                    }
    ];
    
    [manager POST:@"https://w1.mercurycert.net/PaymentsAPI/credit/salebyrecordno" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

@end
