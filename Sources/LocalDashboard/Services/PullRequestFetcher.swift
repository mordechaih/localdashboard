import Foundation

func fetchPullRequests(runner: ProcessRunning) -> [PullRequestInfo]? {
    guard let searchOutput = runner.run("/usr/bin/env", [
        "gh", "search", "prs", "--author=@me", "--state=open",
        "--json", "number,title,url,isDraft,repository,createdAt"
    ]), let searchData = searchOutput.data(using: .utf8) else { return nil }

    let prs = parseSearchResults(searchData)

    var enriched: [PullRequestInfo] = []
    for pr in prs {
        guard let detailOutput = runner.run("/usr/bin/env", [
            "gh", "pr", "view", "\(pr.number)", "--repo", pr.repo,
            "--json", "statusCheckRollup,reviewDecision,mergeable"
        ]), let detailData = detailOutput.data(using: .utf8) else {
            enriched.append(pr)
            continue
        }
        enriched.append(enrichPullRequest(pr, withDetailJSON: detailData))
    }
    return enriched
}
