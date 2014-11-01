//
//  CameraProcessingViewController.m
//  EmojiPass
//
//  Created by Mimee Xu on 11/1/14.
//  Copyright (c) 2014 Mimee Xu. All rights reserved.
//

#import "CameraProcessingViewController.h"
#import <opencv2/videoio/cap_ios.h>

using namespace cv;
@interface CameraProcessingViewController ()
//retain??
@property (nonatomic, strong) CvVideoCamera* videoCamera;

@end

@implementation CameraProcessingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.videoCamera = [[CvVideoCamera alloc] init];//WithParentView:imageView];
    self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
    self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset352x288;
    self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    self.videoCamera.defaultFPS = 30;
    //self.videoCamera.grayscale = NO;
}

@end
