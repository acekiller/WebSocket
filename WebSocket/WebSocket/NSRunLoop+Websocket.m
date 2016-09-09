//
//  NSRunLoop+Websocket.m
//  WebSocket
//
//  Created by Fantasy on 16/9/9.
//  Copyright © 2016年 fantasy. All rights reserved.
//

#import "NSRunLoop+Websocket.h"

@interface _SRRunLoopThread : NSThread

@property (nonatomic, readonly) NSRunLoop *runLoop;

@end

@implementation _SRRunLoopThread {
    dispatch_group_t _waitGroup;
}

@synthesize runLoop = _runLoop;

- (void)dealloc
{
}

- (id)init
{
    self = [super init];
    if (self) {
        _waitGroup = dispatch_group_create();
        dispatch_group_enter(_waitGroup);
    }
    return self;
}

- (void)main;
{
    @autoreleasepool {
        _runLoop = [NSRunLoop currentRunLoop];
        dispatch_group_leave(_waitGroup);
        
        // Add an empty run loop source to prevent runloop from spinning.
        CFRunLoopSourceContext sourceCtx = {
            .version = 0,
            .info = NULL,
            .retain = NULL,
            .release = NULL,
            .copyDescription = NULL,
            .equal = NULL,
            .hash = NULL,
            .schedule = NULL,
            .cancel = NULL,
            .perform = NULL
        };
        CFRunLoopSourceRef source = CFRunLoopSourceCreate(NULL, 0, &sourceCtx);
        CFRunLoopAddSource(CFRunLoopGetCurrent(), source, kCFRunLoopDefaultMode);
        CFRelease(source);
        
        while ([_runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]) {
            
        }
        assert(NO);
    }
}

- (NSRunLoop *)runLoop;
{
    dispatch_group_wait(_waitGroup, DISPATCH_TIME_FOREVER);
    return _runLoop;
}

@end

static _SRRunLoopThread *networkThread = nil;
static NSRunLoop *networkRunLoop = nil;

@implementation NSRunLoop (Websocket)

+ (NSRunLoop *)wsNetworkRunLoop {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        networkThread = [[_SRRunLoopThread alloc] init];
        networkThread.name = @"com.squareup.SocketRocket.NetworkThread";
        [networkThread start];
        networkRunLoop = networkThread.runLoop;
    });
    
    return networkRunLoop;
}


@end
