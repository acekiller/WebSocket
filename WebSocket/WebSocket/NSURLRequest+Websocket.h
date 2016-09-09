//
//  NSURLRequest+Websocket.h
//  WebSocket
//
//  Created by Fantasy on 16/9/9.
//  Copyright © 2016年 fantasy. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const wsSSLCertificatesKey;

@interface NSURLRequest (Websocket)
@property (nonatomic, strong, readonly) NSArray *wsSSLCertificates;
@end

@interface NSMutableURLRequest (Websocket)
@property (nonatomic, strong) NSArray *wsSSLCertificates;
@end
