//
//  GradientView.m
//  BeanBot
//
//  Created by Ben Harraway on 23/06/2014.
//  Copyright (c) 2014 Gourmet Pixel Ltd. All rights reserved.
//

#import "GradientView.h"

@implementation GradientView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor clearColor]];
        _inputY = [NSNumber numberWithFloat:self.frame.size.height/2];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    float thisY = [_inputY floatValue];
    float topY = 0;
    float bottomY = 1.0;
    float screenMidY = self.frame.size.height/2;

    if (_inputY != nil && thisY != screenMidY) {
        CGContextRef currentContext = UIGraphicsGetCurrentContext();
        
        CGGradientRef glossGradient;
        CGColorSpaceRef rgbColorspace;
        rgbColorspace = CGColorSpaceCreateDeviceRGB();
        
        NSArray *colorArray = [NSArray arrayWithObjects:[UIColor darkGrayColor],[UIColor clearColor],[UIColor darkGrayColor], nil];
        if (thisY < screenMidY) {
            // In Top
            topY = (0.5/screenMidY) * thisY;
            
            colorArray = [NSArray arrayWithObjects:
                          [UIColor clearColor],
                          [UIColor clearColor],
                          [UIColor colorWithRed:0.06 green:0.57 blue:0.44 alpha:(1.0-topY)*0.5],
                          [UIColor clearColor],
                          [UIColor clearColor], nil];
            
            glossGradient = [self newGradientWithColors:colorArray locations:[NSArray arrayWithObjects:
                                                                              [NSNumber numberWithFloat:0.0],
                                                                              [NSNumber numberWithFloat:topY],
                                                                              [NSNumber numberWithFloat:topY+0.001],
                                                                              [NSNumber numberWithFloat:0.5],
                                                                              [NSNumber numberWithFloat:1.0], nil]];
            
        } else if (thisY > screenMidY) {
            // In Bottom
            bottomY = (0.5/screenMidY) * thisY;

            colorArray = [NSArray arrayWithObjects:
                          [UIColor clearColor],
                          [UIColor clearColor],
                          [UIColor colorWithRed:0.06 green:0.57 blue:0.44 alpha:bottomY*0.5],
                          [UIColor clearColor],
                          [UIColor clearColor], nil];
            
            glossGradient = [self newGradientWithColors:colorArray locations:[NSArray arrayWithObjects:
                                                                              [NSNumber numberWithFloat:0.0],
                                                                              [NSNumber numberWithFloat:0.5],
                                                                              [NSNumber numberWithFloat:bottomY],
                                                                              [NSNumber numberWithFloat:bottomY+0.001],
                                                                              [NSNumber numberWithFloat:1.0], nil]];
        }
        
        
        CGRect currentBounds = self.bounds;
        CGPoint topCenter = CGPointMake(CGRectGetMidX(currentBounds), 0.0f);
        CGPoint midCenter = CGPointMake(CGRectGetMidX(currentBounds), CGRectGetMaxY(currentBounds));
        CGContextDrawLinearGradient(currentContext, glossGradient, topCenter, midCenter, 0);
        
        CGGradientRelease(glossGradient);
        CGColorSpaceRelease(rgbColorspace);
    }
}

- (CGGradientRef)newGradientWithColors:(NSArray*)colorsArray locations:(NSArray*)locationsArray {
    
    int count = [colorsArray count];
    
    CGFloat* components = malloc(sizeof(CGFloat)*4*count);
    CGFloat* locations = malloc(sizeof(CGFloat)*count);
    
    for (int i = 0; i < count; ++i) {
        UIColor* color = [colorsArray objectAtIndex:i];
        NSNumber* location = (NSNumber*)[locationsArray objectAtIndex:i];
        size_t n = CGColorGetNumberOfComponents(color.CGColor);
        const CGFloat* rgba = CGColorGetComponents(color.CGColor);
        if (n == 2) {
            components[i*4] = rgba[0];
            components[i*4+1] = rgba[0];
            components[i*4+2] = rgba[0];
            components[i*4+3] = rgba[1];
        } else if (n == 4) {
            components[i*4] = rgba[0];
            components[i*4+1] = rgba[1];
            components[i*4+2] = rgba[2];
            components[i*4+3] = rgba[3];
        }
        locations[i] = [location floatValue];
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGColorSpaceRef space = CGBitmapContextGetColorSpace(context);
    CGGradientRef gradient = CGGradientCreateWithColorComponents(space, components, locations, count);
    free(components);
    free(locations);
    return gradient;
}

@end
