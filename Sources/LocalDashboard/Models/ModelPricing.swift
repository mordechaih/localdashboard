import Foundation

struct ModelPricing {
    let contextWindow: Int
    let inputPerMTok: Double
    let outputPerMTok: Double

    static func forModel(_ model: String) -> ModelPricing {
        let m = model.lowercased()
        if m.contains("opus") {
            return ModelPricing(contextWindow: 1_000_000, inputPerMTok: 5.0, outputPerMTok: 25.0)
        } else if m.contains("haiku") {
            return ModelPricing(contextWindow: 200_000, inputPerMTok: 1.0, outputPerMTok: 5.0)
        } else {
            return ModelPricing(contextWindow: 1_000_000, inputPerMTok: 3.0, outputPerMTok: 15.0)
        }
    }
}

struct TokenUsage: Sendable {
    let model: String
    let inputTokens: Int
    let cacheCreationInputTokens: Int
    let cacheReadInputTokens: Int
    let outputTokens: Int
}

func cost(for usage: TokenUsage) -> Double {
    let pricing = ModelPricing.forModel(usage.model)
    let inputCost = Double(usage.inputTokens) / 1_000_000 * pricing.inputPerMTok
    let cacheWriteCost = Double(usage.cacheCreationInputTokens) / 1_000_000 * pricing.inputPerMTok * 1.25
    let cacheReadCost = Double(usage.cacheReadInputTokens) / 1_000_000 * pricing.inputPerMTok * 0.1
    let outputCost = Double(usage.outputTokens) / 1_000_000 * pricing.outputPerMTok
    return inputCost + cacheWriteCost + cacheReadCost + outputCost
}

func contextUsedPercent(model: String, totalContextTokens: Int) -> Int {
    let pricing = ModelPricing.forModel(model)
    let pct = Double(totalContextTokens) / Double(pricing.contextWindow) * 100
    return min(100, Int(pct.rounded()))
}
