//
//  SPiDTokenStorageTests.m
//  SPiDSDK
//
//  Created by Daniel Lazarenko on 09/03/2017.
//

#import <XCTest/XCTest.h>
#import "SPiDTokenStorageUserDefaultsBackend.h"
#import "SPiDAccessToken.h"
#import "SPiDTokenStorage.h"

@interface SPiDTokenStorageTests : XCTestCase
{
    NSUserDefaults *_defaults1;
    id<SPiDTokenStorageBackend> _backend1;
    NSUserDefaults *_defaults2;
    id<SPiDTokenStorageBackend> _backend2;
    NSDictionary<NSNumber *, id<SPiDTokenStorageBackend>> *_backends;
}

@property (readonly) NSDate *expectedExpiresAt;
@property (readonly) NSString *tokenIdentifier;

@end

@implementation SPiDTokenStorageTests

NSUserDefaults *SPiDSDKTestsCreateFreshUserDefaults(void);

- (void)setUp
{
    [super setUp];
    _defaults1 = SPiDSDKTestsCreateFreshUserDefaults(@"xctest1");
    _backend1 = [[SPiDTokenStorageUserDefaultsBackend alloc] initWithUserDefaults:_defaults1];
    _defaults2 = SPiDSDKTestsCreateFreshUserDefaults(@"xctest2");
    _backend2 = [[SPiDTokenStorageUserDefaultsBackend alloc] initWithUserDefaults:_defaults2];
    _backends = @{
        @(SPiDTokenStorageBackendTypeKeychain): _backend1,
        @(SPiDTokenStorageBackendTypeUserDefaults): _backend2,
    };
}

- (SPiDAccessToken *)createExpectedToken
{
    return [[SPiDAccessToken alloc] initWithUserID:@"uid123" accessToken:@"at234"
                                         expiresAt:[NSDate dateWithTimeIntervalSinceReferenceDate:555]
                                      refreshToken:@"rt345"];
}

- (NSString *)tokenIdentifier
{
    return @"AccessToken";
}

- (void)testBackendsAreCleanAfterSetUp
{
    XCTAssertNil([_backend1 accessTokenForIdentifier:self.tokenIdentifier]);
    XCTAssertNil([_backend2 accessTokenForIdentifier:self.tokenIdentifier]);
}

- (void)testLoadsSomeTokenAfterStoring
{
    SPiDTokenStorage *storage = [[SPiDTokenStorage alloc] initWithReadBackendTypes:@[ @(SPiDTokenStorageBackendTypeKeychain) ]
                                                                 writeBackendTypes:@[ @(SPiDTokenStorageBackendTypeKeychain) ]
                                                                          backends:_backends];
    [storage storeAccessTokenWithValue:[self createExpectedToken]];
    SPiDAccessToken *token = [storage loadAccessTokenAndReplicate];
    XCTAssertNotNil(token);
}

- (void)testStoreToOnlyOneWriteBackend
{
    SPiDTokenStorage *storage = [[SPiDTokenStorage alloc] initWithReadBackendTypes:@[ @(SPiDTokenStorageBackendTypeKeychain) ]
                                                                 writeBackendTypes:@[ @(SPiDTokenStorageBackendTypeKeychain) ]
                                                                          backends:_backends];
    [storage storeAccessTokenWithValue:[self createExpectedToken]];
    XCTAssertNotNil([_backend1 accessTokenForIdentifier:self.tokenIdentifier]);
    XCTAssertNil([_backend2 accessTokenForIdentifier:self.tokenIdentifier]);
}

- (void)testWriteToBothBackends
{
    SPiDTokenStorage *storage = [[SPiDTokenStorage alloc] initWithReadBackendTypes:@[ @(SPiDTokenStorageBackendTypeKeychain) ]
                                                                 writeBackendTypes:@[ @(SPiDTokenStorageBackendTypeKeychain), @(SPiDTokenStorageBackendTypeUserDefaults) ]
                                                                          backends:_backends];
    [storage storeAccessTokenWithValue:[self createExpectedToken]];
    XCTAssertNotNil([_backend1 accessTokenForIdentifier:self.tokenIdentifier]);
    XCTAssertNotNil([_backend2 accessTokenForIdentifier:self.tokenIdentifier]);
    SPiDAccessToken *token = [storage loadAccessTokenAndReplicate];
    XCTAssertNotNil(token);
}

- (void)testReplicateAfterReading
{
    SPiDTokenStorage *storageOnly1 = [[SPiDTokenStorage alloc] initWithReadBackendTypes:@[ @(SPiDTokenStorageBackendTypeKeychain) ]
                                                                      writeBackendTypes:@[ @(SPiDTokenStorageBackendTypeKeychain) ]
                                                                               backends:_backends];
    [storageOnly1 storeAccessTokenWithValue:[self createExpectedToken]];
    [storageOnly1 loadAccessTokenAndReplicate];
    XCTAssertNil([_backend2 accessTokenForIdentifier:self.tokenIdentifier]);

    SPiDTokenStorage *storageWriteBoth = [[SPiDTokenStorage alloc] initWithReadBackendTypes:@[ @(SPiDTokenStorageBackendTypeKeychain) ]
                                                                          writeBackendTypes:@[ @(SPiDTokenStorageBackendTypeKeychain), @(SPiDTokenStorageBackendTypeUserDefaults) ]
                                                                                   backends:_backends];
    SPiDAccessToken *token = [storageWriteBoth loadAccessTokenAndReplicate];
    XCTAssertNotNil(token);
    XCTAssertNotNil([_backend1 accessTokenForIdentifier:self.tokenIdentifier]);
    XCTAssertNotNil([_backend2 accessTokenForIdentifier:self.tokenIdentifier]);
}

- (void)testCleanupAfterReadingBackup
{
    SPiDTokenStorage *storageOnlyBackup = [[SPiDTokenStorage alloc] initWithReadBackendTypes:@[ @(SPiDTokenStorageBackendTypeUserDefaults) ]
                                                                           writeBackendTypes:@[ @(SPiDTokenStorageBackendTypeUserDefaults) ]
                                                                                    backends:_backends];
    [storageOnlyBackup storeAccessTokenWithValue:[self createExpectedToken]];
    XCTAssertNil([_backend1 accessTokenForIdentifier:self.tokenIdentifier]);
    XCTAssertNotNil([_backend2 accessTokenForIdentifier:self.tokenIdentifier]);

    SPiDTokenStorage *storageReadBackup = [[SPiDTokenStorage alloc] initWithReadBackendTypes:@[ @(SPiDTokenStorageBackendTypeKeychain), @(SPiDTokenStorageBackendTypeUserDefaults) ]
                                                                           writeBackendTypes:@[ @(SPiDTokenStorageBackendTypeKeychain) ]
                                                                                    backends:_backends];
    SPiDAccessToken *token = [storageReadBackup loadAccessTokenAndReplicate];
    XCTAssertNotNil(token);
    XCTAssertNotNil([_backend1 accessTokenForIdentifier:self.tokenIdentifier]);
    XCTAssertNil([_backend2 accessTokenForIdentifier:self.tokenIdentifier]);
}

- (void)testRemovalFromAllBackends
{
    SPiDTokenStorage *storage = [[SPiDTokenStorage alloc] initWithReadBackendTypes:@[ @(SPiDTokenStorageBackendTypeKeychain) ]
                                                                 writeBackendTypes:@[ @(SPiDTokenStorageBackendTypeKeychain), @(SPiDTokenStorageBackendTypeUserDefaults) ]
                                                                          backends:_backends];
    [storage storeAccessTokenWithValue:[self createExpectedToken]];
    [storage removeAccessToken];
    XCTAssertNil([_backend1 accessTokenForIdentifier:self.tokenIdentifier]);
    XCTAssertNil([_backend2 accessTokenForIdentifier:self.tokenIdentifier]);
    SPiDAccessToken *token = [storage loadAccessTokenAndReplicate];
    XCTAssertNil(token);
}

- (void)testFullMigrationScenario
{
    // logged in app state
    SPiDTokenStorage *storageOnly1 = [[SPiDTokenStorage alloc] initWithReadBackendTypes:@[ @(SPiDTokenStorageBackendTypeKeychain) ]
                                                                      writeBackendTypes:@[ @(SPiDTokenStorageBackendTypeKeychain) ]
                                                                               backends:@{ @(SPiDTokenStorageBackendTypeKeychain): _backend1 }];
    [storageOnly1 storeAccessTokenWithValue:[self createExpectedToken]];

    // update 1: replicate to backup
    SPiDTokenStorage *storageWriteBoth = [[SPiDTokenStorage alloc] initWithReadBackendTypes:@[ @(SPiDTokenStorageBackendTypeKeychain) ]
                                                                          writeBackendTypes:@[ @(SPiDTokenStorageBackendTypeKeychain), @(SPiDTokenStorageBackendTypeUserDefaults) ]
                                                                                   backends:_backends];
    [storageWriteBoth loadAccessTokenAndReplicate];

    // update 2: move to the new account
    [storageOnly1 removeAccessToken];
    SPiDTokenStorage *storageReadBackup = [[SPiDTokenStorage alloc] initWithReadBackendTypes:@[ @(SPiDTokenStorageBackendTypeKeychain), @(SPiDTokenStorageBackendTypeUserDefaults) ]
                                                                           writeBackendTypes:@[ @(SPiDTokenStorageBackendTypeKeychain) ]
                                                                                    backends:_backends];
    [storageReadBackup loadAccessTokenAndReplicate];

    // update 3: back to keychain only
    XCTAssertNotNil([_backend1 accessTokenForIdentifier:self.tokenIdentifier]);
    XCTAssertNil([_backend2 accessTokenForIdentifier:self.tokenIdentifier]);
    SPiDAccessToken *token = [storageOnly1 loadAccessTokenAndReplicate];
    XCTAssertNotNil(token);
}

@end
