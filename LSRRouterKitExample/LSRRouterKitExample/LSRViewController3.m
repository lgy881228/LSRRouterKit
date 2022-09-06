//
//  LSRViewController3.m
//  LSRRouterKitExample
//
//  Created by 李国阳 on 2022/9/6.
//

#import "LSRViewController3.h"

@interface LSRViewController3 ()

@end

@implementation LSRViewController3
LSRRouterRegisterOnLoad(@"lsr", @"LSRViewController3");

- (id)ma_routerWithParams:(NSDictionary *)params {
    
    NSLog(@"%@====%@",self,params);
    return nil;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.nextVC = ^{
        
        [LSRRouter openURLString:@"lsr://LSRViewController0" params:@{@"key":@"from3"} routerCallback:^(id  _Nullable callbackParams) {
            
        }];
      
    };

    self.view.backgroundColor = UIColor.greenColor;
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
