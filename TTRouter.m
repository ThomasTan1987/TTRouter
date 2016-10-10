//
//  TTRouter.m
//  TutorTalk
//
//  Created by ThoamsTan on 16/8/19.
//  Copyright © 2016年 TutorABC. All rights reserved.
//

#import "TTRouter.h"
#import <objc/runtime.h>
#import "NSArray+Safe.h"
#import "TTWebViewController.h"
@interface TTRouter()
@property(nonatomic,strong)NSDictionary *routerMap;
@end
@implementation TTRouter
+ (TTRouter *)sharedRouter
{
    static TTRouter *router = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        router = [[TTRouter alloc] init];
    });
    return router;
}
- (instancetype)init
{
    if (self = [super init]) {
        //读取
        NSString *plistPath = [[NSBundle mainBundle]pathForResource:@"RouterMap" ofType:@"plist"];
        NSDictionary *dataDic = [[NSDictionary alloc]initWithContentsOfFile:plistPath];
        self.routerMap = dataDic[@"routerMap"];
        self.animated = YES;
    }
    return self;
}
- (void)router:(NSString *)url
{
    if ([url hasPrefix:@"vipa:"]) {
        NSArray *array = [url componentsSeparatedByString:@"?"];
        NSString *pageName = [[[array firstObject] componentsSeparatedByString:@"//"] lastObject];
        NSMutableDictionary *paramsDic = [[NSMutableDictionary alloc] init];
        if ([array count] == 2 && ![[array lastObject] isEqualToString:@""]) {
            NSArray *params = [[array lastObject] componentsSeparatedByString:@"&"];
            for (NSString *str in params) {
                NSArray *param = [str componentsSeparatedByString:@"="];
                NSString *key = param[0];
                NSString *value = param[1];
                paramsDic[key] = value;
            }
        }
        [self router:pageName params:paramsDic];
    } else if ([url hasPrefix:@"http:"] || [url hasPrefix:@"https:"]) {
        TTWebViewController *webViewController = [[TTWebViewController alloc] initWithStoryBoard];
        webViewController.url = url;
        //获取topmost viewController
        UIViewController *topMostViewfController = [self topMostViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
        [topMostViewfController.navigationController pushViewController:webViewController animated:self.animated];
        self.animated = NO;
    }
}
- (void)router:(NSString *)pageName params:(NSDictionary *)params
{
    if (self.routerMap[pageName]) {
        [self routerInnerClass:self.routerMap[pageName] params:params];
    } else {
        
    }
}
- (void)routerInnerClass:(NSString *)className params:(NSDictionary *)params
{
    UIViewController *viewController = [self viewController:className params:params];
    viewController.hidesBottomBarWhenPushed = YES;
    //获取topmost viewController
    NSLog(@"%d",[UIApplication sharedApplication].keyWindow.hidden);
    UIViewController *topMostViewController = [self topMostViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
    
    [topMostViewController.navigationController pushViewController:viewController animated:self.animated];
    self.animated = NO;
}
//生成要跳转的viewController，并给属性赋值
- (UIViewController *)viewController:(NSString *)className params:(NSDictionary *)params
{
    UIViewController *viewController = [[NSClassFromString(className) alloc] initWithStoryBoard];
    //给viewController属性赋值
    NSMutableArray * keys = [NSMutableArray array];
    
    unsigned int outCount;
    objc_property_t * properties = class_copyPropertyList([viewController class], &outCount);
    for (int i = 0; i < outCount; i ++) {
        objc_property_t property = properties[i];
        NSString * propertyName = [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        [keys addObject:propertyName];
    }
    free(properties);
    
    for (NSString * key in keys) {
        if ([params valueForKey:key] == nil) continue;
        [viewController setValue:[params valueForKey:key] forKey:key];
    }
    //
    return viewController;
}

- (UIViewController *)topMostViewController:(UIViewController *)rootViewController
{
    if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)rootViewController;
        return [self topMostViewController:[navigationController.viewControllers lastObject]];
    }
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabController = (UITabBarController *)rootViewController;
        return [self topMostViewController:tabController.selectedViewController];
    }
    if (rootViewController.presentedViewController) {
        return [self topMostViewController:rootViewController];
    }
    return rootViewController;
}

@end
