//
//  NSError+WebSocket.m
//  WebSocket
//
//  Created by Fantasy on 16/9/6.
//  Copyright © 2016年 fantasy. All rights reserved.
//

#import "NSError+WebSocket.h"

#define WSErrorDomain @"com.fantasy.websocket"

#define errorLocalDescripitons @{ \
    @(2133) : @"Server specified Sec-WebSocket-Protocol that wasn't requested", \
}

@implementation NSError (WebSocket)

+ (NSDictionary *)userInfoWithCode:(NSInteger)code
{
    return @{NSLocalizedDescriptionKey:@"未知错误"};
}

+ (NSError *)errorWithCode:(NSInteger)code
{
    return [NSError errorWithDomain:WSErrorDomain
                               code:code
                           userInfo:[self userInfoWithCode:code]];
}

+ (NSError *)errorWithHttpCode:(NSInteger)code
{
    return [NSError errorWithDomain:WSErrorDomain
                               code:code
                           userInfo:[self userInfoWithHttpCode:code]];
}

+ (NSDictionary *)userInfoWithHttpCode:(NSInteger)code
{
    return @{NSLocalizedDescriptionKey:[self localDescripitonWithCode:code]
             };
}

+ (NSString *)localDescripitonWithCode:(NSInteger)code {
    NSString *localDescrpition = [errorLocalDescripitons objectForKey:@(code)];
    if (localDescrpition == nil) {
        localDescrpition = @"未知错误";
    }
    return localDescrpition;
}

@end
