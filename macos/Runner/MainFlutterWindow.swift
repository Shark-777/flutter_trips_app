import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    self.contentViewController = flutterViewController
    
    // Set iPhone 16 Pro Max window size (440x956)
    let phoneWidth: CGFloat = 440
    let phoneHeight: CGFloat = 956
    
    // Center window on screen
    if let screen = NSScreen.main {
      let screenFrame = screen.visibleFrame
      let x = (screenFrame.width - phoneWidth) / 2 + screenFrame.origin.x
      let y = (screenFrame.height - phoneHeight) / 2 + screenFrame.origin.y
      let phoneFrame = NSRect(x: x, y: y, width: phoneWidth, height: phoneHeight)
      self.setFrame(phoneFrame, display: true)
    }
    
    // Prevent resizing to keep phone aspect ratio
    self.styleMask.remove(.resizable)
    self.minSize = NSSize(width: phoneWidth, height: phoneHeight)
    self.maxSize = NSSize(width: phoneWidth, height: phoneHeight)

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
