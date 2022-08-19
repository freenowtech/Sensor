import Foundation

public struct Definition<Value> {
    let timeline: String
    let values: [String: Value]
    let errors: [String: Error]
    let expectations: Expectations

    public init(timeline: String, values: [String: Value] = [:], errors: [String: Error] = [:], expectations: Expectations = [:]) {
        self.timeline = timeline
        self.values = values
        self.errors = errors
        self.expectations = expectations
    }

    public func map<NewValue>(_ transform: (Value) -> NewValue) -> Definition<NewValue> {
        return Definition<NewValue>(
            timeline: timeline,
            values: values.mapValues(transform),
            errors: errors,
            expectations: expectations)
    }
}
