import CoreGraphics

/// Layout constants shared across the dashboard panel and its subviews.
enum DashboardMetrics {
    /// The fixed width of the menu-bar panel. The paging PR section and the settings pane both
    /// size themselves to this, so pages span the full window and toggling between them never
    /// resizes the hosting window. Keep these in sync by referencing this single value.
    static let panelWidth: CGFloat = 456
}
