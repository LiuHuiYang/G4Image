//
//  SHZonePreViewController.m
//  G4Image
//
//  Created by LHY on 2017/4/4.
//  Copyright © 2017年 SmartHomeGroup. All rights reserved.
//

#import "SHZonePreViewController.h"
#import "SHZoneDetailViewController.h"
#import "SHZonePreViewCell.h"

@interface SHZonePreViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

/// 显示所有场景的视图
@property (nonatomic, strong) UICollectionView* listView;

/// 所有的区域信息
@property (strong, nonatomic)NSMutableArray *allZones;

@end

@implementation SHZonePreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置导航栏
    [self setNavigationBar];
    
    // 显示内容
    [self.view addSubview:self.listView];
}

#pragma mark - 显示各个场景

/// 屏幕变化时改变大小
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.listView.frame = self.view.bounds;
}

#pragma mark - 导航栏的设置

/// 设置导航栏
- (void)setNavigationBar {
    
    // 设置标题
    self.navigationItem.title = @"All Zones";

    
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Add" style:UIBarButtonItemStylePlain target:self action:@selector(addNewZone:)];
    
    // 设置添加
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem barButtonItemWithImageName:@"add" hightlightedImageName:@"add" addTarget:self action:@selector(addNewZone:)];
}

/// 导航栏点击
- (void)addNewZone:(UIBarButtonItem *)item {
    
    // 创建详情控制器
    SHZoneDetailViewController *detailViewController = [[SHZoneDetailViewController alloc] init];
    
    // 设置页面标记是新增加
    detailViewController.isNew = YES;
    
    SHZone *zone = [[SHZone alloc] init];
    
    // 设置名称与序号
    zone.zoneName = @"New";
    // 设置最新的区域ID
    NSUInteger maxZoneID = [[SHSQLiteManager shareSHSQLiteManager] getMaxZoneID];
    zone.zoneID = ++(maxZoneID);
    
    // 设置当前区域的图片缩放时1.0
    zone.imageScale = 1.0;
    detailViewController.zone = zone;
    
    [self.navigationController pushViewController:detailViewController animated:YES];
}


#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    // 获得区域模型
    SHZone *modelZone = self.allZones[indexPath.item];
    
    // 获得当前区域中的所有按钮
    modelZone.allDeviceButtonInCurrentZone = [[SHSQLiteManager shareSHSQLiteManager] getAllButtonsForCurrentZone:modelZone];
    
    SHZoneDetailViewController *detailViewController = [[SHZoneDetailViewController alloc] init];
    
    detailViewController.isNew = NO;
    detailViewController.zone = modelZone;
    
    [self.navigationController pushViewController:detailViewController animated:YES];
}

#pragma mark - UICollectionViewDataSource 

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
  
    self.allZones = [[SHSQLiteManager shareSHSQLiteManager] searchAllZones];
    
    [self.listView reloadData];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.allZones.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    SHZonePreViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([SHZonePreViewCell class]) forIndexPath:indexPath];
    
    // 获得区域模型
    cell.modelZone = self.allZones[indexPath.item];
    
    return cell;
}


#pragma mark - getter && setter

/// 展示场景
- (UICollectionView *)listView {

    if (!_listView) {
        
        // 1.自定义流水布局
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        
        // 1.1 设置方向
        flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        
        // 1.2 计算每个item的大小
        CGFloat itemMarign = 1;
        
        // 总列数
        NSUInteger totalCols = 3;
        
        CGFloat itemWidth = (self.view.frame_width - (totalCols * itemMarign)) / totalCols;
        flowLayout.itemSize = CGSizeMake(itemWidth, itemWidth);
        
        // 1.3 设置间距
        flowLayout.minimumLineSpacing = itemMarign;
        flowLayout.minimumInteritemSpacing = itemMarign;
        
        // 2.创建 (临时指定一个高度，宽度不需要指定)
        _listView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout] ;
        
        // 设置背景颜色
        _listView.backgroundColor = SHGlobalBackgroundColor;
        
        // 注册cell
        [_listView registerNib:[UINib nibWithNibName:NSStringFromClass([SHZonePreViewCell class]) bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([SHZonePreViewCell class])];
        
        // 设置数据源和方法
        _listView.dataSource = self;
        _listView.delegate = self;
    }
    
    return _listView;
}

@end
