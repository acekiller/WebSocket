//
//  WSInputStream.h
//  WebSocket
//
//  Created by Fantasy on 16/9/12.
//  Copyright © 2016年 fantasy. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WSInputManagerDelegate;

@interface WSInputManager : NSObject
<
    NSStreamDelegate
>

- (instancetype) init NS_UNAVAILABLE;
- (instancetype) initWithQueue:(dispatch_queue_t)queue delegate:(id<WSInputManagerDelegate>)delegate NS_DESIGNATED_INITIALIZER;

@end

@protocol WSInputManagerDelegate <NSObject>

@end
