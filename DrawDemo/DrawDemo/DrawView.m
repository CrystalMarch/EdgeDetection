//
//  DrawView.m
//  DrawDemo
//
//  Created by 朱慧平 on 2017/8/1.
//  Copyright © 2017年 Crystal. All rights reserved.
//

#import "DrawView.h"
#import "DrawViewModel.h"
#define VALUE(_INDEX_) [NSValue valueWithCGPoint:points[_INDEX_]]
#define POINT(_INDEX_) [(NSValue *)[points objectAtIndex:_INDEX_] CGPointValue]
#define granularity 5
@interface DrawView ()

@property (assign, nonatomic) CGMutablePathRef path;
@property (strong, nonatomic) NSMutableArray *pathArray;
@property (strong, nonatomic) NSMutableArray *pointArray;
@property (assign, nonatomic) BOOL isHavePath;
@property (assign, nonatomic) BOOL isCanny;
@property (assign, nonatomic)  UIBezierPath *cannyPath;
@end
@implementation DrawView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _lineWidth = 1.0f;
        _lineColor = [UIColor redColor];
        _pointArray = [NSMutableArray array];
    }
    return self;
}
- (void)drawCannyPath:(NSMutableArray *)pointArray{
    if (pointArray.count > 0) {
        _pointArray = pointArray;
        _isCanny = YES;
        [self setNeedsDisplay];
    }
}
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self drawView:context];
}
- (void)drawView:(CGContextRef)context
{
    if (_isCanny) {
        NSMutableArray *points = [_pointArray mutableCopy];
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetAllowsAntialiasing(context, YES);
        CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
        CGContextSetLineWidth(context, 0.6);
        
        UIBezierPath *smoothedPath = [UIBezierPath bezierPath];
        
        // Add control points to make the math make sense
        [points insertObject:[points objectAtIndex:0] atIndex:0];
        [points addObject:[points lastObject]];
        [smoothedPath moveToPoint:POINT(0)];
        
        for (NSUInteger index = 1; index < points.count - 2; index++) {
            CGPoint p0 = POINT(index - 1);
            CGPoint p1 = POINT(index);
            CGPoint p2 = POINT(index + 1);
            CGPoint p3 = POINT(index + 2);
            
            // now add n points starting at p1 + dx/dy up until p2 using Catmull-Rom splines
            for (int i = 1; i < granularity; i++) {
                
                float t = (float) i * (1.0f / (float) granularity);
                float tt = t * t;
                float ttt = tt * t;
                
                CGPoint pi; // intermediate point
                pi.x = 0.5 * (2*p1.x+(p2.x-p0.x)*t + (2*p0.x-5*p1.x+4*p2.x-p3.x)*tt + (3*p1.x-p0.x-3*p2.x+p3.x)*ttt);
                pi.y = 0.5 * (2*p1.y+(p2.y-p0.y)*t + (2*p0.y-5*p1.y+4*p2.y-p3.y)*tt + (3*p1.y-p0.y-3*p2.y+p3.y)*ttt);
                [smoothedPath addLineToPoint:pi];
            }
            
            // Now add p2
            [smoothedPath addLineToPoint:p2];
        }
        
        // finish by adding the last point
        [smoothedPath addLineToPoint:POINT(points.count - 1)];
        [smoothedPath addLineToPoint:POINT(0)];
        CGContextAddPath(context, smoothedPath.CGPath);
        CGContextDrawPath(context, kCGPathStroke);

    }else{
        for (DrawViewModel *drawViewModel in _pathArray) {
            CGContextAddPath(context, drawViewModel.path.CGPath);
            [drawViewModel.color set];
            CGContextSetLineWidth(context, drawViewModel.width);
            CGContextSetLineCap(context, kCGLineCapRound);
            CGContextDrawPath(context, kCGPathStroke);
        }
        if (_isHavePath) {
            CGContextAddPath(context, _path);
            [_lineColor set];
            CGContextSetLineWidth(context, _lineWidth);
            CGContextSetLineCap(context, kCGLineCapRound);
            CGContextDrawPath(context, kCGPathStroke);
        }
    }
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    _isCanny = NO;
    UITouch *touch = [touches anyObject];
    CGPoint location =[touch locationInView:self];
    [_pointArray removeAllObjects];
    [_pathArray removeAllObjects];
    [_pointArray addObject:[NSValue valueWithCGPoint:location]];
    _path = CGPathCreateMutable();
    _isHavePath = YES;
    CGPathMoveToPoint(_path, NULL, location.x, location.y);
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    [_pointArray addObject:[NSValue valueWithCGPoint:location]];
    CGPathAddLineToPoint(_path, NULL, location.x, location.y);
    [self setNeedsDisplay];
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_pathArray == nil) {
        _pathArray = [NSMutableArray array];
    }
   UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    [_pointArray addObject:[NSValue valueWithCGPoint:location]];
    _finishDrawBlock(_pointArray);
     NSMutableArray *points = [_pointArray mutableCopy];
    CGPathAddLineToPoint(_path, NULL, POINT(0).x, POINT(0).y);
    UIBezierPath *path = [UIBezierPath bezierPathWithCGPath:_path];
    DrawViewModel *drawViewModel = [DrawViewModel viewModelWithColor:_lineColor Path:path Width:_lineWidth];
    [_pathArray addObject:drawViewModel];
    CGPathRelease(_path);
    _isHavePath = NO;
}

@end
