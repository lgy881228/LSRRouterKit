//
//  LSRRouterMacro.h
//  1234
//
//  Created by 李国阳 on 2022/9/1.
//

#ifndef LSRRouterMacro_h
#define LSRRouterMacro_h
#import "LSRRouter.h"
//// Register For Inner Modules
#define LSRRouterRegister(lsr_scheme, lsr_router, lsr_target) \
[LSRRouter registerScheme:lsr_scheme router:lsr_router target:lsr_target];

#define LSRRouterRegisterForAllSchemes(lsr_router, lsr_target) \
[LSRRouter registerRouter:lsr_router target:lsr_target];

#define LSRRouterRegisterOnLoad(lsr_scheme, lsr_router) \
+ (void)load { \
    [LSRRouter registerScheme:lsr_scheme router:lsr_router target:self]; \
}

#define LSRRouterRegisterOnLoadForAllSchemes(lsr_router) \
+ (void)load { \
    [LSRRouter registerRouter:lsr_router target:self]; \
}

//// Public Registers
#define LSRRouterPublicRegister(lsr_scheme, lsr_router, lsr_target) \
[LSRRouter registerPublicScheme:lsr_scheme router:lsr_router target:lsr_target];

#define LSRRouterPublicRegisterForAllSchemes(lsr_router, lsr_target) \
[LSRRouter registerPublicRouter:lsr_router target:lsr_target];

#define LSRRouterPublicRegisterOnLoad(lsr_scheme, lsr_router) \
+ (void)load { \
    [LSRRouter registerPublicScheme:lsr_scheme router:lsr_router target:self]; \
}

#define LSRRouterPublicRegisterOnLoadForAllSchemes(lsr_router) \
+ (void)load { \
    [LSRRouter registerPublicRouter:lsr_router target:self]; \
}

//// RelyingOn Notify Queue
#define LSRRouterNotifyQueueFull(TargetClass, TargetParams) [[TargetClass class] lsr_notifyRouterQueue:TargetParams]
#define LSRRouterNotifyQueueWithParams(TargetParams) [[self class] lsr_notifyRouterQueue:TargetParams]
#define LSRRouterNotifyQueue LSRRouterNotifyQueueWithParams(nil)


#endif /* LSRRouterMacro_h */
