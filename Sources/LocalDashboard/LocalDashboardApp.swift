import SwiftUI
import AppKit

@main
struct LocalDashboardApp: App {
    @StateObject private var store = DashboardStore()

    var body: some Scene {
        MenuBarExtra {
            DashboardPanelView(store: store)
        } label: {
            Group {
                if store.badgeCount > 0 {
                    Image(nsImage: renderBadgeIcon(count: store.badgeCount))
                } else {
                    Image(systemName: "gauge.medium")
                }
            }
            .task { store.startPolling() }
        }
        .menuBarExtraStyle(.window)
    }
}

func renderBadgeIcon(count: Int) -> NSImage {
    let size = 18
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    guard let ctx = CGContext(
        data: nil,
        width: size,
        height: size,
        bitsPerComponent: 8,
        bytesPerRow: 0,
        space: colorSpace,
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    ) else {
        return NSImage(size: CGSize(width: size, height: size))
    }

    let rect = CGRect(x: 0, y: 0, width: size, height: size)
    let path = CGPath(roundedRect: rect, cornerWidth: 5, cornerHeight: 5, transform: nil)
    ctx.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 1))
    ctx.addPath(path)
    ctx.fillPath()

    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(cgContext: ctx, flipped: false)

    let text = "\(count)" as NSString
    let font = NSFont.systemFont(ofSize: 11, weight: .bold)
    let attrs: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: NSColor.black]
    let textSize = text.size(withAttributes: attrs)
    let textRect = CGRect(
        x: (CGFloat(size) - textSize.width) / 2,
        y: (CGFloat(size) - textSize.height) / 2,
        width: textSize.width,
        height: textSize.height
    )
    ctx.setBlendMode(.clear)
    text.draw(in: textRect, withAttributes: attrs)

    NSGraphicsContext.restoreGraphicsState()

    guard let cgImage = ctx.makeImage() else {
        return NSImage(size: CGSize(width: size, height: size))
    }
    let image = NSImage(cgImage: cgImage, size: CGSize(width: size, height: size))
    image.isTemplate = false
    return image
}
