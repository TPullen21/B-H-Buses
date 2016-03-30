//
//  HTTPGetRequest.h
//  B&H Buses
//
//  Created by Tom Pullen on 29/02/2016.
//  Copyright © 2016 Tom Pullen. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol HTTPGetRequestProtocol <NSObject>

- (void)dataDownloaded:(NSData *)data;

@end

@interface HTTPGetRequest : NSObject <NSURLConnectionDataDelegate>

@property (nonatomic, weak) id<HTTPGetRequestProtocol> delegate;

- (void)downloadDataWithURL:(NSString *)url;

@end