//
//  LSRRouterKit.m
//  LSRRouterKit
//
//  Created by liguoyang on 2019/3/4.
//
//

#import "LSRRouter.h"
#import <objc/runtime.h>
#import "LSRIObjectRouter.h"
#import "LSRRouterConfig.h"
#import "LSRRouterNavigator.h"
#import "LSRRelyingOnQueue.h"

NSString * const kMARouterNonResonseParamKeyTarget = @"targetName";
NSString * const kMARouterNonResonseParamKeyAction = @"actionName";
NSString * const kMARouterNonResonseParamKeyParams = @"originParams";

static NSString * const kMARouterDefaultSelectorName        = @"ma_routerWithParams";
static NSString * const kMARouterNonResonseClass            = @"MARouterNonResponse";
static NSString * const kMARouterNonResonseMethod           = @"action:";
static NSString * const kMARouterVCParamsKeyShouldOpenVC    = @"ma_shouldOpen";
static NSString * const kMARouterVCParamsValueShouldOpenVC  = @"1";

static NSMutableDictionary<NSString *, id> *ma_cachedTargets = nil;
static NSMutableDictionary<NSString *, NSString *> *ma_routersMap = nil;
static NSMutableSet<NSString *> *ma_publicRouterKeys = nil;
static NSMutableSet<NSString *> *ma_routerSchemes = nil;
static NSMutableArray<id<LSRIRouterInterceptor>> *ma_router_interceptors = nil;
static BOOL ma_router_autoCheckNavController = NO;

@interface LSRRouter ()
@end

@implementation LSRRouter

#pragma mark - Private Methods

+ (void)cacheTarget:(id)target name:(NSString *)targetName {
    
    if ([target respondsToSelector:@selector(lsr_shouldCachedInRouter)] && [target lsr_shouldCachedInRouter]) {
        @synchronized (ma_cachedTargets) {
            if (!ma_cachedTargets) {
                ma_cachedTargets = [[NSMutableDictionary alloc] init];
            }
            ma_cachedTargets[targetName] = target;
        }
    }
}

+ (NSString *)targetForScheme:(NSString *)scheme host:(NSString *)host {
    if (!ma_routersMap || ma_routersMap.count <= 0) {
        return nil;
    }
    
    NSString *routerKey = [NSString stringWithFormat:@"%@_%@", scheme, host];
    NSString *target = ma_routersMap[routerKey];
    if (!target) {
        routerKey = [NSString stringWithFormat:@"_%@", host];
        target = ma_routersMap[routerKey];
    }
    return target;
}

+ (NSString *)selectorNameFromURL:(NSURL *)url {
    NSArray<NSString *> *pathComponents = url.pathComponents;
    NSString *selectorName = nil;
    for (NSString *path in pathComponents) {
        if (![path isEqualToString:@"/"]) {
            selectorName = path;
            break;
        }
    }
    return [self selectorNameForAction:selectorName];
}

+ (NSString *)selectorNameForAction:(NSString *)actionName {
    NSString *selectorName = actionName;
    if (selectorName.length <= 0) {
        selectorName = kMARouterDefaultSelectorName;
    }
    return selectorName;
}

+ (NSDictionary<NSString *, id> *)queryParamsFromURL:(NSURL *)url {
    if (!url) {
        return nil;
    }
    
    NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
    NSArray<NSURLQueryItem *> *queryItems = [components queryItems] ?: @[];
    NSMutableDictionary *queryParams = @{}.mutableCopy;
    
    for (NSURLQueryItem *item in queryItems) {
        if (item.value == nil) {
            continue;
        }
        
        id oldValue = queryParams[item.name];
        if (oldValue) {
            if ([oldValue isKindOfClass:[NSMutableArray class]]) {
                [oldValue addObject:item.value];
            } else {
                queryParams[item.name] = [NSMutableArray arrayWithObjects:oldValue, item.value, nil];
            }
        } else {
            queryParams[item.name] = item.value;
        }
    }
    
    return queryParams.copy;
}

+ (NSDictionary<NSString *, id> *)solveURLParams:(NSDictionary<NSString *, id> *)urlParams
                                      funcParams:(NSDictionary<NSString *, id> *)funcParams {
    
    NSMutableDictionary *finalParams = nil;
    if (urlParams) {
        finalParams = [urlParams mutableCopy];
    } else {
        finalParams = [[NSMutableDictionary alloc] init];
    }
    
    [funcParams enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        finalParams[key] = obj;
    }];
    
    return finalParams;
}

+ (id)safePerformAction:(SEL)action target:(id)target params:(NSDictionary *)params {
    
    NSMethodSignature* methodSig = [target methodSignatureForSelector:action];
    if(methodSig == nil) {
        return nil;
    }
    const char* retType = [methodSig methodReturnType];
    
    if (strcmp(retType, @encode(void)) == 0) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSig];
        [invocation setArgument:&params atIndex:2];
        [invocation setSelector:action];
        [invocation setTarget:target];
        [invocation invoke];
        return nil;
    }
    
    if (strcmp(retType, @encode(NSInteger)) == 0) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSig];
        [invocation setArgument:&params atIndex:2];
        [invocation setSelector:action];
        [invocation setTarget:target];
        [invocation invoke];
        NSInteger result = 0;
        [invocation getReturnValue:&result];
        return @(result);
    }
    
    if (strcmp(retType, @encode(BOOL)) == 0) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSig];
        [invocation setArgument:&params atIndex:2];
        [invocation setSelector:action];
        [invocation setTarget:target];
        [invocation invoke];
        BOOL result = 0;
        [invocation getReturnValue:&result];
        return @(result);
    }
    
    if (strcmp(retType, @encode(CGFloat)) == 0) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSig];
        [invocation setArgument:&params atIndex:2];
        [invocation setSelector:action];
        [invocation setTarget:target];
        [invocation invoke];
        CGFloat result = 0;
        [invocation getReturnValue:&result];
        return @(result);
    }
    
    if (strcmp(retType, @encode(NSUInteger)) == 0) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSig];
        [invocation setArgument:&params atIndex:2];
        [invocation setSelector:action];
        [invocation setTarget:target];
        [invocation invoke];
        NSUInteger result = 0;
        [invocation getReturnValue:&result];
        return @(result);
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    return [target performSelector:action withObject:params];
#pragma clang diagnostic pop
}

+ (BOOL)shouldJumpToVC:(NSDictionary *)params {
    id shouldOpen = params[kMARouterVCParamsKeyShouldOpenVC];
    if (shouldOpen) {
        return [shouldOpen isEqualToString:kMARouterVCParamsValueShouldOpenVC];
    }
    return YES;
}

+ (void)performTarget:(NSString *)targetName
               action:(NSString *)actionName
               params:(NSDictionary *)params
       routerCallback:(LSRRouterCallback)routerCallback
        customHandler:(MARouterHandler)customHandler
           fromNative:(BOOL)native {
    
    Class targetClass = NSClassFromString(targetName);
    if (!targetClass) {
        [self noTargetActionResponseWithTarget:targetName action:actionName originParams:params classExist:NO];
        return;
    }
    
    //检测依赖项
    if ([targetClass respondsToSelector:@selector(ma_relyingOnRouterURLWithParams:)]) {
        BOOL dependencyExist = [self checkRelyingOnRouterWithTarget:targetClass
                                                             action:actionName
                                                             params:params
                                                     routerCallback:routerCallback
                                                      customHandler:customHandler];
        if (dependencyExist) {
            return;
        }
    }
    
    //需要区分ViewController和普通对象
    if ([targetClass isSubclassOfClass:[UIViewController class]]) {
        [self performControllerTarget:targetClass
                               action:actionName
                               params:params
                       routerCallback:routerCallback
                        customHandler:customHandler];
    } else  {
        [self performObjectTarget:targetClass
                           action:actionName
                           params:params
                   routerCallback:routerCallback
                    customHandler:customHandler];
    }
}

+ (void)performObjectTarget:(Class)targetClass
                     action:(NSString *)actionName
                     params:(NSDictionary *)params
             routerCallback:(LSRRouterCallback)routerCallback
              customHandler:(MARouterHandler)customHandler {
    
    NSString *targetName = NSStringFromClass(targetClass);
    NSString *selectorName = [NSString stringWithFormat:@"%@:", actionName];
    SEL selector = NSSelectorFromString(selectorName);
    
    if ([targetClass instancesRespondToSelector:selector]) {
        id target = ma_cachedTargets[targetName];
        if (!target) {
            target = [[targetClass alloc] init];
            [self cacheTarget:target name:targetName];
        }
        ((NSObject *)target).lsr_routerCallback = routerCallback;
        id returnValue = [self safePerformAction:selector target:target params:params];
        
        if (customHandler) {
            NSString *identifier = [self identifierForTarget:targetName action:selectorName];
            customHandler(identifier, returnValue, target);
        }
    } else if ([targetClass respondsToSelector:selector]) {
        id returnValue = [self safePerformAction:selector target:targetClass params:params];
        if (customHandler) {
            NSString *identifier = [self identifierForTarget:targetName action:selectorName];
            customHandler(identifier, returnValue, targetClass);
        }
    } else {
        [self noTargetActionResponseWithTarget:targetName action:selectorName originParams:params classExist:YES];
        [ma_cachedTargets removeObjectForKey:targetName];
    }
}

+ (void)performControllerTarget:(Class)targetClass
                         action:(NSString *)actionName
                         params:(NSDictionary *)params
                 routerCallback:(LSRRouterCallback)routerCallback
                  customHandler:(MARouterHandler)customHandler {
    
    NSString *selectorName = [NSString stringWithFormat:@"%@:", actionName];
    __block UIViewController *finalController = nil;
    __block id result = nil;
    
    if ([self shouldJumpToVC:params]) {
        [LSRRouterNavigator showViewController:targetClass
                                       params:params
                                    preAction:^(__kindof UIViewController *targetController) {
            finalController = targetController;
            result = [self performSelectorName:selectorName
                                        withVC:finalController
                                        params:params
                                routerCallback:routerCallback];
        }];
    } else {
        finalController = [LSRRouterNavigator sharedVCForController:targetClass params:params];
        result = [self performSelectorName:selectorName
                                    withVC:finalController
                                    params:params
                            routerCallback:routerCallback];
    }
    
    if (customHandler) {
        NSString *identifier = [self identifierForTarget:NSStringFromClass(targetClass) action:selectorName];
        customHandler(identifier, result, finalController);
    }
}

+ (id)performSelectorName:(NSString *)selectorName
                   withVC:(UIViewController *)vc
                   params:(NSDictionary *)params
           routerCallback:(LSRRouterCallback)routerCallback {
    id result = nil;
    vc.lsr_routerCallback = routerCallback;
    SEL selector = NSSelectorFromString(selectorName);
    if ([vc respondsToSelector:selector]) {
        result = [LSRRouter safePerformAction:selector target:vc params:params];
    }
    return result;
}

+ (BOOL)checkRelyingOnRouterWithTarget:(Class)targetClass
                                action:(NSString *)actionName
                                params:(NSDictionary *)params
                        routerCallback:(LSRRouterCallback)routerCallback
                         customHandler:(MARouterHandler)customHandler {
    
    LSRRouterConfig *routerConfig = [targetClass lsr_relyingOnRouterURLWithParams:params];
    if (!routerConfig) {
        return NO;
    }
    
    NSString *targetName = NSStringFromClass(targetClass);
    NSMutableDictionary *finalParams = nil;
    if (params) {
        finalParams = [params mutableCopy];
    }
    //将原有Router加入到参数中，为跳转做准备
    LSRRouterConfig *originRouter = [LSRRouterConfig configWithTarget:targetName
                                                             action:actionName
                                                             params:params
                                                      customHandler:customHandler];
    originRouter.lsr_routerCallback = routerCallback;
    
    if (routerConfig.url) {
        NSString *target = [self targetForScheme:routerConfig.url.scheme host:routerConfig.url.host];
        [LSRRelyingOnQueue cacheRouterConfig:originRouter forClass:NSClassFromString(target)];
        [self openURL:routerConfig.url
               params:finalParams
       routerCallback:routerConfig.lsr_routerCallback
        customHandler:routerConfig.customHandler];
    } else {
        [LSRRelyingOnQueue cacheRouterConfig:originRouter forClass:NSClassFromString(routerConfig.targetName)];
        [self performTarget:routerConfig.targetName
                     action:routerConfig.actionName
                     params:finalParams
             routerCallback:routerConfig.lsr_routerCallback
              customHandler:routerConfig.customHandler];
    }
    return YES;
}

+ (NSString *)identifierForTarget:(NSString *)targetName action:(NSString *)actionName {
    return [NSString stringWithFormat:@"%@.%@", targetName, actionName];
}

#pragma mark - Registers

+ (void)registerScheme:(NSString *)scheme {
    @synchronized (ma_routerSchemes) {
        if (!ma_routerSchemes) {
            ma_routerSchemes = [[NSMutableSet alloc] init];
        }
        if (scheme.length > 0) {
            [ma_routerSchemes addObject:[scheme copy]];
        }
    }
}

+ (void)registerRouter:(NSString *)router target:(Class)targetClass {
    [self registerScheme:@"" router:router target:targetClass];
}

+ (void)registerScheme:(NSString *)scheme router:(NSString *)router target:(Class)targetClass {
    [self registerScheme:scheme router:router target:targetClass public:NO];
}

+ (void)registerPublicRouter:(NSString *)router target:(Class)targetClass {
    [self registerPublicScheme:@"" router:router target:targetClass];
}

+ (void)registerPublicScheme:(NSString *)scheme router:(NSString *)router target:(Class)targetClass {
    [self registerScheme:scheme router:router target:targetClass public:YES];
}

+ (void)registerScheme:(NSString *)scheme router:(NSString *)router target:(Class)targetClass public:(BOOL)isPublic {
    
    NSAssert(scheme != nil, @"scheme不能为nil");
    NSAssert(router.length > 0, @"router不能为nil,并且不能为空字符串");
    NSAssert(targetClass != nil, @"targetClass不能为nil");
    
    NSString *routerKey = [NSString stringWithFormat:@"%@_%@", scheme, router];
    @synchronized (ma_routersMap) {
        if (!ma_routersMap) {
            ma_routersMap = [[NSMutableDictionary alloc] init];
        }
        
        NSString *target = ma_routersMap[routerKey];
        if (target) {
            NSAssert(NO, @"不能重复注册router");
        }
        ma_routersMap[routerKey] = NSStringFromClass(targetClass);
    }
    
    if (!isPublic) {
        return;
    }
    
    @synchronized (ma_publicRouterKeys) {
        if (!ma_publicRouterKeys) {
            ma_publicRouterKeys = [[NSMutableSet alloc] init];
        }
        [ma_publicRouterKeys addObject:routerKey];
    }
}

#pragma mark - Can Open URL

+ (BOOL)canOpenURL:(NSURL *)url {
    return [self canOpenURL:url public:NO];
}

+ (BOOL)canOpenPublicURL:(NSURL *)publicURL {
    return [self canOpenURL:publicURL public:YES];
}

+ (BOOL)canOpenURL:(NSURL *)url public:(BOOL)isPublic {
    return [self canOpenURL:url public:isPublic checkInterceptor:YES];
}

+ (BOOL)canOpenURL:(NSURL *)url public:(BOOL)isPublic checkInterceptor:(BOOL)shouldCheck {
    if (!url) {
        return NO;
    }
    
    if (shouldCheck && [self interceptURL:url shouldProcess:NO]) {
        return YES;
    }
    
    NSString *scheme = url.scheme;
    if (scheme.length <= 0) {
        return NO;
    }
    
    NSString *host = url.host;
    if (host.length <= 0) {
        return NO;
    }
    
    if (isPublic && ![self publicRouterKeysContainScheme:scheme host:host]) {
        return NO;
    }
    
    NSString *target = [self targetForScheme:scheme host:host];
    if (!target) {
        return NO;
    }
    
    Class targetClass = NSClassFromString(target);
    if (!targetClass) {
        return NO;
    }
    
    if ([targetClass isSubclassOfClass:[UIViewController class]]) {
        return YES;
    }
    
    NSString *selectorName = [NSString stringWithFormat:@"%@:", [self selectorNameFromURL:url]];
    SEL selector = NSSelectorFromString(selectorName);
    if ([targetClass instancesRespondToSelector:selector] || [targetClass respondsToSelector:selector]) {
        return YES;
    }
    return NO;
}

+ (BOOL)publicRouterKeysContainScheme:(NSString *)scheme host:(NSString *)host {
    NSString *routerKey = [NSString stringWithFormat:@"%@_%@", scheme, host];
    if ([ma_publicRouterKeys containsObject:routerKey]) {
        return YES;
    }
    
    routerKey = [NSString stringWithFormat:@"_%@", host];
    return [ma_publicRouterKeys containsObject:routerKey];
}

#pragma mark - Open URL

+ (BOOL)openURL:(NSURL *)url
         params:(NSDictionary *)params
 routerCallback:(LSRRouterCallback)routerCallback
  customHandler:(MARouterHandler)customHandler
         public:(BOOL)isPublic {
    //1. 优先处理拦截器逻辑
    if ([self interceptURL:url shouldProcess:YES]) {
        return YES;
    }
    
    //2. 判断是否是公共路由
    if (isPublic && ![self canOpenURL:url public:YES checkInterceptor:NO]) {
        return NO;
    }
    
    //3.判断是否是全局路由
    if (!isPublic && ![self canOpenURL:url public:NO checkInterceptor:NO]) {
        return NO;
    }
    
    NSString *target          = [self targetForScheme:url.scheme host:url.host];
    NSString *selectorName    = [self selectorNameFromURL:url];
    NSDictionary *urlParams   = [self queryParamsFromURL:url];
    NSDictionary *finalParams = [self solveURLParams:urlParams funcParams:params];
    
    [self performTarget:target
                 action:selectorName
                 params:finalParams
         routerCallback:routerCallback
          customHandler:customHandler
             fromNative:NO];
    return YES;
}

+ (BOOL)openURL:(NSURL *)url
         params:(NSDictionary *)params
 routerCallback:(LSRRouterCallback)routerCallback
  customHandler:(MARouterHandler)customHandler {
    return [self openURL:url params:params routerCallback:routerCallback customHandler:customHandler public:NO];
}

+ (BOOL)openURL:(NSURL *)url params:(NSDictionary *)params routerCallback:(LSRRouterCallback)routerCallback {
    return [self openURL:url params:params routerCallback:routerCallback customHandler:NULL];
}

+ (BOOL)openURL:(NSURL *)url routerCallback:(LSRRouterCallback)routerCallback {
    return [self openURL:url params:nil routerCallback:routerCallback];
}

+ (BOOL)openURL:(NSURL *)url {
    return [self openURL:url routerCallback:NULL];
}

+ (BOOL)openPublicURL:(NSURL *)publicURL
               params:(NSDictionary *)params
       routerCallback:(LSRRouterCallback)routerCallback
        customHandler:(MARouterHandler)customHandler {
    return [self openURL:publicURL params:params routerCallback:routerCallback customHandler:customHandler public:YES];
}

+ (BOOL)openPublicURL:(NSURL *)publicURL
               params:(NSDictionary *)params
       routerCallback:(LSRRouterCallback)routerCallback {
    return [self openPublicURL:publicURL params:params routerCallback:routerCallback customHandler:NULL];
}

+ (BOOL)openPublicURL:(NSURL *)publicURL routerCallback:(LSRRouterCallback)routerCallback {
    return [self openPublicURL:publicURL params:nil routerCallback:routerCallback];
}

+ (BOOL)openPublicURL:(NSURL *)publicURL {
    return [self openPublicURL:publicURL routerCallback:NULL];
}

+ (void)performTarget:(NSString *)targetName
               action:(NSString *)actionName
               params:(NSDictionary *)params
       routerCallback:(LSRRouterCallback)routerCallback
        customHandler:(MARouterHandler)customHandler {
    NSString *selectorName = [self selectorNameForAction:actionName];
    [self performTarget:targetName
                 action:selectorName
                 params:params
         routerCallback:routerCallback
          customHandler:customHandler
             fromNative:YES];
}

+ (void)removeObjectFromRouterCache:(NSString *)targetName {
    if (targetName) {
        [ma_cachedTargets removeObjectForKey:targetName];
    }
}


#pragma mark - interceptors
+ (void)registerRouterInterceptor:(id<LSRIRouterInterceptor>)interceptor {
    if (!interceptor) {
        return;
    }
    
    if (!ma_router_interceptors) {
        ma_router_interceptors = [[NSMutableArray alloc] init];
    }
    
    [ma_router_interceptors addObject:interceptor];
}

+ (BOOL)interceptURL:(NSURL *)url shouldProcess:(BOOL)shouldProcess {
    if (!ma_router_interceptors || !url) {
        return NO;
    }
    
    for (id<LSRIRouterInterceptor> interceptor in ma_router_interceptors) {
        if ([interceptor canHandleURL:url]) {
            if (shouldProcess) {
                [interceptor process:url];
            }
            return YES;
        }
    }
    return NO;
}

#pragma mark - Error Asserts

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"

+ (void)noTargetActionResponseWithTarget:(NSString *)targetName
                                  action:(NSString *)actionName
                            originParams:(NSDictionary *)originParams
                              classExist:(BOOL)exist {
    @try {
        if (exist) {
            NSString *errorMsg = [NSString stringWithFormat:@"MARouter:%@未能正常响应%@.", targetName, actionName];
            NSLog(@"%@", errorMsg);
        } else {
            NSString *errorMsg = [NSString stringWithFormat:@"MARouter:项目中未发现%@.", targetName];
            NSLog(@"%@", errorMsg);
        }
        
        id target = [[NSClassFromString(kMARouterNonResonseClass) alloc] init];
        if (!target) {
            return;
        }
        
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        params[kMARouterNonResonseParamKeyTarget] = targetName;
        params[kMARouterNonResonseParamKeyAction] = actionName;
        if (originParams) {
            params[kMARouterNonResonseParamKeyParams] = originParams;
        }
        
        SEL action = NSSelectorFromString(kMARouterNonResonseMethod);
        [self safePerformAction:action target:target params:params];
    } @catch (NSException *exception) {
    }
}

#pragma clang diagnostic pop

@end

@implementation LSRRouter (MAStringURL)

#pragma mark - Private Methods

+ (NSString *)chineseUrlEncode:(NSString *)urlString {

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

    CFStringRef unescapeStr = (CFStringRef)@"!$&'()*+,-./:;=?@_~%#[]";
    NSString *encodedString = CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                        (CFStringRef)urlString,
                                                                                        unescapeStr,
                                                                                        NULL,
                                                                                        kCFStringEncodingUTF8));
#pragma clang diagnostic pop
    
    return encodedString;
}

#pragma mark - Public Methods

+ (BOOL)canOpenURLString:(NSString *)urlString {
    NSString *targetURL = [self chineseUrlEncode:urlString];
    return [self canOpenURL:[NSURL URLWithString:targetURL]];
}

+ (BOOL)canOpenPublicURLString:(NSString *)urlString {
    NSString *targetURL = [self chineseUrlEncode:urlString];
    return [self canOpenPublicURL:[NSURL URLWithString:targetURL]];
}

+ (BOOL)openURLString:(NSString *)urlString
               params:(NSDictionary *)params
       routerCallback:(LSRRouterCallback)routerCallback
        customHandler:(MARouterHandler)customHandler {
    NSURL *targetURL = [NSURL URLWithString:[self chineseUrlEncode:urlString]];
    return [self openURL:targetURL params:params routerCallback:routerCallback customHandler:customHandler];
}

+ (BOOL)openURLString:(NSString *)urlString
               params:(NSDictionary *)params
       routerCallback:(LSRRouterCallback)routerCallback {
    return [self openURLString:urlString params:params routerCallback:routerCallback customHandler:NULL];
}

+ (BOOL)openURLString:(NSString *)urlString routerCallback:(LSRRouterCallback)routerCallback {
    return [self openURLString:urlString params:nil routerCallback:routerCallback];
}

+ (BOOL)openURLString:(NSString *)urlString {
    return [self openURLString:urlString routerCallback:NULL];
}

+ (BOOL)openPublicURLString:(NSString *)urlString
                     params:(NSDictionary *)params
             routerCallback:(LSRRouterCallback)routerCallback
              customHandler:(MARouterHandler)customHandler {
    NSURL *targetURL = [NSURL URLWithString:[self chineseUrlEncode:urlString]];
    return [self openPublicURL:targetURL params:params routerCallback:routerCallback customHandler:customHandler];
}

+ (BOOL)openPublicURLString:(NSString *)urlString
                     params:(NSDictionary *)params
             routerCallback:(LSRRouterCallback)routerCallback {
    return [self openPublicURLString:urlString params:params routerCallback:routerCallback customHandler:NULL];
}

+ (BOOL)openPublicURLString:(NSString *)urlString routerCallback:(LSRRouterCallback)routerCallback {
    return [self openPublicURLString:urlString params:nil routerCallback:routerCallback];
}

+ (BOOL)openPublicURLString:(NSString *)urlString {
    return [self openPublicURLString:urlString routerCallback:NULL];
}

+ (BOOL)navControllerMonitorEnabled {
    return ma_router_autoCheckNavController;
}

+ (void)enableNavControllerMonitor:(BOOL)enabled {
    ma_router_autoCheckNavController = enabled;
}

@end
