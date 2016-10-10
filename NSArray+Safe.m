//
//  NSArray+Safe.m
//  TutorTalk
//
//  Created by ThoamsTan on 16/8/19.
//  Copyright © 2016年 TutorABC. All rights reserved.
//

#import "NSArray+Safe.h"

@implementation NSArray (Safe)
- (id)objectAtSafeIndex:(NSUInteger)index
{
    if (index < self.count) {
        return [self objectAtIndex:index];
    }
    return nil;
}
@end
