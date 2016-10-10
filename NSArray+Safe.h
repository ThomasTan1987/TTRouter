//
//  NSArray+Safe.h
//  TutorTalk
//
//  Created by ThoamsTan on 16/8/19.
//  Copyright © 2016年 TutorABC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Safe)
- (id)objectAtSafeIndex:(NSUInteger)index;
@end
