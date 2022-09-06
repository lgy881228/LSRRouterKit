//
//  ViewController.h
//  LSRRouterKitExample
//
//  Created by 李国阳 on 2022/9/1.
//

#import <UIKit/UIKit.h>
#import "LSRRouterKit.h"
@interface ViewController : UIViewController

@property (nonatomic, copy) void(^nextVC)(void);/** <#BlockName#> */
@end

