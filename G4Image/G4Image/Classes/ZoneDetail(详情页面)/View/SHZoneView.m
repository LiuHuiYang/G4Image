//
//  SHZoneView.m
//  G4Image
//
//  Created by LHY on 2017/4/6.
//  Copyright © 2017年 SmartHomeGroup. All rights reserved.
//

#import "SHZoneView.h"

@interface SHZoneView() <UIScrollViewDelegate>

/// 内部的图片视图
@property (strong,nonatomic)UIImageView *imageViewForZone;

@end

@implementation SHZoneView

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
 
    // 缩放这张图片
    return self.imageViewForZone; // 这种缩放是制造出来的假象，不会真的改变大小。
}

/// 调整布局
- (void)layoutSubviews {
    [super layoutSubviews];
    self.scrollView.frame = self.bounds;
//    self.imageViewForZone.frame = self.scrollView.bounds;
}

/// 初始化
- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        // 设置背景颜色为黑色
        self.backgroundColor = SHGlobalBackgroundColor;
        
        // 添加scrollView
        [self addSubview:self.scrollView];
        // 添加图片控件
        [self.scrollView addSubview:self.imageViewForZone];
    }
    return self;
}

/// 设置区域图片
- (void)setImageForZone:(UIImage *)sourceImge scale:(CGFloat)scale {
    
    self.imageViewForZone.image = sourceImge;
    self.imageViewForZone.frame = CGRectMake(0, 0, sourceImge.size.width, sourceImge.size.height);
    self.scrollView.contentSize = sourceImge.size;
    
    // 设置保存的缩放比例
    self.scrollView.zoomScale = scale;
    
    [self.scrollView setNeedsDisplay];
}

#pragma mark - getter && setter

/// 展示图片的imageView
- (UIImageView *)imageViewForZone {

    if (!_imageViewForZone) {
        _imageViewForZone = [[UIImageView alloc] init];
        _imageViewForZone.userInteractionEnabled = YES;
    }
    return _imageViewForZone;
}

/// 底部滚动视图
- (UIScrollView *)scrollView {
    
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.bounces = NO;
        _scrollView.showsVerticalScrollIndicator = YES;
        _scrollView.showsHorizontalScrollIndicator = YES;
        _scrollView.backgroundColor = SHGlobalBackgroundColor;
        _scrollView.scrollEnabled = YES;
        _scrollView.minimumZoomScale = 0.1;
        _scrollView.maximumZoomScale = 2.0;
        _scrollView.delegate = self;
    }
    return _scrollView;
}

@end
