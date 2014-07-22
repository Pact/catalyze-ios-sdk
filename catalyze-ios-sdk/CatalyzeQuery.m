/*
 * Copyright (C) 2013 catalyze.io, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 *    you may not use this file except in compliance with the License.
 *    You may obtain a copy of the License at
 *
 *        http://www.apache.org/licenses/LICENSE-2.0
 *
 *    Unless required by applicable law or agreed to in writing, software
 *    distributed under the License is distributed on an "AS IS" BASIS,
 *    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *    See the License for the specific language governing permissions and
 *    limitations under the License.
 */

#import "CatalyzeQuery.h"

@implementation CatalyzeQuery
@synthesize catalyzeClassName = _catalyzeClassName;
@synthesize pageNumber = _pageNumber;
@synthesize pageSize = _pageSize;
@synthesize queryValue = _queryValue;
@synthesize queryField = _queryField;

+ (CatalyzeQuery *)queryWithClassName:(NSString *)className {
    return [[CatalyzeQuery alloc] initWithClassName:className];
}

- (id)initWithClassName:(NSString *)newClassName {
    self = [super init];
    if (self) {
        _catalyzeClassName = newClassName;
        self.httpManager = [[CatalyzeHTTPManager alloc] init];
    }
    return self;
}

- (id)init {
    self = [self initWithClassName:@"object"];
    return self;
}

- (void)setValue:(id)value forKey:(NSString *)key {
    @try {
        [super setValue:value forKey:key];
    } @catch (NSException *e) {}
}

#pragma mark -
#pragma mark Retrieve

- (void)retrieveInBackgroundWithBlock:(CatalyzeArrayResultBlock)block {
    NSString *queryFieldParam = @"";
    if (_queryField && ![_queryField isEqualToString:@""]) {
        queryFieldParam = [NSString stringWithFormat:@"&field=%@", _queryField];
    }
    NSString *queryValueParam = @"";
    if (_queryValue && ![_queryValue isEqualToString:@""]) {
        queryValueParam = [NSString stringWithFormat:@"&searchBy=%@", _queryValue];
    }
    [CatalyzeHTTPManager doGet:[NSString stringWithFormat:@"/classes/%@/query?pageSize=%i&pageNumber=%i%@%@",[self catalyzeClassName], _pageSize, _pageNumber, queryFieldParam, queryValueParam] block:^(int status, NSString *response, NSError *error) {
        if (block) {
            NSLog(@"response: %@", response);
            block([NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil], error);
        }
    }];
}

- (void)retrieveInBackgroundWithTarget:(id)target selector:(SEL)selector {
    [self retrieveInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [target performSelector:selector onThread:[NSThread mainThread] withObject:objects waitUntilDone:NO];
    }];
}

@end
