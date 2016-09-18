//
//  WebSocket+HeaderFields.m
//  WebSocket
//
//  Created by Fantasy on 16/9/14.
//  Copyright © 2016年 fantasy. All rights reserved.
//

#import "WebSocket+HeaderFields.h"
#import "NSString+WebSocket.h"

@implementation WebSocket (HeaderFields)

- (void) addValue:(NSString *)value forHTTPHeaderField:(NSString *)field {
    NSMutableURLRequest *request = [self valueForKey:@"urlRequest"];
    [request addValue:value forHTTPHeaderField:field];
}

- (void) addHTTPHeaderFields:(NSDictionary *)fields {
    NSArray *keys = fields.allKeys;
    for (NSString *key in keys) {
        [self addValue:fields[key] forHTTPHeaderField:key];
    }
}

@end
