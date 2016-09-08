//
//  NSError+WebSocket.h
//  WebSocket
//
//  Created by Fantasy on 16/9/6.
//  Copyright © 2016年 fantasy. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, WSErrorCode) {
    WSErrorCodeNormal = 1000,
    WSErrorCodeGoingAway = 1001,
    WSErrorCodeProtocolError = 1002,
    WSErrorCodeUnhandledType = 1003,
    // 1004 reserved.
    WSErrorNoStatusReceived = 1005,
    // 1004-1006 reserved.
    WSErrorCodeInvalidUTF8 = 1007,
    WSErrorCodePolicyViolated = 1008,
    WSErrorCodeMessageTooBig = 1009,
};

@interface NSError (WebSocket)

+ (NSError *)errorWithCode:(NSInteger)code;

+ (NSError *)errorWithHttpCode:(NSInteger)code;

@end
