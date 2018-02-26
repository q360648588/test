//
//  ViewController.h
//  buletoothDemo
//
//  Created by Jeff on 16/12/8.
//  Copyright © 2016年 Jeff. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface ViewController : UIViewController

@property (nonatomic,strong)CBPeripheral *PeripheralDevice;

@end

