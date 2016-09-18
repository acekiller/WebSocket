//
//  WSCommon.m
//  WebSocket
//
//  Created by Fantasy on 16/9/14.
//  Copyright © 2016年 fantasy. All rights reserved.
//

#import "WSCommon.h"

inline void SRFastLog(NSString *format, ...)  {
#ifdef SR_ENABLE_LOG
    __block va_list arg_list;
    va_start (arg_list, format);
    
    NSString *formattedString = [[NSString alloc] initWithFormat:format arguments:arg_list];
    
    va_end(arg_list);
    
    NSLog(@"[SR] %@", formattedString);
#endif
}

