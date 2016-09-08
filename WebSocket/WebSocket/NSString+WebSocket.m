//
//  NSString+WebSocket.m
//  WebSocket
//
//  Created by Fantasy on 16/9/7.
//  Copyright © 2016年 fantasy. All rights reserved.
//

#import "NSString+WebSocket.h"
#import <CommonCrypto/CommonDigest.h>

static NSString *newSHA1String(const char *bytes, size_t length) {
    uint8_t md[CC_SHA1_DIGEST_LENGTH];
    
    assert(length >= 0);
    assert(length <= UINT32_MAX);
    CC_SHA1(bytes, (CC_LONG)length, md);
    
    NSData *data = [NSData dataWithBytes:md length:CC_SHA1_DIGEST_LENGTH];
    
    if ([data respondsToSelector:@selector(base64EncodedStringWithOptions:)]) {
        return [data base64EncodedStringWithOptions:0];
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    return [data base64Encoding];
#pragma clang diagnostic pop
}

@implementation NSString (WebSocket)

- (NSString *)websocketSHA1Base64Encoding {
    return newSHA1String(self.UTF8String, self.length);
}

@end
