//
//  NSOutputStream+Websocket.m
//  WebSocket
//
//  Created by Fantasy on 16/9/12.
//  Copyright © 2016年 fantasy. All rights reserved.
//

#import "NSOutputStream+Websocket.h"

@implementation NSOutputStream (Websocket)

- (void) sendData:(NSData *)data {
    if ([self hasSpaceAvailable]) {
        [self write:[data bytes] maxLength:[data length]];
    }
}

@end
