//
//  ViewController.m
//  buletoothDemo
//
//  Created by Jeff on 16/12/8.
//  Copyright © 2016年 Jeff. All rights reserved.
//

#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

#import "ViewController.h"

static unsigned int count = 0;

@interface ViewController ()<CBPeripheralDelegate,CBCentralManagerDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong)UITableView *tableView;
@property (nonatomic,strong)UITextView *textView;
@property (nonatomic,strong)CBCentralManager *centralManager;
@property (nonatomic,strong)NSMutableArray *deviceArr;
@property (nonatomic,strong)CBCharacteristic *characteristic;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"蓝牙";
    
    [self getTableView];
    
    [self getBluetoothManager];
    
    [self getTextView];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"点击搜索" style:UIBarButtonItemStylePlain target:self action:@selector(search)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"点击" style:UIBarButtonItemStylePlain target:self action:@selector(PeripheralState)];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(PeripheralState) name:@"stateConnected" object:nil];
}
-(void)PeripheralState{
    NSLog(@"被点击");
    UInt8 v[2] = {0x02,0x02};
    NSData *sdata = [[NSData alloc] initWithBytes:v length:2];
    [self.PeripheralDevice writeValue:sdata forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
    NSLog(@"%@",self.characteristic);
}
-(void)getTableView{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 3*ScreenHeight/4)];
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.deviceArr.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    CBPeripheral *peripheral;
    if (self.deviceArr.count>indexPath.row ){
//        NSLog(@"%lu,%ld",self.deviceArr.count,(long)indexPath.row);
        peripheral = self.deviceArr[indexPath.row][0];
        cell.textLabel.text = [NSString stringWithFormat:@"%@,state = %ld,RSSI = %@",peripheral.name,peripheral.state,self.deviceArr[indexPath.row][1]];
    }
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self cancelConnection];
    self.PeripheralDevice = self.deviceArr[indexPath.row][0];
    [self.centralManager connectPeripheral:self.PeripheralDevice options:nil];
    self.PeripheralDevice.delegate = self;
    
    NSLog(@"连接设备%@",self.PeripheralDevice);
}
-(void)getBluetoothManager{
    //不放在主线，防止在搜索的时候卡顿
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
}
//必须实现的代理方法  检测蓝牙状态
-(void)centralManagerDidUpdateState:(CBCentralManager *)central{
    switch (central.state) {
            
        case CBManagerStateUnknown:
            
            break;
            
        case CBManagerStateUnsupported:
            
            NSLog(@"模拟器不支持蓝牙调试");
            
            break;
            
        case CBManagerStateUnauthorized:
            
            NSLog(@"设备未授权");
            
            break;
            
        case CBManagerStatePoweredOff:
            
            NSLog(@"蓝牙处于关闭状态");
            
            break;
            
        case CBManagerStateResetting:
            
            break;
            
        case CBManagerStatePoweredOn:
            
            NSLog(@"蓝牙已开启");
            //蓝牙开启之后必须用此方法开启  扫描外围设备   不然没反应
            //第一个参数是否过滤其他设备之显示参数的设备
            //第二个参数   @{CBCentralManagerScanOptionAllowDuplicatesKey:@YES}
            //        [self.MyCentralManager  scanForPeripheralsWithServices:nil  options:nil];
            break;
    }

}
#pragma mark 开始扫描
-(void)search{
    NSLog(@"开始扫描");
    //取消延时方法
    [self.deviceArr removeAllObjects];
    [self.centralManager stopScan];
    [self cancelConnection];
    //扫描到设备之后会调用并在didDiscoverPeripheral方法显示扫描到的设备
    [self.centralManager scanForPeripheralsWithServices:[NSArray arrayWithObjects:[CBUUID UUIDWithString:@"00000af0-0000-1000-8000-00805f9b34fb"], nil] options:nil];
    
    /*
    //gcd延时停止扫描
    //gcd扫描不能取消延时   需要在block里面添加判断是否执行
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.centralManager stopScan];
        count = 0;
        NSLog(@"停止扫描");
    });
    */
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stop) object:nil];
    [self performSelector:@selector(stop) withObject:nil afterDelay:5.0];
}
-(void)stop{
    [self.centralManager stopScan];
    count = 0;
    NSLog(@"停止扫描");
}
#pragma mark 扫描到设备
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI{
    [self updateTextView:[NSString stringWithFormat:@"%@",peripheral]];
    NSArray *arr = [NSArray arrayWithObjects:peripheral,RSSI, nil];
    if (peripheral.name) {
        [self.deviceArr addObject:arr];
        [self.deviceArr sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            if ([obj1[1] intValue] < [obj2[1] intValue]) {
                return NSOrderedDescending;
            }
            
            if ([obj1[1] intValue] > [obj2[1] intValue]) {
                return NSOrderedAscending;
            }
            return NSOrderedSame;
        }];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}
#pragma mark 连接到设备
-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    [peripheral discoverServices:nil];
}
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(nonnull CBPeripheral *)peripheral error:(nullable NSError *)error{
    
}
#pragma mark 断开已连接的设备
-(void)cancelConnection{
    if (self.PeripheralDevice) {
        NSLog(@"断开连接%@",self.PeripheralDevice);
        [self.centralManager cancelPeripheralConnection:self.PeripheralDevice];
        self.PeripheralDevice.delegate = nil;
        self.PeripheralDevice = nil;
    }
}
#pragma mark 发现服务
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    for (CBService *service in peripheral.services) {
        NSLog(@"service = %@",service);
        
        if ([service.UUID isEqual:[CBUUID UUIDWithString:@"00000af0-0000-1000-8000-00805f9b34fb"]])
        {
            [self.PeripheralDevice discoverCharacteristics:@[[CBUUID UUIDWithString:@"00000af6-0000-1000-8000-00805f9b34fb"],[CBUUID UUIDWithString:@"00000af7-0000-1000-8000-00805f9b34fb"],[CBUUID UUIDWithString:@"00000af1-0000-1000-8000-00805f9b34fb"],[CBUUID UUIDWithString:@"00000af2-0000-1000-8000-00805f9b34fb"]] forService:service];
        }
        else if ([service.UUID isEqual:[CBUUID UUIDWithString:@"180A"]])
        {
            [self.PeripheralDevice discoverCharacteristics:@[[CBUUID UUIDWithString:@"2A27"]] forService:service];
        }
    }
}
-(void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    [peripheral readValueForCharacteristic:characteristic];
}
#pragma mark 发现特征
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    NSLog(@"characteristics = %@",[service characteristics]);
    for (CBCharacteristic *chara in [service characteristics]) {
        if ([chara.UUID isEqual:[CBUUID UUIDWithString:@"00000af7-0000-1000-8000-00805f9b34fb"]] || [chara.UUID isEqual:[CBUUID UUIDWithString:@"00000af2-0000-1000-8000-00805f9b34fb"]] || [CBUUID UUIDWithString:@"00001531-1212-EFDE-1523-785FEABCD123"]) {
            [self.PeripheralDevice setNotifyValue:YES forCharacteristic:chara];
//            NSData *data = chara.value;
//            UInt8 val[20] = {0};
//            [data getBytes:&val length:data.length];
//            NSLog(@"%d,%d,%d,%d",val[4],val[5],val[6],val[7]);
        }else if ([chara.UUID isEqual:[CBUUID UUIDWithString:@"00000af6-0000-1000-8000-00805f9b34fb"]]){
            self.characteristic = chara;
        }else if ([chara isEqual:[CBUUID UUIDWithString:@"00001534-1212-EFDE-1523-785FEABCD123"] ]){
            [self.PeripheralDevice readValueForCharacteristic:chara];
        }
    }
}
#pragma marl 写入数据
-(void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error{
    NSLog(@"错误信息%@",error);
}
#pragma mark 数据处理
-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    NSData *data = characteristic.value;
    UInt8 val[20] = {0};
    [data getBytes:&val length:data.length];
    if (val[0] == 0x02)
    {
        if (val[1] == 0x01)
        {
            NSLog(@"1111");
//            UInt8 v[2] = {0x02,2};
//            NSData *sdata = [[NSData alloc] initWithBytes:v length:2];
//            [self.PeripheralDevice writeValue:sdata forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
            NSLog(@"%d",val[7]);
        }else if (val[1] == 0x02){
            NSLog(@"222");
//            UInt8 v[2] = {0x02,0x02};
//            NSData *sdata = [[NSData alloc] initWithBytes:v length:2];
//            [self.PeripheralDevice writeValue:sdata forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
//            UInt8 a[20] = {0};
//            [data getBytes:&a length:data.length];
            NSLog(@"%d",val[6]&0x01);
        }
    }
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"stateConnected" object:nil];
}
-(void)getTextView{
    self.textView = [[UITextView alloc] initWithFrame:CGRectMake(0,3*ScreenHeight/4+10, ScreenWidth, 200)];
    self.textView.backgroundColor = [UIColor whiteColor];
    //设置不能编辑，阻止键盘弹出
    self.textView.editable = NO;
    [self.view addSubview:self.textView];
}
-(void)updateTextView:(NSString *)text{
    dispatch_async(dispatch_get_main_queue(), ^{
        //reason: 'Only run on the main thread!'..不放在主线程会崩
        [self.textView setText:[NSString stringWithFormat:@"[%d]%@ \n%@\n",count,text,self.textView.text]];
    });
    count++;
}


-(NSMutableArray *)deviceArr{
    if (!_deviceArr) {
        _deviceArr = [NSMutableArray array];
    }
    return _deviceArr;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
