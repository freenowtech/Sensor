//
//  AssertDSLProtocol.swift
//  SensorTest
//
//  Created by Ferran Pujol Camins on 14/08/2019.
//  Copyright © 2019 Intelligent Apps GmbH. All rights reserved.
//

import RxSwift

/// This protocol specifies the assertion methods that are available
///
/// We use it to ensure all methods are available as a first assertion (SensorTestCase) or subsequent assertion (TestMethod).
public protocol AssertionDSLProtocol {
    func assert<V>(preassertion: @escaping PreAssertion<V>, assertion: @escaping Assertion<V>) -> SensorTest.TestMethod

    func assert<O>(_ subject: O,
                   isEqualTo definition: (timeline: String, values: [String : O.Element]),
                   file: StaticString,
                   line: UInt) -> SensorTest.TestMethod where O : ObservableConvertibleType, O.Element : Equatable

    func assert<O>(_ subject: O,
                   isEqualTo definition: (timeline: String, values: [String : O.Element], errors: [String : Error]),
                   file: StaticString,
                   line: UInt) -> SensorTest.TestMethod where O : ObservableConvertibleType, O.Element : Equatable

    func assert<O>(_ subject: O,
                   isEqualTo definition: (timeline: String, values: [String : O.Element], expectations: Expectations),
                   file: StaticString,
                   line: UInt) -> SensorTest.TestMethod where O : ObservableConvertibleType, O.Element : Equatable

    func assert<O>(_ subject: O,
                   isEqualTo definition: (timeline: String, values: [String : O.Element], errors: [String : Error], expectations: Expectations),
                   file: StaticString,
                   line: UInt) -> SensorTest.TestMethod where O : ObservableConvertibleType, O.Element : Equatable

    func assert<O>(_ observable: O,
                   isEqualToTimeline expectedTimeline: String,
                   withValues values: [String : O.Element],
                   errors: [String : Error],
                   andExpectations expectations: Expectations,
                   file: StaticString,
                   line: UInt) -> TestMethod where O: ObservableConvertibleType, O.Element: Equatable
}
