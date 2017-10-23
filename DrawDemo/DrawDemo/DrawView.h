//
//  DrawView.h
//  DrawDemo
//
//  Created by 朱慧平 on 2017/8/1.
//  Copyright © 2017年 Crystal. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^FinishDraw)(NSMutableArray *pointArray); //定义一个block返回值void参数为颜色值
@interface DrawView : UIView
@property (assign, nonatomic) CGFloat lineWidth;
@property (strong, nonatomic) UIColor *lineColor;
@property (nonatomic , strong) FinishDraw finishDrawBlock;
- (void)drawCannyPath:(NSMutableArray *)pointArray;
@end
