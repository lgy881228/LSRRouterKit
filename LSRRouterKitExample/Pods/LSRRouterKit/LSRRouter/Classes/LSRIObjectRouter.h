//
//  LSRIObjectRouter.h
//  LSRRouterKit
//
//  Created by liguoyang on 2019/3/5.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class LSRRouterConfig;

/**
 公共的Router协议配置
 */
@protocol LSRIRouter <NSObject>

@optional

/**
 配置的当前路由执行之前需要依赖的路由url。
 在依赖的路由完成需要的操作后，需要调用ma_notifyRouterQueue来进行回调通知。
 
 @param params 打开源路由的参数
 @return 依赖的路由url
 */
+ (LSRRouterConfig *)lsr_relyingOnRouterURLWithParams:(NSDictionary *)params;

/**
 在url中如果只是定义了host没有定义path，默认的实例方法签名。
 
 @param params 参数
 @return 返回值
 */
- (id)lsr_routerWithParams:(NSDictionary *)params;

/**
 在url中如果只是定义了host没有定义path，默认的类方法签名。
 
 @param params 参数
 @return 返回值
 */
+ (id)lsr_routerWithParams:(NSDictionary *)params;

@end


/**
 非Controller类的Router协议配置
 */
@protocol LSRIObjectRouter <LSRIRouter>

@optional

/**
 配置当前类生成的实例是否要缓存到Router中。
 类的实例会优先从缓存中获取，没有才会进行实例化。默认不会进行缓存。

 @return 当前类生成的实例是否要缓存到Router中。
 */
- (BOOL)lsr_shouldCachedInRouter;

@end

/**
 定义Controller的打开方式
 - MANavigationModePush: push a viewController in NavigationController
 - MANavigationModePresent: present a viewController in NavigationController
 */
typedef NS_ENUM(NSUInteger, LSRNavigationMode) {
    LSRNavigationModePush = 0,
    LSRNavigationModePresent
};


/**
 Controller类型的Router协议配置
 */
@protocol LSRIControllerRouter <LSRIRouter>

@optional

/**
 @return 当前Controller的打开方式，默认为MANavigationModePush。
 */
+ (LSRNavigationMode)lsr_navigationMode;

/**
 当前UIViewController在NavigationController中只保存一个当前类型的viewController，
 如果已经存在直接跳到已经存在的Controller中。

 @return 导航控制器的栈中是否只有一个实例
 */
+ (BOOL)lsr_isSharedController;

@end

NS_ASSUME_NONNULL_END
