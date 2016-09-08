//
//  WebSocket.m
//  WebSocket
//
//  Created by Fantasy on 16/9/6.
//  Copyright © 2016年 fantasy. All rights reserved.
//

#import "WebSocket.h"
#import "NSError+WebSocket.h"
#import "NSString+WebSocket.h"

static NSString *const WSWebSocketGUID = @"258EAFA5-E914-47DA-95CA-C5AB0DC85B11";

@interface WebSocket ()
@property (nonatomic, strong) NSString *secKey;
@property (nonatomic, assign) BOOL didFail;
@end

@implementation WebSocket {
    dispatch_queue_t _workQueue;
}

@synthesize httpHeaders=_httpHeaders;

- (void) didConnect {
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
}

- (void) connectFinish {
    /**
     *  解析http请求的状况:1.响应判断。2.数据合法性检查。3.支持的协议合法性解析。
     *  Upgrade: websocket
     *  Connection: Upgrade
     *  Sec-WebSocket-Accept: s3pPLMBiTxaQ9kYGzzhZRbK+xOo=
     *  Sec-WebSocket-Protocol: chat
     */
    NSInteger responseCode = CFHTTPMessageGetResponseStatusCode(self.httpHeaders);
    
    if (responseCode >= 400) {
        NSLog(@"error code");
        return;
    }
    
    if ([self socketIsValidate:self.httpHeaders]) {
        NSLog(@"非法socket链接");
        return;
    }
    
    if (![self webSocketProtocol:self.httpHeaders]) {
        NSLog(@"指定协议没有找到");
        return;
    }
    
    self.connectState = WS_OPEN;
    if (!self.didFail) {
        NSLog(@"开始读区数据");
    }
    NSLog(@"链接成功事件");
}

- (BOOL) webSocketProtocol:(CFHTTPMessageRef)message
{
    NSString *negotiatedProtocol = CFBridgingRelease(CFHTTPMessageCopyHeaderFieldValue(message, CFSTR("Sec-WebSocket-Protocol")));
//    if (negotiatedProtocol) {
//        // Make sure we requested the protocol
//        if ([_requestedProtocols indexOfObject:negotiatedProtocol] == NSNotFound) {
//            [self _failWithError:[NSError errorWithDomain:SRWebSocketErrorDomain code:2133 userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"Server specified Sec-WebSocket-Protocol that wasn't requested"] forKey:NSLocalizedDescriptionKey]]];
//            return;
//        }
//        
//        _protocol = negotiatedProtocol;
//    }
    
    return NO;
}

- (BOOL) socketIsValidate:(CFHTTPMessageRef)message {
    NSString *acceptHeader = CFBridgingRelease(CFHTTPMessageCopyHeaderFieldValue(message, CFSTR("Sec-WebSocket-Accept")));
    
    if (acceptHeader == nil) {
        return NO;
    }
    
    NSString *concattedString = [self.secKey stringByAppendingString:WSWebSocketGUID];
    NSString *expectedAccept = [concattedString websocketSHA1Base64Encoding];
    return [acceptHeader isEqualToString:expectedAccept];
}

- (void) failedWithCode:(NSInteger)code
{
    //错误分发，及链接关闭处理
    dispatch_async(_workQueue, ^{
        if (self.connectState == WS_CLOSED) {
            return;
        }
        /**
         *  错误分发
         */
//        self.connectState = WS_CLOSED;
    });
}

- (CFHTTPMessageRef) httpHeaders {
    if (_httpHeaders == nil) {
        _httpHeaders = CFHTTPMessageCreateEmpty(NULL, NO);
    }
    return _httpHeaders;
}

@end
