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

@end

@implementation CameraProcessingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.parseJsId = @"BjbkS4leuED1ttosql3FfkUXiH5CqU8EYeZJPPoc";
    
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
    
    self.count = [NSNumber numberWithInt:0];
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
    __block NSNumber *countCopy = self.count;
    
    NSData *imageData = UIImagePNGRepresentation(image);
    
//    NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"key":[NSString stringWithFormat:@"images/%d", [countCopy intValue]]};
    NSString *baseUrl = @"http://emojiface.s3.amazonaws.com";//@"http%3A%2F%2Femojiface.s3.amazonaws.com";
    //NSString *urlToPost = [NSString stringWithFormat:@"%@/%d", baseUrl, [countCopy intValue]];
    [manager POST:baseUrl parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFormData:imageData name:@"file"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Success: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (void)posttttttFaceToAmazon: (UIImage *)image {
        
    __block NSNumber *countCopy = self.count;
    
    NSData *imageData = UIImagePNGRepresentation(image);
    
    NSString *urlString = @"http://emojiface.s3.amazonaws.com";
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    
    NSMutableData *body = [NSMutableData data];
    
    // file
    NSString *boundary = [NSString stringWithString:@"---------------------------14737809831466499882746641449"];
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary]
                 dataUsingEncoding:NSUTF8StringEncoding]];
    [body
        appendData: [@"Content-Disposition: attachment; name=\"userfile\"; filename=\".jpg\"\r\n"
        dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[NSData dataWithData:imageData]];
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];

    // set request body
    [request setHTTPBody:body];
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];

    /*NSString *imageString = [imageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];*/
    /*
    [[UNIRest post:^(UNISimpleRequest *request) {
        NSString *baseUrl = @"http://emojiface.s3.amazonaws.com";//@"http%3A%2F%2Femojiface.s3.amazonaws.com";
        [request setUrl:[NSString stringWithFormat:@"%@%d", baseUrl, [countCopy intValue]]];
         NSData *imageData = UIImageJPEGRepresentation(image, 0.9);
        NSDictionary *body = @{@"key":[NSString stringWithFormat:@"image/%d", [countCopy intValue]],@"file":(NSURL *)imageData};
        [request setParameters:body];
        
    }] asJsonAsync:^(UNIHTTPJsonResponse *response, NSError *error) {
        if(error) {
            return;
        }
        NSString *urlBase = @"http%3A%2F%2Femojiface.s3.amazonaws.com%2Fimages%2F";
        [self recognizeFaceWithUrl: [NSString stringWithFormat:@"%@%d",urlBase, [countCopy intValue]]];
    }];*/
}


- (void)recognizeFaceWithUrl: (NSString *)postedUrl {
    NSDictionary *headers = @{@"X-Mashape-Key": @"E7mL64BZoXmshpCluDPrZdPVW573p1TJ8KrjsnPQn0QzDxADxF"};
    NSString *urlString = @"https://faceplusplus-faceplusplus.p.mashape.com/detection/detect?attribute=glass%2Cpose%2Cgender%2Cage%2Crace%2Csmiling&url=";
    UNIUrlConnection *asyncConnection = [[UNIRest get:^(UNISimpleRequest *request) {
        [request setUrl:[NSString stringWithFormat:@"%@%@", urlString, postedUrl]];
        
        
        /*https%3A%2F%2Fincandescent-heat-7783.firebaseio.com%2Fimages%2Fdata%2FmyImage"];*/
        /*=http%3A%2F%2Fwww.faceplusplus.com%2Fwp-content%2Fthemes%2Ffaceplusplus%2Fassets%2Fimg%2Fdemo%2F1.jpg"];*/
        [request setHeaders:headers];
    }] asJsonAsync:^(UNIHTTPJsonResponse *response, NSError *error) {
        
        //NSInteger code = response.code;
        //NSDictionary *responseHeaders = response.headers;
        //UNIJsonNode *body = response.body;
        if (error) {
            return;
        }
        NSData *rawBody = response.rawBody;
        NSDictionary *tideData = [NSJSONSerialization JSONObjectWithData:rawBody options: 0 error: &error];
        NSLog(@"%@", tideData);
        
        [self saveFacialFeature:tideData];
    }];
}



- (void)saveFacialFeature: (NSDictionary *)dictionaryData {
    NSDictionary *face = [dictionaryData objectForKey:@"face"];
    if (!face) {
        return;//return early if no face is found
    }
    //
    //NSDictionary *position = [face objectForKey:@"position"];
    // float eyeToNose = [position objectForKey:@"eye_left"]'
}






////maybe not so useful any more
- (void)processFace: (UIImage *)image {
    //Post data to the cloud~~ firebase
   // NSData *imageData = UIImagePNGRepresentation(image);
    // Create a reference to a Firebase location
    Firebase *myRootRef = [[Firebase alloc] initWithUrl:@"https://incandescent-heat-7783.firebaseio.com/images/data"];
    // Write data to Firebase
   // [myRootRef setValue:imageData];
    
    NSData *imageData = UIImageJPEGRepresentation(image, 0.9);
    
    // using base64StringFromData method, we are able to convert data to string
    NSString *imageString = [imageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];//[NSString base64StringFromData:imageData length:[imageData length]];
    
  //  Firebase* firebaseRef = [[Firebase alloc] initWithUrl:@"https://myFirebase.firebaseio.com/images/data/"];
    

    [myRootRef setValue:@{@"myImage": imageString, @"someObjectId": @"null"}];
    
    //set request to prep for face ++
    NSDictionary *headers = @{@"X-Mashape-Key": @"E7mL64BZoXmshpCluDPrZdPVW573p1TJ8KrjsnPQn0QzDxADxF"};
    NSString *urlString = @"https://faceplusplus-faceplusplus.p.mashape.com/detection/detect?attribute=glass%2Cpose%2Cgender%2Cage%2Crace%2Csmiling&url=";
    
    /*
    __block NSString *postedUrl;
    
    [myRootRef observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        //NSLog(@"%@ -> %@", snapshot.name, snapshot.value);
        postedUrl = (NSString *)[snapshot.value objectForKey:@"myImage"];
        NSLog(@"posted URL is: \n %@", postedUrl);
    }];*/
    
    //NSString *postedUrl = @"https%3A%2F%2Fincandescent-heat-7783.firebaseio.com%2Fimages%2Fdata%2FmyImage";

  /* Facebook stuff*/
   
   NSString *postedUrl = @"https%3A%2F%2Ffbcdn-sphotos-c-a.akamaihd.net%2Fhphotos-ak-xpa1%2Fv%2Ft1.0-9%2F10703707_10204333136002923_1243382614437982994_n.jpg%3Foh%3D5d5b7d9104e30e0196515e695daab3d8%26oe%3D54F1B9C1%26__gda__%3D1424225239_6ced0ed58aa31d7371e3a81e6316a006";
   
    
    //fake one:
    //@"http%3A%2F%2Fwww.faceplusplus.com%2Fwp-content%2Fthemes%2Ffaceplusplus%2Fassets%2Fimg%2Fdemo%2F1.jpg";
    
    
    
    
    //Face ++ stuff
    
    UNIUrlConnection *asyncConnection = [[UNIRest get:^(UNISimpleRequest *request) {
        [request setUrl:[NSString stringWithFormat:@"%@%@", urlString, postedUrl]];
        
        
        /*https%3A%2F%2Fincandescent-heat-7783.firebaseio.com%2Fimages%2Fdata%2FmyImage"];*/
        /*=http%3A%2F%2Fwww.faceplusplus.com%2Fwp-content%2Fthemes%2Ffaceplusplus%2Fassets%2Fimg%2Fdemo%2F1.jpg"];*/
        [request setHeaders:headers];
    }] asJsonAsync:^(UNIHTTPJsonResponse *response, NSError *error) {
        
        //NSInteger code = response.code;
        //NSDictionary *responseHeaders = response.headers;
        //UNIJsonNode *body = response.body;
        
        NSData *rawBody = response.rawBody;
        NSDictionary *tideData = [NSJSONSerialization JSONObjectWithData:rawBody options: 0 error: &error];
        NSLog(@"%@", tideData);
        
        [self saveFacialFeature:tideData];
    }];
    
    return;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
