import SwiftUI

struct DashboardPanelView: View {
    @ObservedObject var store: DashboardStore

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            UsageSectionView(usage: store.usage, unavailable: store.usageUnavailable)
            Divider()
            SessionsSectionView(rows: store.sessionRows)
            Divider()
            PullRequestsSectionView(pullRequests: store.pullRequests, unavailable: store.prsUnavailable)
            Divider()
            Button("Refresh") {
                store.refreshAll()
            }
            .padding(8)
        }
        .frame(width: 320)
    }
}
