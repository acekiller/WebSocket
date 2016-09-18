//
//  WSCommon.h
//  WebSocket
//
//  Created by Fantasy on 16/9/14.
//  Copyright © 2016年 fantasy. All rights reserved.
//

#import <Foundation/Foundation.h>

#define CRLFCRLF [[NSData alloc] initWithBytes:"\r\n\r\n" length:4];
#define WebSocketVersion 13
#define CRLFCRLFBytes {'\r', '\n', '\r', '\n'};
#define WSWebSocketGUID @"258EAFA5-E914-47DA-95CA-C5AB0DC85B11"

extern inline void SRFastLog(NSString *format, ...);

