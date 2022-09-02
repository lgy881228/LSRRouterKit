//
//  MARouterNavigator.m
//  MARouterKit
//
//  Created by liguoyang on 2019/3/8.
//
//

#import "LSRRouterNavigator.h"
#import "LSRIObjectRouter.h"
#import "LSRRouter.h"
#import "UINavigationController+LSRPresent.h"

#define MARouterNavigatorKeyShared   @"lsr_shared"
#define MARouterNavigatorValueShared @"1"

static UINavigationController *lsr_currentNavController = nil;

@interface LSRRouterNavigator ()

@end

@implementation LSRRouterNavigator

#pragma mark - Private Methods

+ (LSRNavigationMode)navModeForClass:(Class)targetClass {
    LSRNavigationMode navMode = LSRNavigationModePush;
    if ([targetClass respondsToSelector:@selector(lsr_navigationMode)]) {
        navMode = [targetClass lsr_navigationMode];
    }
    return navMode;
}

+ (BOOL)isControllerShared:(Class)targetClass params:(NSDictionary *)params {
    id shared = params[MARouterNavigatorKeyShared];
    if (shared) {
        return [shared isEqualToString:MARouterNavigatorValueShared];
    }
    return [targetClass respondsToSelector:@selector(lsr_isSharedController)] && [targetClass lsr_isSharedController];
}

+ (UIViewController *)currentViewController {
    UIViewController *viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (viewController) {
        if ([viewController isKindOfClass:[UITabBarController class]]) {
            UITabBarController *tbvc = (UITabBarController*)viewController;
            viewController = tbvc.selectedViewController;
        } else if ([viewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController *nvc = (UINavigationController*)viewController;
            viewController = nvc.topViewController;
        } else if (viewController.presentedViewController) {
            viewController = viewController.presentedViewController;
        } else if ([viewController isKindOfClass:[UISplitViewController class]] &&
                   ((UISplitViewController *)viewController).viewControllers.count > 0) {
            UISplitViewController *svc = (UISplitViewController *)viewController;
            viewController = svc.viewControllers.lastObject;
        } else  {
            return viewController;
        }
    }
    return viewController;
}

#pragma mark - Public Methods

+ (void)setCurrentNavController:(UINavigationController *)navController {
    @synchronized (lsr_currentNavController) {
        lsr_currentNavController = navController;
    }
}

+ (UINavigationController *)currentNavController {
    if ([LSRRouter navControllerMonitorEnabled]) {
        return [self currentViewController].navigationController;
    } else {
        NSAssert(lsr_currentNavController, @"请在应用启动的时候设置NavigationController");
        return lsr_currentNavController;
    }
}

+ (void)showViewController:(Class)vcClass
                    params:(NSDictionary *)params
                 preAction:(MANavigatorPreAction)preAction {

    LSRNavigationMode navMode = [self navModeForClass:vcClass];
    BOOL matched = NO;
    NSUInteger index = 0;
    UITabBarController *tabbarController = nil;
    UIViewController *targetController = nil;
    
    BOOL shared = [self isControllerShared:vcClass params:params];
    
    if (shared) {
        targetController = [LSRRouterNavigator controllerInNavForTargetClass:vcClass
                                                           tabbarController:&tabbarController
                                                                      index:&index
                                                                      exist:&matched];
    } else {
        targetController = [[vcClass alloc] init];
    }
    
    if (preAction) {
        preAction(targetController);
    }
    
    UINavigationController *navController = [LSRRouterNavigator currentNavController];
    
    if (shared) {
        if (matched) {
            UIViewController *topController = [navController topViewController];
            UIViewController *finalController = targetController;
            
            if (topController == finalController) {
                return;
            }
            
            if (tabbarController) {
                finalController = tabbarController;
                tabbarController.selectedIndex = index;
            }
            
            if ([self navModeForClass:[topController class]] == LSRNavigationModePresent) {
                [navController lsr_dismissToViewController:finalController];
            } else {
                [navController popToViewController:finalController animated:YES];
            }
        } else {
            [navController pushViewController:targetController animated:YES];
        }
    } else {
        if (navMode == LSRNavigationModePush) {
            [navController pushViewController:targetController animated:YES];
        } else if (navMode == LSRNavigationModePresent) {
            [navController lsr_presentViewController:targetController];
        }
    }
}

+ (UIViewController *)sharedVCForController:(Class)vcClass params:(NSDictionary *)params {
    UIViewController *targetController = nil;
    BOOL shared = [self isControllerShared:vcClass params:params];
    
    if (shared) {
        BOOL matched = NO;
        NSUInteger index = 0;
        UITabBarController *tabbarController = nil;
        targetController = [LSRRouterNavigator controllerInNavForTargetClass:vcClass
                                                           tabbarController:&tabbarController
                                                                      index:&index
                                                                      exist:&matched];
    } else {
        targetController = [[vcClass alloc] init];
    }
    
    return targetController;
}

+ (UIViewController *)controllerInNavForTargetClass:(Class)targetClass
                                   tabbarController:(UITabBarController * _Nonnull *)tabbarController
                                              index:(NSUInteger * _Nonnull)index
                                              exist:(BOOL * _Nonnull)exist {
    UINavigationController *navController = [LSRRouterNavigator currentNavController];
    __block UIViewController *targetController = nil;
    __block UITabBarController *tmpTabbarController = nil;
    __block NSUInteger tmpIndex = 0;
    
    NSArray<UIViewController *> *viewControllers = navController.viewControllers;
    [viewControllers enumerateObjectsWithOptions:NSEnumerationReverse
                                      usingBlock:
                                        ^(UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                          if ([obj isKindOfClass:[UITabBarController class]]) {
                                              UITabBarController *tController = (UITabBarController *)obj;
                                              NSUInteger tIndex = 0;
                                              for (UIViewController *obj in tController.viewControllers) {
                                                  if ([obj class] == targetClass) {
                                                      targetController = obj;
                                                      tmpTabbarController = tController;
                                                      tmpIndex = tIndex;
                                                      *stop = YES;
                                                      break;
                                                  }
                                                  tIndex++;
                                              }
                                          } else if ([obj class] == targetClass) {
                                              targetController = obj;
                                              *stop = YES;
                                          }
                                      }];
    
    
    BOOL matched = NO;
    if (targetController) {
        matched = YES;
    } else {
        targetController = [[targetClass alloc] init];
    }
    
    if (tabbarController) {
        *tabbarController = tmpTabbarController;
    }
    
    if (index) {
        *index = tmpIndex;
    }
    
    if (exist) {
        *exist = matched;
    }
    
    return targetController;
}

@end
