import XCTest
@testable import LocalDashboard

private struct FakeTokenProvider: KeychainTokenProviding {
    let token: String?
    func fetchOAuthToken() -> String? { token }
}

final class UsageWindowFetcherTests: XCTestCase {
    func testReturnsNilWhenNoToken() async {
        let dataTask: DataTaskFunc = { _ in (Data(), URLResponse()) }
        let result = await fetchUsageWindow(tokenProvider: FakeTokenProvider(token: nil), dataTask: dataTask)
        XCTAssertNil(result)
    }

    func testParsesSuccessfulResponse() async {
        let json = #"{"extra_usage":{"used_credits":1000,"monthly_limit":5000,"utilization":20.0}}"#
        let dataTask: DataTaskFunc = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (json.data(using: .utf8)!, response)
        }
        let result = await fetchUsageWindow(tokenProvider: FakeTokenProvider(token: "tok"), dataTask: dataTask)
        XCTAssertEqual(result?.usedPercent, 20)
    }

    func testReturnsNilOnNon200Status() async {
        let dataTask: DataTaskFunc = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 401, httpVersion: nil, headerFields: nil)!
            return (Data(), response)
        }
        let result = await fetchUsageWindow(tokenProvider: FakeTokenProvider(token: "tok"), dataTask: dataTask)
        XCTAssertNil(result)
    }

    func testReturnsNilWhenDataTaskThrows() async {
        struct FetchError: Error {}
        let dataTask: DataTaskFunc = { _ in throw FetchError() }
        let result = await fetchUsageWindow(tokenProvider: FakeTokenProvider(token: "tok"), dataTask: dataTask)
        XCTAssertNil(result)
    }
}
