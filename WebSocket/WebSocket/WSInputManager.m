//
//  WSInputStream.m
//  WebSocket
//
//  Created by Fantasy on 16/9/12.
//  Copyright © 2016年 fantasy. All rights reserved.
//

#import "WSInputManager.h"
#import "NSInputStream+Websocket.h"

@interface WSInputManager ()
{
    id<WSInputManagerDelegate>_delegate;
    dispatch_queue_t _workQueue;
    
    NSMutableData *_readBuffer;
    NSUInteger _readBufferOffset;
}
@end


@implementation WSInputManager

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode;
{
}

- (instancetype) initWithQueue:(dispatch_queue_t)queue delegate:(id<WSInputManagerDelegate>)delegate
{
    self = [super init];
    if (self) {
        _readBuffer = [[NSMutableData alloc] init];
        _workQueue = queue;
        _delegate = delegate;
    }
    return self;
}

@end
