import Foundation

/// Looks for a local clone of `repo` by its bare name under each configured search root,
/// returning the first directory that contains a `.git` entry. Roots are searched in order,
/// so earlier entries win. Tildes in roots are expanded.
func localRepoDirectory(
    forRepo repo: String,
    searchRoots: [String],
    fileExists: (String) -> Bool = { FileManager.default.fileExists(atPath: $0) }
) -> String? {
    guard let repoName = repo.split(separator: "/").last.map(String.init) else { return nil }
    for root in searchRoots {
        let expandedRoot = NSString(string: root).expandingTildeInPath
        let candidate = (expandedRoot as NSString).appendingPathComponent(repoName)
        if fileExists((candidate as NSString).appendingPathComponent(".git")) {
            return candidate
        }
    }
    return nil
}

@discardableResult
func checkoutPullRequestBranch(
    repo: String,
    number: Int,
    runner: ProcessRunning,
    searchRoots: [String] = [],
    localRepoDir: String? = nil,
    fileExists: (String) -> Bool = { FileManager.default.isExecutableFile(atPath: $0) }
) -> Bool {
    guard let ghPath = resolveGHExecutablePath(runner: runner, fileExists: fileExists) else { return false }
    guard let repoDir = localRepoDir ?? localRepoDirectory(forRepo: repo, searchRoots: searchRoots) else { return false }
    return runner.run(ghPath, ["pr", "checkout", "\(number)", "--repo", repo], cwd: repoDir) != nil
}
