//
//  AppDelegate.m
//  LSRRouterKitExample
//
//  Created by 李国阳 on 2022/9/1.
//

#import "AppDelegate.h"
#import "LSRRouterKit.h"
#import "LSRViewController0.h"
#import "LSRViewController1.h"
#import "LSRViewController2.h"
#import "LSRViewController3.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    /// 注册路由关键字
    [LSRRouter registerScheme:@"lsr"];
    [self initTabbarVC];
    return YES;
}

- (void)initTabbarVC
{
    LSRViewController0 *vc0 = [[LSRViewController0 alloc] init];
    vc0.tabBarItem.title = @"vc0";
    vc0.tabBarItem.image = [UIImage imageNamed:@"tabbar_vc0"];
    vc0.tabBarItem.selectedImage = [UIImage imageNamed:@"tabbar_vc0_select"];
    LSRViewController1 *vc1 = [[LSRViewController1 alloc] init];
    vc1.tabBarItem.title = @"vc1";
    vc1.tabBarItem.image = [UIImage imageNamed:@"tabbar_vc1"];
    vc1.tabBarItem.selectedImage = [UIImage imageNamed:@"tabbar_vc1_select"];
    LSRViewController2 *vc2 = [[LSRViewController2 alloc] init];
    vc2.tabBarItem.title = @"vc2";
    vc2.tabBarItem.image = [UIImage imageNamed:@"tabbar_vc2"];
    vc2.tabBarItem.selectedImage = [UIImage imageNamed:@"tabbar_vc2_select"];
    LSRViewController3 *vc3 = [[LSRViewController3 alloc] init];
    vc3.tabBarItem.title = @"vc3";
    vc3.tabBarItem.image = [UIImage imageNamed:@"tabbar_vc3"];
    vc3.tabBarItem.selectedImage = [UIImage imageNamed:@"tabbar_vc3_select"];
    
    UITabBarController *tabVC = [[UITabBarController alloc] init];
    tabVC.viewControllers = @[vc0,vc1,vc2,vc3];
    tabVC.tabBar.backgroundColor = UIColor.whiteColor;
    
    //配置路由组件的导航栈
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:tabVC];
    [LSRRouterNavigator setCurrentNavController:navigationController];
    
    self.window.rootViewController = navigationController;
    
}



@end
