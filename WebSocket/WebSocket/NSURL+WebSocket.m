//
//  NSURL+WebSocket.m
//  WebSocket
//
//  Created by Fantasy on 16/9/7.
//  Copyright © 2016年 fantasy. All rights reserved.
//

#import "NSURL+WebSocket.h"

@implementation NSURL (WebSocket)

- (NSString *)wsOrigin;
{
    NSString *scheme = [self.scheme lowercaseString];
    
    if ([scheme isEqualToString:@"wss"]) {
        scheme = @"https";
    } else if ([scheme isEqualToString:@"ws"]) {
        scheme = @"http";
    }
    
    BOOL portIsDefault = !self.port ||
    ([scheme isEqualToString:@"http"] && self.port.integerValue == 80) ||
    ([scheme isEqualToString:@"https"] && self.port.integerValue == 443);
    
    if (!portIsDefault) {
        return [NSString stringWithFormat:@"%@://%@:%@", scheme, self.host, self.port];
    } else {
        return [NSString stringWithFormat:@"%@://%@", scheme, self.host];
    }
}

@end
