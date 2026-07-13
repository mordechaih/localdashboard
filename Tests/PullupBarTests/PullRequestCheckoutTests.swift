import XCTest
@testable import PullupBar

private struct FakeCheckoutRunner: ProcessRunning {
    let ghPath: String?
    var lastCheckoutArgs: [String]?
    var lastCwd: String?
    let checkoutSucceeds: Bool

    func run(_ path: String, _ args: [String]) -> String? {
        if args == ["-l", "-c", "command -v gh"] { return ghPath }
        return nil
    }

    func run(_ path: String, _ args: [String], cwd: String) -> String? {
        checkoutSucceeds ? "done" : nil
    }
}

final class PullRequestCheckoutTests: XCTestCase {
    func testLocalRepoDirectoryFindsExistingClone() {
        let dir = localRepoDirectory(
            forRepo: "mordechaih/pullupbar",
            searchRoots: ["/Users/example/GitHub"],
            fileExists: { $0 == "/Users/example/GitHub/pullupbar/.git" }
        )
        XCTAssertEqual(dir, "/Users/example/GitHub/pullupbar")
    }

    func testLocalRepoDirectorySearchesRootsInOrder() {
        let dir = localRepoDirectory(
            forRepo: "owner/pullupbar",
            searchRoots: ["/Users/example/code", "/Users/example/GitHub"],
            fileExists: { $0 == "/Users/example/GitHub/pullupbar/.git" }
        )
        XCTAssertEqual(dir, "/Users/example/GitHub/pullupbar")
    }

    func testLocalRepoDirectoryReturnsNilWhenNoCloneFound() {
        let dir = localRepoDirectory(
            forRepo: "mordechaih/pullupbar",
            searchRoots: ["/Users/example/GitHub"],
            fileExists: { _ in false }
        )
        XCTAssertNil(dir)
    }

    func testLocalRepoDirectoryReturnsNilWhenNoRoots() {
        let dir = localRepoDirectory(
            forRepo: "mordechaih/pullupbar",
            searchRoots: [],
            fileExists: { _ in true }
        )
        XCTAssertNil(dir)
    }

    func testCheckoutPullRequestBranchSucceedsWhenRepoDirProvided() {
        let runner = FakeCheckoutRunner(ghPath: "/usr/bin/gh", checkoutSucceeds: true)
        let result = checkoutPullRequestBranch(repo: "o/r", number: 5, runner: runner, localRepoDir: "/tmp/r")
        XCTAssertTrue(result)
    }

    func testCheckoutPullRequestBranchFailsWhenGHUnresolved() {
        let runner = FakeCheckoutRunner(ghPath: nil, checkoutSucceeds: true)
        let result = checkoutPullRequestBranch(
            repo: "o/r",
            number: 5,
            runner: runner,
            localRepoDir: "/tmp/r",
            fileExists: { _ in false }
        )
        XCTAssertFalse(result)
    }

    func testCheckoutPullRequestBranchFailsWhenNoLocalRepoDir() {
        let runner = FakeCheckoutRunner(ghPath: "/usr/bin/gh", checkoutSucceeds: true)
        let result = checkoutPullRequestBranch(
            repo: "o/definitely-not-a-real-cloned-repo-\(UUID().uuidString)",
            number: 5,
            runner: runner,
            searchRoots: [],
            localRepoDir: nil
        )
        XCTAssertFalse(result)
    }
}
