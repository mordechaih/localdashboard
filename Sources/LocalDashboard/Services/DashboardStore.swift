import Foundation

@MainActor
final class DashboardStore: ObservableObject {
    @Published var sessionRows: [SessionRow] = []
    @Published var usage: UsageWindowInfo?
    @Published var usageUnavailable = false
    @Published var pullRequests: [PullRequestInfo] = []
    @Published var prsUnavailable = false

    private let sessionsDir: String
    private let projectsDir: String
    private let tokenProvider: KeychainTokenProviding
    private let processRunner: ProcessRunning
    private let dataTask: DataTaskFunc

    private var sessionTimer: Timer?
    private var apiTimer: Timer?

    var badgeCount: Int { pullRequests.count }

    init(
        sessionsDir: String = NSString(string: "~/.claude/sessions").expandingTildeInPath,
        projectsDir: String = NSString(string: "~/.claude/projects").expandingTildeInPath,
        tokenProvider: KeychainTokenProviding = KeychainTokenProvider(),
        processRunner: ProcessRunning = SystemProcessRunner(),
        dataTask: @escaping DataTaskFunc = URLSession.shared.data(for:)
    ) {
        self.sessionsDir = sessionsDir
        self.projectsDir = projectsDir
        self.tokenProvider = tokenProvider
        self.processRunner = processRunner
        self.dataTask = dataTask
    }

    func refreshSessions() {
        sessionRows = computeSessionRows(sessionsDir: sessionsDir, projectsDir: projectsDir)
    }

    func refreshUsage() async {
        if let result = await fetchUsageWindow(tokenProvider: tokenProvider, dataTask: dataTask) {
            usage = result
            usageUnavailable = false
        } else {
            usageUnavailable = true
        }
    }

    func refreshPullRequests() async {
        let runner = processRunner
        let result = await Task.detached(priority: .utility) { () -> [PullRequestInfo]? in
            fetchPullRequests(runner: runner)
        }.value

        if let result {
            pullRequests = result
            prsUnavailable = false
        } else {
            prsUnavailable = true
        }
    }

    func refreshAll() {
        refreshSessions()
        Task { await refreshUsage() }
        Task { await refreshPullRequests() }
    }

    func startPolling() {
        refreshAll()
        sessionTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.refreshSessions() }
        }
        apiTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.refreshUsage()
                await self?.refreshPullRequests()
            }
        }
    }
}
