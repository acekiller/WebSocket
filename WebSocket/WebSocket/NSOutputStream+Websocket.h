//
//  NSOutputStream+Websocket.h
//  WebSocket
//
//  Created by Fantasy on 16/9/12.
//  Copyright © 2016年 fantasy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSOutputStream (Websocket)
<
    NSStreamDelegate
>

- (void) sendData:(NSData *)data;

@end
