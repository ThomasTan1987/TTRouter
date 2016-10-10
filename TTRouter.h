//
//  TTRouter.h
//  TutorTalk
//
//  Created by ThoamsTan on 16/8/19.
//  Copyright © 2016年 TutorABC. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSUInteger, TransStyle) {
    TransStylePush,
    TransStylePresent,
};
@interface TTRouter : NSObject
@property (nonatomic, assign) BOOL animated;
+ (TTRouter *)sharedRouter;
//通过外部url跳转，需在plist里注册
- (void)router:(NSString *)url;
//- (void)router:(NSString *)pageName params:(NSDictionary *)params;
//直接用类名，无需在plist里注册
- (void)routerInnerClass:(NSString *)className params:(NSDictionary *)params;
@end