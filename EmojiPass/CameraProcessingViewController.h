//
//  CameraProcessingViewController.h
//  EmojiPass
//
//  Created by Mimee Xu on 11/1/14.
//  Copyright (c) 2014 Mimee Xu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CameraProcessingViewController : UIViewController//<CvVideoCameraDelegate>

@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *currentString;//keep track of what emoticons are currently being set

@end
