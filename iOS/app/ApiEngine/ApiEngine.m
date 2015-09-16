//
//  ApiEngine.m
//  TheApp
//
//  Created by Joel Oliveira on 8/7/13.
//  Copyright (c) 2013 Notificare. All rights reserved.
//

#import "ApiEngine.h"

@implementation ApiEngine

/*!
 * Generic API method call
 *
 */
- (void) requestWithHostName:(NSString *)hostName
                     apiPath:(NSString *)path
                  httpMethod:(NSString *)httpMethod
              applicationKey:(NSString *)appKey
           applicationSecret:(NSString *)appSecret
                customParams:(NSDictionary *)customParams
                   onSuccess:(SuccessBlock)successBlock
                     onError:(ErrorBlock)errorBlock {
    
    if ([httpMethod isEqualToString:@"GET"] || [httpMethod isEqualToString:@"DELETE"]) {
        
        MKNetworkOperation *op = [self operationWithURLString:[NSString stringWithFormat:@"%@/%@", hostName, path]
                                                       params:customParams httpMethod:httpMethod];
        
        if ([self apiID] && [self apiSecret]) {
        
            [op setUsername:[self apiID] password:[self apiSecret] basicAuth:YES];
        }
        
        [op setShouldContinueWithInvalidCertificate:NO];
        
        [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
            
            [completedOperation responseJSONWithCompletionHandler:^(id jsonObject) {
                
                successBlock(jsonObject);
            }];
            
        } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
            
            errorBlock(error);
        }];
        
        [self enqueueOperation:op];
        
    } else if ([httpMethod isEqualToString:@"POST"] || [httpMethod isEqualToString:@"PUT"]) {
        
        NSMutableDictionary * params = [NSMutableDictionary dictionary];
        
        if (customParams) {
            
            [params addEntriesFromDictionary:customParams];
        }
        
        MKNetworkOperation *op = [self operationWithURLString:[NSString stringWithFormat:@"%@/%@", hostName, path]
                                                       params:params httpMethod:httpMethod];
        
        if ([self apiID] && [self apiSecret]) {
            
            [op setUsername:[self apiID] password:[self apiSecret] basicAuth:YES];
        }
        
        [op setShouldContinueWithInvalidCertificate:NO];
        
        [op setPostDataEncoding:MKNKPostDataEncodingTypeJSON];
        
        [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
            
            [completedOperation responseJSONWithCompletionHandler:^(id jsonObject) {
                
                successBlock(jsonObject);
            }];
            
        } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
            
            errorBlock(error);
        }];
        
        [self enqueueOperation:op];
        
    } else {
        
        NSLog(@"Not a valid http method, please use POST, PUT, GET or DELETE for the API requests.");
    }
}

/*!
 * 
 *
 */
- (void)getEvents:(SuccessBlock)successBlock errorHandler:(ErrorBlock)errorBlock {
    
    MKNetworkOperation *op = [self operationWithPath:@"/"
                                              params:nil httpMethod:@"GET" ssl:YES];
    
    //[op setShouldContinueWithInvalidCertificate:NO];
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        
        [completedOperation responseJSONWithCompletionHandler:^(id jsonObject) {
            
            successBlock(jsonObject);
            
        }];
        
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        
        errorBlock(error);
        
    }];
    
    [self enqueueOperation:op];
}

/*!
 *
 *
 */
-(NSString*) cacheDirectoryName {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths[0];
    NSString *cacheDirectoryName = [documentsDirectory stringByAppendingPathComponent:@"AppImages"];
    return cacheDirectoryName;
}



@end
