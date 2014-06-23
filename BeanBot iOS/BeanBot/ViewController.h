//
//  ViewController.h
//  BeanBot
//
//  Created by Ben Harraway on 20/06/2014.
//  Copyright (c) 2014 Gourmet Pixel Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PTDBean.h"
#import "PTDBeanManager.h"
#import "PTDBeanRadioConfig.h"

#import "GradientView.h"

@interface ViewController : UIViewController <PTDBeanDelegate, PTDBeanManagerDelegate> {
    UILabel *statusLabel;
    
    GradientView *leftGradientView;
    GradientView *rightGradientView;
}

@property (nonatomic, retain) PTDBean *bean;
@property (nonatomic, retain) PTDBeanManager *beanManager;

@end
