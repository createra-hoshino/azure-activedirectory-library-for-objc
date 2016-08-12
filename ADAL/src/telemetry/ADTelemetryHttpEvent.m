// Copyright (c) Microsoft Corporation.
// All rights reserved.
//
// This code is licensed under the MIT License.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files(the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and / or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions :
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "ADTelemetryHttpEvent.h"

@implementation ADTelemetryHttpEvent

- (void)setHttpMethod:(NSString*)method
{
    [self setProperty:@"http_method" value:method];
}

- (void)setHttpPath:(NSString*)path
{
    [self setProperty:@"http_path" value:path];
}

- (void)setHttpResponseCode:(NSString*)code
{
    [self setProperty:@"http_response_code" value:code];
}

- (void)setHttpResponseMethod:(NSString*)method
{
    [self setProperty:@"http_response_method" value:method];
}

- (void)setHttpRequestQueryParams:(NSString*)params
{
    [self setProperty:@"request_query_params" value:params];
}

- (void)setHttpUserAgent:(NSString*)userAgent
{
    [self setProperty:@"user_agent" value:userAgent];
}

- (void)setHttpErrorDomain:(NSString*)errorDomain
{
    [self setProperty:@"http_error_domain" value:errorDomain];
}

- (NSString*)scrubTenantFromUrl:(NSString*)url
{
    //Scrub the tenant domain from the url
    //E.g., "https://login.windows.net/omercantest.onmicrosoft.com"
    //will become "https://login.windows.net/*.onmicrosoft.com"
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern: @"/[^/.]+.onmicrosoft.com"
                                                                           options: NSRegularExpressionCaseInsensitive
                                                                             error: nil];
    
    NSString* scrubbedUrl = [regex stringByReplacingMatchesInString:url
                                                          options:0
                                                            range:NSMakeRange(0, [url length])
                                                     withTemplate:@"/*.onmicrosoft.com"];
    return scrubbedUrl;
}

@end