import Cocoa

class WindowUtils {
    /**
     * Positions a window
     */
    class func position(window:NSWindow, position:CGPoint){
        window.setFrame(NSRect(position.x,position.y,window.frame.width,window.frame.height), display: true)/*<--unsure what the display var does*/
    }
    /**
     * Aligns a window to an alignment type
     * NOTE: The screen aligns from the bottom up (so use bottom for top and top for bottom)
     */
    class func align(panel:NSWindow,_ canvasAlignment:String,_ viewAlignment:String,_ offset:CGPoint = CGPoint(0,0)) {
        let alignmentPoint:CGPoint = Align.alignmentPoint(CGSize(panel.frame.width,panel.frame.height), CGSize(NSScreen.mainScreen()!.visibleFrame.width,NSScreen.mainScreen()!.visibleFrame.height),canvasAlignment,viewAlignment,offset)
        //Swift.print("ScreenUtils.alignmentPoint: " + "\(alignmentPoint)")
        panel.setFrame(NSRect(alignmentPoint.x,alignmentPoint.y,panel.frame.width,panel.frame.height), display: true)/*<--unsure what the display var does*/
    }
}
