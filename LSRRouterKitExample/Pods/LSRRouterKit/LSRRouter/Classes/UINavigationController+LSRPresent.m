//
//  UINavigationController+LSRPresent.m
//  LSRRouterKit
//
//  Created by liguoyang on 2019/3/10.
//


#import "UINavigationController+LSRPresent.h"
#import <QuartzCore/QuartzCore.h>

@interface MAAnimationDelegate : NSObject <CAAnimationDelegate>

@property (nonatomic, copy) LSRAnimationCompletion completion;

- (instancetype)initWithCompletion:(LSRAnimationCompletion)completion;
+ (instancetype)delegateWithCompletion:(LSRAnimationCompletion)completion;

@end

@implementation MAAnimationDelegate

- (instancetype)initWithCompletion:(LSRAnimationCompletion)completion {
    self = [super init];
    if (self) {
        _completion = completion;
    }
    return self;
}

+ (instancetype)delegateWithCompletion:(LSRAnimationCompletion)completion {
    return [[self alloc] initWithCompletion:completion];
}

#pragma mark - CAAnimationDelegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (flag && _completion) {
        _completion();
    }
}

@end

@implementation UINavigationController (LSRPresent)

#pragma mark - Private Methods

- (void)lsr_dismissAction:(void(^ __nonnull)(void))dismissAction
                animated:(BOOL)animated
              completion:(LSRAnimationCompletion)completion {
    if (animated) {
        CATransition* transition = [CATransition animation];
        transition.type = kCATransitionReveal;
        transition.subtype = kCATransitionFromBottom;
        if (completion) {
            transition.delegate = [MAAnimationDelegate delegateWithCompletion:completion];
        }
        [self.view.layer addAnimation:transition forKey:kCATransition];
    }
    
    dismissAction();
    
    if (!animated && completion) {
        completion();
    }
}

#pragma mark - Public Methods

- (void)lsr_presentViewController:(UIViewController *)viewController {
    [self lsr_presentViewController:viewController animated:YES completion:nil];
}

- (void)lsr_presentViewController:(UIViewController *)viewController
                        animated:(BOOL)animated
                      completion:(nullable LSRAnimationCompletion)completion {
    if (!viewController) {
        return;
    }
    
    if (animated) {
        CATransition* transition = [CATransition animation];
        transition.type = kCATransitionMoveIn;
        transition.subtype = kCATransitionFromTop;
        if (completion) {
            transition.delegate = [MAAnimationDelegate delegateWithCompletion:completion];
        }
        [self.view.layer addAnimation:transition forKey:kCATransition];
    }
    
    [self pushViewController:viewController animated:NO];
    
    if (!animated && completion) {
        completion();
    }
}

- (void)lsr_dismissViewController {
    [self lsr_dismissViewControllerAnimated:YES completion:nil];
}

- (void)lsr_dismissViewControllerAnimated:(BOOL)animated
                              completion:(nullable LSRAnimationCompletion)completion {
    
    [self lsr_dismissAction:^{
        [self popViewControllerAnimated:NO];
    } animated:animated completion:completion];
}

- (void)lsr_dismissToViewController:(UIViewController *)viewController {
    [self lsr_dismissToViewController:viewController animated:YES completion:nil];
}

- (void)lsr_dismissToViewController:(UIViewController *)viewController
                          animated:(BOOL)animated
                        completion:(nullable LSRAnimationCompletion)completion {
    [self lsr_dismissAction:^{
        [self popToViewController:viewController animated:NO];
    } animated:animated completion:completion];
}

- (void)lsr_dismissToRootViewController {
    [self lsr_dismissToRootViewControllerAnimated:YES completion:nil];
}

- (void)lsr_dismissToRootViewControllerAnimated:(BOOL)animated
                                    completion:(nullable LSRAnimationCompletion)completion {
    [self lsr_dismissAction:^{
        [self popToRootViewControllerAnimated:NO];
    } animated:animated completion:completion];
}

@end
