//
//  WebSocket+HeaderFields.h
//  WebSocket
//
//  Created by Fantasy on 16/9/14.
//  Copyright © 2016年 fantasy. All rights reserved.
//

#import "WebSocket.h"

@interface WebSocket (HeaderFields)

- (void) addValue:(NSString *)value forHTTPHeaderField:(NSString *)field;

- (void) addHTTPHeaderFields:(NSDictionary *)fields;

@end
