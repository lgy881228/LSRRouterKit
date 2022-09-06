//
//  NSObject+MARouter.m
//  MARouterKit
//
//  Created by liguoyang on 2019/3/12.
//

#import "NSObject+LSRRouter.h"
#import "LSRRouter.h"
#import "LSRRouterConfig.h"
#import "LSRRelyingOnQueue.h"
#import <objc/runtime.h>

static char kMARouterCallbackKey;

@implementation NSObject (LSRRouter)

#pragma mark - Private Methods

+ (void)ma_notifyRouterQueuePrivate:(Class)targetClass params:(NSDictionary *)params {
    LSRRouterConfig *routerConfig = [LSRRelyingOnQueue popRouterConfigForClass:targetClass];
    if (!routerConfig) {
        return;
    }
    
    NSMutableDictionary *finalParams = [[NSMutableDictionary alloc] initWithDictionary:routerConfig.params];
    if (params) {
        [finalParams addEntriesFromDictionary:params];
    }
    
    if (routerConfig.url) {
        [LSRRouter openURL:routerConfig.url
                   params:finalParams
           routerCallback:routerConfig.lsr_routerCallback
            customHandler:routerConfig.customHandler];
    } else {
        [LSRRouter performTarget:routerConfig.targetName
                         action:routerConfig.actionName
                         params:finalParams
                 routerCallback:routerConfig.lsr_routerCallback
                  customHandler:routerConfig.customHandler];
    }
}

#pragma mark - Public Methods

+ (void)lsr_notifyRouterQueue:(NSDictionary *)params {
    [self ma_notifyRouterQueuePrivate:self params:params];
}

- (void)lsr_notifyRouterQueue:(NSDictionary *)params {
    [NSObject ma_notifyRouterQueuePrivate:[self class] params:params];
}

#pragma mark - Getters and Setters

- (void)setLsr_routerCallback:(LSRRouterCallback)ma_routerCallback {
    objc_setAssociatedObject(self, &kMARouterCallbackKey, ma_routerCallback, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (LSRRouterCallback)lsr_routerCallback {
    return objc_getAssociatedObject(self, &kMARouterCallbackKey);
}

@end
