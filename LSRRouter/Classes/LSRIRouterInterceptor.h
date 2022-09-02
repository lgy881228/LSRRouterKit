//
//  LSRIRouterInterceptor.h
//  LSRRouterKit
//
//  Created by liguoyang on 2021/6/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


/// 路由拦截器，用于进行通用路由规则解析前的拦截处理，开发者可以进行自定义处理
@protocol LSRIRouterInterceptor <NSObject>

@required


/// 自定义逻辑判断URL是否可被拦截器处理。
/// @param url 将要被处理的路由url。
- (BOOL)canHandleURL:(NSURL *)url;

/// 自定义拦截器处理逻辑，只有当方法canHandleURL:返回YES时，该方法才会被执行。且被注册的拦截器只有一个会被执行。
/// @param url 将要被处理的路由url。
- (void)process:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END
