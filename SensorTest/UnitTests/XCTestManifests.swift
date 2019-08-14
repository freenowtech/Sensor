#if !canImport(ObjectiveC)
import XCTest

extension AssertionTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__AssertionTests = [
        ("testCompletionSuccess", testCompletionSuccess),
        ("testCompletionWithEventSuccess", testCompletionWithEventSuccess),
        ("testDifferentLengthTimeline", testDifferentLengthTimeline),
        ("testDifferentObjectSubValue", testDifferentObjectSubValue),
        ("testDifferentSubSubValue", testDifferentSubSubValue),
        ("testDifferentSubValue", testDifferentSubValue),
        ("testDifferentSubValueAndTimeline", testDifferentSubValueAndTimeline),
        ("testDifferentValue", testDifferentValue),
        ("testDifferentValueWithWhiteSpace", testDifferentValueWithWhiteSpace),
        ("testEnumSubvalues", testEnumSubvalues),
        ("testMissingCompletion", testMissingCompletion),
        ("testMissingCompletionWithEvent", testMissingCompletionWithEvent),
        ("testMissingEvents", testMissingEvents),
        ("testMissingUnknownError", testMissingUnknownError),
        ("testMissingUnknownErrorWithEvent", testMissingUnknownErrorWithEvent),
        ("testSameTimelineDifferentEventNames", testSameTimelineDifferentEventNames),
        ("testSeveralEventsSameTimeAssertionSuccessful", testSeveralEventsSameTimeAssertionSuccessful),
        ("testSeveralEventsSameTimeDifferentEvents", testSeveralEventsSameTimeDifferentEvents),
        ("testSeveralEventsSameTimeMissingEvent", testSeveralEventsSameTimeMissingEvent),
        ("testSeveralEventsSameTimeSeveralGroupsAssertionSuccessful", testSeveralEventsSameTimeSeveralGroupsAssertionSuccessful),
        ("testSeveralEventsSameTimeSeveralGroupsMissingElement", testSeveralEventsSameTimeSeveralGroupsMissingElement),
        ("testSeveralEventsSameTimeUnexpectedEvent", testSeveralEventsSameTimeUnexpectedEvent),
        ("testUnexpectedCompletion", testUnexpectedCompletion),
        ("testUnexpectedCompletionWithEvent", testUnexpectedCompletionWithEvent),
        ("testUnexpectedEvents", testUnexpectedEvents),
        ("testUnexpectedUnknownError", testUnexpectedUnknownError),
        ("testUnexpectedUnknownErrorWithEvent", testUnexpectedUnknownErrorWithEvent),
        ("testUnknownErrorMatchesAnyError", testUnknownErrorMatchesAnyError),
        ("testUnknownErrorMatchesAnyErrorWithOtherEvents", testUnknownErrorMatchesAnyErrorWithOtherEvents),
        ("testUnknownErrorSuccess", testUnknownErrorSuccess),
        ("testUnkownErrorWithEventSuccess", testUnkownErrorWithEventSuccess),
    ]
}

extension RandomAssertionTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__RandomAssertionTests = [
        ("testRandomTimeline", testRandomTimeline),
    ]
}

extension TimelineTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__TimelineTests = [
        ("testCompleted", testCompleted),
        ("testEmptyTimeline", testEmptyTimeline),
        ("testError", testError),
        ("testUnkownError", testUnkownError),
        ("testValues", testValues),
        ("testValuesAtSameTime", testValuesAtSameTime),
        ("testValuesAtSameTimeWithCompletion", testValuesAtSameTimeWithCompletion),
    ]
}

public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(AssertionTests.__allTests__AssertionTests),
        testCase(RandomAssertionTests.__allTests__RandomAssertionTests),
        testCase(TimelineTests.__allTests__TimelineTests),
    ]
}
#endif
