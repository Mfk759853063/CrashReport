//
//  AAA.m
//  TestLog
//
//  Created by vbn on 2019/6/10.
//  Copyright © 2019 pori. All rights reserved.
//

#import "AAA.h"
#import "TestLog-Swift.h"
#import <XCGLogger-umbrella.h>
@implementation AAA

- (instancetype)init {
    self = [super init];
    if (self) {
        [[KNCrashReport shared] log:@"******************in objc *************************" function:nil line:0];
        
        NSArray *test = @[@1,@2,@3];
        [[KNCrashReport shared] log:[NSString stringWithFormat:@"%@", test] function:nil line:0];
//        test[4];
        
    }
    return self;
}

@end
