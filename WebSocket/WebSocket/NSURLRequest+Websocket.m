//
//  NSURLRequest+Websocket.m
//  WebSocket
//
//  Created by Fantasy on 16/9/9.
//  Copyright © 2016年 fantasy. All rights reserved.
//

#import "NSURLRequest+Websocket.h"

NSString * const wsSSLCertificatesKey = @"wsSSLCertificates";

@implementation NSURLRequest (Websocket)
- (NSArray *)wsSSLCertificates;
{
    return [NSURLProtocol propertyForKey:wsSSLCertificatesKey inRequest:self];
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
