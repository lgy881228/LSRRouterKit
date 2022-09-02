//
//  MARouterNavigator.h
//  MARouterKit
//
//  Created by liguoyang on 2019/3/8.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^MANavigatorPreAction)(__kindof UIViewController * _Nonnull targetController);

@interface LSRRouterNavigator : NSObject

/**
 @return 当前导航控制器
 */
+ (UINavigationController * _Nonnull)currentNavController;

/**
 设置项目所使用的根导航控制器，建议在应用初始化的时候设置全局的导航控制器。

 @param navController 导航控制器
 */
+ (void)setCurrentNavController:(UINavigationController * _Nonnull)navController;


/**
 显示目标控制器，在控制器显示之前会执行preAction中的操作。
 判断是否用共享VC规则：
  1. 首先判断路由传递的参数中是否包含ma_shared参数，如果存在为1则共享VC，其他则生成新的VC实例
  2. 如果参数中不包含ma_shared参数，则直接判断方法ma_isSharedController的返回值进行控制。返回YES，则共享VC；返回NO生成新的VC实例

 @param vcClass controller对应的Class类
 @param params 路由中解析出的参数，如果参数中包含ma_shared，则用于判断是否要使用共享的VC
 @param preAction 该block中设置预先执行的操作
 */
+ (void)showViewController:(nonnull Class)vcClass
                    params:(NSDictionary * _Nullable)params
                 preAction:(MANavigatorPreAction _Nullable)preAction;


/**
 根据当前VC和参数获取最终执行路由的VC实例对象
 判断是否用共享VC规则：
  1. 首先判断路由传递的参数中是否包含ma_shared参数，如果存在为1则共享VC，其他则生成新的VC实例
  2. 如果参数中不包含ma_shared参数，则直接判断方法ma_isSharedController的返回值进行控制。返回YES，则共享VC；返回NO生成新的VC实例
 
 @param vcClass controller对应的Class类
 @param params 路由中解析出的参数，如果参数中包含ma_shared，则用于判断是否要使用共享的VC
 */
+ (UIViewController * _Nonnull)sharedVCForController:(nonnull Class)vcClass
                                              params:(NSDictionary * _Nullable)params;


/**
 在当前导航控制器中查找targetClass类型的控制，如果有则直接返回栈中的控制器，否则重新初始化一个。
 在查找的过程中，如果遇到UITabbarController，则会查找它的子控制器。
 如果查找到则一起返回对应的UITabbarController和子控制器所在的index。

 @param targetClass 目前控制器类型
 @param tabbarController 查找到的UITabbarController
 @param index 目标控制器在UITabbarController中的index
 @param exist 目标控制器是否存在于导航控制器的栈中
 @return 目标控制器
 */
+ (UIViewController * _Nonnull)controllerInNavForTargetClass:(Class _Nonnull)targetClass
                                            tabbarController:(UITabBarController * _Nonnull * _Nullable)tabbarController
                                                       index:(NSUInteger * _Nonnull)index
                                                       exist:(BOOL * _Nonnull)exist;

@end
