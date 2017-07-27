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

#import <XCTest/XCTest.h>

#import "ADTestLoader.h"
#import "ADTokenCacheItem+Internal.h"
#import "ADUserInformation.h"

@interface ADTestLoaderCacheTests : XCTestCase

@end

@implementation ADTestLoaderCacheTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


- (void)testCache_whenEmpty
{
    ADTestLoader *loader = [[ADTestLoader alloc] initWithString:@"<Cache></Cache>"];
    XCTAssertNotNil(loader);
    
    NSError *error = nil;
    XCTAssertTrue([loader parse:&error]);
    XCTAssertNil(error);
    
    NSArray *cache = loader.cacheItems;
    XCTAssertNotNil(cache);
    XCTAssertEqual(cache.count, 0);
}

- (void)testCache_unsupportedElementType_shouldFail
{
    ADTestLoader *loader = [[ADTestLoader alloc] initWithString:@"<Cache><MonsterToken/></Cache>"];
    XCTAssertNotNil(loader);
    
    NSError *error = nil;
    XCTAssertFalse([loader parse:&error]);
    XCTAssertNotNil(error);
    
    NSArray *cache = loader.cacheItems;
    XCTAssertNil(cache);
}

- (void)testCache_basicSingleResourceRefreshToken_shouldSucceed
{
    ADTestLoader *loader = [[ADTestLoader alloc] initWithString:@"<Cache><RefreshToken token=\"i_am_a_refresh_token\" resource=\"resource\" clientId=\"clientid\" authority=\"https://iamanauthority.com\" tenant=\"mytenant\" /></Cache>"];
    XCTAssertNotNil(loader);
    
    NSError *error = nil;
    XCTAssertTrue([loader parse:&error]);
    XCTAssertNil(error);
    
    NSArray *cache = loader.cacheItems;
    XCTAssertNotNil(cache);
    XCTAssertEqual(cache.count, 1);
}

- (void)testCache_basicMultiResourceRefreshToken_shouldSucceed
{
    ADTestLoader *loader = [[ADTestLoader alloc] initWithString:@"<Cache><MultiResourceRefreshToken token=\"i_am_a_refresh_token\" clientId=\"clientid\" authority=\"https://iamanauthority.com\" tenant=\"mytenant\" /></Cache>"];
    XCTAssertNotNil(loader);
    
    NSError *error = nil;
    XCTAssertTrue([loader parse:&error]);
    XCTAssertNil(error);
    
    NSArray *cache = loader.cacheItems;
    XCTAssertNotNil(cache);
    XCTAssertEqual(cache.count, 1);
    
    ADTokenCacheItem *item = cache[0];
    XCTAssertEqualObjects(item.refreshToken, @"i_am_a_refresh_token");
    
}

- (void)testCache_MRRTWithIdToken_shouldSucceed
{
    ADTestLoader *loader = [[ADTestLoader alloc] initWithString:@"<Cache><MultiResourceRefreshToken token=\"i_am_a_refresh_token\" clientId=\"clientid\" authority=\"https://iamanauthority.com\" tenant=\"mytenant\" idtoken=\"eyJ0eXAiOiJKV1QiLCJhbGciOiJub25lIn0.eyJ1cG4iOiJ1c2VyQGNvbnRvc28uY29tIn0\" /></Cache>"];
    XCTAssertNotNil(loader);
    
    NSError *error = nil;
    XCTAssertTrue([loader parse:&error]);
    XCTAssertNil(error);
    
    NSArray *cache = loader.cacheItems;
    XCTAssertNotNil(cache);
    XCTAssertEqual(cache.count, 1);
    
    ADTokenCacheItem *item = cache[0];
    XCTAssertEqualObjects(item.refreshToken, @"i_am_a_refresh_token");
}

- (void)testCache_whenRefreshTokenNoAttributes_shouldFail
{
    ADTestLoader *loader = [[ADTestLoader alloc] initWithString:@"<Cache><RefreshToken/></Cache>"];
    XCTAssertNotNil(loader);
    
    NSError *error = nil;
    XCTAssertFalse([loader parse:&error]);
    XCTAssertNotNil(error);
    
    NSArray *cache = loader.cacheItems;
    XCTAssertNil(cache);
}


- (void)testCache_whenRefreshTokenNoToken_shouldFail
{
    ADTestLoader *loader = [[ADTestLoader alloc] initWithString:@"<Cache><RefreshToken resource=\"resource\" clientId=\"clientid\" authority=\"https://iamanauthority.com\" /></Cache>"];
    XCTAssertNotNil(loader);
    
    NSError *error = nil;
    XCTAssertFalse([loader parse:&error]);
    XCTAssertNotNil(error);
    
    NSArray *cache = loader.cacheItems;
    XCTAssertNil(cache);
}

- (void)testCache_whenRefreshTokenNoClientId_shouldFail
{
    ADTestLoader *loader = [[ADTestLoader alloc] initWithString:@"<Cache><RefreshToken token=\"i_am_a_refresh_token\" resource=\"resource\" authority=\"https://iamanauthority.com\" /></Cache>"];
    XCTAssertNotNil(loader);
    
    NSError *error = nil;
    XCTAssertFalse([loader parse:&error]);
    XCTAssertNotNil(error);
    
    NSArray *cache = loader.cacheItems;
    XCTAssertNil(cache);
}

- (void)testCache_whenRefreshTokenNoAuthority_shouldFail
{
    ADTestLoader *loader = [[ADTestLoader alloc] initWithString:@"<Cache><RefreshToken token=\"i_am_a_refresh_token\" resource=\"resource\" clientId=\"clientid\" /></Cache>"];
    XCTAssertNotNil(loader);
    
    NSError *error = nil;
    XCTAssertFalse([loader parse:&error]);
    XCTAssertNotNil(error);
    
    NSArray *cache = loader.cacheItems;
    XCTAssertNil(cache);
}

- (void)testCache_whenRefreshTokenAuthorityNotURL_shouldFail
{
    ADTestLoader *loader = [[ADTestLoader alloc] initWithString:@"<Cache><RefreshToken token=\"i_am_a_refresh_token\" resource=\"resource\" clientId=\"clientid\" authority=\"iamnotanauthority88(&@#@#$R12343\" /></Cache>"];
    XCTAssertNotNil(loader);
    
    NSError *error = nil;
    XCTAssertFalse([loader parse:&error]);
    XCTAssertNotNil(error);
    
    NSArray *cache = loader.cacheItems;
    XCTAssertNil(cache);
    
}

- (void)testCache_whenAccessTokenNoResource_shouldFail
{
    ADTestLoader *loader = [[ADTestLoader alloc] initWithString:@"<Cache><AccessToken token=\"i_am_a_refresh_token\" clientId=\"clientid\" authority=\"https://iamanauthority.com\" /></Cache>"];
    XCTAssertNotNil(loader);
    
    NSError *error = nil;
    XCTAssertFalse([loader parse:&error]);
    XCTAssertNotNil(error);
    
    NSArray *cache = loader.cacheItems;
    XCTAssertNil(cache);
}

- (void)testCache_whenAccessTokenNoExpiresIn_shouldDefaultTo3600
{
    ADTestLoader *loader = [[ADTestLoader alloc] initWithString:@"<Cache><AccessToken token=\"i_am_a_token\" clientId=\"clientid\" authority=\"https://iamanauthority.com\" resource=\"resource\" tenant=\"mytenant\" /></Cache>"];
    XCTAssertNotNil(loader);
    
    NSError *error = nil;
    XCTAssertTrue([loader parse:&error]);
    XCTAssertNil(error);
    
    NSArray *cache = loader.cacheItems;
    XCTAssertNotNil(cache);
    XCTAssertEqual(cache.count, 1);
    
    ADTokenCacheItem *item = cache[0];
    XCTAssertNotNil(item.expiresOn);
    XCTAssertEqualWithAccuracy(item.expiresOn.timeIntervalSinceNow, 3600.0, 5.0);
}

- (void)testCache_whenAccessTokenWithExpiresIn_shouldSucceed
{
    ADTestLoader *loader = [[ADTestLoader alloc] initWithString:@"<Cache><AccessToken token=\"i_am_a_token\" clientId=\"clientid\" authority=\"https://iamanauthority.com\" resource=\"resource\" expiresIn=\"60\" tenant=\"mytenant\" /></Cache>"];
    XCTAssertNotNil(loader);
    
    NSError *error = nil;
    XCTAssertTrue([loader parse:&error]);
    XCTAssertNil(error);
    
    NSArray *cache = loader.cacheItems;
    XCTAssertNotNil(cache);
    XCTAssertEqual(cache.count, 1);
    
    ADTokenCacheItem *item = cache[0];
    XCTAssertNotNil(item.expiresOn);
    XCTAssertEqualWithAccuracy(item.expiresOn.timeIntervalSinceNow, 60.0, 5.0);
}

- (void)testCache_whenAccessTokenWithIdToken_shouldSucceed
{
    ADTestLoader *loader = [[ADTestLoader alloc] initWithString:@"<Cache><AccessToken token=\"i_am_a_token\" clientId=\"clientid\" authority=\"https://iamanauthority.com\" resource=\"resource\" idToken=\"eyJ0eXAiOiJKV1QiLCJhbGciOiJub25lIn0.eyJ1cG4iOiJ1c2VyQGNvbnRvc28uY29tIn0\" tenant=\"mytenant\" /></Cache>"];
    XCTAssertNotNil(loader);
    
    NSError *error = nil;
    XCTAssertTrue([loader parse:&error]);
    XCTAssertNil(error);
    
    NSArray<ADTokenCacheItem *> *cache = loader.cacheItems;
    XCTAssertNotNil(cache);
    XCTAssertEqual(cache.count, 1);
    XCTAssertEqualObjects(cache[0].userInformation.userId, @"user@contoso.com");
}

- (void)testCache_whenAccessTokenWithBadIdToken_shouldFail
{
    ADTestLoader *loader = [[ADTestLoader alloc] initWithString:@"<Cache><AccessToken token=\"i_am_a_token\" clientId=\"clientid\" authority=\"https://iamanauthority.com\" resource=\"resource\" idToken=\"asdasiudhy2098134ujijsad0897ny89ashujdoiajhdsoiukjhn098sd=-0123=uji9kaosdenlkiasdlk\" tenant=\"mytenant\" /></Cache>"];
    XCTAssertNotNil(loader);
    
    NSError *error = nil;
    XCTAssertFalse([loader parse:&error]);
    XCTAssertNotNil(error);
}

#pragma mark -
#pragma mark Variable Substitutions

- (void)testCache_whenAccessTokenWithTokenSubstitution_shouldPass
{
    ADTestLoader *loader = [[ADTestLoader alloc] initWithString:@"<Cache><AccessToken token=\"$(token)\" clientId=\"clientid\" authority=\"https://iamanauthority.com\" resource=\"resource\" idToken=\"eyJ0eXAiOiJKV1QiLCJhbGciOiJub25lIn0.eyJ1cG4iOiJ1c2VyQGNvbnRvc28uY29tIn0\" tenant=\"mytenant\" /></Cache>"];
    
    loader.testVariables = [@{ @"token" : @"subaccesstoken" } mutableCopy];
    
    NSError *error = nil;
    XCTAssertTrue([loader parse:&error]);
    XCTAssertNil(error);
    
    NSArray<ADTokenCacheItem *> *cache = loader.cacheItems;
    XCTAssertNotNil(cache);
    XCTAssertEqual(cache.count, 1);
    
    ADTokenCacheItem *item = cache[0];
    XCTAssertNotNil(item);
    XCTAssertEqualObjects(item.accessToken, @"subaccesstoken");
}

- (void)testCache_whenAccessTokenWithClientIdSubstitution_shouldPass
{
    ADTestLoader *loader = [[ADTestLoader alloc] initWithString:@"<Cache><AccessToken token=\"i_am_a_token\" clientId=\"$(clientId)\" authority=\"https://iamanauthority.com\" resource=\"resource\" idToken=\"eyJ0eXAiOiJKV1QiLCJhbGciOiJub25lIn0.eyJ1cG4iOiJ1c2VyQGNvbnRvc28uY29tIn0\" tenant=\"mytenant\" /></Cache>"];
    
    loader.testVariables = [@{ @"clientId" : @"subclientid" } mutableCopy];
    
    NSError *error = nil;
    XCTAssertTrue([loader parse:&error]);
    XCTAssertNil(error);
    
    NSArray<ADTokenCacheItem *> *cache = loader.cacheItems;
    XCTAssertNotNil(cache);
    XCTAssertEqual(cache.count, 1);
    
    ADTokenCacheItem *item = cache[0];
    XCTAssertNotNil(item);
    XCTAssertEqualObjects(item.clientId, @"subclientid");
}

- (void)testCache_whenAccessTokenWithAuthoritySubstitution_shouldPass
{
    ADTestLoader *loader = [[ADTestLoader alloc] initWithString:@"<Cache><AccessToken token=\"i_am_a_token\" clientId=\"clientid\" authority=\"$(authority)\" resource=\"resource\" idToken=\"eyJ0eXAiOiJKV1QiLCJhbGciOiJub25lIn0.eyJ1cG4iOiJ1c2VyQGNvbnRvc28uY29tIn0\" tenant=\"mytenant\" /></Cache>"];
    
    loader.testVariables = [@{ @"authority" : @"https://subauthority.com"} mutableCopy];
    
    NSError *error = nil;
    XCTAssertTrue([loader parse:&error]);
    XCTAssertNil(error);
    
    NSArray<ADTokenCacheItem *> *cache = loader.cacheItems;
    XCTAssertNotNil(cache);
    XCTAssertEqual(cache.count, 1);
    
    ADTokenCacheItem *item = cache[0];
    XCTAssertNotNil(item);
    XCTAssertEqualObjects(item.authority, @"https://subauthority.com");
}

- (void)testCache_whenAccessTokenWithResourceSubstitution_shouldPass
{
    ADTestLoader *loader = [[ADTestLoader alloc] initWithString:@"<Cache><AccessToken token=\"i_am_a_token\" clientId=\"clientid\" authority=\"https://iamanauthority.com\" resource=\"$(resource)\" idToken=\"eyJ0eXAiOiJKV1QiLCJhbGciOiJub25lIn0.eyJ1cG4iOiJ1c2VyQGNvbnRvc28uY29tIn0\" tenant=\"mytenant\" /></Cache>"];
    
    loader.testVariables = [@{ @"resource" : @"subresource" } mutableCopy];
    
    NSError *error = nil;
    XCTAssertTrue([loader parse:&error]);
    XCTAssertNil(error);
    
    NSArray<ADTokenCacheItem *> *cache = loader.cacheItems;
    XCTAssertNotNil(cache);
    XCTAssertEqual(cache.count, 1);
    
    ADTokenCacheItem *item = cache[0];
    XCTAssertNotNil(item);
    XCTAssertEqualObjects(item.resource, @"subresource");
}

- (void)testCache_whenAccessTokenWithIdTokenVariableSubstitution_shouldSucceed
{
    ADTestLoader *loader = [[ADTestLoader alloc] initWithString:@"<Cache><AccessToken token=\"i_am_a_token\" clientId=\"clientid\" authority=\"https://iamanauthority.com\" resource=\"resource\" idToken=\"$(idtoken)\" tenant=\"mytenant\" /></Cache>"];
    
    loader.testVariables = [@{ @"idtoken" : @"eyJ0eXAiOiJKV1QiLCJhbGciOiJub25lIn0.eyJ1cG4iOiJ1c2VyQGNvbnRvc28uY29tIn0"} mutableCopy];
    
    NSError *error = nil;
    XCTAssertTrue([loader parse:&error]);
    XCTAssertNil(error);
    
    NSArray<ADTokenCacheItem *> *cache = loader.cacheItems;
    XCTAssertNotNil(cache);
    XCTAssertEqual(cache.count, 1);
    XCTAssertEqualObjects(cache[0].userInformation.userId, @"user@contoso.com");
}


- (void)testCache_whenAccessTokenWithTenantSubstitution_shouldPass
{
    ADTestLoader *loader = [[ADTestLoader alloc] initWithString:@"<Cache><AccessToken token=\"i_am_a_token\" clientId=\"clientid\" authority=\"https://iamanauthority.com\" resource=\"resource\" idToken=\"eyJ0eXAiOiJKV1QiLCJhbGciOiJub25lIn0.eyJ1cG4iOiJ1c2VyQGNvbnRvc28uY29tIn0\" tenant=\"$(tenant)\" /></Cache>"];
    
    loader.testVariables = [@{ @"tenant" : @"subtenant" } mutableCopy];
    
    NSError *error = nil;
    XCTAssertTrue([loader parse:&error]);
    XCTAssertNil(error);
    
    NSArray<ADTokenCacheItem *> *cache = loader.cacheItems;
    XCTAssertNotNil(cache);
    XCTAssertEqual(cache.count, 1);
    
    // Tenant doesn't get used in objC so we don't have anything to check for here, other platforms will want to check.
}

- (void)testCache_whenAccessTokenWithExpiresInSubstitution_shouldPass
{
    ADTestLoader *loader = [[ADTestLoader alloc] initWithString:@"<Cache><AccessToken token=\"i_am_a_token\" clientId=\"clientid\" authority=\"https://iamanauthority.com\" resource=\"resource\" idToken=\"eyJ0eXAiOiJKV1QiLCJhbGciOiJub25lIn0.eyJ1cG4iOiJ1c2VyQGNvbnRvc28uY29tIn0\" tenant=\"mytenant\" expiresIn=\"$(expiresIn)\" /></Cache>"];
    
    loader.testVariables = [@{ @"expiresIn" : @"90" } mutableCopy];
    
    NSError *error = nil;
    XCTAssertTrue([loader parse:&error]);
    XCTAssertNil(error);
    
    NSArray<ADTokenCacheItem *> *cache = loader.cacheItems;
    XCTAssertNotNil(cache);
    XCTAssertEqual(cache.count, 1);
    
    ADTokenCacheItem *item = cache[0];
    XCTAssertNotNil(item);
    XCTAssertEqualWithAccuracy(item.expiresOn.timeIntervalSinceNow, 90.0, 5.0);
}

@end
