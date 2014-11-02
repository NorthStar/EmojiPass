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

- (void)processPaymentAmount:(float)amount
                 withSuccess:(void (^)(AFHTTPRequestOperation *operation, id response))success
                     failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:@"Basic MDIzMzU4MTUwNTExNjY2Onh5eg==" forHTTPHeaderField:@"Authorization"];
    
    NSMutableDictionary *parameters =
    [NSMutableDictionary dictionaryWithDictionary:@{
                                                    @"InvoiceNo":@"1",
                                                    @"RefNo":@"1",
                                                    @"Memo":@"emojipass Money2020",
                                                    @"Purchase":[NSString stringWithFormat:@"%0.2f",amount],
                                                    @"Frequency":@"OneTime",
                                                    @"RecordNo":@"OdDOgYVlrkVeir9/q9lDtjinQwZ7rUsh8tua5x1YYSMiEgUQCSIQCI1B",
                                                    @"OperatorID":@"money2020"
                                                    }
    ];
    
    [manager POST:@"https://w1.mercurycert.net/PaymentsAPI/credit/salebyrecordno" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(operation, responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(failure, error);
    }];
}

@end
