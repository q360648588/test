//
//  CALayer+colorChange.m
//  testToSpeech
//
//  Created by Jeff on 17/4/12.
//  Copyright © 2017年 Jeff. All rights reserved.
//

#import "CALayer+colorChange.h"

@implementation CALayer (colorChange)

-(void)setBorderUIColor:(UIColor*)color
{
    self.borderColor = color.CGColor;
}
-(UIColor*)borderUIColor
{
    return [UIColor colorWithCGColor:self.borderColor];
}

@end
