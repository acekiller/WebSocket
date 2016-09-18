//
//  WSOutputStream.m
//  WebSocket
//
//  Created by Fantasy on 16/9/12.
//  Copyright © 2016年 fantasy. All rights reserved.
//

#import "WSOutputManager.h"
#import "NSOutputStream+Websocket.h"

@interface WSOutputManager ()
{
    id<WSOutputManagerDelegate>_delegate;
    dispatch_queue_t _workQueue;
    
    NSMutableData *_outputBuffer;
    NSUInteger _outputBufferOffset;
}
@end

@implementation WSOutputManager

- (void) dealloc {
//    [self unscheduleFromRunLoop];
}

- (instancetype) initWithQueue:(dispatch_queue_t)queue delegate:(id<WSOutputManagerDelegate>)delegate
{
    self = [super init];
    if (self) {
        _outputBuffer = [[NSMutableData alloc] init];
        _workQueue = queue;
        _delegate = delegate;
    }
    return self;
}

//NSStreamEventNone = 0,
//NSStreamEventOpenCompleted = 1UL << 0,
//NSStreamEventHasBytesAvailable = 1UL << 1,
//NSStreamEventHasSpaceAvailable = 1UL << 2,
//NSStreamEventErrorOccurred = 1UL << 3,
//NSStreamEventEndEncountered = 1UL << 4
- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode;
{
}

- (void)scheduleInRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode;
{
//    [_outputStream scheduleInRunLoop:aRunLoop forMode:mode];
//    [_inputStream scheduleInRunLoop:aRunLoop forMode:mode];
//    
//    [_scheduledRunloops addObject:@[aRunLoop, mode]];
}

- (void)unscheduleFromRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode;
{
//    [_outputStream removeFromRunLoop:aRunLoop forMode:mode];
//    [_inputStream removeFromRunLoop:aRunLoop forMode:mode];
//    
//    [_scheduledRunloops removeObject:@[aRunLoop, mode]];
}

@end
