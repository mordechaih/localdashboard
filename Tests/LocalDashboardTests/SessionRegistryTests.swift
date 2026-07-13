import XCTest
@testable import LocalDashboard

final class SessionRegistryTests: XCTestCase {
    var tempDir: URL!

    override func setUpWithError() throws {
        tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: tempDir)
    }

    private func writeSession(pid: Int, sessionId: String, cwd: String, name: String, status: String) throws {
        let json = #"{"pid":\#(pid),"sessionId":"\#(sessionId)","cwd":"\#(cwd)","name":"\#(name)","status":"\#(status)"}"#
        try json.write(to: tempDir.appendingPathComponent("\(sessionId).json"), atomically: true, encoding: .utf8)
    }

    func testLoadSessionsFiltersDeadPids() throws {
        try writeSession(pid: 111, sessionId: "alive-1", cwd: "/tmp/a", name: "alive", status: "busy")
        try writeSession(pid: 222, sessionId: "dead-1", cwd: "/tmp/b", name: "dead", status: "idle")

        let sessions = loadSessions(sessionsDir: tempDir.path, isAlive: { $0 == 111 })

        XCTAssertEqual(sessions.count, 1)
        XCTAssertEqual(sessions.first?.sessionId, "alive-1")
    }

    func testLoadSessionsIgnoresNonJSONFiles() throws {
        try writeSession(pid: 333, sessionId: "alive-2", cwd: "/tmp/c", name: "alive2", status: "busy")
        try "not a session".write(to: tempDir.appendingPathComponent("notes.txt"), atomically: true, encoding: .utf8)

        let sessions = loadSessions(sessionsDir: tempDir.path, isAlive: { _ in true })

        XCTAssertEqual(sessions.count, 1)
    }

    func testIsPidAliveDetectsDefinitelyDeadPid() {
        XCTAssertFalse(isPidAlive(999_999))
    }
}
