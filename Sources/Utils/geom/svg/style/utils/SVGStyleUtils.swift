import Cocoa
/**
 * DISCUSSION: Probably move this into a more central place, but in the spirit of moving on!, Or not since its probably only related to how svg names these variables
 * NOTE: these methods provide a central place to convert values from the svg value scheme to the quartz value scheme
 */

enum SVGLineJoin:String{
    case miter = "miter"
    case round = "round"
    case bevel = "bevel"
}
extension CGLineJoin{
    static func lineJoin(_ lineJoin:SVGLineJoin) -> CGLineJoin {
        switch lineJoin {
        case .miter:
            return .miter
        case .round:
            return .round
        case .bevel:
            return .bevel
    }
}

class SVGStyleUtils {
    /**
     * TODO: try to find a method in swift that can extract enum values by providing a string
     */
    static func lineCap(_ lineCap:String?)->CGLineCap{
        let strokeLineCap = lineCap != nil && lineCap != "" ? lineCap : "butt"/*<-this was none, but it doesnt need to be since we wont extract this value from */
        if(strokeLineCap == "butt"){return CGLineCap.butt}
        else if(strokeLineCap == "round"){return CGLineCap.round}
        else if(strokeLineCap == "square"){return CGLineCap.square}
        else{fatalError("this lineCap type is not supported")}
    }
    static func lineJoin(_ lineJoin:String?)->CGLineJoin{
        let strokeLineJoin:String = {
            guard let lineJoin = lineJoin, lineJoin != "" else{
                return "miter"
            };return lineJoin
        }()
        guard let lineJoin:SVGLineJoin = SVGLineJoin(rawValue:strokeLineJoin) else{
            fatalError("this strokeLineJoin type is not supported: \(strokeLineJoin)")
        }
        return CGLineJoin.lineJoin(lineJoin)
      
    }
    static func miterLimit(_ miterLimit:CGFloat)->CGFloat{
        return !miterLimit.isNaN ? miterLimit : 10/*<--was 1.414*/
    }
    static func strokeWidth(_ strokeWidth:CGFloat)->CGFloat{
        return !(strokeWidth.isNaN) ? strokeWidth : 0
    }
    static func strokeColor(_ strokeColor:Double,_ strokeOpacity:CGFloat)->NSColor{
        let colorVal:Double = !(strokeColor.isNaN) ? strokeColor : Double(0x000000)
        let strokeOpacityVal:CGFloat = !(strokeOpacity.isNaN) ? strokeOpacity : 1;
        let color:NSColor = NSColorParser.nsColor(UInt(colorVal), strokeOpacityVal)
        return color
    }
    /**
     * Returns the boundingBox for the stroke in (the returned CGRect is in 0,0 space)
     * NOTE: if there is no strokeMiterLimit, then 10 is set as the default miter limit in LineStyle, this isn't always applied, and if its not there then we still need a value to work with, we could include it in the parsing of the svg, but then it would be exportable, which is undesired behaviour
     * TODO: if thre is no value the 0 can be used to calc the bounding box, this should be detected before the bounding box call though, as you dont need to calc the boundingbox if the stroke is 0
     */
    static func boundingBox(_ path:CGPath,_ style:SVGStyle)->CGRect{
        let strokeMiterLimit:CGFloat = SVGStyleUtils.miterLimit(style.strokeMiterLimit != nil ? style.strokeMiterLimit! : 10)
        let strokeLineCap:CGLineCap = SVGStyleUtils.lineCap(style.strokeLineCap)
        let strokeLineJoin:CGLineJoin = SVGStyleUtils.lineJoin(style.strokeLineJoin)
        let strokeWidth:CGFloat = SVGStyleUtils.strokeWidth(style.strokeWidth != nil ? style.strokeWidth!:0)/*this is new, we cant set a default value when parsing svg, if thre is no value the 0 can be used to calc the bounding box, this should be detected before the bounding box call though, as you dont need to calc the boundingbox if the stroke is 0*/
        let outlinePath = path.copy(strokingWithWidth: strokeWidth, lineCap: strokeLineCap, lineJoin: strokeLineJoin, miterLimit: strokeMiterLimit)//Swift 3 update, was: CGPathCreateCopyByStrokingPath
        let boundingBox:CGRect = outlinePath.boundingBoxOfPath/*there is also CGPathGetBoundingBox, which works a bit different, the difference is probably just support for cruves etc*/
        return boundingBox
    }
    /**
     * New
     */
    static func graphicStyle(_ svgGraphic:ISVGGraphic)->IGraphicStyle{
        guard let style = svgGraphic.style else{
            return GraphicStyle()
        }
        let fillStyle:IFillStyle? = SVGFillStyleUtils.fillStyle(style, svgGraphic.fillShape)
        let lineStyle:ILineStyle? = SVGLineStyleUtils.lineStyle(style, svgGraphic.lineShape)
        return GraphicStyle(fillStyle,lineStyle)
    }
}
