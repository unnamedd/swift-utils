import Cocoa
protocol IFillStyle {
    var color: NSColor { get set }
}
class FillStyle :IFillStyle{
    var color:NSColor
    /**
    *
    */
    init(_ color:NSColor){
        self.color = color
    }
}

