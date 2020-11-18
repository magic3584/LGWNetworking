//
//  LGWNetworkManager.m
//  LGWNetworkingDemo
//
//  Created by Lugick Wang on 2020/11/18.
//

#import "LGWNetworkManager.h"

@implementation LGWNetworkManager


+ (LGWNetworkManager *)sharedInstance {
    static LGWNetworkManager * shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[LGWNetworkManager alloc] init];
    });
    return shared;
}

@end
