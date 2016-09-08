//
//  WebSocket.h
//  WebSocket
//
//  Created by Fantasy on 16/9/6.
//  Copyright © 2016年 fantasy. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, WSConnectState) {
    WS_CLOSED       = 0,
    WS_CONNECTING   = 1,
    WS_OPEN         = 2,
    WS_CLOSING      = 3,
};

@protocol WebSocketDelegate <NSObject>

@end

@interface WebSocket : NSObject <NSStreamDelegate>

@property (nonatomic, assign) WSConnectState connectState;
@property (nonatomic,readonly) CFHTTPMessageRef httpHeaders;
@property (nonatomic, strong) NSURL *url;

- (instancetype) init;

@end
