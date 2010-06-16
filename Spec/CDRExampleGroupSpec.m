#import <Cedar/SpecHelper.h>
#import <OCMock/OCMock.h>
#import "CDRExampleGroup.h"
#import "CDRExample.h"

#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

SPEC_BEGIN(CDRExampleGroupSpec)

describe(@"CDRExampleGroup", ^{
    __block CDRExampleGroup *group;

    beforeEach(^{
        group = [[CDRExampleGroup alloc] initWithText:@"a group"];
    });

    afterEach(^{
        [group release];
    });

    describe(@"state", ^{
        describe(@"for a group containing no examples", ^{
            beforeEach(^{
                assertThatInt([[group examples] count], equalToInt(0));
            });

            it(@"should be CDRExampleStatePassed", ^{
                assertThatInt([group state], equalToInt(CDRExampleStatePassed));
            });
        });

        describe(@"for a group containing at least one incomplete example", ^{
            beforeEach(^{
                CDRExample *incompleteExample = [[CDRExample alloc] initWithText:@"incomplete" andBlock:^{}];
                [group add:incompleteExample];
                [incompleteExample release];
            });

            it(@"should be CDRExampleStateIncomplete", ^{
                assertThatInt([group state], equalToInt(CDRExampleStateIncomplete));
            });
        });

        describe(@"for a group containing only complete examples", ^{
            describe(@"with only passing examples", ^{
                beforeEach(^{
                    CDRExample *passingExample = [[CDRExample alloc] initWithText:@"I should pass" andBlock:^{}];
                    [group add:passingExample];
                    [passingExample release];

                    [passingExample runWithRunner:nil];
                });

                it(@"should be CDRExampleStatePassed", ^{
                    assertThatInt([group state], equalToInt(CDRExampleStatePassed));
                });
            });

            describe(@"with only failing examples", ^{
                it(@"should be CDRExampleStateFailed", PENDING);
            });

            describe(@"with only pending examples", ^{
                it(@"should be CDRExampleStatePending", PENDING);
            });

            describe(@"with only error examples", ^{
                it(@"should be CDRExampleStateError", PENDING);
            });

            describe(@"with at least one failing example", ^{
                describe(@"with all other examples passing", ^{
                    it(@"should be CDRExampleStateFailed", PENDING);
                });

                describe(@"with at least one pending example", ^{
                    it(@"should be CDRExampleStateFailed", PENDING);
                });
            });

            describe(@"with at least one error example", ^{
                describe(@"with all other examples passing", ^{
                    it(@"should be CDRExampleStateError", PENDING);
                });

                describe(@"with at least one failing example", ^{
                    it(@"should be CDRExampleStateError", PENDING);
                });

                describe(@"with at least one pending example", ^{
                    it(@"should be CDRExampleStateError", PENDING);
                });
            });

            describe(@"with at least one pending example", ^{
                describe(@"with all other examples passing", ^{
                    it(@"should be CDRExampleStatePending", PENDING);
                });
            });
        });

        describe(@"KVO", ^{
            __block id mockObserver;

            describe(@"when a child changes state, causing the group to change state", ^{
                __block CDRExample *example;

                beforeEach(^{
                    example = [[CDRExample alloc] initWithText:@"I should pass" andBlock:^{}];
                    [group add:example];
                    [example release];

                    mockObserver = [OCMockObject niceMockForClass:[NSObject class]];
                    [[mockObserver expect] observeValueForKeyPath:@"state" ofObject:group change:[OCMArg any] context:NULL];
                });

                it(@"should report that the state has changed", ^{
                    [group addObserver:mockObserver forKeyPath:@"state" options:0 context:NULL];
                    [example runWithRunner:nil];
                    [group removeObserver:mockObserver forKeyPath:@"state"];

                    [mockObserver verify];
                });
            });

            describe(@"when a child's child changes state, causing the child to change state, causing the group to change state", ^{
                __block CDRExampleGroup *subgroup;
                __block CDRExample *example;

                beforeEach(^{
                    subgroup = [[CDRExampleGroup alloc] initWithText:@"subgroup"];
                    [group add:subgroup];
                    [subgroup release];

                    example = [[CDRExample alloc] initWithText:@"I should pass" andBlock:^{}];
                    [subgroup add:example];
                    [example release];

                    mockObserver = [OCMockObject niceMockForClass:[NSObject class]];
                    [[mockObserver expect] observeValueForKeyPath:@"state" ofObject:group change:[OCMArg any] context:NULL];
                });

                it(@"should report that the state has changed", ^{
                    [group addObserver:mockObserver forKeyPath:@"state" options:0 context:NULL];
                    [example runWithRunner:nil];
                    [group removeObserver:mockObserver forKeyPath:@"state"];

                    [mockObserver verify];
                });
            });

            describe(@"when a child example changes state, but the group state does not change", ^{
                it(@"should not report that the state has changed", PENDING);
            });
        });
    });

    describe(@"progress", ^{
        // !!!
    });
});

SPEC_END