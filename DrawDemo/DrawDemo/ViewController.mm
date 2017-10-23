//
//  ViewController.m
//  DrawDemo
//
//  Created by 朱慧平 on 2017/8/1.
//  Copyright © 2017年 Crystal. All rights reserved.
//
#include <opencv2/opencv.hpp>
#include <vector>
#include "auto_clip.hpp"
#import "ViewController.h"
#import "DrawView.h"
#import <Accelerate/Accelerate.h>
//#import "UIImageView+ContentFrame.h"
#import "Utility.h"
@interface ViewController (){
    cv::Mat cvImage;
    UIImageView *_sourceImageView;
    UIImage * _adjustedImage;
    NSMutableArray *_cannyPointArray;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    _sourceImageView = [[UIImageView alloc] init];
    _adjustedImage = [UIImage imageNamed:@"pinkCup"];
    CGFloat imageWidth = CGImageGetWidth(_adjustedImage.CGImage);
    CGFloat imageHeight = CGImageGetHeight(_adjustedImage.CGImage);
 
//    adjustedImageView.image = _adjustedImage;
//    [self.view addSubview:adjustedImageView];
    cvImage = [Utility cvMatFromUIImage:_adjustedImage];
    _sourceImageView.image = _adjustedImage;
//    _sourceImageView.image = [Utility UIImageFromCVMat:scan(cvImage, 3)];
    
    _sourceImageView.frame = CGRectMake(0, 0, self.view.frame.size.width*0.8, self.view.frame.size.width*0.8*(imageHeight/imageWidth));
    _sourceImageView.center = self.view.center;
    [_sourceImageView setContentMode:UIViewContentModeScaleAspectFit];
    _sourceImageView.userInteractionEnabled = YES;
    [self.view addSubview:_sourceImageView];
    DrawView *drawView = [[DrawView alloc] initWithFrame:_sourceImageView.bounds ];
    drawView.finishDrawBlock = ^(NSMutableArray *pointArray) {
//        CGPoint minXPoint = [[pointArray firstObject] CGPointValue];
//        CGPoint maxXPoint = [[pointArray firstObject] CGPointValue];
//        CGPoint minYPoint = [[pointArray firstObject] CGPointValue];
//        CGPoint maxYPoint = [[pointArray firstObject] CGPointValue];
//
//        for (int i = 0; i < pointArray.count; i ++) {
//              CGPoint touchPoint =[[pointArray objectAtIndex:i] CGPointValue];
//            if (touchPoint.x > maxXPoint.x) {
//                maxXPoint = touchPoint;
//            }else if (touchPoint.x < minXPoint.x){
//                minXPoint = touchPoint;
//            }else if (touchPoint.y < minYPoint.y){
//                minYPoint = touchPoint;
//            }else if (touchPoint.y > maxYPoint.y){
//                maxYPoint = touchPoint;
//            }
//        }
//
//        _cannyPointArray =  getTheEdgesPoint(cvImage, CGRectMake(minXPoint.x, minYPoint.y, maxXPoint.x - minXPoint.x, maxYPoint.y - minYPoint.y), CGSizeMake(_sourceImageView.frame.size.width, _sourceImageView.frame.size.height));
        
        for (int i = 0; i < pointArray.count; i ++) {
            CGPoint touchPoint =[[pointArray objectAtIndex:i] CGPointValue];
            [pointArray replaceObjectAtIndex:i withObject:[NSValue valueWithCGPoint:clipImage(cvImage, touchPoint, CGSizeMake(_sourceImageView.frame.size.width, _sourceImageView.frame.size.height))]];
        }
//        [self sortPoints:pointArray];
        [drawView drawCannyPath:pointArray];
    };
    [_sourceImageView addSubview:drawView];
}
- (void)sortPoints:(NSArray *)pointArray{
    NSMutableDictionary *pointDictionary = [NSMutableDictionary dictionary];
    _cannyPointArray = [NSMutableArray array];
    for (int i = 0;i < pointArray.count ;i ++) {
        CGPoint point = [pointArray[i] CGPointValue];
        NSLog(@"point is :(%f,%f)",point.x,point.y);
        if (pointDictionary[[NSString stringWithFormat:@"%f",point.x
                             ]]) {
            NSMutableArray *array =[[NSMutableArray alloc] initWithArray:[pointDictionary objectForKey:[NSString stringWithFormat:@"%f",point.x]]];
            NSLog(@"array is :%@",array);
            [array addObject:[NSValue valueWithCGPoint:point]];
            NSArray *result = [array sortedArrayUsingComparator:^NSComparisonResult(NSValue * obj1, NSValue * obj2) {
                CGPoint point1 = [obj1 CGPointValue];
                CGPoint point2 = [obj2 CGPointValue];
                NSNumber *number1 = [NSNumber numberWithFloat:point1.y];
                NSNumber *number2 = [NSNumber numberWithFloat:point2.y];
                return [number1 compare: number2];
            }];
            [pointDictionary setObject:result forKey:[NSString stringWithFormat:@"%f",point.x]];
        }else{
            [pointDictionary setObject:@[[NSValue valueWithCGPoint:point]] forKey:[NSString stringWithFormat:@"%f",point.x]];
        }
    }
    NSLog(@"pointDictionary is :%@",pointDictionary);
    NSArray *keyArray = [pointDictionary allKeys];
    NSArray *sortArray = [keyArray sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString * obj2) {
        return [[NSNumber numberWithDouble:[obj1 doubleValue]] compare: [NSNumber numberWithDouble:[obj2 doubleValue]]];
    }];
    for (int i = 0; i < sortArray.count; i ++) {
        NSArray *edgesPoint = [pointDictionary objectForKey:[sortArray objectAtIndex:i]];
        [_cannyPointArray addObject:[edgesPoint firstObject]];
    }
            for (int i = 0; i < sortArray.count; i ++) {
                NSArray *edgesPoint = [pointDictionary objectForKey:[sortArray objectAtIndex:(sortArray.count-1-i)]];
                [_cannyPointArray addObject:[edgesPoint lastObject]];
    }
    NSLog(@"cannyPointArray is :%@",_cannyPointArray);
}
+(CGSize)getPNGImageSizeWithRequest:(NSMutableURLRequest*)request
{
    [request setValue:@"bytes=16-23" forHTTPHeaderField:@"Range"];
    NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    if(data.length == 8)
    {
        int w1 = 0, w2 = 0, w3 = 0, w4 = 0;
        [data getBytes:&w1 range:NSMakeRange(0, 1)];
        [data getBytes:&w2 range:NSMakeRange(1, 1)];
        [data getBytes:&w3 range:NSMakeRange(2, 1)];
        [data getBytes:&w4 range:NSMakeRange(3, 1)];
        int w = (w1 << 24) + (w2 << 16) + (w3 << 8) + w4;
        int h1 = 0, h2 = 0, h3 = 0, h4 = 0;
        [data getBytes:&h1 range:NSMakeRange(4, 1)];
        [data getBytes:&h2 range:NSMakeRange(5, 1)];
        [data getBytes:&h3 range:NSMakeRange(6, 1)];
        [data getBytes:&h4 range:NSMakeRange(7, 1)];
        int h = (h1 << 24) + (h2 << 16) + (h3 << 8) + h4;
        return CGSizeMake(w, h);
    }
    return CGSizeZero;
}
#pragma mark - OpenCV 代码

using namespace cv;
using namespace std;


void getCanny(Mat gray, Mat &canny) {
    Mat thres;
    double high_thres = threshold(gray, thres, 0, 255, CV_THRESH_BINARY | CV_THRESH_OTSU), low_thres = high_thres * 0.5;//计算阈值
    std::cout<<"low_thres:"<<low_thres<<",high_thres:"<<high_thres<<std::endl;
    cv::Canny(gray, canny, 50, 51);
}

struct Line {
    cv::Point _p1;
    cv::Point _p2;
    cv::Point _center;
    
    Line(cv::Point p1, cv::Point p2) {
        _p1 = p1;
        _p2 = p2;
        _center = cv::Point((p1.x + p2.x) / 2, (p1.y + p2.y) / 2);
    }
};

bool cmp_y(const Line &p1, const Line &p2) {
    return p1._center.y < p2._center.y;
}

bool cmp_x(const Line &p1, const Line &p2) {
    return p1._center.x < p2._center.x;
}

/**
 * Compute intersect point of two lines l1 and l2
 * @param l1
 * @param l2
 * @return Intersect Point
 */
Point2f computeIntersect(Line l1, Line l2) {
    int x1 = l1._p1.x, x2 = l1._p2.x, y1 = l1._p1.y, y2 = l1._p2.y;
    int x3 = l2._p1.x, x4 = l2._p2.x, y3 = l2._p1.y, y4 = l2._p2.y;
    if (float d = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4)) {
        Point2f pt;
        pt.x = ((x1 * y2 - y1 * x2) * (x3 - x4) - (x1 - x2) * (x3 * y4 - y3 * x4)) / d;
        pt.y = ((x1 * y2 - y1 * x2) * (y3 - y4) - (y1 - y2) * (x3 * y4 - y3 * x4)) / d;
        return pt;
    }
    return Point2f(-1, -1);
}

cv::Mat getImage(Mat file,CGRect rect,CGSize imageViewSize) {
    Mat img = file;
    Mat img_proc;
    int w = img.size().width, h = img.size().height, min_w = 200;
    double scale = min(10.0, w * 1.0 / min_w);
    int w_proc = w * 1.0 / scale, h_proc = h * 1.0 / scale;
    
    resize(img, img_proc, cv::Size(w_proc, h_proc));
    /* get four outline edges of the document */
    // get edges of the image
    cv::Rect SrcImgROI = cv::Rect(w_proc/imageViewSize.width*rect.origin.x,h_proc/imageViewSize.height*rect.origin.y,w_proc/imageViewSize.width*rect.size.width,h_proc/imageViewSize.height*rect.size.height);
    cv::Mat SrcROIImg = img_proc(SrcImgROI);
    cv::Size wholeSize;
    cv::Point ofs;
    SrcROIImg.locateROI(wholeSize, ofs);
    Mat dest_image;
    SrcROIImg.convertTo(dest_image, CV_8UC1);
    Mat gray, canny;
    cvtColor(dest_image, gray, CV_BGR2GRAY); //灰度化处理
    blur(gray, gray, cv::Size(3,3));
    getCanny(gray, canny);   //寻找边缘
    
    vector<Vec4i> lines;
    vector<Line> horizontals, verticals;
    HoughLinesP(canny, lines, 1, CV_PI / 180, w_proc / 10, w_proc / 10, 20);
    
    NSMutableArray *pointArray = [NSMutableArray array];
    for (size_t i = 0; i < lines.size(); i++) {
        Vec4i v = lines[i];
        double delta_x = v[0] - v[2], delta_y = v[1] - v[3];
        Line l(cv::Point(v[0]+ofs.x, v[1]+ofs.y), cv::Point(v[2]+ofs.x, v[3]+ofs.y));
        line(img_proc, cv::Point(v[0]+ofs.x, v[1]+ofs.y), cv::Point(v[2]+ofs.x, v[3]+ofs.y), Scalar(255, 0, 0),1);
        [pointArray addObject:[NSValue valueWithCGPoint:CGPointMake(imageViewSize.width/w_proc*(v[0]+ofs.x), imageViewSize.height/h_proc*(v[1]+ofs.y))] ];
        [pointArray addObject:[NSValue valueWithCGPoint:CGPointMake(imageViewSize.width/w_proc*(v[2]+ofs.x), imageViewSize.height/h_proc*(v[3]+ofs.y))] ];
    }
    
    return img_proc;
}

NSMutableArray *getTheEdgesPoint(Mat file,CGRect rect,CGSize imageViewSize){
    Mat img = file;
    Mat img_proc;
    int w = img.size().width, h = img.size().height, min_w = 200;
    double scale = min(10.0, w * 1.0 / min_w);
    int w_proc = w * 1.0 / scale, h_proc = h * 1.0 / scale;
    
    resize(img, img_proc, cv::Size(w_proc, h_proc));
    /* get four outline edges of the document */
    // get edges of the image
    cv::Rect SrcImgROI = cv::Rect(w_proc/imageViewSize.width*rect.origin.x,h_proc/imageViewSize.height*rect.origin.y,w_proc/imageViewSize.width*rect.size.width,h_proc/imageViewSize.height*rect.size.height);
    cv::Mat SrcROIImg = img_proc(SrcImgROI);
    cv::Size wholeSize;
    cv::Point ofs;
    SrcROIImg.locateROI(wholeSize, ofs);
    Mat dest_image;
    SrcROIImg.convertTo(dest_image, CV_8UC1);
   
    Mat gray, canny;
    cvtColor(dest_image, gray, CV_BGR2GRAY); //灰度化处理
    blur(gray, gray, cv::Size(3,3));
    getCanny(gray, canny);   //寻找边缘
    
    // extract lines from the edge image
    vector<Vec4i> lines;
    vector<Line> horizontals, verticals;
    HoughLinesP(canny, lines, 1, CV_PI / 180, w_proc / 10, w_proc / 10, 20);
    
    NSMutableArray *pointArray = [NSMutableArray array];
    NSMutableDictionary *pointDictionary = [NSMutableDictionary dictionary];
    for (size_t i = 0; i < lines.size(); i++) {
        Vec4i v = lines[i];
        NSArray *linesPointArray = @[[NSValue valueWithCGPoint:CGPointMake(v[0]+ofs.x, v[1]+ofs.y)],[NSValue valueWithCGPoint:CGPointMake(v[2]+ofs.x, v[3]+ofs.y)]];
        NSLog(@"linesPointArray is :%@",linesPointArray);
        for (int i = 0;i < linesPointArray.count ;i ++) {
            CGPoint point = [linesPointArray[i] CGPointValue];
            NSLog(@"point is :(%f,%f)",point.x,point.y);
            if (pointDictionary[[NSString stringWithFormat:@"%f",point.x
                                 ]]) {
                NSMutableArray *array = [[NSMutableArray alloc] initWithArray: [pointDictionary objectForKey:[NSString stringWithFormat:@"%f",point.x]]];
                [array addObject:[NSValue valueWithCGPoint:point]];
                NSArray *result = [array sortedArrayUsingComparator:^NSComparisonResult(NSValue * obj1, NSValue * obj2) {
                    CGPoint point1 = [obj1 CGPointValue];
                    CGPoint point2 = [obj2 CGPointValue];
                    NSNumber *number1 = [NSNumber numberWithFloat:point1.y];
                    NSNumber *number2 = [NSNumber numberWithFloat:point2.y];
                    return [number1 compare: number2];
                }];
                [pointDictionary setObject:@[[result firstObject],[result lastObject]] forKey:[NSString stringWithFormat:@"%f",point.x]];
            }else{
                [pointDictionary setObject:@[[NSValue valueWithCGPoint:point]] forKey:[NSString stringWithFormat:@"%f",point.x]];
            }
        }
    }
     NSLog(@"pointDictionary is :%@",pointDictionary);
    NSArray *keyArray = [pointDictionary allKeys];
    NSArray *sortArray = [keyArray sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString * obj2) {
        return [[NSNumber numberWithDouble:[obj1 doubleValue]] compare: [NSNumber numberWithDouble:[obj2 doubleValue]]];
    }];
    for (int i = 0; i < sortArray.count; i ++) {
        NSArray *edgesPoint = [pointDictionary objectForKey:[sortArray objectAtIndex:i]];
        [pointArray addObject:[edgesPoint firstObject]];
    }
    for (int i = 0; i < sortArray.count; i ++) {
        NSArray *edgesPoint = [pointDictionary objectForKey:[sortArray objectAtIndex:(sortArray.count-1-i)]];
        [pointArray addObject:[edgesPoint lastObject]];
    }
     NSLog(@"pointArray is :%@",pointArray);
    return pointArray;
}

CGPoint clipImage(Mat file,CGPoint point,CGSize imageViewSize){
    Mat img = file;
    Mat img_proc;
    int w = img.size().width, h = img.size().height, min_w = 200;
    double scale = min(10.0, w * 1.0 / min_w);
    int w_proc = w * 1.0 / scale, h_proc = h * 1.0 / scale;
    
    resize(img, img_proc, cv::Size(w_proc, h_proc));
//    Mat rgbImage;
//    cvtColor(img_proc, rgbImage,  CV_RGBA2RGB);
//    Mat dstImg ;
//    pyrMeanShiftFiltering(rgbImage, dstImg, 20, 40);
    
    /* get four outline edges of the document */
    // get edges of the image
    cv::Rect SrcImgROI = cv::Rect(MIN(w_proc ,MAX(0, w_proc/imageViewSize.width*point.x-15)), MIN(h_proc,MAX(0,h_proc/imageViewSize.height*point.y-15)), MAX(1,1+MIN(29, (imageViewSize.width-point.x)*(w_proc/imageViewSize.width))), MAX(1,1+MIN(29, (imageViewSize.height-point.y)*(h_proc/imageViewSize.height))) );
    cv::Mat SrcROIImg = img_proc(SrcImgROI);
    cv::Size wholeSize;
    cv::Point ofs;
    SrcROIImg.locateROI(wholeSize, ofs);
    Mat dest_image;
    SrcROIImg.convertTo(dest_image, CV_8UC1);
    
    
//    Mat out;
//    Mat dilateImage;
//    Mat element = getStructuringElement(MORPH_RECT, cv::Size(3,3));
//
//    erode(dest_image, out, element);
//    dilate(out, dilateImage, element);
    
    
    

    Mat gray, canny;
    cvtColor(dest_image, gray, CV_BGR2GRAY); //灰度化处理
    blur(gray, gray, cv::Size(3,3));
    getCanny(gray, canny);   //寻找边缘

    // extract lines from the edge image
    vector<Vec4i> lines;
    vector<Line> horizontals, verticals;
    HoughLinesP(canny, lines, 1, CV_PI / 180, w_proc / 10, w_proc / 10, 20);
  
    NSMutableArray *pointArray = [NSMutableArray array];
    
    for (size_t i = 0; i < lines.size(); i++) {
        Vec4i v = lines[i];
        double delta_x = v[0] - v[2], delta_y = v[1] - v[3];
        Line l(cv::Point(v[0]+ofs.x, v[1]+ofs.y), cv::Point(v[2]+ofs.x, v[3]+ofs.y));
        
        [pointArray addObject:[NSValue valueWithCGPoint:CGPointMake(imageViewSize.width/w_proc*(v[0]+ofs.x), imageViewSize.height/h_proc*(v[1]+ofs.y))] ];
        [pointArray addObject:[NSValue valueWithCGPoint:CGPointMake(imageViewSize.width/w_proc*(v[2]+ofs.x), imageViewSize.height/h_proc*(v[3]+ofs.y))] ];
        // get horizontal lines and vertical lines respectively
        if (fabs(delta_x) > fabs(delta_y)) {
            horizontals.push_back(l);
           
                line(img_proc, cv::Point(v[0]+ofs.x, v[1]+ofs.y), cv::Point(v[2]+ofs.x, v[3]+ofs.y), Scalar(255, 0, 0),1);
        } else {
            verticals.push_back(l);
                line(img_proc, cv::Point(v[0]+ofs.x, v[1]+ofs.y), cv::Point(v[2]+ofs.x, v[3]+ofs.y), Scalar(0, 255, 0),1);
        }
    }
    double minDistance = 100;
    CGPoint cannyPoint = point;
    for (int i = 0; i < pointArray.count; i ++) {
      CGPoint indexPoint =   [[pointArray objectAtIndex:i] CGPointValue];
        if (minDistance > sqrt(pow((indexPoint.x - point.x), 2) + pow((indexPoint.y - point.y), 2))) {
            cannyPoint = indexPoint;
            minDistance = sqrt(pow((indexPoint.x - point.x), 2) + pow((indexPoint.y - point.y), 2));
        }
    }
   
    return cannyPoint;
}

cv::Mat scan(Mat file,int type, bool debug = true) {
    
    Mat img = file;
    Mat img_proc;
    
    int w = img.size().width, h = img.size().height, min_w = 200;
    double scale = min(10.0, w * 1.0 / min_w);
    int w_proc = w * 1.0 / scale, h_proc = h * 1.0 / scale;
    
    resize(img, img_proc, cv::Size(w_proc, h_proc));
    Mat rgbImage;
    cvtColor(img_proc, rgbImage,  CV_RGBA2RGB);
    Mat dstImg ;
    pyrMeanShiftFiltering(rgbImage, dstImg, 20, 40);
   
   
    
    
    /* get four outline edges of the document */
    // get edges of the image
    Mat gray, canny;
    cvtColor(dstImg, gray, CV_BGR2GRAY); //灰度化处理
    
    
    Mat out;
    Mat dilateImage;
    Mat element = getStructuringElement(MORPH_RECT, cv::Size(3,3));
    erode(img_proc, out, element);

    dilate(out , dilateImage, element);

    
    
    return dilateImage;
    
    blur(gray, gray, cv::Size(3,3));
    
    if (type == 1) {
        return gray;
    }
    getCanny(gray, canny);   //寻找边缘
    
    if (type == 2) {
        return canny;
    }
   
    
    // extract lines from the edge image
    vector<Vec4i> lines;
    vector<Line> horizontals, verticals;

    HoughLinesP(canny, lines, 1, CV_PI / 180, w_proc / 10, w_proc / 10, 20);
   
    for (size_t i = 0; i < lines.size(); i++) {
        Vec4i v = lines[i];
        double delta_x = v[0] - v[2], delta_y = v[1] - v[3];
        Line l(cv::Point(v[0], v[1]), cv::Point(v[2], v[3]));
        
        // get horizontal lines and vertical lines respectively
        if (fabs(delta_x) > fabs(delta_y)) {
            horizontals.push_back(l);
            if (debug)
                line(img_proc, cv::Point(v[0], v[1]), cv::Point(v[2], v[3]), Scalar(255, 0, 0),1);
        } else {
            verticals.push_back(l);
            if (debug)
                line(img_proc, cv::Point(v[0], v[1]), cv::Point(v[2], v[3]), Scalar(0, 255, 0),1);
        }
    }
    if (type == 3) {
        return img_proc;
    }
    
//     edge cases when not enough lines are detected
    if (horizontals.size() < 2) {
        if (horizontals.size() == 0 || horizontals[0]._center.y > h_proc / 2) {
            horizontals.push_back(Line(cv::Point(0, 0), cv::Point(w_proc - 1, 0)));
        }
        if (horizontals.size() == 0 || horizontals[0]._center.y <= h_proc / 2) {
            horizontals.push_back(Line(cv::Point(0, h_proc - 1), cv::Point(w_proc - 1, h_proc - 1)));
        }
    }
    if (verticals.size() < 2) {
        if (verticals.size() == 0 || verticals[0]._center.x > w_proc / 2) {
            verticals.push_back(Line(cv::Point(0, 0), cv::Point(0, h_proc - 1)));
        }
        if (verticals.size() == 0 || verticals[0]._center.x <= w_proc / 2) {
            verticals.push_back(Line(cv::Point(w_proc - 1, 0), cv::Point(w_proc - 1, h_proc - 1)));
        }
    }
    // sort lines according to their center point
    sort(horizontals.begin(), horizontals.end(), cmp_y);
    sort(verticals.begin(), verticals.end(), cmp_x);
    // for visualization only
    if (debug) {
        line(img_proc, horizontals[0]._p1, horizontals[0]._p2, Scalar(0, 255, 0), 2, CV_AA);
        line(img_proc, horizontals[horizontals.size() - 1]._p1, horizontals[horizontals.size() - 1]._p2, Scalar(0, 255, 0), 2, CV_AA);
        line(img_proc, verticals[0]._p1, verticals[0]._p2, Scalar(255, 0, 0), 2, CV_AA);
        line(img_proc, verticals[verticals.size() - 1]._p1, verticals[verticals.size() - 1]._p2, Scalar(255, 0, 0), 2, CV_AA);
    }
    /* perspective transformation */
    // define the destination image size: A4 - 200 PPI
    int w_a4 = 1654, h_a4 = 2339;
    //int w_a4 = 595, h_a4 = 842;
    Mat dst = Mat::zeros(h_a4, w_a4, CV_8UC3);

    // corners of destination image with the sequence [tl, tr, bl, br]
    vector<Point2f> dst_pts, img_pts;
    dst_pts.push_back(cv::Point(0, 0));
    dst_pts.push_back(cv::Point(w_a4 - 1, 0));
    dst_pts.push_back(cv::Point(0, h_a4 - 1));
    dst_pts.push_back(cv::Point(w_a4 - 1, h_a4 - 1));

    // corners of source image with the sequence [tl, tr, bl, br]
    img_pts.push_back(computeIntersect(horizontals[0], verticals[0]));
    img_pts.push_back(computeIntersect(horizontals[0], verticals[verticals.size() - 1]));
    img_pts.push_back(computeIntersect(horizontals[horizontals.size() - 1], verticals[0]));
    img_pts.push_back(computeIntersect(horizontals[horizontals.size() - 1], verticals[verticals.size() - 1]));

    // convert to original image scale
    for (size_t i = 0; i < img_pts.size(); i++) {
        // for visualization only
        if (debug) {
            circle(img_proc, img_pts[i], 10, Scalar(255, 255, 0), 3);
        }
        img_pts[i].x *= scale;
        img_pts[i].y *= scale;
    }

    // get transformation matrix
    Mat transmtx = getPerspectiveTransform(img_pts, dst_pts);

    // apply perspective transformation
    warpPerspective(img, dst, transmtx, dst.size());
    
    return dst;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
