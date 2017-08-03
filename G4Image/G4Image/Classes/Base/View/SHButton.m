//
//  SHButton.m
//  TouchTest
//
//  Created by Firas on 12/11/13.
//  Copyright (c) 2013 SH. All rights reserved.
//

#import "SHButton.h"

#define SHButtonMaign (5)

@implementation SHButton

/// 获得按钮种类的名称
+ (NSString *)titleKindForButton:(SHButton *)button {
    
    switch (button.buttonKind) {
        case ButtonKindMediaTV:
            return @"TV";
            
        case ButtonKindCurtain:
            return @"Curtain";
            
        case ButtonKindLight:
            return @"Light";
            
        case ButtonKindAC:
            return @"Air Conditioner";
            
        case ButtonKindLed:
            return @"LED";
            
        case ButtonKindMusic:
            return @"Audio";
            
        default:
            return @"";
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    //    self.titleLabel.backgroundColor = [UIColor redColor];
    //    self.imageView.backgroundColor = [UIColor greenColor];
    
    self.titleLabel.frame_x = 0;
    self.titleLabel.frame_y = 0;
    self.titleLabel.frame_width = self.frame_width * 0.6;
    self.titleLabel.frame_height = self.frame_height;
    
    self.imageView.frame_width = self.frame_width - self.titleLabel.frame_width - SHButtonMaign;
    self.imageView.frame_x = self.titleLabel.frame_width;
}

/// 字典转换为模型
+ (instancetype)buttonWithDictionary:(NSDictionary *)dictionary {
    
    SHButton *btn = [[self alloc] init];
    
    // 设置每个属性
    
    btn.subNetID = [[dictionary objectForKey:@"subnetID"] integerValue];
    btn.deviceID = [[dictionary objectForKey:@"deviceID"] integerValue];
    
    
    btn.zoneID = [[dictionary objectForKey:@"zoneID"] integerValue];
    btn.buttonID = [[dictionary objectForKey:@"buttonID"] integerValue];
    
    btn.buttonKind = (ButtonKind)[dictionary[@"buttonKind"] integerValue];
    
    btn.buttonRectSaved = CGRectFromString(dictionary[@"buttonRectSaved"]);
    
    btn.buttonPara1 = [dictionary[@"buttonPara1"] integerValue];
    btn.buttonPara2 = [dictionary[@"buttonPara2"] integerValue];
    btn.buttonPara3 = [dictionary[@"buttonPara3"] integerValue];
    btn.buttonPara4 = [dictionary[@"buttonPara4"] integerValue];
    btn.buttonPara5 = [dictionary[@"buttonPara5"] integerValue];
    btn.buttonPara6 = [dictionary[@"buttonPara6"] integerValue];
    
    return btn;
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        self.titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        self.titleLabel.textAlignment = NSTextAlignmentRight;
        
        CGFloat fontSize = ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) ? 12 : 18;
        
        self.titleLabel.font = [UIFont boldSystemFontOfSize:fontSize];
        
        [self setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    }
    return self;
}

@end
