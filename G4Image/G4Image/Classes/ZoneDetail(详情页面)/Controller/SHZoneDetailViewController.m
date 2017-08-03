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
@property (strong, nonatomic) UIScrollView *selectDeviceButtonScrollView;

/// 设备列表名称
@property (strong, nonatomic) NSArray *selectNames;

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
    [SHUtility writeImageToDocment:self.zone.zoneID data: image];
    
    // 设置图片
    [self.showZoneView setImageForZone:image scale:self.zone.imageScale];
    
    // 保存当前区域
    [[SHSQLiteManager shareSHSQLiteManager] inserNewZone:self.zone];
}


/// 显示设备列表的代理回调
- (void)setAreaViewShowDeviceList:(UIButton *)deviceButton {
    
    self.selectDeviceButtonScrollView.hidden = !deviceButton.selected;
    
    // 控制手势来控制
    self.showZoneView.scrollView.pinchGestureRecognizer.enabled = deviceButton.selected;
    
    // 选遍历区域中的子控件
    for (SHButton *button in self.zone.allDeviceButtonInCurrentZone) {
        
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
    [SHUtility deleteImageFromDocment:self.zone.zoneID];
    
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
    for (SHButton *button in self.zone.allDeviceButtonInCurrentZone) {
        
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
    [self.view addSubview:self.selectDeviceButtonScrollView];
    self.selectDeviceButtonScrollView.hidden = YES;
    
    // 初始化socket设置代理
    [SHUdpSocket shareSHUdpSocket].delegate = self;
}

/// 显示区域信息
- (void)showZones {
    
    
    [self.view insertSubview:self.showZoneView belowSubview:self.setAreaView];
    
    // 获得当前区域的图片
    UIImage *image = [SHUtility getImageForZones:self.zone.zoneID];
    if (!image) {
        return;
    }
    
    // 设置图片
    [self.showZoneView setImageForZone:image scale:self.zone.imageScale];
    
    // 获得当前区域的所有按钮
    self.zone.allDeviceButtonInCurrentZone = [[SHSQLiteManager shareSHSQLiteManager] getAllButtonsForCurrentZone:self.zone];
    
    for (SHButton *button in self.zone.allDeviceButtonInCurrentZone) {
        
        [self addButtonModel:button];
    }
}

/// 添加保存的所有按钮到显示器上
- (void)addButtonModel:(SHButton *)button {
    
    // 匹配不同的按钮有不同的交互
    switch (button.deviceType) {
            
        case  SHDeviceButtonTypeLight: {  // 灯
            
            [button buttonWithTitle:@"Light" imageName:@"Light" target:self action:@selector(lightPressed:)];
            // 增加值变化
            UIPanGestureRecognizer *panMove = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(updateLightValue:)];
            [panMove setTranslation:CGPointZero inView:button];
            [button addGestureRecognizer:panMove];
        }
            break;
            
        case SHDeviceButtonTypeAirConditioning: { // 空调
            
            [button buttonWithTitle:@"OFF" imageName:@"AC" target:self action:@selector(acOnAndOff:)];
            
            // 增加值变化
            UIPanGestureRecognizer *panMove = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(updateACTempture:)];
            [panMove setTranslation:CGPointZero inView:button];
            [button addGestureRecognizer:panMove];
        }
            break;
            
        case  SHDeviceButtonTypeAudio: { // 音乐
            
            [button buttonWithTitle:@"END" imageName:@"Audio" target:self action:@selector(musicPlayAndStop:)];
            
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
            
            [button buttonWithTitle:@"Curtain" imageName:@"Curtain" target:self action:@selector(curtainPressed:)];
        }
            
            break;
            
        case SHDeviceButtonTypeMediaTV: { // 电视
            
            [button buttonWithTitle:@"OFF" imageName:@"TV" target:self action:@selector(watchTvPressed:)];
        }
            break;
            
        case SHDeviceButtonTypeLed: {
            
            // 增加监听
            [button buttonWithTitle:@"LED" imageName:@"LED" target:self action:@selector(setLedColor:)];
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

///  双击
- (void)selectDeviceTouched:(SHButton *)button {
    
    // 创建一个新的按钮
    SHButton *newButton = [[SHButton alloc] init];
    
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
            
            [newButton buttonWithTitle:@"Light" imageName:@"Light" target:self action:@selector(lightPressed:)];
            break;
            
        case SHDeviceButtonTypeAirConditioning:
            
            [newButton buttonWithTitle:@"OFF" imageName:@"AC" target:self action:@selector(acOnAndOff:)];
            break;
            
        case  SHDeviceButtonTypeAudio:
            
            [newButton buttonWithTitle:@"END" imageName:@"Audio" target:self action:@selector(musicPlayAndStop:)];
            break;
            
        case SHDeviceButtonTypeCurtain:
            
            [newButton buttonWithTitle:@"Close" imageName:@"Curtain" target:self action:@selector(curtainPressed:)];
            break;
            
        case SHDeviceButtonTypeMediaTV:
            
            [newButton buttonWithTitle:@"OFF" imageName:@"TV" target:self action:@selector(watchTvPressed:)];
            break;
            
        case SHDeviceButtonTypeLed:
            [newButton buttonWithTitle:@"LED" imageName:@"LED" target:self action:@selector(setLedColor:)];
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
    settingViewController.settingButton = (SHButton *)recognizer.view;
    settingViewController.sourceViewController = self;
    
    [self.navigationController pushViewController:settingViewController animated:YES];
}

/// 移动到目标区域
- (void)moveToTargetLocation:(UIPanGestureRecognizer *)recognizer {
    
    // 获得按钮
    SHButton *button = (SHButton *)recognizer.view;
    
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
- (void)watchTvPressed:(SHButton *)button {
    
    [SHSendDeviceData watchTv:button];
}

/// 窗帘移动
- (void)curtainPressed:(SHButton *)button {

    [SHSendDeviceData curtainOpenOrClose:button];
}

/// 音乐播放
- (void)musicPlayAndStop:(SHButton *)button {
    
    [SHSendDeviceData musicPlayAndStop:button];
}

/// AC 空调开关
- (void)acOnAndOff:(SHButton *)button {
    [SHSendDeviceData acOnAndOff:button];
}

/// 开关点击
- (void)lightPressed:(SHButton *)button {
    
    [SHSendDeviceData setDimmer:button];
}

/// 设置LED的颜色
- (void)setLedColor:(SHButton *)button {
    
    SHSelectColorViewController *selectController = [[SHSelectColorViewController alloc] init];
    [selectController show:button];
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
- (UIScrollView *)selectDeviceButtonScrollView {
    
    if (!_selectDeviceButtonScrollView) {
        
        _selectDeviceButtonScrollView = [[UIScrollView alloc] init];
        _selectDeviceButtonScrollView.showsVerticalScrollIndicator = YES;
        _selectDeviceButtonScrollView.pagingEnabled = YES;
        
        // 添加按钮
        NSArray *selectNames = @[@"Light", @"AC",@"Audio", @"Curtain", @"TV", @"LED"];
        self.selectNames = selectNames;
        
        _selectDeviceButtonScrollView.contentSize = CGSizeMake(0, selectNames.count * SHTabBarHeight);
        
        for (NSUInteger i = 0; i < selectNames.count; i++) {
            
            SHButton *button = [SHButton buttonWithType:UIButtonTypeCustom];
            
            button.tag = i;
            
            // 匹配图片和文字
            [button setImage:[UIImage imageNamed:selectNames[i]] forState:UIControlStateNormal];
            [button setTitle:[selectNames objectAtIndex:i] forState:UIControlStateNormal];
            
            // 匹配按钮类型
            switch (i) {
                case 0:
                    button.deviceType = SHDeviceButtonTypeLight;
                    break;
                    
                case 1:
                    button.deviceType = SHDeviceButtonTypeAirConditioning;
                    break;
                    
                case 2:
                    button.deviceType =  SHDeviceButtonTypeAudio;
                    break;
                    
                case 3:
                    button.deviceType = SHDeviceButtonTypeCurtain;
                    break;
                    
                case 4:
                    button.deviceType = SHDeviceButtonTypeMediaTV;
                    break;
                    
                case 5:
                    button.deviceType = SHDeviceButtonTypeLed;
                    break;
                    
                default:
                    break;
            }
            
            // 点击显示出来
            [button addTarget:self action:@selector(selectDeviceTouched:) forControlEvents:UIControlEventTouchUpInside];
            
            [_selectDeviceButtonScrollView addSubview:button];
        }
    }
    return _selectDeviceButtonScrollView;
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
    CGFloat scrollViewWidth = ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) ?
        SHButtonWidthForPhone : SHButtonWidthForPad;
    
    self.selectDeviceButtonScrollView.frame  = CGRectMake(self.view.frame_width - scrollViewWidth, self.view.frame_CenterY, scrollViewWidth, self.view.frame_CenterY * 0.5);
    
    for (NSUInteger i = 0; i < self.selectDeviceButtonScrollView.subviews.count; i++) {
        UIView *subView = self.selectDeviceButtonScrollView.subviews[i];
        
        if ([subView isKindOfClass:[SHButton class]]) {
            subView.frame = CGRectMake(SHDeviceButtonPadding, subView.tag * SHTabBarHeight , self.selectDeviceButtonScrollView.frame_width, SHTabBarHeight - SHDeviceButtonPadding);
        }
    }
}

@end
