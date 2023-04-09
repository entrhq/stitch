import XCTest
import Combine

extension Publisher {
    /// Helper method for waiting for publisher completion and asserting its results
    ///
    /// Completes the expectation in the onCompletion handler of the sink
    /// and forwards the received value and error value to
    /// their respective completion closures for use in the test.
    public func sinkToExpectation(
        _ expectation: XCTestExpectation,
        valueCompletion: @escaping (Output) -> Void,
        failureCompletion: @escaping (Failure) -> Void
    ) -> AnyCancellable {
        self.sink(receiveCompletion: { completion in
            switch completion {
            case .finished:
                break
            case .failure(let err):
                failureCompletion(err)
            }
            
            expectation.fulfill()
        }, receiveValue: { response in
            valueCompletion(response)
        })
    }
}

extension Publisher where Failure == Never {
    /// Helper method for waiting for publisher completion and asserting its results
    ///
    /// Completes the expectation in the onCompletion handler of the sink
    /// and forwards the received value to the value closure
    public func sinkToExpectation(
        _ expectation: XCTestExpectation,
        valueCompletion: @escaping (Output) -> Void
    ) -> AnyCancellable {
        self.sink { response in
            valueCompletion(response)
        }
    }
}
