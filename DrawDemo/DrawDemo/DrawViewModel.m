//
//  DrawViewModel.m
//  DrawDemo
//
//  Created by 朱慧平 on 2017/8/1.
//  Copyright © 2017年 Crystal. All rights reserved.
//

#import "DrawViewModel.h"

@implementation DrawViewModel

+ (id)viewModelWithColor:(UIColor *)color Path:(UIBezierPath *)path Width:(CGFloat)width
{
    DrawViewModel *drawViewModel = [[DrawViewModel alloc] init];
    
    drawViewModel.color = color;
    drawViewModel.path = path;
    drawViewModel.width = width;
    
    return drawViewModel;
}
@end

