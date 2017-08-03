//
//  SHSetAreaView.m
//  G4Image
//
//  Created by LHY on 2017/6/2.
//  Copyright © 2017年 LHY. All rights reserved.
//

#import "SHSetAreaView.h"

@interface SHSetAreaView() <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

/// 设备按钮
@property (weak, nonatomic) IBOutlet UIButton *deviceButton;

@end

@implementation SHSetAreaView

// MARK: - 删除区域

/// 删除区域
- (IBAction)deleteArea {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"Are you sure to delete current zone?" preferredStyle:UIAlertControllerStyleActionSheet];
    
    // 添加两个操作
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        // 执行回调
        if ([self.delegate respondsToSelector:@selector(setAreaViewDeleteZone)]) {
            [self.delegate setAreaViewDeleteZone];
        }
    }];
    
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleCancel handler:nil];
    
    [alertController addAction:sureAction];
    [alertController addAction:cancleAction];
    
    
    alertController.popoverPresentationController.sourceView = [self.subviews firstObject];
    alertController.popoverPresentationController.sourceRect = CGRectMake(0, 0, SHTabBarHeight, SHNavigationBarHeight);
    alertController.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
    
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
}

/// 添加设备按钮
- (IBAction)addDeviceButton {
    
    self.deviceButton.selected = !self.deviceButton.selected;

    if ([self.delegate respondsToSelector:@selector(setAreaViewShowDeviceList:)]) {
        [self.delegate setAreaViewShowDeviceList:self.deviceButton];
    }
}

// MARK: - 照片的处理

/// 照片选择的代理
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    // 获得图片,对图片进行处理，不能直接使用。（因为它会自动旋转）
    UIImage *sourceImage = [UIImage fixOrientation:info[UIImagePickerControllerOriginalImage]];
    
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        
        // 写到胶卷中
        UIImageWriteToSavedPhotosAlbum(sourceImage, self, nil, nil);
    }
    
    // 关闭图片的选择界面
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    // --------   后续的处理 ---------
    
    if ([self.delegate respondsToSelector:@selector(setAreaViewPictureForZone:)]) {
        [self.delegate setAreaViewPictureForZone:sourceImage];
    }
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}


/// 获取照片
- (IBAction)photos {

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
        
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:picker animated:YES completion:nil];
        
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
        
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:picker animated:YES completion:nil];
        
        picker = nil;
    }];
    
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"Cancle" style:UIAlertActionStyleCancel handler:nil];
    
    [alertController addAction:photoAction];
    [alertController addAction:cameraAction];
    [alertController addAction:cancleAction];
    
    alertController.popoverPresentationController.sourceView = self;
    ;
    alertController.popoverPresentationController.sourceRect = self.bounds;
    alertController.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
    
    
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
}

/// 返回固定的大小
+ (CGSize)areaViewSize {

    return CGSizeMake(2 * SHTabBarHeight, SHNavigationBarHeight * 3);
}

/// 实例化设置界面
+ (instancetype)setAreaView {
    
    return [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil] lastObject];
}

@end
