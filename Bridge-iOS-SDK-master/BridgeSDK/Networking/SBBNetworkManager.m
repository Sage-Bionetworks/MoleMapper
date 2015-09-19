/*
 Copyright (c) 2015, Sage Bionetworks. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 
 1.  Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 2.  Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation and/or
 other materials provided with the distribution.
 
 3. Neither the name of the copyright holder(s) nor the names of any contributors
 may be used to endorse or promote products derived from this software without
 specific prior written permission. No license is granted to the trademarks of
 the copyright holders even if such marks are included in this software.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "BridgeSDK.h"
#import "SBBNetworkManagerInternal.h"
#import "SBBErrors.h"
#import "NSError+SBBAdditions.h"
#import "Reachability.h"
#import "UIDevice+Hardware.h"
#import "NSDate+SBBAdditions.h"

SBBEnvironment gSBBDefaultEnvironment;

const NSInteger kMaxRetryCount = 5;

static SBBNetworkManager * sharedInstance;
NSString *kBackgroundSessionIdentifier = @"org.sagebase.backgroundsession";
NSString *kAPIPrefix = @"webservices";

#pragma mark - APC Retry Object - Keeps track of retry count

@implementation APCNetworkRetryObject

@end

#pragma mark - SBBDataTaskCompletionWrapper

@interface SBBDataTaskCompletionWrapper : NSObject

@property (nonatomic, copy) SBBNetworkManagerTaskCompletionBlock completion;

- (instancetype)initWithBlock:(SBBNetworkManagerTaskCompletionBlock)block;

@end

@implementation SBBDataTaskCompletionWrapper

- (instancetype)initWithBlock:(SBBNetworkManagerTaskCompletionBlock)block
{
  if (self = [super init]) {
    self.completion = block;
  }
  
  return self;
}

@end

#pragma mark - SBBDownloadCompletionWrapper

@interface SBBDownloadCompletionWrapper: NSObject

@property (nonatomic, copy) SBBNetworkManagerDownloadCompletionBlock completion;

- (instancetype)initWithBlock:(SBBNetworkManagerDownloadCompletionBlock)block;

@end

@implementation SBBDownloadCompletionWrapper

- (instancetype)initWithBlock:(SBBNetworkManagerDownloadCompletionBlock)block
{
  if (self = [super init]) {
    self.completion = block;
  }
  
  return self;
}

@end

#pragma mark - SBBNetworkManager

@interface SBBNetworkManager () <NSURLSessionDataDelegate, NSURLSessionDownloadDelegate>

@property (nonatomic, strong) Reachability * internetReachability;
@property (nonatomic, strong) Reachability * serverReachability;

// baseURL is the scheme & host part of the URL for hitting REST API endpoints. For Bridge it will be built
// up from the prefix ("webservices"), the environment (prod, dev, staging), and the domain "sagebridge.org".
// For non-Bridge APIs it will just be given as a string representing the common prefix for that API's
// endpoint URLs.
@property (nonatomic, strong) NSString * baseURL;

// bridgeStudy is the study identifier, which is the prefix set at app launch (e.g. "parkinsons"). It is used
// in the Bridge-Study header to identify the study for which a request to the Bridge baseURL is intended
// (see above). For non-Bridge APIs it will be nil, and will not be sent as a header.
@property (nonatomic, strong) NSString * bridgeStudy;

@property (nonatomic, strong) NSURLSession * mainSession; //For data tasks
@property (nonatomic, strong) NSURLSession * backgroundSession; //For upload/download tasks

@property (nonatomic, copy) void (^backgroundCompletionHandler)(void);
@property (nonatomic, strong) NSMutableDictionary *uploadCompletionHandlers;
@property (nonatomic, strong) NSMutableDictionary *downloadCompletionHandlers;

@end

@implementation SBBNetworkManager
@synthesize environment = _environment;
@synthesize backgroundTransferDelegate = _backgroundTransferDelegate;
@synthesize sendCookies = _sendCookies;

+ (NSString *)baseURLForEnvironment:(SBBEnvironment)environment appURLPrefix:(NSString *)prefix baseURLPath:(NSString *)path
{
  NSString *baseURL = nil;
  NSString *host = nil;

  if ([prefix length] > 0) {
    host = [self hostForEnvironment:environment appURLPrefix:prefix baseURLPath:path];
  }
  
  if (host.length) {
    baseURL = [NSString stringWithFormat:@"https://%@", host];
  } else {
    baseURL = path;
  }

  return baseURL;
}

+ (NSString *)hostForEnvironment:(SBBEnvironment)environment appURLPrefix:(NSString *)prefix baseURLPath:(NSString *)path
{
    static NSString *envFormatStrings[] = {
        @"%@",
        @"%@-staging",
        @"%@-develop",
        @"%@-custom"
    };
    NSString *host = nil;

    if ([prefix length] > 0 && (NSInteger)environment < sizeof(envFormatStrings) / sizeof(NSString *)) {
        NSString *firstComponent = [NSString stringWithFormat:envFormatStrings[environment], prefix];
        host = [NSString stringWithFormat:@"%@.%@", firstComponent, path];
    } else {
        host = nil;
    }
    
    return host;
}

+ (instancetype)networkManagerForEnvironment:(SBBEnvironment)environment study:(NSString *)study baseURLPath:(NSString *)baseURLPath
{
  NSString *baseURL = [self baseURLForEnvironment:environment appURLPrefix:kAPIPrefix baseURLPath:baseURLPath];
  SBBNetworkManager *networkManager = [[self alloc] initWithBaseURL:baseURL bridgeStudy:study];
  networkManager.environment = environment;
  return networkManager;
}

+ (instancetype)defaultComponent
{
  if (!gSBBAppStudy) {
    return nil;
  }
  
  static SBBNetworkManager *shared;
  
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    SBBEnvironment environment = gSBBDefaultEnvironment;
    
    NSString *baseURL = [self baseURLForEnvironment:environment appURLPrefix:kAPIPrefix baseURLPath:@"sagebridge.org"];
    NSString *bridgeStudy = gSBBAppStudy;
    shared = [[self alloc] initWithBaseURL:baseURL bridgeStudy:bridgeStudy];
    shared.environment = environment;
  });
  
  return shared;
}

/*********************************************************************************/
#pragma mark - Initializers & Accessors
/*********************************************************************************/

- (instancetype) initWithBaseURL: (NSString*) baseURL
{
    return [self initWithBaseURL:baseURL bridgeStudy:nil];
}

- (instancetype) initWithBaseURL: (NSString*) baseURL bridgeStudy: (NSString*)bridgeStudy
{
    self = [super init]; //Using [self class] instead of APCNetworkManager to enable subclassing
    if (self) {
        self.baseURL = baseURL;
        self.bridgeStudy = bridgeStudy;
        self.internetReachability = [Reachability reachabilityForInternetConnection];
        NSURL *url = [NSURL URLWithString:baseURL];
        self.serverReachability = [Reachability reachabilityWithHostName:[url host]]; //Check if only hostname is required
        [self.serverReachability startNotifier]; //Turning on ONLY server reachability notifiers
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
        self.environment = SBBEnvironmentCustom;
        self.uploadCompletionHandlers = [NSMutableDictionary dictionary];
        self.downloadCompletionHandlers = [NSMutableDictionary dictionary];
        
        // If this network manager communicates with Bridge servers, turn off cookies so we don't get
        // unexpected authentication-related behavior. In general though, leave cookies on (default NSURLSession
        // behavior) and let the caller turn them off if so desired.
        if (bridgeStudy.length) {
            self.sendCookies = NO;
        } else {
            self.sendCookies = YES;
        }
    }
    return self;
}

- (NSURLSession *)mainSession
{
    if (!_mainSession) {
        _mainSession = [NSURLSession sharedSession];
    }
    return _mainSession;
}

- (NSURLSession *)backgroundSession
{
    if (!_backgroundSession) {
      // dispatch_once to make sure there's only ever one instance of a background session created with this identifier
      static NSURLSession *bgSession;
      static dispatch_once_t onceToken;
      dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:kBackgroundSessionIdentifier];
        bgSession = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
      });
      
      _backgroundSession = bgSession;
    }
  
    return _backgroundSession;
}

- (BOOL)isInternetConnected
{
    return (self.internetReachability.currentReachabilityStatus != NotReachable);
}

- (BOOL)isServerReachable
{
    return (self.serverReachability.currentReachabilityStatus != NotReachable);
}

/*********************************************************************************/
#pragma mark - basic HTTP methods
/*********************************************************************************/
- (NSURLSessionDataTask *)get:(NSString *)URLString headers:(NSDictionary *)headers parameters:(id)parameters completion:(SBBNetworkManagerCompletionBlock)completion
{
  return [self doDataTask:@"GET" retryObject:nil URLString:URLString headers:headers parameters:parameters completion:completion];
}

- (NSURLSessionDataTask *)put:(NSString *)URLString headers:(NSDictionary *)headers parameters:(id)parameters completion:(SBBNetworkManagerCompletionBlock)completion
{
  return [self doDataTask:@"PUT" retryObject:nil URLString:URLString headers:headers parameters:parameters completion:completion];
}

- (NSURLSessionDataTask *)post:(NSString *)URLString headers:(NSDictionary *)headers parameters:(id)parameters completion:(SBBNetworkManagerCompletionBlock)completion
{
  return [self doDataTask:@"POST" retryObject:nil URLString:URLString headers:headers parameters:parameters completion:completion];
}

- (NSURLSessionDataTask *)delete:(NSString *)URLString headers:(NSDictionary *)headers parameters:(id)parameters completion:(SBBNetworkManagerCompletionBlock)completion
{
  return [self doDataTask:@"DELETE" retryObject:nil URLString:URLString headers:headers parameters:parameters completion:completion];
}

// in case this class is used from C++, because delete is a keyword in that language (see header)
- (NSURLSessionDataTask *)delete_:(NSString *)URLString headers:(NSDictionary *)headers parameters:(id)parameters completion:(SBBNetworkManagerCompletionBlock)completion
{
  return [self delete:URLString headers:headers parameters:parameters completion:completion];
}

- (NSString *)keyForTask:(NSURLSessionTask *)task
{
  return [NSString stringWithFormat:@"%llu", (unsigned long long)task];
}

- (SBBNetworkManagerTaskCompletionBlock)completionBlockForTask:(NSURLSessionTask *)task
{
  SBBDataTaskCompletionWrapper *wrapper = [_uploadCompletionHandlers objectForKey:[self keyForTask:task]];
  return wrapper.completion;
}

- (void)setCompletionBlock:(SBBNetworkManagerTaskCompletionBlock)completion forTask:(NSURLSessionTask *)task
{
  if (!completion) {
    [self removeCompletionBlockForTask:task];
    return;
  }
  SBBDataTaskCompletionWrapper *wrapper = [[SBBDataTaskCompletionWrapper alloc] initWithBlock:completion];
  [_uploadCompletionHandlers setObject:wrapper forKey:[self keyForTask:task]];
}

- (void)removeCompletionBlockForTask:(NSURLSessionTask *)task
{
  [_uploadCompletionHandlers removeObjectForKey:[self keyForTask:task]];
}

- (NSURLSessionUploadTask *)uploadFile:(NSURL *)fileUrl httpHeaders:(NSDictionary *)headers toUrl:(NSString *)urlString taskDescription:(NSString *)description completion:(SBBNetworkManagerTaskCompletionBlock)completion
{
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
  [request setAllHTTPHeaderFields:headers];
  request.HTTPMethod = @"PUT";
  NSURLSessionUploadTask *task = [self.backgroundSession uploadTaskWithRequest:request fromFile:fileUrl];
  [self setCompletionBlock:completion forTask:task];
  task.taskDescription = description;
  
  [task resume];
  
  return task;
}

- (SBBNetworkManagerDownloadCompletionBlock)completionBlockForDownload:(NSURLSessionDownloadTask *)task
{
  SBBDownloadCompletionWrapper *wrapper = [_downloadCompletionHandlers objectForKey:[self keyForTask:task]];
  return wrapper.completion;
}

- (void)setCompletionBlock:(SBBNetworkManagerDownloadCompletionBlock)completion forDownload:(NSURLSessionDownloadTask *)task
{
  if (!completion) {
    [self removeCompletionBlockForDownload:task];
    return;
  }
  SBBDownloadCompletionWrapper *wrapper = [[SBBDownloadCompletionWrapper alloc] initWithBlock:completion];
  [_downloadCompletionHandlers setObject:wrapper forKey:[self keyForTask:task]];
}

- (void)removeCompletionBlockForDownload:(NSURLSessionDownloadTask *)task
{
  [_downloadCompletionHandlers removeObjectForKey:[self keyForTask:task]];
}

- (NSURLSessionDownloadTask *)downloadFileFromURLString:(NSString *)urlString method:(NSString *)httpMethod httpHeaders:(NSDictionary *)headers parameters:(NSDictionary *)parameters taskDescription:(NSString *)description downloadCompletion:(SBBNetworkManagerDownloadCompletionBlock)downloadCompletion taskCompletion:(SBBNetworkManagerTaskCompletionBlock)taskCompletion
{
  NSMutableURLRequest *request = [self requestWithMethod:httpMethod URLString:urlString headers:headers parameters:parameters error:nil];
  
  NSURLSessionDownloadTask *task = [self.backgroundSession downloadTaskWithRequest:request];
  [self setCompletionBlock:downloadCompletion forDownload:task];
  [self setCompletionBlock:taskCompletion forTask:task];
  task.taskDescription = description;
  
  [task resume];
  
  return task;
}



- (void)restoreBackgroundSession:(NSString *)identifier completionHandler:(void (^)(void))completionHandler
{
  // make sure we're being called with the expected identifier--if not, ignore
  if ([identifier isEqualToString:kBackgroundSessionIdentifier]) {
    [self backgroundSession];
    _backgroundCompletionHandler = completionHandler;
  }
}


/*********************************************************************************/
#pragma mark - Helper Methods
/*********************************************************************************/

- (NSDictionary *)headersPreparedForRetry:(NSDictionary *)headers
{
    return headers;
}

- (NSURLSessionDataTask *) doDataTask: (NSString*) method
                          retryObject: (APCNetworkRetryObject*) retryObject
                            URLString: (NSString*)URLString
                              headers: (NSDictionary *)headers
                           parameters:(NSDictionary *)parameters
                           completion:(SBBNetworkManagerCompletionBlock)completion
{
    APCNetworkRetryObject * localRetryObject;
    __weak APCNetworkRetryObject * weakLocalRetryObject;
    if (!retryObject) {
        localRetryObject = [[APCNetworkRetryObject alloc] init];
        weakLocalRetryObject = localRetryObject;
        localRetryObject.completionBlock = completion;
        localRetryObject.retryBlock = ^ {
            __strong APCNetworkRetryObject * strongLocalRetryObject = weakLocalRetryObject; //To break retain cycle
          [self doDataTask:method retryObject:strongLocalRetryObject URLString:URLString headers:[self headersPreparedForRetry:headers] parameters:parameters completion:completion];
        };
    }
    else
    {
        localRetryObject = retryObject;
    }
    
  NSMutableURLRequest *request = [self requestWithMethod:method URLString:URLString headers:headers parameters:parameters error:nil];
    __block NSURLSessionDataTask *task = [self.mainSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSError * httpError = [NSError generateSBBErrorForStatusCode:((NSHTTPURLResponse*)response).statusCode data:data];
        NSDictionary * responseObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
        if (error)
        {
            [self handleError:error task:task response:responseObject retryObject:localRetryObject];
        }
        else if (httpError)
        {
            [self handleHTTPError:httpError task:task response:responseObject retryObject:localRetryObject];
        }
        else
        {
            if (completion) {
                completion(task, responseObject, nil);
            }
        }
    }];
  
    [task resume];
 
    return task;
    
}

- (NSString *)queryStringFromParameters:(NSDictionary *)parameters
{
  if (![parameters isKindOfClass:[NSDictionary class]]) {
    return nil;
  }
  
  NSMutableArray *queryParams = [NSMutableArray arrayWithCapacity:parameters.count];
  for (NSString *param in parameters) {
    id value = parameters[param];
    NSString *valueString;
    if ([value isKindOfClass:[NSString class]]) {
      valueString = value;
    } else if ([value isKindOfClass:[NSNumber class]]) {
      NSNumber *valueNum = (NSNumber *)value;
      if (valueNum.objCType[0] == 'B') {
        BOOL valueBool = [valueNum boolValue];
        valueString = valueBool ? @"true" : @"false";
      } else {
        valueString = [valueNum stringValue];
      }
    } else if ([value isKindOfClass:[NSDate class]]) {
      NSDate *valueDate = (NSDate *)value;
      valueString = [valueDate ISO8601String];
    } else if ([value isKindOfClass:[NSDictionary class]] || [value isKindOfClass:[NSArray class]]) {
      NSData *valueData = [NSJSONSerialization dataWithJSONObject:value options:0 error:nil];
      if (valueData.length) {
        valueString = [[NSString alloc] initWithData:valueData encoding:NSUTF8StringEncoding];
      }
    } else {
      NSLog(@"Unable to determine how to convert parameter '%@' value to string: %@, skipping", param, value);
    }
    
    if (valueString) {
      NSString *qParam = [NSString stringWithFormat:@"%@=%@",
                          [param stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]],
                          [valueString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]]];
      [queryParams addObject:qParam];
    }
  }
  
  return [queryParams componentsJoinedByString:@"&"];
}

- (NSString *)userAgentHeader
{
  NSDictionary *localizedInfoDictionary = [[NSBundle mainBundle] localizedInfoDictionary];
  if (!localizedInfoDictionary) {
    localizedInfoDictionary = [[NSBundle mainBundle] infoDictionary];
  }
  NSString *appName = [localizedInfoDictionary objectForKey:(NSString *)kCFBundleNameKey];
  NSString *appVersion = [localizedInfoDictionary objectForKey:(NSString *)kCFBundleVersionKey];
  NSString *deviceModel = [[UIDevice currentDevice] platformString];
  NSString *osName = [[UIDevice currentDevice] systemName];
  NSString *osVersion = [[UIDevice currentDevice] systemVersion];
  
  return [NSString stringWithFormat:@"%@/%@ (%@; %@ %@) BridgeSDK/%0.0f", appName, appVersion, deviceModel, osName, osVersion, BridgeSDKVersionNumber];
}

- (NSString *)acceptLanguageHeader
{
  return [NSString stringWithFormat:@"%@", [[NSLocale preferredLanguages] componentsJoinedByString:@", "]];
}

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method
                                 URLString:(NSString *)URLString
                                   headers:(NSDictionary *)headers
                                parameters:(id)parameters
                                     error:(NSError *__autoreleasing *)error
{
  BOOL isGET = [method isEqualToString:@"GET"];
  if (parameters && isGET) {
    NSString *queryString = [self queryStringFromParameters:parameters];
    if (queryString.length) {
      if ([URLString containsString:@"?"]) {
        URLString = [NSString stringWithFormat:@"%@&%@", URLString, queryString];
      } else {
        URLString = [NSString stringWithFormat:@"%@?%@", URLString, queryString];
      }
    }
  }
  
  NSURL *url = [self URLForRelativeorAbsoluteURLString:URLString];
  NSMutableURLRequest *mutableRequest = [[NSMutableURLRequest alloc] initWithURL:url];
  mutableRequest.HTTPMethod = method;
  mutableRequest.HTTPShouldHandleCookies = self.sendCookies;
  [mutableRequest setValue:[self userAgentHeader] forHTTPHeaderField:@"User-Agent"];
  [mutableRequest setValue:[self acceptLanguageHeader] forHTTPHeaderField:@"Accept-Language"];
  
  if (headers) {
    for (NSString *header in headers.allKeys) {
      [mutableRequest addValue:headers[header] forHTTPHeaderField:header];
    }
  }
    
  if (parameters && !isGET) {
    if (![mutableRequest valueForHTTPHeaderField:@"Content-Type"]) {
      NSString *charset = (__bridge NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
      [mutableRequest setValue:[NSString stringWithFormat:@"application/json; charset=%@", charset] forHTTPHeaderField:@"Content-Type"];
    }
    
    [mutableRequest setHTTPBody:[NSJSONSerialization dataWithJSONObject:parameters options:0 error:error]];
  }
#if DEBUG
    NSLog(@"Prepared request--URL:\n%@\nHeaders:\n%@\nBody:\n%@", mutableRequest.URL.absoluteString, mutableRequest.allHTTPHeaderFields, [[NSString alloc] initWithData:mutableRequest.HTTPBody encoding:NSUTF8StringEncoding]);
#endif
  
  return mutableRequest;
}

- (NSURL *) URLForRelativeorAbsoluteURLString: (NSString*) URLString
{
    NSURL *url = [NSURL URLWithString:URLString];
    if ([url.scheme.lowercaseString hasPrefix:@"http"]) {
        return url;
    }
    else
    {
        NSURL * tempURL =[NSURL URLWithString:URLString relativeToURL:[NSURL URLWithString:self.baseURL]];
        return [NSURL URLWithString:[tempURL absoluteString]];
    }
}

#pragma mark - NSURLSessionDownloadDelegate methods

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
{
  if (_backgroundTransferDelegate && [_backgroundTransferDelegate respondsToSelector:@selector(URLSession:downloadTask:didResumeAtOffset:expectedTotalBytes:)]) {
    [_backgroundTransferDelegate URLSession:session downloadTask:downloadTask didResumeAtOffset:fileOffset expectedTotalBytes:expectedTotalBytes];
  }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
  if (_backgroundTransferDelegate && [_backgroundTransferDelegate respondsToSelector:@selector(URLSession:downloadTask:didWriteData:totalBytesWritten:totalBytesExpectedToWrite:)]) {
    [_backgroundTransferDelegate URLSession:session downloadTask:downloadTask didWriteData:bytesWritten totalBytesWritten:totalBytesWritten totalBytesExpectedToWrite:totalBytesExpectedToWrite];
  }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
  SBBNetworkManagerDownloadCompletionBlock completion = [self completionBlockForDownload:downloadTask];
  if (completion) {
    completion(location);
    [self removeCompletionBlockForDownload:downloadTask];
  }
  
  if (_backgroundTransferDelegate && [_backgroundTransferDelegate respondsToSelector:@selector(URLSession:downloadTask:didFinishDownloadingToURL:)]) {
    [_backgroundTransferDelegate URLSession:session downloadTask:downloadTask didFinishDownloadingToURL:location];
  }
}

#pragma mark - NSURLSessionDataDelegate methods

#pragma mark - NSURLSessionTaskDelegate methods

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
  SBBNetworkManagerTaskCompletionBlock completion = [self completionBlockForTask:task];
  if (completion) {
    completion((NSURLSessionUploadTask *)task, (NSHTTPURLResponse *)task.response, error);
    [self removeCompletionBlockForTask:task];
  }
  
  if (_backgroundTransferDelegate && [_backgroundTransferDelegate respondsToSelector:@selector(URLSession:task:didCompleteWithError:)]) {
    [_backgroundTransferDelegate URLSession:session task:task didCompleteWithError:error];
  }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler
{
  if (_backgroundTransferDelegate && [_backgroundTransferDelegate respondsToSelector:@selector(URLSession:task:didReceiveChallenge:completionHandler:)]) {
    [_backgroundTransferDelegate URLSession:session task:task didReceiveChallenge:challenge completionHandler:completionHandler];
  } else {
    completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
  }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend
{
  if (_backgroundTransferDelegate && [_backgroundTransferDelegate respondsToSelector:@selector(URLSession:task:didSendBodyData:totalBytesSent:totalBytesExpectedToSend:)]) {
    [_backgroundTransferDelegate URLSession:session task:task didSendBodyData:bytesSent totalBytesSent:totalBytesSent totalBytesExpectedToSend:totalBytesExpectedToSend];
  }
}

#pragma mark - NSURLSessionDelegate methods

- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error
{
  [_downloadCompletionHandlers removeAllObjects];
  [_uploadCompletionHandlers removeAllObjects];
  
  if (_backgroundTransferDelegate && [_backgroundTransferDelegate respondsToSelector:@selector(URLSession:didBecomeInvalidWithError:)]) {
    [_backgroundTransferDelegate URLSession:session didBecomeInvalidWithError:error];
  }
}

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session
{
  if (_backgroundCompletionHandler) {
    _backgroundCompletionHandler();
    _backgroundCompletionHandler = nil;
  }
  
  if (_backgroundTransferDelegate && [_backgroundTransferDelegate respondsToSelector:@selector(URLSessionDidFinishEventsForBackgroundURLSession:)]) {
    [_backgroundTransferDelegate URLSessionDidFinishEventsForBackgroundURLSession:session];
  }
}

/*********************************************************************************/
#pragma mark - Error Handler
/*********************************************************************************/
- (void)handleError:(NSError*)error task:(NSURLSessionDataTask*)task response:(id)responseObject retryObject: (APCNetworkRetryObject*)retryObject
{
    NSInteger errorCode = error.code;
    NSError * apcError = [NSError generateSBBErrorForNSURLError:error isInternetConnected:self.isInternetConnected isServerReachable:self.isServerReachable];
    
    if (!self.isInternetConnected || !self.isServerReachable) {
        if (retryObject.completionBlock)
        {
            retryObject.completionBlock(task, responseObject, apcError);
        }
        retryObject.retryBlock = nil;
    }
    else if ([self checkForTemporaryErrors:errorCode])
    {
        if (retryObject && retryObject.retryBlock && retryObject.retryCount < kMaxRetryCount)
        {
            double delayInSeconds = pow(2.0, retryObject.retryCount + 1); //Exponential backoff
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                retryObject.retryBlock();
                retryObject.retryCount++;
            });
        }
        else
        {
            if (retryObject.completionBlock)
            {
                retryObject.completionBlock(task, responseObject, apcError);
            }
            retryObject.retryBlock = nil;
        }
    }
    else
    {
        if (retryObject.completionBlock)
        {
            retryObject.completionBlock(task, responseObject, apcError);
        }
        retryObject.retryBlock = nil;
    }
}

- (void)handleHTTPError:(NSError *)error task:(NSURLSessionDataTask *)task response:(id)responseObject retryObject:(APCNetworkRetryObject *)retryObject
{
    //TODO: Add retry for Server maintenance
    if (retryObject.completionBlock)
    {
        retryObject.completionBlock(task, responseObject, error);
    }
    retryObject.retryBlock = nil;
}

- (BOOL) checkForTemporaryErrors:(NSInteger) errorCode
{
    return (errorCode == NSURLErrorTimedOut || errorCode == NSURLErrorCannotFindHost || errorCode == NSURLErrorCannotConnectToHost || errorCode == NSURLErrorNotConnectedToInternet || errorCode == NSURLErrorSecureConnectionFailed);
}


/*********************************************************************************/
#pragma mark - Misc
/*********************************************************************************/
- (void)reachabilityChanged: (NSNotification*) notification
{
    //TODO: Figure out what needs to be done here
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.serverReachability stopNotifier];
}
@end
