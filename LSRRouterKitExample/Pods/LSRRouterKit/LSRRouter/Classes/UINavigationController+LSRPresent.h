//
//  UINavigationController+LSRPresent.h
//  MARouterKit
//
//  Created by liguoyang on 2019/3/10.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^LSRAnimationCompletion)(void);

@interface UINavigationController (LSRPresent)

#pragma mark - Present

/**
 调用 @see lsr_presentViewController:animated:completion:，默认开启动画，无回调。

 @param viewController viewController
 */
- (void)lsr_presentViewController:(UIViewController *)viewController;


/**
 以present的动画方式将viewController入栈

 @param viewController viewController
 @param animated 是否动画
 @param completion 动画执行完成后的回调
 */
- (void)lsr_presentViewController:(UIViewController *)viewController
                        animated:(BOOL)animated
                      completion:(nullable LSRAnimationCompletion)completion;


#pragma mark - dismissViewController

/**
 调用 @see lsr_dismissViewControllerAnimated:completion: ，默认开启动画，无回调。
 */
- (void)lsr_dismissViewController;

/**
 以ViewController的dismiss的动画方式，将栈顶controller出栈

 @param animated 是否动画
 @param completion 动画执行完成后的回调
 */
- (void)lsr_dismissViewControllerAnimated:(BOOL)animated
                              completion:(nullable LSRAnimationCompletion)completion;


#pragma mark - dismissToViewController

/**
 调用 @see lsr_dismissToViewController:animated:completion:，默认开启动画，无回调。

 @param viewController viewController
 */
- (void)lsr_dismissToViewController:(UIViewController *)viewController;

/**
 以ViewController的dismiss的动画方式，弹出到栈中的viewController

 @param viewController viewController
 @param animated 是否动画
 @param completion 动画执行完成后的回调
 */
- (void)lsr_dismissToViewController:(UIViewController *)viewController
                          animated:(BOOL)animated
                        completion:(nullable LSRAnimationCompletion)completion;


#pragma mark - dismissToRootViewController

/**
 调用 @see lsr_dismissToRootViewControllerAnimated:completion: ，默认开启动画，无回调。
 */
- (void)lsr_dismissToRootViewController;

/**
 以ViewController的dismiss的动画方式，弹出到栈的最底部

 @param animated 是否动画
 @param completion 动画执行完成后的回调
 */
- (void)lsr_dismissToRootViewControllerAnimated:(BOOL)animated
                                    completion:(nullable LSRAnimationCompletion)completion;


@end

NS_ASSUME_NONNULL_END
