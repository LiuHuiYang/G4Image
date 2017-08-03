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
#import <PhotosUI/PhotosUI.h>


/// 按钮间距
const CGFloat SHDeviceButtonPadding = 5;

@interface SHZoneDetailViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIGestureRecognizerDelegate, SHUdpSocketDelegate>

/// 底部工具条
@property (weak, nonatomic) UIToolbar *toolBar;

/// 选择不同的设备列表
@property (strong, nonatomic) UIScrollView *selectDeviceButtonScrollView;

/// 设备列表名称
@property (strong, nonatomic) NSArray *selectNames;

/// 显示图片的位置
@property (strong, nonatomic) SHZoneView *showZoneView;

@end

@implementation SHZoneDetailViewController

#pragma mark - 解析数组

/// 解析收到的数据
- (void)analyzeReceiveData:(NSData *)data {
    
    [SHAnalyDeviceData analyDeviceData:data inZone:self.zone];
}

#pragma mark - UI

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
    
    // 5.设置底部的toolBar
    [self setToolBar];
    
    // 初始化socket设置代理
    [SHUdpSocket shareSHUdpSocket].delegate = self;
}

/// 显示区域信息
- (void)showZones {
    
    [self.view addSubview:self.showZoneView];
    
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
    switch (button.buttonKind) {
            
        case  ButtonKindLight: {  // 灯
            
            [button buttonWithTitle:@"Light" imageName:@"Light" target:self action:@selector(lightPressed:)];
            // 增加值变化
            UIPanGestureRecognizer *panMove = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(updateLightValue:)];
            [panMove setTranslation:CGPointZero inView:button];
            [button addGestureRecognizer:panMove];
        }
            break;
            
        case ButtonKindAC: { // 空调
            
            [button buttonWithTitle:@"OFF" imageName:@"AC" target:self action:@selector(acOnAndOff:)];
            
            // 增加值变化
            UIPanGestureRecognizer *panMove = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(updateACTempture:)];
            [panMove setTranslation:CGPointZero inView:button];
            [button addGestureRecognizer:panMove];
        }
            break;
            
        case  ButtonKindMusic: { // 音乐
            
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
            
        case ButtonKindCurtain: {
            
            [button buttonWithTitle:@"Curtain" imageName:@"Curtain" target:self action:@selector(curtainPressed:)];
        }
            
            break;
            
        case ButtonKindMediaTV: { // 电视
            
            [button buttonWithTitle:@"OFF" imageName:@"TV" target:self action:@selector(watchTvPressed:)];
        }
            break;
            
        case ButtonKindLed: {
            
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
    
    if (!self.isNew) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Delete" style:UIBarButtonItemStyleDone target:self action:@selector(deleteZone)];
    }
}

/// 设置toolBar
- (void)setToolBar {
    
    // 1.工具格
    UIToolbar *toolBar = [[UIToolbar alloc] init];
    toolBar.barTintColor = [UIColor colorWithWhite:97/255.0 alpha:1.0];
    
    [self.view addSubview:toolBar];
    self.toolBar = toolBar;
    
    // 添加item
    
    // 1.创建弹簧
    UIBarButtonItem *flexibleSpaceitem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    // 2.G4
    UIButton *G4Button = [UIButton buttonWithImageName:@"G4" hightlightedImageName:@"G4_highlighted" addTarget:self action:@selector(G4ItemClick:)];
    G4Button.frame_width *= 0.6;
    G4Button.frame_height = G4Button.frame_width;
    
    [G4Button setImage:[UIImage imageNamed:@"G4_highlighted"] forState:UIControlStateSelected];
    
    UIBarButtonItem *G4Item = [[UIBarButtonItem alloc] initWithCustomView:G4Button];
    
    // 中间增加一个空格
    UIBarButtonItem *middleItem = [UIBarButtonItem barButtonItemWithImageName:nil hightlightedImageName:nil addTarget:nil action:nil];
    
    // 3.相册
    UIBarButtonItem *photoItem = [UIBarButtonItem barButtonItemWithImageName:@"photo" hightlightedImageName:nil addTarget:self action:@selector(photoItemClick)];
    
    self.toolBar.items = @[flexibleSpaceitem, photoItem, middleItem, G4Item];
}

// MARK: - 区域场景的选择

/// 选择照片
- (void)photoItemClick {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    // 添加三个操作
    UIAlertAction *photoAction = [UIAlertAction actionWithTitle:@"From Photos" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
            return ;
        }
        
        // 打开相册
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.delegate = self;
        
        [self presentViewController:picker animated:YES completion:nil];
        
        picker = nil;
    }];
    
    // 添加三个操作
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"Camera" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        {
            return ;
        }
        
        // 打开相机
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        picker.delegate = self;
        
        [self presentViewController:picker animated:YES completion:nil];
        
        picker = nil;
    }];
    
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"Cancle" style:UIAlertActionStyleCancel handler:nil];
    
    [alertController addAction:photoAction];
    [alertController addAction:cameraAction];
    [alertController addAction:cancleAction];
    
    alertController.popoverPresentationController.sourceView = self.toolBar;
    ;
    alertController.popoverPresentationController.sourceRect = self.toolBar.bounds;
    alertController.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
    
    
    [self presentViewController:alertController animated:YES completion:nil];
}

/// 照片选择的代理
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    // 获得图片,对图片进行处理，不能直接使用。（因为它会自动旋转）
    UIImage *sourceImage = [UIImage fixOrientation:[UIImage darwNewImage:info[UIImagePickerControllerOriginalImage] width:[UIView frame_ScreenWidth]]];

    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        
        // 写到胶卷中
        UIImageWriteToSavedPhotosAlbum(sourceImage, self, nil, nil);
    }
    
    // 关闭图片的选择界面
    [picker dismissViewControllerAnimated:YES completion:nil];
//    picker =  nil;

    // 准备图征保存在沙盒中
    [SHUtility writeImageToDocment:self.zone.zoneID data: sourceImage];
    
    // 修改比例为最初比例
    self.zone.imageScale = 1.0;
    [self.showZoneView setImageForZone:sourceImage scale:self.zone.imageScale];
    
    // 保存当前区域
    [[SHSQLiteManager shareSHSQLiteManager] inserNewZone:self.zone];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

// MARK: - 区域的信息保存与删除

/// G4点击
- (void)G4ItemClick:(UIButton *)sender {
    
    sender.selected = !sender.selected;
    
    self.selectDeviceButtonScrollView.hidden = !sender.selected;
    
    // 控制手势来控制
    self.showZoneView.scrollView.pinchGestureRecognizer.enabled = sender.selected;
    
    // 选遍历区域中的子控件
    for (SHButton *button in self.zone.allDeviceButtonInCurrentZone) {
    
        // 移除所有的手势
        for (UIGestureRecognizer *recognizer in button.gestureRecognizers) {
            [button removeGestureRecognizer:recognizer];
        }
        
        // 选中才可以移动
        if (sender.selected) {
            
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
            switch (button.buttonKind) {
                    
                case ButtonKindLight: {
                    
                    UIPanGestureRecognizer *panMove = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(updateLightValue:)];
                    [panMove setTranslation:CGPointZero inView:button];
                    [button addGestureRecognizer:panMove];
                }
                    
                    break;
                    
                case ButtonKindCurtain: {
                    
                }
                    break;
                    
                case  ButtonKindMusic: {
                    
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
                    
                case ButtonKindAC: {
                    
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
    if (!sender.selected) {
        
        // 获得当前比例
        self.zone.imageScale = self.showZoneView.scrollView.zoomScale;
        
        // 更新当前区域的所有信息
        [[SHSQLiteManager shareSHSQLiteManager] saveCurrentZonesButtons:self.zone];
    }
}

/// 删除区域
- (void)deleteZone {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"Are you sure to delete current zone?" preferredStyle:UIAlertControllerStyleActionSheet];
    
    // 添加两个操作
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        // 数据库删除这个区域记录
        [[SHSQLiteManager shareSHSQLiteManager] deleteCurrntZone:self.zone];
        
        // 删除图片
        [SHUtility deleteImageFromDocment:self.zone.zoneID];
        
        // 回到预览
        [self.navigationController popViewControllerAnimated:YES];
        
    }];
    
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        // ...
    }];
    
    [alertController addAction:sureAction];
    [alertController addAction:cancleAction];
    
    
    alertController.popoverPresentationController.barButtonItem = self.navigationItem.rightBarButtonItem;
    alertController.popoverPresentationController.sourceRect = self.view.bounds;
    alertController.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
  
    [self presentViewController:alertController animated:YES completion:nil];
}

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
    newButton.buttonKind = button.buttonKind;
    newButton.zoneID = self.zone.zoneID;
    newButton.buttonID = [[SHSQLiteManager shareSHSQLiteManager] getMaxButtonID] + 1;
    newButton.buttonKind = button.buttonKind;
    
    // 设置图片
    switch (button.buttonKind) {
        case  ButtonKindLight:
            
            [newButton buttonWithTitle:@"Light" imageName:@"Light" target:self action:@selector(lightPressed:)];
            break;
            
        case ButtonKindAC:
            
            [newButton buttonWithTitle:@"OFF" imageName:@"AC" target:self action:@selector(acOnAndOff:)];
            break;
            
        case  ButtonKindMusic:
            
            [newButton buttonWithTitle:@"END" imageName:@"Audio" target:self action:@selector(musicPlayAndStop:)];
            break;
            
        case ButtonKindCurtain:
            
            [newButton buttonWithTitle:@"Close" imageName:@"Curtain" target:self action:@selector(curtainPressed:)];
            break;
            
        case ButtonKindMediaTV:
            
            [newButton buttonWithTitle:@"OFF" imageName:@"TV" target:self action:@selector(watchTvPressed:)];
            break;
            
        case ButtonKindLed:
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
                    button.buttonKind = ButtonKindLight;
                    break;
                    
                case 1:
                    button.buttonKind = ButtonKindAC;
                    break;
                    
                case 2:
                    button.buttonKind =  ButtonKindMusic;
                    break;
                    
                case 3:
                    button.buttonKind = ButtonKindCurtain;
                    break;
                    
                case 4:
                    button.buttonKind = ButtonKindMediaTV;
                    break;
                    
                case 5:
                    button.buttonKind = ButtonKindLed;
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
    
    // 0.中间场景区域的图形
    self.showZoneView.frame = CGRectMake(0, SHNavigationBarHeight, self.view.frame_width, self.view.frame_height - SHNavigationBarHeight - SHTabBarHeight);
    
    // 1.工具条的位置
    self.toolBar.frame = CGRectMake(0, self.view.frame_height- SHTabBarHeight, self.view.frame_width, SHTabBarHeight);
    
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
