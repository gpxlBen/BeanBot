//
//  ViewController.m
//  BeanBot
//
//  Created by Ben Harraway on 20/06/2014.
//  Copyright (c) 2014 Gourmet Pixel Ltd. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

#define servoOffDegrees 90
#define servoLeft 1         // Bean Scratch number for left servo
#define servoRight 2        // Bean Scratch number for right servo

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.beanManager = [[PTDBeanManager alloc] initWithDelegate:self];
    self.bean = nil;

    // Disconnect Bean if app goes into background
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disconnectBean) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    // Connect Bean when app is active
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startScanningSoon) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    self.view.multipleTouchEnabled = YES;
    
    leftGradientView = [[GradientView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.height/2, self.view.frame.size.width)];
    [leftGradientView setUserInteractionEnabled:NO];
    [self.view addSubview:leftGradientView];

    rightGradientView = [[GradientView alloc] initWithFrame:CGRectMake(self.view.frame.size.height/2, 0, self.view.frame.size.height/2, self.view.frame.size.width)];
    [rightGradientView setUserInteractionEnabled:NO];
    [self.view addSubview:rightGradientView];

    statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, ((self.view.frame.size.width-40)/2)+20, self.view.frame.size.height-20, 30)];
    [statusLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14]];
    [statusLabel setText:@"hello"];
    [statusLabel setTextColor:[UIColor lightGrayColor]];
    [statusLabel setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:statusLabel];
    
    UIView *middleLineView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.width/2, self.view.frame.size.height, 1)];
    [middleLineView setBackgroundColor:[UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:0.5]];
    [self.view addSubview:middleLineView];
    
    UILabel *lblBeanBot = [[UILabel alloc] initWithFrame:CGRectMake(0, ((self.view.frame.size.width-40)/2)-20, self.view.frame.size.height, 40)];
    [lblBeanBot setTextAlignment:NSTextAlignmentCenter];
    [lblBeanBot setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:30]];
    [lblBeanBot setText:@"BeanBot"];
    [self.view addSubview:lblBeanBot];
    
    UILabel *lblBeanBotHow = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.frame.size.width-40, self.view.frame.size.height, 40)];
    [lblBeanBotHow setTextAlignment:NSTextAlignmentCenter];
    [lblBeanBotHow setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14]];
    [lblBeanBotHow setText:@"Tap on left of screen to turn left, tap right to turn right.  Tap both to move forwards."];
    [self.view addSubview:lblBeanBotHow];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) startScanningSoon {
    [self performSelector:@selector(startScanning) withObject:nil afterDelay:1.5];
}

- (void) startScanning {
    if(self.beanManager.state == BeanManagerState_PoweredOn) {
        NSError *err;
        [self.beanManager startScanningForBeans_error:&err];
        statusLabel.text = @"Scanning";
        if (err) {
            statusLabel.text = [err localizedDescription];
        }
    } else {
        statusLabel.text = @"Bean Manager not powered on. Reload app to try again";
    }
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint touchPoint = [[touches anyObject] locationInView:self.view];
    [self calculateMovement:touchPoint];
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint touchPoint = [[touches anyObject] locationInView:self.view];
    [self calculateMovement:touchPoint];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint touchPoint = [[touches anyObject] locationInView:self.view];
    
    if (touchPoint.x < self.view.frame.size.height/2) {
        [self moveBeanBot:servoOffDegrees toServo:servoLeft];
        leftGradientView.inputY = nil;
        [leftGradientView setNeedsDisplay];
    } else {
        [self moveBeanBot:servoOffDegrees toServo:servoRight];
        rightGradientView.inputY = nil;
        [rightGradientView setNeedsDisplay];
    }
}

- (void) calculateMovement:(CGPoint)touchPoint {
    float maxY = 180;
    float screenMaxY = self.view.frame.size.width;
    
    unsigned int servoSpeed = floor((touchPoint.y / screenMaxY) * maxY);
    
    if (touchPoint.x < self.view.frame.size.height/2) {
        [self moveBeanBot:servoSpeed toServo:servoLeft];
        
        // Change Gradients
        leftGradientView.inputY = [NSNumber numberWithFloat:touchPoint.y];
        [leftGradientView setNeedsDisplay];
    } else {
        [self moveBeanBot:servoSpeed toServo:servoRight];
        
        // Change Gradients
        rightGradientView.inputY = [NSNumber numberWithFloat:touchPoint.y];
        [rightGradientView setNeedsDisplay];
    }
}

- (void) moveBeanBot:(unsigned int)sendData toServo:(int)toServo {
    // Because of the servo positions, we need to flip one servo from 0->180 to 180->0
    if (toServo == servoRight) sendData = 180-sendData;
    NSMutableData *data = [NSMutableData dataWithBytes:&sendData length:sizeof(sendData)];
    [self.bean setScratchNumber:toServo withValue:data];
}

- (void) sendDataToBean:(NSMutableData *)sendData {
    [self.bean setScratchNumber:1 withValue:sendData];
}

// bean discovered
- (void)BeanManager:(PTDBeanManager*)beanManager didDiscoverBean:(PTDBean*)aBean error:(NSError*)error{
    if (error) {
        statusLabel.text = [error localizedDescription];
        return;
    }
    statusLabel.text = [NSString stringWithFormat:@"Bean found: %@",[aBean name]];
    [self.beanManager connectToBean:aBean error:nil];
}

// bean connected
- (void)BeanManager:(PTDBeanManager*)beanManager didConnectToBean:(PTDBean*)bean error:(NSError*)error{
    if (error) {
        statusLabel.text = [error localizedDescription];
        return;
    }
    // do stuff with your bean
    statusLabel.text = @"Bean connected!";
    self.bean = bean;
    self.bean.delegate = self;
}

- (void)BeanManager:(PTDBeanManager*)beanManager didDisconnectBean:(PTDBean*)bean error:(NSError*)error {
    statusLabel.text = @"Bean disconnected.";
}

- (void) disconnectBean {
    NSError *err;
    [self.beanManager disconnectBean:self.bean error:&err];
    if (err) statusLabel.text = [err localizedDescription];
}

@end
