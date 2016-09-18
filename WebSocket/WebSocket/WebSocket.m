//
//  WebSocket.m
//  WebSocket
//
//  Created by Fantasy on 16/9/6.
//  Copyright © 2016年 fantasy. All rights reserved.
//

#import "WebSocket.h"
#import "WSCommon.h"
#import "NSError+WebSocket.h"
#import "NSURLRequest+Websocket.h"
#import "NSRunLoop+Websocket.h"
#import "WSInputManager.h"
#import "WSOutputManager.h"

@interface WebSocket ()
<
    WSInputManagerDelegate,
    WSOutputManagerDelegate
>
#pragma mark --Init API Params
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSMutableURLRequest *urlRequest;
@property (nonatomic, assign) BOOL didFail;

@property (nonatomic, strong) WSInputManager *inputManager;
@property (nonatomic, strong) WSOutputManager *outputNanager;

@end

@implementation WebSocket {
    NSArray *_requestedProtocols;
    BOOL _allowsUntrustedSSLCertificates;
    BOOL _consumerStopped;
    
    //
    dispatch_queue_t _workQueue;    //用于通信数据收发处理的队列
    dispatch_queue_t _mainDispatchQueue;//用语将通信队列接收到的数据传回主线程队列
    
    //socket read & write stream.
    NSInputStream *_inputStream;
    NSOutputStream *_outputStream;
    NSString *_protocol;    //Websocket 通信协议
    
    NSMutableSet *_scheduledRunloops;
    
}

@synthesize httpHeaders=_httpHeaders;

#pragma mark --Dealloc
- (void)dealloc
{
    _inputStream.delegate = nil;
    _outputStream.delegate = nil;
    
    [_inputStream close];
    [_outputStream close];
    
    _inputStream = nil;
    _outputStream = nil;
    
    if (_workQueue) {
        _workQueue = NULL;
    }
    
    if (_httpHeaders) {
        CFRelease(_httpHeaders);
        _httpHeaders = NULL;
    }
    
    if (_mainDispatchQueue) {
        _mainDispatchQueue = NULL;
    }
}


#pragma mark --Init Method

- (instancetype) initWithURL:(NSURL *)url
{
    return [self initWithURL:url protocols:nil];
}

- (instancetype) initWithURL:(NSURL *)url protocols:(NSArray *)protocols;
{
    return [self initWithURL:url protocols:protocols allowsUntrustedSSLCertificates:NO];
}

- (instancetype) initWithURL:(NSURL *)url protocols:(NSArray *)protocols allowsUntrustedSSLCertificates:(BOOL)allowsUntrustedSSLCertificates;
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    return [self initWithURLRequest:request protocols:protocols allowsUntrustedSSLCertificates:allowsUntrustedSSLCertificates];
}

- (instancetype) initWithURLRequest:(NSURLRequest *)request;
{
    return [self initWithURLRequest:request protocols:nil];
}

- (instancetype) initWithURLRequest:(NSURLRequest *)request protocols:(NSArray *)protocols;
{
    return [self initWithURLRequest:request protocols:protocols allowsUntrustedSSLCertificates:NO];
}

- (instancetype) initWithURLRequest:(NSURLRequest *)request protocols:(NSArray *)protocols allowsUntrustedSSLCertificates:(BOOL)allowsUntrustedSSLCertificates;
{
    self = [super init];
    if (self) {
        assert(request.URL);
        self.url = request.URL;
        self.urlRequest = [[NSMutableURLRequest alloc] initWithURL:request.URL];
        _allowsUntrustedSSLCertificates = allowsUntrustedSSLCertificates;
        _requestedProtocols = [protocols copy];
        [self wsInitCommonData];
    }
    
    return self;
}

- (void)wsInitCommonData {
    
    NSString *scheme = _url.scheme.lowercaseString;
    assert([scheme isEqualToString:@"ws"] || [scheme isEqualToString:@"http"] || [scheme isEqualToString:@"wss"] || [scheme isEqualToString:@"https"]);
    
//    if ([scheme isEqualToString:@"wss"] || [scheme isEqualToString:@"https"]) {
//        _secure = YES;
//    }
    
    _connectState = WS_CONNECTING;
    _consumerStopped = YES;
    
    _workQueue = dispatch_queue_create(NULL, DISPATCH_QUEUE_SERIAL);
    // Going to set a specific on the queue so we can validate we're on the work queue
    dispatch_queue_set_specific(_workQueue, (__bridge void *)self,
                                (__bridge void *)(_workQueue),
                                NULL);
    _mainDispatchQueue = dispatch_get_main_queue();
    
    //_readBuffer = [[NSMutableData alloc] init];
    //_outputBuffer = [[NSMutableData alloc] init];
    
//    继续初始化对象...
    _scheduledRunloops = [[NSMutableSet alloc] init];
    [self initializeStreams];
    
}

//创建socket通信流,不打开读写处理。
- (void) initializeStreams {
    assert(_url.port.unsignedIntValue <= UINT32_MAX);
    uint32_t port = _url.port.unsignedIntValue;
    if (port == 0) {
        if (!_urlRequest.security) {
            port = 80;
        } else {
            port = 443;
        }
    }
    NSString *host = _url.host;
    
    CFReadStreamRef readStream = NULL;
    CFWriteStreamRef writeStream = NULL;
    
    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)host, port, &readStream, &writeStream);
    
    _outputStream = CFBridgingRelease(writeStream);
    _inputStream = CFBridgingRelease(readStream);
    
    self.outputNanager = [[WSOutputManager alloc] initWithQueue:_workQueue delegate:self];
    self.inputManager = [[WSInputManager alloc] initWithQueue:_workQueue delegate:self];
}

#pragma mark -- Open & close Socket communication
- (void) open {
    if (_connectState != WS_CONNECTING) {
        NSLog(@"Cannot call -(void)open on SRWebSocket more than once");
        return;
    }
    
    [self openConnection];
}

- (void)openConnection;
{
    [self _updateSecureStreamOptions];
    
    if (!_scheduledRunloops.count) {
        [self scheduleInRunLoop:[NSRunLoop wsNetworkRunLoop] forMode:NSDefaultRunLoopMode];
    }
    
    
    [_outputStream open];
    [_inputStream open];
}

- (void)_updateSecureStreamOptions;
{
    if (self.urlRequest.security) {
        NSMutableDictionary *SSLOptions = [[NSMutableDictionary alloc] init];
        
        [_outputStream setProperty:(__bridge id)kCFStreamSocketSecurityLevelNegotiatedSSL forKey:(__bridge id)kCFStreamPropertySocketSecurityLevel];
        
        // If we're using pinned certs, don't validate the certificate chain
        if ([_urlRequest wsSSLCertificates].count) {
            [SSLOptions setValue:@NO forKey:(__bridge id)kCFStreamSSLValidatesCertificateChain];
        }
        
#if DEBUG
        _allowsUntrustedSSLCertificates = YES;
#endif
        
        if (_allowsUntrustedSSLCertificates) {
            [SSLOptions setValue:@NO forKey:(__bridge id)kCFStreamSSLValidatesCertificateChain];
            SRFastLog(@"Allowing connection to any root cert");
        }
        
        [_outputStream setProperty:SSLOptions
                            forKey:(__bridge id)kCFStreamPropertySSLSettings];
    }
}

- (void)scheduleInRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode;
{
    [_outputStream scheduleInRunLoop:aRunLoop forMode:mode];
    [_inputStream scheduleInRunLoop:aRunLoop forMode:mode];
    
    [_scheduledRunloops addObject:@[aRunLoop, mode]];
}

- (void)unscheduleFromRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode;
{
    [_outputStream removeFromRunLoop:aRunLoop forMode:mode];
    [_inputStream removeFromRunLoop:aRunLoop forMode:mode];
    
    [_scheduledRunloops removeObject:@[aRunLoop, mode]];
}

- (void) close {
    
}

- (void) didConnect {
    NSData *data = [self.urlRequest webSocketRequestData:WebSocketVersion
                                                 cookies:nil
                                      requestedProtocols:nil];
    //写数据到服务器
    //读取响应数据
}

/*
 * 与websocket链接响应数据合法性检查。
 */
- (void) connectFinish {
    NSInteger responseCode = CFHTTPMessageGetResponseStatusCode(self.httpHeaders);
    
    if (responseCode >= 400) {
        NSLog(@"error code");
        return;
    }
    
    if ([self.urlRequest socketIsValidateResponse:self.httpHeaders]) {
        NSLog(@"非法socket链接");
        return;
    }
    
    if (![self.urlRequest hasValidateWebSocketProtocol:self.httpHeaders
                                   requestedProtocols:_requestedProtocols]) {
        [self failedWithCode:2133];
        return;
    }
    
    _protocol = [self.urlRequest negotiatedProtocol:self.httpHeaders
                                 requestedProtocols:_requestedProtocols];
    
    self.connectState = WS_OPEN;
    if (!self.didFail) {
        NSLog(@"开始读取数据");
    }
    NSLog(@"链接成功事件");
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

//队列检查，用于检查是否在工作队列之中
- (void)assertOnWorkQueue;
{
    assert([self isOnWorkQueue]);
}

//判断当前对象的对列是否为工作队列
- (BOOL)isOnWorkQueue {
    return dispatch_get_specific((__bridge const void *)(self)) == (__bridge void *)(_workQueue);
}

@end
