//
//  OCMockito - MockingProgressTest.m
//  Copyright 2011 Jonathan M. Reid. See LICENSE.txt
//

    // Class under test
#import "MKTMockingProgress.h"

    // Collaborators
#import "MKTExactTimes.h"
#import "MKTInvocationContainer.h"
#import "MKTInvocationMatcher.h"
#import "MKTOngoingStubbing.h"

    // Test support
#import <SenTestingKit/SenTestingKit.h>

#define HC_SHORTHAND
#import <OCHamcrestIOS/OCHamcrestIOS.h>


@interface MockingProgressTest : SenTestCase
{
    MKTMockingProgress *mockingProgress;
}
@end


@implementation MockingProgressTest

- (void)setUp
{
    [super setUp];
    mockingProgress = [[MKTMockingProgress alloc] init];
}

- (void)tearDown
{
    [mockingProgress release];
    [super tearDown];
}

- (void)testPullOngoingStubbingWithoutStubbingReportedShouldBeNil
{
    assertThat([mockingProgress pullOngoingStubbing], is(nilValue()));
}

- (void)testPullOngoingStubbingWithStubbingReportedShouldReturnStubbing
{
    // given
    MKTInvocationContainer *invocationContainer = [[[MKTInvocationContainer alloc]
                                                   initWithMockingProgress:mockingProgress] autorelease];
    MKTOngoingStubbing *ongoingStubbing = [[[MKTOngoingStubbing alloc]
                                           initWithInvocationContainer:invocationContainer] autorelease];
    
    // when
    [mockingProgress reportOngoingStubbing:ongoingStubbing];
    
    // then
    assertThat([mockingProgress pullOngoingStubbing], is(sameInstance(ongoingStubbing)));
}

- (void)testPullOngoingStubbingShouldClearCurrentStubbing
{
    // given
    MKTInvocationContainer *invocationContainer = [[[MKTInvocationContainer alloc]
                                                   initWithMockingProgress:mockingProgress] autorelease];
    MKTOngoingStubbing *ongoingStubbing = [[[MKTOngoingStubbing alloc]
                                           initWithInvocationContainer:invocationContainer] autorelease];
    
    // when
    [mockingProgress reportOngoingStubbing:ongoingStubbing];
    [mockingProgress pullOngoingStubbing];
    
    // then
    assertThat([mockingProgress pullOngoingStubbing], is(nilValue()));
}

- (void)testPullVerificationModeWithoutVerificationStartedShouldBeNil
{
    assertThat([mockingProgress pullVerificationMode], is(nilValue()));
}

- (void)testPullVerificationModeWithVerificationStartedShouldReturnMode
{
    // given
    id <MKTVerificationMode> mode = [MKTExactTimes timesWithCount:42];
    
    // when
    [mockingProgress verificationStarted:mode atLocation:MKTTestLocationMake(self, __FILE__, __LINE__)];
    
    // then
    assertThat([mockingProgress pullVerificationMode], is(sameInstance(mode)));
}

- (void)testPullVerificationModeShouldClearCurrentVerification
{
    // given
    id <MKTVerificationMode> mode = [MKTExactTimes timesWithCount:42];
    
    // when
    [mockingProgress verificationStarted:mode atLocation:MKTTestLocationMake(self, __FILE__, __LINE__)];
    [mockingProgress pullVerificationMode];
    
    // then
    assertThat([mockingProgress pullVerificationMode], is(nilValue()));
}

- (void)testPullInvocationMatcherWithoutSettingMatchersShouldBeNil
{
    assertThat([mockingProgress pullInvocationMatcher], is(nilValue()));
}

- (void)testPullInvocationMatcherAfterSettingMatchersShouldHaveThoseMatchers
{
    // given
    [mockingProgress setMatcher:equalTo(@"irrelevant") forArgument:1];
    
    // when
    MKTInvocationMatcher *invocationMatcher = [mockingProgress pullInvocationMatcher];
    
    // then
    assertThatUnsignedInteger([invocationMatcher argumentMatchersCount], equalToUnsignedInteger(4));
}

- (void)testPullInvocationMatcherShouldClearCurrentMatcher
{
    // given
    [mockingProgress setMatcher:equalTo(@"irrelevant") forArgument:3];

    // when
    [mockingProgress pullInvocationMatcher];
    
    // then
    assertThat([mockingProgress pullInvocationMatcher], is(nilValue()));
}

- (void)testMoreThanOneSetMatcherShouldAccumulate
{
    // given
    [mockingProgress setMatcher:equalTo(@"irrelevant") forArgument:1];
    [mockingProgress setMatcher:equalTo(@"irrelevant") forArgument:0];

    // when
    MKTInvocationMatcher *invocationMatcher = [mockingProgress pullInvocationMatcher];
    
    // then
    assertThatUnsignedInteger([invocationMatcher argumentMatchersCount], equalToUnsignedInteger(4));
}

@end
