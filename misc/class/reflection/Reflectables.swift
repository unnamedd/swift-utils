import Cocoa

extension CGColorRef:Reflectable{
    var reflection:(type:String,value:String) {
        return (type:"CGColor",value:RGBAParser.hex(self.nsColor))//we store 0xFF0000FF values, which includes rgb and alpha
    }
}
extension NSColor:Reflectable{
    var reflection:(type:String,value:String) {
        Swift.print("reflection")
        Swift.print("self: " + "\(self)")
        
        //Continue here: it seems to not want to
        let color:NSColor = self
        Swift.print("nsColor: " + "\(color)")
        let r:UInt = color.redComponent.uint * 255
        Swift.print("r: " + "\(r)")
        let g:UInt = color.greenComponent.uint*255
        Swift.print("g: " + "\(g)")
        let b:UInt = color.blueComponent.uint*255
        Swift.print("b: " + "\(b)")
        let a:UInt = color.alphaComponent.uint*255
        Swift.print("a: " + "\(a)")
        let hex:String = HexParser.hexString(a,r,g,b)
        Swift.print("hex: " + "\(hex)")
        
        let hexString:String = RGBAParser.hex(color)
        
        Swift.print("hexString: " + "\(hexString)")
        return (type:"NSColor",value:hexString)//we store 0xFF0000FF values, which includes rgb and alpha
    }
}
extension CGTransform:Reflectable{
    var reflection:(type:String,value:String) {
        return (type:"CGTransform",value:self.identity)
    }
}
extension CGPoint:Reflectable{
    var reflection:(type:String,value:String) {
        return (type:"CGPoint",value:self.x.string + "," + self.y.string)
    }
}
extension CGSize:Reflectable{
    var reflection:(type:String,value:String) {
        return (type:"CGSize",value:self.width.string + "," + self.height.string)
    }
}
extension IStyleProperty{
    /**
     * Converts xml to a Selector
     */
    static func styleProperty(xml:XML)->IStyleProperty{
        //Swift.print("xml.string: " + "\(xml.string)")
        /* let name:String = xml.firstNode("name")!.value
        //Swift.print("element: " + "\(element)")
        let valueXML:XML = xml.firstNode("value")!
        Swift.print("valueXML.XMLString: " + "\(valueXML.XMLString)")
        
        
        
        let value:Any? = nil//ReflectionUtils.toType(valueXML)
        
        let depth:Int = xml.firstNode("depth")!.value.int
        */
        fatalError("this is out of order atm, and its not needed as this class is handled automatically")
        
        //return StyleProperty(name,value,depth)
    }
}