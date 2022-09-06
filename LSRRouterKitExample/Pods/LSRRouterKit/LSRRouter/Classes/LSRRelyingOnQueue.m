//
//  MARelyingOnQueue.m
//  MARouterKit
//
//  Created by liguoyang on 2019/3/12.
//
//

#import "LSRRelyingOnQueue.h"
#import "LSRRouterConfig.h"

@interface LSRRelyingOnQueue ()

@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableArray<LSRRouterConfig *> *> *cachedConfigs;

@end

@implementation LSRRelyingOnQueue

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static LSRRelyingOnQueue *_sharedRelyingOnQueue = nil;
    dispatch_once(&onceToken, ^{
        _sharedRelyingOnQueue = [[self alloc] init];
    });
    return _sharedRelyingOnQueue;
}

#pragma mark - Private Methods

- (void)cacheRouterConfig:(LSRRouterConfig *)routerConfig forClass:(Class)targetClass {
    if (!routerConfig || !targetClass) {
        return;
    }
    
    NSString *cachedKey = NSStringFromClass(targetClass);
    NSMutableArray *configs = self.cachedConfigs[cachedKey];
    if (!configs) {
        configs = [[NSMutableArray alloc] init];
        self.cachedConfigs[cachedKey] = configs;
    }
    [configs addObject:routerConfig];
}

- (LSRRouterConfig *)popRouterConfigForClass:(Class)targetClass {
    if (!targetClass) {
        return nil;
    }
    
    NSString *cachedKey = NSStringFromClass(targetClass);
    NSMutableArray *configs = self.cachedConfigs[cachedKey];
    
    if ([configs count] > 0) {
        LSRRouterConfig *routerConfig = [configs lastObject];
        [configs removeLastObject];
        return routerConfig;
    }
    
    return nil;
}

#pragma mark - Public Methods

+ (void)cacheRouterConfig:(LSRRouterConfig *)routerConfig forClass:(Class)targetClass {
    [[self sharedInstance] cacheRouterConfig:routerConfig forClass:targetClass];
}

+ (LSRRouterConfig *)popRouterConfigForClass:(Class)targetClass {
    return [[self sharedInstance] popRouterConfigForClass:targetClass];
}

+ (void)emptyQueue {
    [LSRRelyingOnQueue sharedInstance].cachedConfigs = nil;
}

#pragma mark - Getters and Setters

- (NSMutableDictionary<NSString *,NSMutableArray<LSRRouterConfig *> *> *)cachedConfigs {
    if (!_cachedConfigs) {
        _cachedConfigs = [[NSMutableDictionary alloc] init];
    }
    return _cachedConfigs;
}

@end
