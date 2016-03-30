//
//  HTTPGetRequest.m
//  B&H Buses
//
//  Created by Tom Pullen on 29/02/2016.
//  Copyright © 2016 Tom Pullen. All rights reserved.
//

#import "HTTPGetRequest.h"

@interface HTTPGetRequest()

@property (strong, nonatomic) NSMutableData *downloadedData;

@end

@implementation HTTPGetRequest

- (void)downloadDataWithURL:(NSString *)url {
    // Download the json file
    NSURL *jsonFileUrl = [NSURL URLWithString:url];
    
    // Create the request
    NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:jsonFileUrl];
    
    // Create the NSURLConnection
    [NSURLConnection connectionWithRequest:urlRequest delegate:self];
}

#pragma mark NSURLConnectionDataProtocol Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // Initialize the data object
    self.downloadedData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the newly downloaded data
    [self.downloadedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    // Ready to notify delegate that data is ready and pass back items
    if (self.delegate) {
        [self.delegate dataDownloaded:self.downloadedData];
    }
}


@end

