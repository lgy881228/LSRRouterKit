//
//  LSRRouterKit.h
//  LSRRouterKit
//
//  Created by liguoyang on 2019/3/4.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "NSObject+LSRRouter.h"
#import "LSRIRouterInterceptor.h"

FOUNDATION_EXTERN NSString * const kLSRRouterNonResonseParamKeyTarget;
FOUNDATION_EXTERN NSString * const kLSRRouterNonResonseParamKeyAction;
FOUNDATION_EXTERN NSString * const kLSRRouterNonResonseParamKeyParams;

/**
 Router处理完成后的回调

 @param targetIdentifier 处理Router的唯一标识
 @param returnValue 处理router后的返回值
            --> 执行actionName方法后的返回值
 @param target 目标对象
            --> 如果路由的target是视图控制器，那么target就是【控制器对象】
            --> 如果路由的target是NSObject子类，且actionName是类方法，那么target就是【类对象】
            --> 如果路由的target是NSObject子类，且actionName是实例方法，那么target就是【实例对象】
 */
typedef void(^LSRRouterHandler)(NSString *targetIdentifier,
                               id returnValue,
                               id target);

@class LSRRouterConfig, LSRIRouterInterceptor;
@interface LSRRouter : NSObject

/**
 注册Router支持的scheme，该方法不会覆盖原有的注册，会保留所有的注册。

 @param scheme 支持的scheme
 */
+ (void)registerScheme:(NSString *)scheme;

/**
 
 对router进行注册，默认使用scheme为空字符串@""，调用registerScheme:router:target:
 
 @param router url的host
 @param targetClass 映射的类对象
 */
+ (void)registerRouter:(NSString *)router target:(Class)targetClass;

/**
 
 对router进行注册
 建议target在+load中进行该注册操作。
 
 @param scheme url的scheme
 @param router url的host
 @param targetClass 映射的类对象
 */
+ (void)registerScheme:(NSString *)scheme router:(NSString *)router target:(Class)targetClass;

/**
 
 对公共的router进行注册，默认使用scheme为空字符串@""，调用registerPublicScheme:router:target:
 公共的router: 可以供H5、推送通知等中定义的url打开的router
 
 @param router url的host
 @param targetClass 映射的类对象
 */
+ (void)registerPublicRouter:(NSString *)router target:(Class)targetClass;

/**
 
 对公共的router进行注册
 公共的router: 可以供H5、推送通知等中定义的url打开的router
 建议target在+load中进行该注册操作。
 
 @param scheme url的scheme
 @param router url的host
 @param targetClass 映射的类对象
 */
+ (void)registerPublicScheme:(NSString *)scheme router:(NSString *)router target:(Class)targetClass;

#pragma mark - URL调用

/**
 是否可以处理url
 
 url的规则
 scheme://host/path?param1=value1&p2=v2
 
 判断规则如下：
 1. url的解析规则
    -> scheme: 注册部分的scheme
    -> host: 注册部分的router
    -> path: 待处理的具体方法
 
 2. 匹配规则
    -> 通过scheme和host来确定目标类<Target>
    -> 如果Target为UIViewController的子类
        -> 匹配成功
    -> 如果Target为普通的对象
        -> 判断Target是否实现了path对应的实例方法@selector(path:)
            -> 匹配成功
        -> 判断Target是否实现了path对应的类方法@selector(path:)
            -> 匹配成功

 @param url 待处理的url
 @return 是否可以处理
 */
+ (BOOL)canOpenURL:(NSURL *)url;

/**
 是否可以处理公共的URL
 
 判断规则如下：
 1. 首先判断url是否在公共的router注册表中，如果不在直接返回NO。
 2. 参照canOpenURL:的判断逻辑。

 @param publicURL 待处理的url
 @return 是否可以处理
 */
+ (BOOL)canOpenPublicURL:(NSURL *)publicURL;

/**
 处理URL
 
 url的规则
 scheme://host/path?param1=value1&p2=v2
 
 1. url的解析规则
     -> scheme: 注册部分的scheme
     -> host: 注册部分的router
     -> path: 待处理的具体方法
     -> query: 经过解析会生成方法的参数，会对参数值进行urlDecode，类型为NSDictionary
 
 2. 处理规则
    -> 从注册表中查询对应的<Target>
        1> 通过scheme和host来确定目标类<Target>
        2> 直接通过host来确定目标类<Target>
 
    -> <Target>的对象类型
        1> UIViewController对象
            -> 直接初始化
            -> 如果path存在
                -> 如果实现了path对应的实例方法@selector(path:), 则调用。
            -> 如果path不存在，则默认path为lsr_routerWithParams
                -> 如果实现了path对应的实例方法@selector(path:), 则调用。
            -> 判断是Push还是Present方式显示VC
            -> 判断是否单例
                -> 解释：UINavigationController中只保存一个该类型的实例
        2> 普通对象
            -> 如果实现了path对应的实例方法@selector(path:)，直接调用。
            -> 判断Target是否实现了path对应的类方法@selector(path:)，直接调用。
            -> 判断是否需要缓存到Router中
                -> 如果需要缓存，则优先从缓存中来获取该类的对象实例

 @param url 待处理的url
 @param params 额外的参数配置，会覆盖从url中解析到的参数
 @param routerCallback 在被调起方执行该block进行回调操作，仅支持实例方法的回调
 @param customHandler 自定义的回调handler
                 -->执行路由逻辑后，立即执行该回调，供集成方自己处理别的逻辑
                 -->会返回标识、目标控制器、actionName方法执行后的返回值
 @return 是否可以处理
 */
+ (BOOL)openURL:(NSURL *)url
         params:(NSDictionary *)params
 routerCallback:(LSRRouterCallback)routerCallback
  customHandler:(LSRRouterHandler)customHandler;

+ (BOOL)openURL:(NSURL *)url params:(NSDictionary *)params routerCallback:(LSRRouterCallback)routerCallback;
+ (BOOL)openURL:(NSURL *)url routerCallback:(LSRRouterCallback)routerCallback;
+ (BOOL)openURL:(NSURL *)url;

/**
 处理公共的URL
 解析逻辑参考openURL:params:customHandler:
 
 @param publicURL 待处理的url
 @param params 额外的参数配置，会覆盖从url中解析到的参数
 @param routerCallback 在被调起方执行该block进行回调操作，仅支持实例方法的回调
 @param customHandler 自定义的回调handler
                 -->执行路由逻辑后，立即执行该回调，供集成方自己处理别的逻辑
                 -->会返回标识、目标控制器、actionName方法执行后的返回值
 @return 是否可以处理
 */
+ (BOOL)openPublicURL:(NSURL *)publicURL
               params:(NSDictionary *)params
       routerCallback:(LSRRouterCallback)routerCallback
        customHandler:(LSRRouterHandler)customHandler;

+ (BOOL)openPublicURL:(NSURL *)publicURL params:(NSDictionary *)params routerCallback:(LSRRouterCallback)routerCallback;
+ (BOOL)openPublicURL:(NSURL *)publicURL routerCallback:(LSRRouterCallback)routerCallback;
+ (BOOL)openPublicURL:(NSURL *)publicURL;

#pragma mark - 应用内模块之间调用

/**
 处理规则
 -> <Target>的对象类型
     1> UIViewController对象
         -> 直接初始化
         -> 如果actionName存在
            -> 如果实现了actionName对应的实例方法@selector(actionName:), 则调用。
         -> 如果actionName不存在，则默认actionName为lsr_routerWithParams
            -> 如果实现了path对应的实例方法@selector(actionName:), 则调用。
         -> 判断是Push还是Present方式显示VC
         -> 判断是否单例
            -> 解释：UINavigationController中只保存一个该类型的实例
     2> 普通对象
         -> 如果实现了actionName对应的实例方法@selector(actionName:)，直接调用。
            -> 判断Target是否实现了actionName对应的类方法@selector(actionName:)，直接调用。
         -> 判断Target是否实现了path对应的类方法@selector(path:)，直接调用。
         -> 判断是否需要缓存到Router中
            -> 如果需要缓存，则优先从缓存中来获取该类的对象实例
 -> 如果没有找到对应的类和实现方法的实现。
    1. 自动实例化LSRRouterNonResponse类，并且调用该类的action:方法
    2. action方法的参数为NSDictionary类型，参数值说明。
        kLSRRouterNonResonseParamKeyTarget -> 原目标类类型
        kLSRRouterNonResonseParamKeyAction -> 原调用的方法名
        kLSRRouterNonResonseParamKeyParams -> 原参数列表
 

 @param targetName 目标类
 @param actionName 目标方法名，【必须带有参数，否则提示未注册】
 @param params 参数
 @param routerCallback 在被调起方执行该block进行回调操作，仅支持实例方法的回调
 @param customHandler 自定义的回调handler，
                 -->执行路由逻辑后，立即执行该回调，供集成方自己处理别的逻辑
                 -->会返回标识、目标控制器、actionName方法执行后的返回值
 */
+ (void)performTarget:(NSString *)targetName
               action:(NSString *)actionName
               params:(NSDictionary *)params
       routerCallback:(LSRRouterCallback)routerCallback
        customHandler:(LSRRouterHandler)customHandler;

/**
 从缓存中移除Class对应的实例，释放内存。

 @param targetName 待移除的类名
 */
+ (void)removeObjectFromRouterCache:(NSString *)targetName;


#pragma mark - 拦截器配置

/// 配置路由拦截器，拦截器执行逻辑将优先于通用路由规则处理
/// 拦截器执行顺序，按照注册的顺序执行，如果有一个拦截器执行，其他拦截器逻辑将不执行。
/// @param interceptor 拦截器
+ (void)registerRouterInterceptor:(id<LSRIRouterInterceptor>)interceptor;

@end

@interface LSRRouter (LSRStringURL)


/**
 是否可以处理urlString
 API会先对传入的urlString中的特殊字符包括中文进行编码，防止无法生成NSURL对象

 @param urlString 待处理的urlString
 @return 是否可以处理
 */
+ (BOOL)canOpenURLString:(NSString *)urlString;

+ (BOOL)canOpenPublicURLString:(NSString *)urlString;

/**
 处理urlString
 API会先对传入的urlString中的特殊字符包括中文进行编码，防止无法生成NSURL对象
 
 @param urlString 待处理的urlString
 @param params 参数
 @param routerCallback 在被调起方执行该block进行回调操作，仅支持实例方法的回调
 @param customHandler 自定义的回调handler
 @return 是否可以处理
 */
+ (BOOL)openURLString:(NSString *)urlString
               params:(NSDictionary *)params
       routerCallback:(LSRRouterCallback)routerCallback
        customHandler:(LSRRouterHandler)customHandler;

+ (BOOL)openURLString:(NSString *)urlString
               params:(NSDictionary *)params
       routerCallback:(LSRRouterCallback)routerCallback;

+ (BOOL)openURLString:(NSString *)urlString routerCallback:(LSRRouterCallback)routerCallback;
+ (BOOL)openURLString:(NSString *)urlString;


/**
 处理urlString，处理逻辑参考openURLString:params:customHandler:

 @param urlString 待处理的urlString
 @param params 参数
 @param routerCallback 在被调起方执行该block进行回调操作，仅支持实例方法的回调
 @param customHandler 自定义的回调handler
 @return 是否可以处理
 */
+ (BOOL)openPublicURLString:(NSString *)urlString
                     params:(NSDictionary *)params
             routerCallback:(LSRRouterCallback)routerCallback
              customHandler:(LSRRouterHandler)customHandler;

+ (BOOL)openPublicURLString:(NSString *)urlString
                     params:(NSDictionary *)params
             routerCallback:(LSRRouterCallback)routerCallback;

+ (BOOL)openPublicURLString:(NSString *)urlString routerCallback:(LSRRouterCallback)routerCallback;
+ (BOOL)openPublicURLString:(NSString *)urlString;

/// 获取是否自动检测UINavigationController
+ (BOOL)navControllerMonitorEnabled;

/// 设置是否自动检测UINavigationController
/// 如果为YES，则自动检测。
/// 如果为NO，直接使用 [LSRRouterNavigator currentNavController]。
/// @param enabled 是否自动检测UINavigationController，默认不检测
+ (void)enableNavControllerMonitor:(BOOL)enabled;

@end
