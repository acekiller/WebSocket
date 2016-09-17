//
//  NSURLRequest+Websocket.m
//  WebSocket
//
//  Created by Fantasy on 16/9/9.
//  Copyright © 2016年 fantasy. All rights reserved.
//

#import "NSURLRequest+Websocket.h"
#import "NSURL+WebSocket.h"
#import "NSData+WebSocket.h"
#import "NSString+WebSocket.h"
#import <objc/runtime.h>

NSString * const wsSSLCertificatesKey = @"wsSSLCertificates";

#define WSWebSocketGUID @"258EAFA5-E914-47DA-95CA-C5AB0DC85B11"

@implementation NSURLRequest (Websocket)

- (NSString *) secKey {
    NSString *secKey = objc_getAssociatedObject(self, _cmd);
    if (secKey == nil) {
        NSMutableData *keyBytes = [[NSMutableData alloc] initWithLength:16];
        int result = SecRandomCopyBytes(kSecRandomDefault, keyBytes.length, keyBytes.mutableBytes);
        secKey = [keyBytes wsBase64EncodeString];
        if (result > 0) {
            objc_setAssociatedObject(self, _cmd, secKey, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
    return secKey;
}

- (NSArray *)wsSSLCertificates;
{
    return [NSURLProtocol propertyForKey:wsSSLCertificatesKey inRequest:self];
}

- (NSString *)httpMessageHost {
    NSString *host = self.URL.host;
    if (self.URL.port) {
        host = [host stringByAppendingFormat:@":%@", self.URL.port];
    }
    return host;
}

- (NSData *)webSocketRequestData:(uint8_t)webSocketProtocolVersion
                         cookies:(NSArray *)cookies
              requestedProtocols:(NSArray *)requestedProtocols
{
    NSURL *url = self.URL;
    CFHTTPMessageRef message = CFHTTPMessageCreateRequest(NULL, CFSTR("GET"), (__bridge CFURLRef)url, kCFHTTPVersion1_1);
    CFHTTPMessageSetHeaderFieldValue(message, CFSTR("Host"), (__bridge CFStringRef)[self httpMessageHost]);
    
    NSString *baseAuthorization = [url AuthorizationHeader];
    if (baseAuthorization) {
        CFHTTPMessageSetHeaderFieldValue(message, CFSTR("Authorization"), (__bridge CFStringRef)baseAuthorization);
    }
    
    NSString *secKey = [self secKey];
    if (secKey && secKey.length > 0) {
        CFHTTPMessageSetHeaderFieldValue(message, CFSTR("Sec-WebSocket-Key"), (__bridge CFStringRef)(secKey));
    }
    
    if (cookies) {
        NSDictionary<NSString *, NSString *> *messageCookies = [NSHTTPCookie requestHeaderFieldsWithCookies:cookies];
        [messageCookies enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL *stop) {
            if (key.length && obj.length) {
                CFHTTPMessageSetHeaderFieldValue(message, (__bridge CFStringRef)key, (__bridge CFStringRef)obj);
            }
        }];
    }
    
    CFHTTPMessageSetHeaderFieldValue(message, CFSTR("Upgrade"), CFSTR("websocket"));
    CFHTTPMessageSetHeaderFieldValue(message, CFSTR("Connection"), CFSTR("Upgrade"));
    CFHTTPMessageSetHeaderFieldValue(message, CFSTR("Sec-WebSocket-Version"), (__bridge CFStringRef)@(webSocketProtocolVersion).stringValue);
    
    CFHTTPMessageSetHeaderFieldValue(message, CFSTR("Origin"), (__bridge CFStringRef)[url wsOrigin]);
    
    if (requestedProtocols.count) {
        CFHTTPMessageSetHeaderFieldValue(message, CFSTR("Sec-WebSocket-Protocol"),
                                         (__bridge CFStringRef)[requestedProtocols componentsJoinedByString:@", "]);
    }
    
    NSDictionary *allFileds = self.allHTTPHeaderFields;
    NSArray *allKeys = allFileds.allKeys;
    for (NSString *key in allKeys) {
        CFHTTPMessageSetHeaderFieldValue(message, (__bridge CFStringRef)(key), (__bridge CFStringRef)(allFileds[key]));
    }
    
    return CFBridgingRelease(CFHTTPMessageCopySerializedMessage(message));
    
}

- (BOOL) security {
    NSString *scheme = self.URL.scheme.lowercaseString;
    return ([scheme isEqualToString:@"wss"] || [scheme isEqualToString:@"https"]);
}

@end

@implementation NSURLRequest (WebsocketResponse)

- (BOOL) socketIsValidateResponse:(CFHTTPMessageRef)message {
    NSString *acceptHeader = CFBridgingRelease(CFHTTPMessageCopyHeaderFieldValue(message, CFSTR("Sec-WebSocket-Accept")));
    
    if (acceptHeader == nil) {
        return NO;
    }
    
    NSString *concattedString = [self.secKey stringByAppendingString:WSWebSocketGUID];
    NSString *expectedAccept = [concattedString websocketSHA1Base64Encoding];
    return [acceptHeader isEqualToString:expectedAccept];
}

- (NSString *)negotiatedProtocol:(CFHTTPMessageRef)message
              requestedProtocols:(NSArray *)requestedProtocols {
    NSString *negotiatedProtocol = CFBridgingRelease(CFHTTPMessageCopyHeaderFieldValue(message, CFSTR("Sec-WebSocket-Protocol")));
    if (requestedProtocols == nil || requestedProtocols.count <= 0) {
        return negotiatedProtocol;
    }
    
    if (negotiatedProtocol) {
        // Make sure we requested the protocol
        if ([requestedProtocols indexOfObject:negotiatedProtocol] == NSNotFound) {
            return nil;
        }
        
        return negotiatedProtocol;
    }
    
    return nil;
}

- (BOOL) hasValidateWebSocketProtocol:(CFHTTPMessageRef)message
                   requestedProtocols:(NSArray *)requestedProtocols {
    NSString *negotiatedProtocol = [self negotiatedProtocol:message requestedProtocols:requestedProtocols];
    return ((negotiatedProtocol != nil) && (negotiatedProtocol.length > 0));
    
}

@end

@implementation NSMutableURLRequest (Websocket)

- (NSArray *)wsSSLCertificates;
{
    return [NSURLProtocol propertyForKey:wsSSLCertificatesKey inRequest:self];
}

- (void)setWsSSLCertificates:(NSArray *)wsSSLCertificates;
{
    [NSURLProtocol setProperty:wsSSLCertificates forKey:wsSSLCertificatesKey inRequest:self];
}

@end
