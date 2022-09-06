//
//  NSObject+MARouter.h
//  MARouterKit
//
//  Created by liguoyang on 2019/3/12.
//

#import <Foundation/Foundation.h>

typedef void (^LSRRouterCallback)(_Nullable id callbackParams);

@interface NSObject (LSRRouter)

/**
 用于存放router的回调，不要在代码中显示设置该属性。
 router在调用相应方法的时候会自动设置该属性。
 */
@property (nonatomic, copy, nullable) LSRRouterCallback lsr_routerCallback;

/**
 对于设置了依赖lsr_relyingOnRouterURLWithParams:的对象，
 在执行完依赖routerConfig后，需要继续执行原有Router的，调用该方法。
  */
+ (void)lsr_notifyRouterQueue:(NSDictionary * _Nullable)params;


/**
 @see +lsr_notifyRouterQueue
 */
- (void)lsr_notifyRouterQueue:(NSDictionary * _Nullable)params;

@end
