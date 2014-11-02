//
//  CameraProcessingViewController.m
//  EmojiPass
//
//  Created by Mimee Xu on 11/1/14.
//  Copyright (c) 2014 Mimee Xu. All rights reserved.
//

//#import "CameraProcessingViewController.h"
#import <opencv2/videoio/cap_ios.h>

using namespace cv;
@interface CameraProcessingViewController: UIViewController<CvVideoCameraDelegate>// ()


@property (nonatomic, strong) UIImageView* imageView;
//retain??
@property (nonatomic, strong) CvVideoCamera* videoCamera;

@end

@implementation CameraProcessingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //Add the imageview
    CGRect bounds = self.view.bounds;
    self.imageView = [[UIImageView alloc]
                      initWithFrame:CGRectMake(bounds.origin.x + 10 , bounds.origin.y, 288, 352)];
    [self.imageView setBackgroundColor:[UIColor blueColor]];
    [self.view addSubview:self.imageView];
    
    //video camera
    self.videoCamera = [[CvVideoCamera alloc] initWithParentView:self.imageView];
    self.videoCamera.delegate = self;
    
    self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
    self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset352x288;
    self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    self.videoCamera.defaultFPS = 30;
    self.videoCamera.grayscaleMode = NO;
    
    [self.videoCamera start];
}

#pragma mark - Protocol CvVideoCameraDelegate

#ifdef __cplusplus
- (void)processImage:(Mat&)image;
{
    // Do some OpenCV stuff with the image
    Mat image_copy;
    cvtColor(image, image_copy, COLOR_BGR2GRAY);
    
    // invert image
    bitwise_not(image_copy, image_copy);
    
    //Convert BGR to BGRA (three channel to four channel)
    Mat bgr;
    cvtColor(image_copy, bgr, COLOR_GRAY2BGR);
    
    cvtColor(bgr, image, COLOR_BGR2BGRA);
    
    [self processFace:[self UIImageFromCVMat:image_copy]];
    return;
}

-(UIImage *)UIImageFromCVMat:(cv::Mat)cvMat
{
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                        cvMat.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * cvMat.elemSize(),                       //bits per pixel
                                        cvMat.step[0],                            //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    
    
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}

#endif

- (void)processFace: (UIImage *)image {
    return;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
