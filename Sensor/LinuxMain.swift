import XCTest

import SensorTestUnitTests
import SensorUnitTests

var tests = [XCTestCaseEntry]()
tests += SensorTestUnitTests.__allTests()
tests += SensorUnitTests.__allTests()

XCTMain(tests)
