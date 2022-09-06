//
//  ViewController.m
//  LSRRouterKitExample
//
//  Created by 李国阳 on 2022/9/1.
//

#import "ViewController.h"
#import "Masonry.h"
@interface ViewController ()
/** vc */
@property (nonatomic, strong) UIButton *pushButton;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.pushButton];
    [self.pushButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.centerY.mas_equalTo(self.view.mas_centerY);
        make.height.width.mas_equalTo(200);

    }];
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

- (void)pushAction:(UIButton *)button
{
    if (self.nextVC) {
        self.nextVC();
    }
    
}
- (UIButton *)pushButton
{
    if (!_pushButton)
    {
        _pushButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_pushButton setTitle:@"tiao" forState:UIControlStateNormal];
        [_pushButton setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        [_pushButton addTarget:self action:@selector(pushAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _pushButton;
}

@end
