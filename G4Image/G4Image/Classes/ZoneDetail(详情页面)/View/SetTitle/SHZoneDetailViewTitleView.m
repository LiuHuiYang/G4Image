//
//  SHAreaTitleView.m
//  G4Image
//
//  Created by LHY on 2017/6/2.
//  Copyright © 2017年 LHY. All rights reserved.
//

#import "SHZoneDetailViewTitleView.h"

@interface SHZoneDetailViewTitleView() <UITextFieldDelegate>

/// 标题textField
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;


@end

@implementation SHZoneDetailViewTitleView

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    // 保存名称
    NSString *title = textField.text;
    
    if (title.length) {
        
        self.name = title;
    }
    
    [textField endEditing:YES];
    
    return YES;
}

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    self.titleTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    
}

- (void)setName:(NSString *)name {

    _name = name.copy;
    
    self.titleTextField.text = name;
}

/// 实例化标题栏
+ (instancetype)zoneTitleView {

    return [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil] lastObject];
}

@end
