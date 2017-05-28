import Foundation

class FlexBoxModifier{
    /**
     * TODO: Possibly use FlexItem here that decorates something
     */
    static func justifyContent<T:IPositional>(_ items:[T], _ type:FlexBoxType.Justify, _ containerSize:CGSize) where T:ISizeable{
        switch type{
            case .flexStart:
                Swift.print("flexStart")
                JustifyUtils.justifyFlexStart(items)
            case .flexEnd:
                Swift.print("flexEnd")
            case .center:
                Swift.print("center")
            case .spacebetween:
                Swift.print("spacebetween")
            case .spaceAround:
                Swift.print("spaceAround")
        }
    }
}
class JustifyUtils{
    /**
     * Aligns from start to end
     */
    static func justifyFlexStart<T:IPositional>(_ items:[T]) where T:ISizeable{
        var x:CGFloat = 0//interim x
        items.forEach{ item in
            item.x = x
            x += item.width
        }
    }
    static func justifyFlexEnd<T:IPositional>(_ items:[T], _ containerSize:CGSize) where T:ISizeable{
        
        //move backwards?
        if let last = items.last{
            var x:CGFloat = containerSize.width - last.width//interim x
            items.reversed().forEach{ item in
                item.x = x
                x += item.width
            }
        }
        
    }
}
