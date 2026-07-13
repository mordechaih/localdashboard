import Foundation

struct SessionInfo: Codable, Sendable {
    let pid: Int
    let sessionId: String
    let cwd: String
    let name: String?
    let status: String
}

func isPidAlive(_ pid: Int) -> Bool {
    kill(pid_t(pid), 0) == 0
}

func loadSessions(sessionsDir: String, isAlive: (Int) -> Bool = isPidAlive) -> [SessionInfo] {
    let fm = FileManager.default
    guard let files = try? fm.contentsOfDirectory(atPath: sessionsDir) else { return [] }

    var result: [SessionInfo] = []
    let decoder = JSONDecoder()
    for file in files where file.hasSuffix(".json") {
        let path = (sessionsDir as NSString).appendingPathComponent(file)
        guard let data = fm.contents(atPath: path) else { continue }
        guard let info = try? decoder.decode(SessionInfo.self, from: data) else { continue }
        if isAlive(info.pid) {
            result.append(info)
        }
    }
    return result
}
