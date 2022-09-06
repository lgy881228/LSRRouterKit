//
//  LSRRouterKitConfig.m
//  LSRRouterKit
//
//  Created by liguoyang on 2019/3/6.
//
//

#import "LSRRouterConfig.h"

@interface LSRRouterConfig ()

@property (nonatomic, strong, readwrite) NSString *targetName;
@property (nonatomic, strong, readwrite) NSString *actionName;

@property (nonatomic, strong, readwrite) NSURL *url;
@property (nonatomic, strong, readwrite) id params;
@property (nonatomic, copy, readwrite) MARouterHandler customHandler;


@end

@implementation LSRRouterConfig

- (instancetype)initWithTarget:(NSString *)target
                        action:(NSString *)action
                           url:(NSURL *)url
                        params:(NSDictionary *)params
                 customHandler:(MARouterHandler)customHandler {
    self = [super init];
    if (self) {
        _url = url;
        _params = params;
        _targetName = target;
        _actionName = action;
        _customHandler = customHandler;
    }
    
    return self;
}

+ (instancetype)configWithTarget:(NSString *)target
                          action:(NSString *)action
                          params:(NSDictionary *)params
                   customHandler:(MARouterHandler)customHandler {
    NSAssert(target.length > 0, @"MARouterConfig:target不能为空");
    NSAssert(action.length > 0, @"MARouterConfig:action不能为空");
    return [[self alloc] initWithTarget:target action:action url:nil params:params customHandler:customHandler];
    
}

+ (instancetype)configWithURL:(NSURL *)url {
    return [self configWithURL:url params:nil customHandler:nil];
}

+ (instancetype)configWithURL:(NSURL *)url
                       params:(NSDictionary<NSString *, id> *)params
                customHandler:(MARouterHandler)customHandler {
    NSAssert(url, @"MARouterConfig:url不能为空");
    return [[self alloc] initWithTarget:nil action:nil url:url params:params customHandler:customHandler];
}

+ (instancetype)configWithURLString:(NSString *)urlString {
    return [self configWithURLString:urlString params:nil customHandler:nil];
}

+ (instancetype)configWithURLString:(NSString *)urlString
                             params:(NSDictionary<NSString *, id> *)params
                      customHandler:(MARouterHandler)customHandler {
    NSCharacterSet *charsets = [NSCharacterSet URLQueryAllowedCharacterSet];
    NSString *targetURL = [urlString stringByAddingPercentEncodingWithAllowedCharacters:charsets];
    return [self configWithURL:[NSURL URLWithString:targetURL]
                        params:params
                 customHandler:customHandler];
}

+ (NSString *)sdkVersion {
    return @"1.4.3.0";
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    LSRRouterConfig *routerConfig = [LSRRouterConfig allocWithZone:zone];
    routerConfig.targetName = [_targetName copy];
    routerConfig.actionName = [_actionName copy];
    routerConfig.url = [_url copy];
    routerConfig.params = [_params copy];
    routerConfig.customHandler = _customHandler;
    return routerConfig;
}

#pragma mark - NSMutableCopying

- (id)mutableCopyWithZone:(NSZone *)zone {
    return [self copyWithZone:zone];
}

@end
