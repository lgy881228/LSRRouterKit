//
//  LSRViewController1.m
//  LSRRouterKitExample
//
//  Created by 李国阳 on 2022/9/6.
//

#import "LSRViewController1.h"


@interface LSRViewController1 ()

@end

@implementation LSRViewController1
LSRRouterRegisterOnLoad(@"lsr", @"LSRViewController1");

- (id)ma_routerWithParams:(NSDictionary *)params {
    
    NSLog(@"%@====%@",self,params);
    return nil;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.blueColor;
    self.nextVC = ^{
        
        [LSRRouter openURLString:@"lsr://LSRViewController2" params:@{@"key":@"from1"} routerCallback:^(id  _Nullable callbackParams) {
            
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
