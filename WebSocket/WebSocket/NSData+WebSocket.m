//
//  NSData+WebSocket.m
//  WebSocket
//
//  Created by fantasy on 16/9/15.
//  Copyright © 2016年 fantasy. All rights reserved.
//

#import "NSData+WebSocket.h"

@implementation NSData (WebSocket)

- (NSString *)wsBase64EncodeString {
    if ([self respondsToSelector:@selector(base64EncodedStringWithOptions:)]) {
        return [self base64EncodedStringWithOptions:0];
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    return [self base64Encoding];
#pragma clang diagnostic pop
}

@end
