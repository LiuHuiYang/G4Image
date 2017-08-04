//
//  SHZoneDetailViewController.m
//  G4Image
//
//  Created by LHY on 2017/4/4.
//  Copyright © 2017年 SmartHomeGroup. All rights reserved.
//

#import "SHZoneDetailViewController.h"
#import "SHZoneView.h"
#import "SHSettingViewController.h"

#import "SHUdpSocket.h"
#import "SHSQLiteManager.h"

#import "SHSelectColorViewController.h"


#import "SHSetAreaView.h"
#import "SHZoneDetailViewTitleView.h"

/// 按钮间距
const CGFloat SHDeviceButtonPadding = 5;

@interface SHZoneDetailViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIGestureRecognizerDelegate, SHUdpSocketDelegate, SHSetAreaViewDelegate>


/// 选择不同的设备列表
@property (strong, nonatomic) UIScrollView *deviceListView;

/// 设备列表种称
@property (strong, nonatomic) NSArray *deviceKinds;

/// 显示图片的位置
@property (strong, nonatomic) SHZoneView *showZoneView;

/// 调用区域场景列表【设置 && 选择列表】
@property (nonatomic, strong) SHSetAreaView *setAreaView;

/// 标题view
@property (strong, nonatomic) SHZoneDetailViewTitleView* zoneTitleView;

@end

@implementation SHZoneDetailViewController

#pragma mark - 解析数组

/// 解析收到的数据
- (void)analyzeReceiveData:(NSData *)data {
    
    [SHAnalyDeviceData analyDeviceData:data inZone:self.zone];
}

// MARK: - 设备区域的代理回调

/// 获得图片的代理回调
- (void)setAreaViewPictureForZone:(UIImage *)image {
    
    // 修改比例为最初比例
    self.zone.imageScale = 1.0;
    
    // 准备图征保存在沙盒中
    [UIImage writeImageToDocment:self.zone.zoneID data: image];
    
    // 设置图片
    [self.showZoneView setImageForZone:image scale:self.zone.imageScale];
    
    // 保存当前区域
    [[SHSQLiteManager shareSHSQLiteManager] inserNewZone:self.zone];
}


/// 显示设备列表的代理回调
- (void)setAreaViewShowDeviceList:(UIButton *)deviceButton {
    
    self.deviceListView.hidden = !deviceButton.selected;
    
    // 控制手势来控制
    self.showZoneView.scrollView.pinchGestureRecognizer.enabled = deviceButton.selected;
    
    // 选遍历区域中的子控件
    for (SHDeviceButton *button in self.zone.allDeviceButtonInCurrentZone) {
        
        // 移除所有的手势
        for (UIGestureRecognizer *recognizer in button.gestureRecognizers) {
            [button removeGestureRecognizer:recognizer];
        }
        
        // 选中才可以移动
        if (deviceButton.selected) {
            
            // 添加两个新手势
            UIPanGestureRecognizer *panMove = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(moveToTargetLocation:)];
            [button addGestureRecognizer:panMove];
            
            UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(setArgs:)];
            longPress.minimumPressDuration = 1.5;
            longPress.cancelsTouchesInView = YES;
            [button addGestureRecognizer:longPress];
            
            // 没有选中做其他事情
        } else {
            
            // 匹配不同的按钮类型再添加手势
            switch (button.deviceType) {
                    
                case SHDeviceButtonTypeLight: {
                    
                    UIPanGestureRecognizer *panMove = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(updateLightValue:)];
                    [panMove setTranslation:CGPointZero inView:button];
                    [button addGestureRecognizer:panMove];
                }
                    
                    break;
                    
                case SHDeviceButtonTypeCurtain: {
                    
                }
                    break;
                    
                case  SHDeviceButtonTypeAudio: {
                    
                    UIPanGestureRecognizer *panMove = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(updateAuidoVOL:)];
                    panMove.delegate = self;
                    [panMove setTranslation:CGPointZero inView:button];
                    [button addGestureRecognizer:panMove];
                    
                    UISwipeGestureRecognizer *toLeftDetail = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(toLeftAndRightDetail:)];
                    toLeftDetail.delegate = self;
                    toLeftDetail.direction=UISwipeGestureRecognizerDirectionLeft;
                    [button addGestureRecognizer:toLeftDetail];
                    
                    UISwipeGestureRecognizer *toRightDetail = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(toLeftAndRightDetail:)];
                    toRightDetail.delegate = self;
                    toRightDetail.direction=UISwipeGestureRecognizerDirectionRight;
                    [button addGestureRecognizer:toRightDetail];
                    
                    [panMove requireGestureRecognizerToFail:toLeftDetail];
                    [panMove requireGestureRecognizerToFail:toRightDetail];
                }
                    break;
                    
                case SHDeviceButtonTypeAirConditioning: {
                    
                    UIPanGestureRecognizer *panMove = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(updateACTempture:)];
                    [panMove setTranslation:CGPointZero inView:button];
                    [button addGestureRecognizer:panMove];
                }
                    break;
                    
                default:
                    break;
            }
        }
    }
    
    // 没有选中
    if (!deviceButton.selected) {
        
        [self saveCurrentZone];
    }
}

/// 保存当前区域
- (void)saveCurrentZone {
    
    // 获得名称
    self.zone.zoneName = self.zoneTitleView.name;
    
    // 获得当前比例
    self.zone.imageScale = self.showZoneView.scrollView.zoomScale;
    
    // 更新当前区域的所有信息
    [[SHSQLiteManager shareSHSQLiteManager] saveCurrentZonesButtons:self.zone];
}

/// 删除这个区域的回调
- (void)setAreaViewDeleteZone {
    
    if (self.isNew) {
        return;
    }
    
    // 数据库删除这个区域记录
    [[SHSQLiteManager shareSHSQLiteManager] deleteCurrntZone:self.zone];
    
    // 删除图片
    [UIImage deleteImageFromDocment:self.zone.zoneID];
    
    // 回到预览
    [self.navigationController popViewControllerAnimated:YES];
}

// MARK: - UI

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    [self saveCurrentZone];
}

/// 进入界面不能缩放
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // 禁止scrollView缩放
    self.showZoneView.scrollView.pinchGestureRecognizer.enabled = NO;
    
    // 给当前所有的设备按钮来读取状态
    for (SHDeviceButton *button in self.zone.allDeviceButtonInCurrentZone) {
        
        [SHSendDeviceData readDeviceStatus:button];
    }
}

/// 界面加载
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 1.设置背景颜色
    self.view.backgroundColor = SHGlobalBackgroundColor;
    
    // 取消自动偏移
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    // 2.设置导航栏
    [self setNavigationBar];
    
    // 3.显示中间的图片区域
    [self showZones];
    
    // 4.设置右边的按钮选择列表
    [self.view addSubview:self.deviceListView];
    self.deviceListView.hidden = YES;
    
    // 初始化socket设置代理
    [SHUdpSocket shareSHUdpSocket].delegate = self;
}

/// 显示区域信息
- (void)showZones {
    
    [self.view insertSubview:self.showZoneView belowSubview:self.setAreaView];
    
    // 获得当前区域的图片
    UIImage *image = [UIImage getImageForZones:self.zone.zoneID];
    if (!image) {
        return;
    }
    
    // 设置图片
    [self.showZoneView setImageForZone:image scale:self.zone.imageScale];
    
    // 获得当前区域的所有按钮
    self.zone.allDeviceButtonInCurrentZone = [[SHSQLiteManager shareSHSQLiteManager] getAllButtonsForCurrentZone:self.zone];
    
    for (SHDeviceButton *button in self.zone.allDeviceButtonInCurrentZone) {
        
        [self addButtonModel:button];
    }
}

/// 添加保存的所有按钮到显示器上
- (void)addButtonModel:(SHDeviceButton *)button {
    
    // 匹配不同的按钮有不同的交互
    switch (button.deviceType) {
            
        case  SHDeviceButtonTypeLight: {  // 灯
            
            [button addTarget:self action:@selector(lightPressed:) forControlEvents:UIControlEventTouchUpInside];
            
            // 增加值变化
            UIPanGestureRecognizer *panMove = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(updateLightValue:)];
            [panMove setTranslation:CGPointZero inView:button];
            [button addGestureRecognizer:panMove];
        }
            break;
            
        case SHDeviceButtonTypeAirConditioning: { // 空调
            
            [button addTarget:self action:@selector(acOnAndOff:) forControlEvents:UIControlEventTouchUpInside];
            
            // 增加值变化
            UIPanGestureRecognizer *panMove = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(updateACTempture:)];
            [panMove setTranslation:CGPointZero inView:button];
            [button addGestureRecognizer:panMove];
        }
            break;
            
        case  SHDeviceButtonTypeAudio: { // 音乐
            
            [button addTarget:self action:@selector(musicPlayAndStop:) forControlEvents:UIControlEventTouchUpInside];
            
            // 1.增加拖拽手势
            UIPanGestureRecognizer *panMove = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(updateAuidoVOL:)];
            
            // 设置代理
            panMove.delegate = self;

            [panMove setTranslation:CGPointZero inView:button];
            [button addGestureRecognizer:panMove];
            

            // 2.清扫手势上一首
            UISwipeGestureRecognizer *toLeftDetail = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(toLeftAndRightDetail:)];
            toLeftDetail.delegate = self;
            toLeftDetail.direction = UISwipeGestureRecognizerDirectionLeft;//不设置默认为右
            [button addGestureRecognizer:toLeftDetail];
            
            // 3.清扫手势下一首
            UISwipeGestureRecognizer *toRightDetail = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(toLeftAndRightDetail:)];
            toRightDetail.delegate = self;
            toRightDetail.direction=UISwipeGestureRecognizerDirectionRight;
            [button addGestureRecognizer:toRightDetail];
            
            // 4.设置手势依赖
            [panMove requireGestureRecognizerToFail:toLeftDetail];
            [panMove requireGestureRecognizerToFail:toRightDetail];
            
        }
            break;
            
        case SHDeviceButtonTypeCurtain: {
            
             [button addTarget:self action:@selector(curtainPressed:) forControlEvents:UIControlEventTouchUpInside];
        }
            
            break;
            
        case SHDeviceButtonTypeMediaTV: { // 电视
            
            [button addTarget:self action:@selector(watchTvPressed:) forControlEvents:UIControlEventTouchUpInside];
        }
            break;
            
        case SHDeviceButtonTypeLed: {
            
            [button addTarget:self action:@selector(ledPressed:) forControlEvents:UIControlEventTouchUpInside];
        }
            break;
            
        default:
            break;
    }
    
    button.frame = button.buttonRectSaved;
    [self.showZoneView.scrollView addSubview:button];
}

/// 设置导航栏
- (void)setNavigationBar {
    
    // 设置右侧导航栏为setting
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem barButtonItemWithImageName:@"setting" hightlightedImageName:@"setting" addTarget:self action:@selector(settingRooms)];
    
    [self.view addSubview:self.setAreaView];
    self.setAreaView.hidden = YES;
    
    
    //  设置中间的标题
    self.zoneTitleView.name = self.zone.zoneName;
    
    self.navigationItem.titleView = self.zoneTitleView;
    
    self.navigationItem.titleView.backgroundColor = self.navigationController.navigationBar.backgroundColor;
}

/// 设置区域信息
- (void)settingRooms {
    
    self.setAreaView.hidden = !self.setAreaView.hidden;
}

// MARK: - 区域场景的选择

#pragma mark - 手势所有的操作

/// 切换音乐
- (void)toLeftAndRightDetail:(UISwipeGestureRecognizer *)recognizer {
    
    [SHSendDeviceData switchMusic:recognizer];
}

/// 调整声音的大小
- (void)updateAuidoVOL:(UIPanGestureRecognizer *)recognizer {
    
    [SHSendDeviceData updateAuidoVOL:recognizer];
}

/// 改变AC的温度值
- (void)updateACTempture:(UIPanGestureRecognizer *)recognizer {
    
    [SHSendDeviceData updateACTempture:recognizer];
}

/// 改变灯光的值
- (void)updateLightValue:(UIPanGestureRecognizer *)recognizer {
  
    [SHSendDeviceData updateDimmerBrightness:recognizer];
}

///  单击选择设备
- (void)selectDeviceTouched:(SHDeviceButton *)button {
    
    // 创建一个新的按钮
    SHDeviceButton *newButton = [SHDeviceButton deviceButtonType:button.deviceType];
    
    newButton.bounds = button.bounds;
    newButton.frame_x = self.showZoneView.frame_CenterX;
    newButton.frame_y = self.showZoneView.frame_CenterX * 0.5 + (button.tag) * button.frame_height;
    
    // 添加到界面上
    [self.showZoneView.scrollView addSubview:newButton];
    newButton.buttonRectSaved = newButton.frame;
    
    // 添加到个数组中去
    [self.zone.allDeviceButtonInCurrentZone addObject:newButton];
    
    // 设置属性
    newButton.subNetID = 1; // 默认是1
    newButton.deviceType = button.deviceType;
    newButton.zoneID = self.zone.zoneID;
    newButton.buttonID = [[SHSQLiteManager shareSHSQLiteManager] getMaxButtonID] + 1;
    newButton.deviceType = button.deviceType;
    
    // 设置图片
    switch (button.deviceType) {
        case  SHDeviceButtonTypeLight:

            [newButton addTarget:self action:@selector(lightPressed:) forControlEvents:UIControlEventTouchUpInside];
            break;
            
        case SHDeviceButtonTypeAirConditioning:
            
            [newButton addTarget:self action:@selector(acOnAndOff:) forControlEvents:UIControlEventTouchUpInside];
            break;
            
        case  SHDeviceButtonTypeAudio:
            
            [newButton addTarget:self action:@selector(musicPlayAndStop:) forControlEvents:UIControlEventTouchUpInside];
            
            break;
            
        case SHDeviceButtonTypeCurtain:
            
            [newButton addTarget:self action:@selector(curtainPressed:) forControlEvents:UIControlEventTouchUpInside];
            
            break;
            
        case SHDeviceButtonTypeMediaTV:
            
             [newButton addTarget:self action:@selector(watchTvPressed:) forControlEvents:UIControlEventTouchUpInside];
            
            break;
            
        case SHDeviceButtonTypeLed:
            
             [newButton addTarget:self action:@selector(ledPressed:) forControlEvents:UIControlEventTouchUpInside];
            
            break;
            
        default:
            break;
    }
    
    // 添加移动手势
    UIPanGestureRecognizer *panMove = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveToTargetLocation:)];
    [newButton addGestureRecognizer:panMove];
    
    // 添加长按手势
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(setArgs:)];
    
    // 设置长按时间
    longPress.minimumPressDuration = 1.5;
    longPress.cancelsTouchesInView = YES; // 默认也是YES
    [newButton addGestureRecognizer:longPress];
    
    // 此进应该选保存一次，这是最新的按钮
    [[SHSQLiteManager shareSHSQLiteManager] inserNewButton:newButton];
}

/// 长按修改参数
- (void)setArgs:(UILongPressGestureRecognizer *)recognizer  {
    
    // 长按修改参数
    if (recognizer.state != UIGestureRecognizerStateBegan ) {
        return;
    }
    
    SHSettingViewController *settingViewController = [[UIStoryboard storyboardWithName:NSStringFromClass([SHSettingViewController class]) bundle:nil] instantiateInitialViewController];
    
    // 设置长按的按钮
    settingViewController.settingButton = (SHDeviceButton *)recognizer.view;
    settingViewController.sourceViewController = self;
    
    [self.navigationController pushViewController:settingViewController animated:YES];
}

/// 移动到目标区域
- (void)moveToTargetLocation:(UIPanGestureRecognizer *)recognizer {
    
    // 获得按钮
    SHDeviceButton *button = (SHDeviceButton *)recognizer.view;
    
    // 移动的距离 -> 转换成在相关的控件中的位置
    CGPoint point = [recognizer translationInView:self.showZoneView];
    
    button.center =  CGPointMake(button.frame_CenterX + point.x, button.frame_CenterY + point.y);
    
    //  因为拖动起来一直是在递增，所以每次都要用setTranslation:方法制0这样才不至于不受控制般滑动出视图
    [recognizer setTranslation:CGPointZero inView:self.showZoneView];
}

/// 手势代理
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return NO;
}

// MARK: - 设备的开和关

/// 播放电视
- (void)watchTvPressed:(SHDeviceButton *)button {
    
    [SHSendDeviceData watchTv:button];
}

/// 窗帘移动
- (void)curtainPressed:(SHDeviceButton *)button {

    [SHSendDeviceData curtainOpenOrClose:button];
}

/// 音乐播放
- (void)musicPlayAndStop:(SHDeviceButton *)button {
    
    [SHSendDeviceData musicPlayAndStop:button];
}

/// AC 空调开关
- (void)acOnAndOff:(SHDeviceButton *)button {
    [SHSendDeviceData acOnAndOff:button];
}

/// 开关点击
- (void)lightPressed:(SHDeviceButton *)button {
    
    [SHSendDeviceData setDimmer:button];
}

/// LED的开关被点击
- (void)ledPressed:(SHDeviceButton *)button {

    [SHSendDeviceData ledOnAndOff:button];
}

// MARK: - getter && setter

/// 标题列表
- (SHZoneDetailViewTitleView *)zoneTitleView {
    
    if (!_zoneTitleView) {
        _zoneTitleView = [SHZoneDetailViewTitleView zoneTitleView];
    }
    return _zoneTitleView;
}

// 设置区域列表
- (SHSetAreaView *)setAreaView {
        
        if (!_setAreaView) {
            _setAreaView = [SHSetAreaView setAreaView];
            _setAreaView.delegate = self;
        }
        return _setAreaView;
    }

/// 选择设备列表框
- (UIScrollView *)deviceListView {
    
    if (!_deviceListView) {
        
        _deviceListView = [[UIScrollView alloc] init];
        _deviceListView.showsVerticalScrollIndicator = YES;
//        _deviceListView.pagingEnabled = YES;
        
        _deviceListView.contentSize = CGSizeMake(0, self.deviceKinds.count * SHNavigationBarHeight);
        
        for (NSUInteger i = 0; i < self.deviceKinds.count; i++) {
            
            SHDeviceButton *button = [SHDeviceButton deviceButtonType:(SHDeviceButtonType)[self.deviceKinds[i] integerValue]];
            
            button.tag = i;
            
            // 点击显示出来
            [button addTarget:self action:@selector(selectDeviceTouched:) forControlEvents:UIControlEventTouchUpInside];
            
            [_deviceListView addSubview:button];
        }
    }
    return _deviceListView;
}

- (NSArray *)deviceKinds {

    if (!_deviceKinds) {
        _deviceKinds =  @[@(SHDeviceButtonTypeLight), @(SHDeviceButtonTypeLed), @(SHDeviceButtonTypeAirConditioning), @(SHDeviceButtonTypeAudio),  @(SHDeviceButtonTypeCurtain), @(SHDeviceButtonTypeMediaTV)];
    }
    return _deviceKinds;
}

/// 场景视图
- (SHZoneView *)showZoneView {
    
    if (!_showZoneView) {
        _showZoneView = [[SHZoneView alloc] init];
    }
    return _showZoneView;
}

/// 依据屏幕方向来匹配不同的位置
- (void)viewDidLayoutSubviews {
    
     self.setAreaView.frame = CGRectMake(self.view.frame_width - [SHSetAreaView areaViewSize].width, SHNavigationBarHeight, [SHSetAreaView areaViewSize].width, [SHSetAreaView areaViewSize].height);
    
    // 0.中间场景区域的图形
    self.showZoneView.frame = CGRectMake(0, SHNavigationBarHeight, self.view.frame_width, self.view.frame_height - SHNavigationBarHeight - SHTabBarHeight);
        
    // 2.选择设备列表
     self.deviceListView.frame = CGRectMake(self.view.frame_width - self.setAreaView.frame_width, self.setAreaView.frame_height + self.setAreaView.frame_y, self.setAreaView.frame_width, self.setAreaView.frame_height);
    
    for (NSUInteger i = 0; i < self.deviceListView.subviews.count; i++) {
        UIView *subView = self.deviceListView.subviews[i];
        
        if ([subView isKindOfClass:[SHDeviceButton class]]) {
            subView.frame = CGRectMake(SHDeviceButtonPadding, subView.tag * SHNavigationBarHeight , self.deviceListView.frame_width, SHNavigationBarHeight - SHDeviceButtonPadding);
        }
    }
}

@end
