//
//  LGWNetworkManager.h
//  LGWNetworkingDemo
//
//  Created by Lugick Wang on 2020/11/18.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import "LGWEnum.h"


NS_ASSUME_NONNULL_BEGIN

@interface LGWNetworkManager : NSObject

+ (LGWNetworkManager *)sharedInstance;


- (NSURLSessionTask *)dataTaskWithMethod:(LGWMethodType)type
                               urlString:(NSString *)urlString
                              parameters:(nullable id)parameters
                                 headers:(nullable NSDictionary <NSString *, NSString *> *)headers
                                progress:(nullable void (^)(NSProgress * _Nonnull))progress
                       completionHandler:(nullable void(^)(NSURLSessionTask *, id _Nullable, NSError * _Nullable))completionHandler;

- (void)setRequestHeaders:(NSDictionary *)headers;

@end
NS_ASSUME_NONNULL_END
