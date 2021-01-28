//
//  LGWNetworkManager.m
//  LGWNetworkingDemo
//
//  Created by Lugick Wang on 2020/11/18.
//

#import "LGWNetworkManager.h"
#import "LGWEnum.h"

@interface LGWNetworkManager()

@property (nonatomic, strong) AFHTTPSessionManager * manager;

@property (nonatomic, strong) NSDictionary *headers;


@end

@implementation LGWNetworkManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSURLSessionConfiguration * config = [NSURLSessionConfiguration defaultSessionConfiguration];
        self.manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:config];
        self.manager.requestSerializer = [AFJSONRequestSerializer serializer];
    }
    return self;
}

+ (LGWNetworkManager *)sharedInstance {
    static LGWNetworkManager * shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[LGWNetworkManager alloc] init];
    });
    return shared;
}

- (void)dealWithDataTask:(NSURLSessionTask *)task
                response:(id)response
                   error:(NSError *)error
       completionHandler:(nullable void(^)(NSURLSessionTask *, id _Nullable, NSError * _Nullable))completionHandler {
    
    NSMutableString * log = [NSMutableString string];
    
    [log appendString: [NSString stringWithFormat:@"\nURL:%@\n", task.originalRequest.URL.absoluteString]];
    
    if (task.originalRequest.allHTTPHeaderFields) {
        [log appendString:@"header:\n"];

        [task.originalRequest.allHTTPHeaderFields enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
            [log appendString:[NSString stringWithFormat:@"%@:",key]];
            [log appendString:[NSString stringWithFormat:@"%@\n",obj]];
        }];
    }
    
    if (task.originalRequest.HTTPBody) {
        [log appendString: [NSString stringWithFormat:@"httpBody:%@\n",[NSJSONSerialization JSONObjectWithData:task.originalRequest.HTTPBody options:kNilOptions error:nil]]];
    }
    
    if (task.originalRequest.URL.query) {
        [log appendString: [NSString stringWithFormat:@"query: %@\n", task.originalRequest.URL.query]];
    }
    
    [log appendString:[NSString stringWithFormat:@"response: %@", response]];
    

    if (error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            completionHandler(task, nil, error);

        });
        
    } else {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSDictionary *dict = (NSDictionary *)response;
            
            NSInteger code = [dict[@"code"] integerValue];
            NSString *msg = dict[@"msg"];
            
            if (code == 0) {
                completionHandler(task, (NSDictionary *)response[@"data"], nil);

            } else {
                
                completionHandler(task, nil, [NSError errorWithDomain:msg code:-1 userInfo:nil]);
            }
            
        });
        
    }
    
}

- (NSURLSessionTask *)dataTaskWithMethod:(LGWMethodType)type
                               urlString:(NSString *)urlString
                              parameters:(nullable id)parameters
                                 headers:(nullable NSDictionary <NSString *, NSString *> *)headers
                                progress:(nullable void (^)(NSProgress * _Nonnull))progress
                       completionHandler:(nullable void(^)(NSURLSessionTask *, id _Nullable, NSError * _Nullable))completionHandler {
   
    NSMutableDictionary * defaultHeader = [self.headers mutableCopy];
    [headers enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
        defaultHeader[key] = obj;
    }];
    
    NSURLSessionDataTask * dataTask = nil;
    
    __weak typeof(self) weakSelf = self;
    
    if (type == LGWMethodTypeGET) {
        dataTask = [self.manager GET:urlString parameters:parameters headers:defaultHeader progress:progress success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [weakSelf dealWithDataTask:task response:responseObject error:nil completionHandler:completionHandler];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [weakSelf dealWithDataTask:task response:nil error:error completionHandler:completionHandler];
        }];
    } else if (type == LGWMethodTypePOST) {
        dataTask = [self.manager POST:urlString parameters:parameters headers:defaultHeader progress:progress success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [weakSelf dealWithDataTask:task response:responseObject error:nil completionHandler:completionHandler];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [weakSelf dealWithDataTask:task response:nil error:error completionHandler:completionHandler];
        }];
    } else if (type == LGWMethodTypePUT) {
        dataTask = [self.manager PUT:urlString parameters:parameters headers:defaultHeader success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [weakSelf dealWithDataTask:task response:responseObject error:nil completionHandler:completionHandler];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [weakSelf dealWithDataTask:task response:nil error:error completionHandler:completionHandler];
        }];
    } else if (type == LGWMethodTypeDELETE) {
        dataTask = [self.manager DELETE:urlString parameters:parameters headers:defaultHeader success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [weakSelf dealWithDataTask:task response:responseObject error:nil completionHandler:completionHandler];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [weakSelf dealWithDataTask:task response:nil error:error completionHandler:completionHandler];
        }];
    }
    
    return dataTask;
}

- (void)setRequestHeaders:(NSDictionary *)headers {
    self.headers = [headers copy];
}

@end
