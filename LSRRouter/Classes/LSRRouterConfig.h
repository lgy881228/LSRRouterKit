//
//  LSRRouterKitConfig.h
//  LSRRouterKit
//
//  Created by liguoyang on 2019/3/6.
//
//

#import <Foundation/Foundation.h>
#import "LSRRouter.h"

@interface LSRRouterConfig : NSObject <NSCopying, NSMutableCopying>

@property (nonatomic, strong, readonly) NSString *targetName;
@property (nonatomic, strong, readonly) NSString *actionName;

@property (nonatomic, strong, readonly) NSURL *url;
@property (nonatomic, strong, readonly) NSDictionary *params;
@property (nonatomic, copy, readonly) LSRRouterHandler customHandler;


/**
 应用内的路由配置的初始化

 @param target 目标类对象的字符串
 @param action 目前方法名
 @param params 调用参数
 @param customHandler 路由回调
 @return 路由配置
 */
+ (instancetype)configWithTarget:(NSString *)target
                          action:(NSString *)action
                          params:(NSDictionary *)params
                   customHandler:(LSRRouterHandler)customHandler;

/**
 应用外URL的路由配置的初始化

 @param url 路由url
 @param params 额外的参数
 @param customHandler 路由回调
 @return 路由配置
 */
+ (instancetype)configWithURL:(NSURL *)url
                       params:(NSDictionary<NSString *, id> *)params
                customHandler:(LSRRouterHandler)customHandler;
+ (instancetype)configWithURL:(NSURL *)url;


/**
 应用外URL的路由配置的简便入口，调用 @see configWithURL:params:customHandler:

 @param urlString 路由url的字符串表示
 @param params 额外的参数
 @param customHandler 路由回调
 @return 路由配置
 */
+ (instancetype)configWithURLString:(NSString *)urlString
                             params:(NSDictionary<NSString *, id> *)params
                      customHandler:(LSRRouterHandler)customHandler;

+ (instancetype)configWithURLString:(NSString *)urlString;

/**
 SDK版本号
 */
+ (NSString *)sdkVersion;

@end
