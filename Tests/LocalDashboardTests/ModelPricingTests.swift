import XCTest
@testable import LocalDashboard

final class ModelPricingTests: XCTestCase {
    func testSonnetCostAndPercent() {
        let usage = TokenUsage(
            model: "claude-sonnet-5",
            inputTokens: 2,
            cacheCreationInputTokens: 67,
            cacheReadInputTokens: 67535,
            outputTokens: 1301
        )
        XCTAssertEqual(cost(for: usage), 0.040032750000000006, accuracy: 0.0000001)
        XCTAssertEqual(
            contextUsedPercent(model: usage.model, totalContextTokens: 2 + 67 + 67535 + 1301),
            7
        )
    }

    func testOpusCostAndPercent() {
        let usage = TokenUsage(
            model: "claude-opus-4-8",
            inputTokens: 100_000,
            cacheCreationInputTokens: 0,
            cacheReadInputTokens: 500_000,
            outputTokens: 20_000
        )
        XCTAssertEqual(cost(for: usage), 1.25, accuracy: 0.0000001)
        XCTAssertEqual(contextUsedPercent(model: usage.model, totalContextTokens: 620_000), 62)
    }

    func testHaikuHasSmallerContextWindow() {
        XCTAssertEqual(ModelPricing.forModel("claude-haiku-4-5").contextWindow, 200_000)
    }

    func testPercentClampsAt100() {
        XCTAssertEqual(contextUsedPercent(model: "claude-sonnet-5", totalContextTokens: 2_000_000), 100)
    }
}
