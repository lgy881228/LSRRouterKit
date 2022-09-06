//
//  LSRViewController2.m
//  LSRRouterKitExample
//
//  Created by 李国阳 on 2022/9/6.
//

#import "LSRViewController2.h"

@interface LSRViewController2 ()

@end

@implementation LSRViewController2
LSRRouterRegisterOnLoad(@"lsr", @"LSRViewController2");

- (id)ma_routerWithParams:(NSDictionary *)params {
    
    NSLog(@"%@====%@",self,params);
    return nil;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.view.backgroundColor = UIColor.yellowColor;
    self.nextVC = ^{
        
        [LSRRouter openURLString:@"lsr://LSRViewController3" params:@{@"key":@"from2"} routerCallback:^(id  _Nullable callbackParams) {
            
        }];
    };
    // Do any additional setup after loading the view.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
