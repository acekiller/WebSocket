//
//  NSInputStream+Websocket.h
//  WebSocket
//
//  Created by Fantasy on 16/9/12.
//  Copyright © 2016年 fantasy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSInputStream (Websocket)

- (void) appendReceivedData:(NSData *)receivedData;

//获取第一个完整的包
- (NSData *)firstPayload;

@end
