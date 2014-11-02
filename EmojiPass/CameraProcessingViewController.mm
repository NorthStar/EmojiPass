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
#import <QuartzCore/QuartzCore.h>
#import "ProgressHUD.h"

using namespace cv;
@interface CameraProcessingViewController: UIViewController<CvVideoCameraDelegate>// ()


@property (nonatomic, strong) UIImageView* imageView;
//retain??
@property (nonatomic, strong) CvVideoCamera *videoCamera;
@property (nonatomic, strong) NSString *parseJsId;
@property (nonatomic, strong) NSNumber *count;
@property (nonatomic, strong) NSNumber *callBackCount;

@property (nonatomic, strong) UILabel *emoticonLabel;//for icons
@property (nonatomic, strong) UILabel *textLabel;//for text, duh
@property (nonatomic, strong) NSString *currentString;//keep track of what emoticons are currently being set

@property (nonatomic, strong) NSMutableDictionary *masterProperty;
@property (nonatomic, strong) NSMutableDictionary *globalProperty;
@property (nonatomic, strong, readwrite) NSString *state;

@end

@implementation CameraProcessingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.parseJsId = @"BjbkS4leuED1ttosql3FfkUXiH5CqU8EYeZJPPoc";
    
    // Do any additional setup after loading the view, typically from a nib.
    
    //initialize the global property
    self.globalProperty = [NSMutableDictionary dictionary];
    self.masterProperty = [NSMutableDictionary dictionaryWithDictionary:
                           @{@":-)":@{},
                             @";-P":@{},
                             @":-D":@{}}];
    
    self.currentString = @":)";
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    //Add the imageview
    CGRect bounds = self.view.bounds;
    self.imageView = [[UIImageView alloc]
                      initWithFrame:CGRectMake(bounds.origin.x + 10 , bounds.origin.y, 288, 352)];
    [self.view addSubview:self.imageView];
    
    //Emoticon Label
    self.emoticonLabel = [[UILabel alloc] initWithFrame:CGRectMake(bounds.origin.x + 250 , bounds.origin.y + 400, 44, 44)];
    self.emoticonLabel.font = [UIFont fontWithName:@"Ariel" size:48];
    self.emoticonLabel.text =  self.currentString;
    [self.emoticonLabel setTextColor:[UIColor grayColor]];
    [self.view addSubview:self.emoticonLabel];
    //Text Label
    self.textLabel = [[UILabel alloc] initWithFrame:CGRectMake(bounds.origin.x + 44 , bounds.origin.y + 400, 200, 44)];
    self.textLabel.font = [UIFont fontWithName:@"Ariel" size:58];
    self.textLabel.text =  @"Prepping for...";
    [self.textLabel setTextColor:[UIColor grayColor]];
    [self.view addSubview:self.textLabel];

    
    
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
    self.count = [NSNumber numberWithInt:[self.count intValue] + 1];
    
    // Do some OpenCV stuff with the image
    Mat image_copy;
    cvtColor(image, image_copy, COLOR_BGR2GRAY);
    if ([self.count intValue] < 50 ||[self.count intValue] > 300) {
        // invert image
        // bitwise_not(image_copy, image_copy);
        
        //Convert BGR to BGRA (three channel to four channel)
        Mat bgr;
        cvtColor(image_copy, bgr, COLOR_GRAY2BGR);
        
        cvtColor(bgr, image, COLOR_BGR2BGRA);
        return;
    }
    
    [self postFaceToAmazon:[self UIImageFromCVMat:image_copy]];
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


- (void)postFaceToAmazon: (UIImage *)image {

    if ([self.count intValue] >= 80) {
        [self stopTapingForSmiles];
        return;
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
    /*
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            
            //Stop your activity indicator or anything else with the GUI
            //Code here is run on the main thread
            
            
        });
    });*/
    //Call your function or whatever work that needs to be done
    //Code in this part is run on a background thread
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

//Problem: the emoticon and the analysis are not yet associated
- (void)saveFacialFeature: (NSDictionary *)dictionaryData {
    if ([self.callBackCount intValue] >= 70) {
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

- (void)stopTapingForSmiles {
//    [self.videoCamera stop];
    
    if ([self.currentString isEqualToString:@":)"]) {
        self.currentString = @";-P";
        [self.textLabel removeFromSuperview];
    }
        //(important to say else here)
    else if ([self.currentString isEqualToString:@";-P"]) {
        self.currentString = @":-D";
    }
    
    else if ([self.currentString isEqualToString:@":-D"]) {
        self.currentString = @"!_!";
    }
    
 /*   [self.view layoutIfNeeded];
    [self.view bringSubviewToFront:self.imageView];*/
    
    if (![self.currentString isEqualToString:@"!_!"]) {
/*
        dispatch_async(dispatch_get_main_queue(), ^{
            [ProgressHUD show:@"Please wait..."];
        });*/
        self.count = [NSNumber numberWithInt:0];
    } else {
/*        [ProgressHUD show:@"About done..."];*/
/*        dispatch_async(dispatch_get_main_queue(), ^{
            [ProgressHUD show:@"About done..."];
        });*/
        
        //at least make all views disppear

    }
}

- (void)stopProcessing {
/*    [ProgressHUD dismiss];*/
    
    if (![self.currentString isEqualToString:@"!_!"]) {
        self.callBackCount = [NSNumber numberWithInt:50];
//        [self.videoCamera start];
    } else {
        if (self.globalProperty) {
            if ([self.state isEqualToString:@"calibrate"]) {
                [self.masterProperty setObject:self.globalProperty forKey:self.currentString];
                if ([self.currentString isEqualToString:@"!_!"]) {
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
            } else {
                    //compare stuff
                    if ([self.currentString isEqualToString:@"!_!"]) {
                        [self dismissViewControllerAnimated:YES completion:nil];
                    }
            }
        }
    }
    //set state to stop
}


- (void)compare: (NSMutableDictionary *)left with: (NSMutableDictionary *)right{
    return;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Overwriting setter
- (void)setState: (NSString *)state {
    _state = state;
}

@end
