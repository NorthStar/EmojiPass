//
//  CameraProcessingViewController.m
//  EmojiPass
//
//  Created by Mimee Xu on 11/1/14.
//  Copyright (c) 2014 Mimee Xu. All rights reserved.
//

//#import "CameraProcessingViewController.h"
#import <opencv2/videoio/cap_ios.h>
#import <UNIRest.h>
#import <Firebase/Firebase.h>
#import "AFHTTPRequestOperationManager.h"

using namespace cv;
@interface CameraProcessingViewController: UIViewController<CvVideoCameraDelegate>// ()


@property (nonatomic, strong) UIImageView* imageView;
//retain??
@property (nonatomic, strong) CvVideoCamera *videoCamera;
@property (nonatomic, strong) NSString *parseJsId;
@property (nonatomic, strong) NSNumber *count;
@property (nonatomic, strong) NSNumber *callBackCount;

@property (nonatomic, strong) NSMutableDictionary *globalProperty;

@end

@implementation CameraProcessingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.parseJsId = @"BjbkS4leuED1ttosql3FfkUXiH5CqU8EYeZJPPoc";
    
    // Do any additional setup after loading the view, typically from a nib.
    
    //initialize the global property
    self.globalProperty = nil;
    
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
    
    self.count = [NSNumber numberWithInt:0];
    self.callBackCount = [NSNumber numberWithInt:0];
    
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
   // bitwise_not(image_copy, image_copy);
    
    //Convert BGR to BGRA (three channel to four channel)
    Mat bgr;
    cvtColor(image_copy, bgr, COLOR_GRAY2BGR);
    
    cvtColor(bgr, image, COLOR_BGR2BGRA);
    
    [self postFaceToAmazon:[self UIImageFromCVMat:image_copy]];
    return;
}

-(UIImage *)UIImageFromCVMat:(cv::Mat)cvMat
{
    self.count = [NSNumber numberWithInt:[self.count intValue] + 1];
    
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


- (void)postFaceToAmazon: (UIImage *)image {
    
    if ([self.count intValue] >= 30) {
        [self stopTaping];
    }
    __block NSNumber *countCopy = self.count;

    /*  UIImagePNGRep instead of JPEG */
    //NSData *imageData = UIImagePNGRepresentation(image);
    
    NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"key":[NSString stringWithFormat:@"images/%d", [countCopy intValue]]};
    NSString *baseUrl = @"http://emojiface.s3.amazonaws.com";
    
    
    [manager POST:baseUrl parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFormData:imageData name:@"file"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"Success: %@", responseObject);
        
        NSString *formattedUrl = @"http%3A%2F%2Femojiface.s3.amazonaws.com%2Fimages%2F";
        [self recognizeFaceWithUrl:[NSString stringWithFormat:@"%@%d", formattedUrl, [countCopy intValue]]];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}


- (void)recognizeFaceWithUrl: (NSString *)postedUrl {
    NSDictionary *headers = @{@"X-Mashape-Key": @"E7mL64BZoXmshpCluDPrZdPVW573p1TJ8KrjsnPQn0QzDxADxF"};
    NSString *urlString = @"https://faceplusplus-faceplusplus.p.mashape.com/detection/detect?attribute=glass%2Cpose%2Cgender%2Cage%2Crace%2Csmiling&url=";
    
    /* if I need the end result, do:*/
    //UNIUrlConnection *asyncConnection =
    
    [[UNIRest get:^(UNISimpleRequest *request) {
        [request setUrl:[NSString stringWithFormat:@"%@%@", urlString, postedUrl]];
        [request setHeaders:headers];
    }] asJsonAsync:^(UNIHTTPJsonResponse *response, NSError *error) {
        
        /* If I need the rest of the return */
        //NSInteger code = response.code;
        //NSDictionary *responseHeaders = response.headers;
        //UNIJsonNode *body = response.body;
        
        if (error) {
            return;
        }
        NSData *rawBody = response.rawBody;
        NSDictionary *tideData = [NSJSONSerialization JSONObjectWithData:rawBody options: 0 error: &error];
        NSLog(@"%@", tideData);
        self.callBackCount = [NSNumber numberWithInt:[self.callBackCount intValue] + 1];
        
        [self saveFacialFeature:tideData];
    }];
}



- (void)saveFacialFeature: (NSDictionary *)dictionaryData {
    if ([self.callBackCount intValue] >= 30) {
        [self stopProcessing];
    }
    
    NSArray *face = [dictionaryData objectForKey:@"face"];
    if (!face) {
        return;//return early if no face is found
    }
    
    if ([face isKindOfClass:[NSArray class]]) {
        if (face.count == 0) {
            return;
        }
    }
    //
    NSDictionary *position = [[face firstObject] objectForKey:@"position"];
    float eyeToNose = [[[position objectForKey:@"eye_left"] objectForKey:@"x"] floatValue];
    if (eyeToNose > 0) {
        
        [self.globalProperty setObject:position forKey:@"position"];
        [self.globalProperty setObject:[[[[face firstObject] objectForKey:@"attribute"] objectForKey:@"gender"] objectForKey:@"value"] forKey:@"gender"];
    }
}

- (void)stopTaping {
    [self.videoCamera stop];
    self.count = [NSNumber numberWithInt:0];
}
- (void)stopProcessing {
    if (self.globalProperty) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    //set state to stop
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
