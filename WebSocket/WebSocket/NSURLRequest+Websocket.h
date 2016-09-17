//
//  NSURLRequest+Websocket.h
//  WebSocket
//
//  Created by Fantasy on 16/9/9.
//  Copyright © 2016年 fantasy. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const wsSSLCertificatesKey;

/**
 *  websocket链接链接.这里主要工作是组装完整的http请求数据结构.然后通过socket方式同服务器交互。
 *  GET /chat HTTP/1.1
 *  Host: server.example.com
 *  Upgrade: websocket
 *  Connection: Upgrade
 *  Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==
 *  Origin: http://example.com
 *  Sec-WebSocket-Protocol: chat, superchat
 *  Sec-WebSocket-Version: 13
 */
@interface NSURLRequest (Websocket)

@property (nonatomic, strong, readonly) NSArray *wsSSLCertificates;

@property (nonatomic, readonly) BOOL security;

@property (nonatomic, strong, readonly) NSString *secKey;

- (NSData *)webSocketRequestData:(uint8_t)webSocketProtocolVersion
                         cookies:(NSArray *)cookies
              requestedProtocols:(NSArray *)requestedProtocols;

@end

/**
 *  解析http请求的状况:1.响应判断。2.数据合法性检查。3.支持的协议合法性解析。
 *  Upgrade: websocket
 *  Connection: Upgrade
 *  Sec-WebSocket-Accept: s3pPLMBiTxaQ9kYGzzhZRbK+xOo=
 *  Sec-WebSocket-Protocol: chat
 */
@interface NSURLRequest (WebsocketResponse)

- (BOOL) socketIsValidateResponse:(CFHTTPMessageRef)message;

- (NSString *)negotiatedProtocol:(CFHTTPMessageRef)message
              requestedProtocols:(NSArray *)requestedProtocols;

- (BOOL) hasValidateWebSocketProtocol:(CFHTTPMessageRef)message
                   requestedProtocols:(NSArray *)requestedProtocols;

@end

@interface NSMutableURLRequest (Websocket)

@property (nonatomic, strong) NSArray *wsSSLCertificates;

@end
