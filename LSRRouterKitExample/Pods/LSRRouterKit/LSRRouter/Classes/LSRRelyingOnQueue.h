//
//  MARelyingOnQueue.h
//  MARouterKit
//
//  Created by liguoyang on 2019/3/12.
//
//

#import <Foundation/Foundation.h>

@class LSRRouterConfig;
@interface LSRRelyingOnQueue : NSObject

/**
 缓存对应依赖Class的routerConfig到栈中。
 
 @param routerConfig 路由配置
 @param targetClass 依赖的类对象
 */
+ (void)cacheRouterConfig:(LSRRouterConfig *)routerConfig forClass:(Class)targetClass;

/**
 从缓存栈的最顶端获取依赖Class的routerConfig，并出栈。

 @param targetClass 依赖的类对象
 @return 路由配置
 */
+ (LSRRouterConfig *)popRouterConfigForClass:(Class)targetClass;

/**
 清空当前所有的缓存信息。
 */
+ (void)emptyQueue;

@end
