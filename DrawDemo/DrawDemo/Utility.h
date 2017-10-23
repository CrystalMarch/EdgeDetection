//
//  Utility.h
//  JCOpenCVCameraImgMatchDemo
//
//  Created by jimple on 14-1-10.
//  Copyright (c) 2014年 Jimple Chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#include <opencv2/opencv.hpp>


@interface Utility : NSObject

+ (IplImage *)CreateIplImageFromUIImage:(UIImage *)image;
+ (UIImage *)UIImageFromIplImage:(IplImage *)image grayImg:(BOOL)bIsGrayImg;
+ (CvHistogram *)get4ChannelHist:(IplImage *)image;
+ (CvHistogram *)getHSVHist:(IplImage *)image;


+ (cv::Mat)cvMatFromUIImage:(UIImage *)image;

+ (UIImage *)UIImageFromCVMat:(cv::Mat)cvMat;

@end
