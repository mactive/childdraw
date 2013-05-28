//
//  UpYun.m
//  upyundemo
//
//  Created by andy yao on 12-6-14.
//  Copyright (c) 2012年 upyun.com. All rights reserved.
//

#import "UpYun.h"
#import "WBUtil.h"
#import "SBJson.h"

@interface UpYun() {
    NSMutableData *_data;
}

@end

@implementation UpYun
@synthesize 
bucket= _bucket,
expiresIn = _expiresIn,
params = _params,
passcode = _passcode,
delegate = _delegate;

- (void)upload:(NSDictionary *)dic {
    
    if (_data) {
        _data = nil;
    }
    _data = [NSMutableData data];
    
    NSString *policy = [dic objectForKey:@"policy"];
    NSString *signature = [dic objectForKey:@"signature"];
    id file = [dic objectForKey:@"file"];
    
    NSMutableData *post = [NSMutableData data];
    NSURL *myWebserverURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@/",API_DOMAIN,self.bucket]];
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:myWebserverURL]; 
    
	[request setTimeoutInterval: 60.0];
	[request setCachePolicy: NSURLRequestUseProtocolCachePolicy];
    
    [request setHTTPMethod:@"POST"];
    
    NSString *charset = (NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
	
	// Set your own boundary string only if really obsessive. We don't bother to check if post data contains the boundary, since it's pretty unlikely that it does.
	NSString *stringBoundary = @"0xKhTmLbOuNdArY";
	
	[request addValue:[NSString stringWithFormat:@"multipart/form-data; charset=%@; boundary=%@", charset, stringBoundary] forHTTPHeaderField:@"Content-Type"];
	
	[post appendData:[[NSString stringWithFormat:@"--%@\r\n",stringBoundary] dataUsingEncoding:NSASCIIStringEncoding]];
	
	// Adds post data
    
	NSString *endItemBoundary = [NSString stringWithFormat:@"\r\n--%@\r\n",stringBoundary];

    [post appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",@"policy"] dataUsingEncoding:NSASCIIStringEncoding]];
    [post appendData:[policy dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    [post appendData:[endItemBoundary dataUsingEncoding:NSASCIIStringEncoding]];
    
    [post appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",@"signature"] dataUsingEncoding:NSASCIIStringEncoding]];
    [post appendData:[signature dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    [post appendData:[endItemBoundary dataUsingEncoding:NSASCIIStringEncoding]];
    
    // Adds files to upload
    if (file) {
        [post appendData:[endItemBoundary dataUsingEncoding:NSASCIIStringEncoding]];
        [post appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", @"file", @"pic"] dataUsingEncoding:NSASCIIStringEncoding]];
        [post appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", @"application/octet-stream"] dataUsingEncoding:NSASCIIStringEncoding]];
        if ([file isKindOfClass:[NSString class]]) {
            NSInputStream *stream = [[NSInputStream alloc] initWithFileAtPath:file];
            [stream open];
            NSUInteger bytesRead;
            while ([stream hasBytesAvailable]) {
                
                unsigned char buffer[1024*256];
                bytesRead = [stream read:buffer maxLength:sizeof(buffer)];
                if (bytesRead == 0) {
                    break;
                }
                
                [post appendData:[NSData dataWithBytes:buffer length:bytesRead]];
            }
            [stream close];
        } else {
            [post appendData:file];
        }
    }
    
    // Only add the boundary if this is not the last item in the post body
	
	[post appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",stringBoundary] dataUsingEncoding:NSASCIIStringEncoding]];
    
    NSString *postLength = [NSString stringWithFormat:@"%d", [post length]];  
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:post];
    
    [NSURLConnection connectionWithRequest:request delegate:self];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    SBJsonParser *p = [[SBJsonParser alloc] init];
    NSDictionary *dic = [p objectWithString:[[NSString alloc] initWithData:_data encoding:NSASCIIStringEncoding]];
    NSLog(@"dic %@",dic);
    if ([self.delegate respondsToSelector:@selector(upYun:requestDidFailWithError:)]) {
        [self.delegate upYun:self requestDidFailWithError:error];
    }
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
    if ([self.delegate respondsToSelector:@selector(upYun:requestDidSendBytes:progress:)]) {
        [self.delegate upYun:self requestDidSendBytes:bytesWritten progress:(float)totalBytesWritten/(float)totalBytesExpectedToWrite];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_data appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    SBJsonParser *p = [[SBJsonParser alloc] init];
    NSDictionary *dic = [p objectWithString:[[NSString alloc] initWithData:_data encoding:NSASCIIStringEncoding]];

    NSString *message = [dic objectForKey:@"message"];
    if ([@"ok" isEqualToString:message]) {
        if ([self.delegate respondsToSelector:@selector(upYun:requestDidSendBytes:progress:)]) {
            [self.delegate upYun:self requestDidSendBytes:0 progress:1];
        }
        if ([self.delegate respondsToSelector:@selector(upYun:requestDidSucceedWithResult:)]) {
            [self.delegate upYun:self requestDidSucceedWithResult:dic];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(upYun:requestDidFailWithError:)]) {
            NSError *err = [NSError errorWithDomain:ERROR_DOMAIN code:[[dic objectForKey:@"code"] intValue] userInfo:dic];
            [self.delegate upYun:self requestDidFailWithError:err];
        }
    }
}

- (NSString *)policy:(NSString *)savekey {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:self.bucket forKey:@"bucket"];
    [dic setObject:[NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970] + self.expiresIn] forKey:@"expiration"];
    [dic setObject:savekey forKey:@"save-key"];
    for (NSString *key in self.params.keyEnumerator) {
        [dic setObject:[self.params objectForKey:key] forKey:key];
    }
    NSString *json = [self JSONParse:dic];
    return [json base64EncodedString];
}

- (NSString *)JSONParse:(id)object {
    SBJsonWriter *writer = [[SBJsonWriter alloc] init];
    NSString *json = [writer stringWithObject:object];
    if (!json)
        NSLog(@"-JSONRepresentation failed. Error is: %@", writer.error);
    return json;
}


- (void) uploadImagePath:(NSString *)path savekey:(NSString *)savekey {
    NSString *policy = [self policy:savekey];
    NSString *str = [NSString stringWithFormat:@"%@&%@",policy,self.passcode];
    NSString *signature = [[str MD5EncodedString] lowercaseString];
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:policy,@"policy",signature,@"signature",path,@"file", nil];
    
    [self upload:dic];
}

- (void) uploadImageData:(NSData *)data savekey:(NSString *)savekey {
    NSString *policy = [self policy:savekey];
    NSString *str = [NSString stringWithFormat:@"%@&%@",policy,self.passcode];
    NSString *signature = [[str MD5EncodedString] lowercaseString];
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:policy,@"policy",signature,@"signature",data,@"file", nil];
    
    [self upload:dic];
}

@end
