//
//  LSRViewController0.m
//  LSRRouterKitExample
//
//  Created by 李国阳 on 2022/9/6.
//

#import "LSRViewController0.h"

@interface LSRViewController0 ()

@end

@implementation LSRViewController0
LSRRouterRegisterOnLoad(@"lsr", @"LSRViewController0");

/// 接收参数 在viewDidLoad之前调用
- (id)ma_routerWithParams:(NSDictionary *)params {
    
    NSLog(@"%@====%@",self,params);
    return nil;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.redColor;
    self.nextVC = ^{
        
        [LSRRouter openURLString:@"lsr://LSRViewController1" params:@{@"key":@"from0"} routerCallback:^(id  _Nullable callbackParams) {
            NSLog(@"%@",callbackParams);
        }];
        
    };
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    if (self.lsr_routerCallback) {
        self.lsr_routerCallback(self);

    }
}


@end
