import Cocoa

class SVGFillStyleUtils{
    /**
     * Converts SVGStyle to IFillStyle
     */
    class func fillStyle(style:SVGStyle,_ shape:Shape)-> IFillStyle?{
        Swift.print("SVGFillStyleUtils.fillStyle() style: " + "\(style)")
        Swift.print("SVGFillStyleUtils.fillStyle() style.fill: " + "\(style.fill)")
        var fillStyle:IFillStyle?
        if(/*style != nil && */style.fill is Double/* && style!.fill != "none"*/ && !(style.fill as! Double).isNaN) {
            let color:NSColor = SVGFillStyleUtils.fillColor(style)
            //Swift.print("color: " + "\(color)")
            fillStyle = FillStyle(color)
        }else if(style.fill != nil && style.fill is ISVGGradient){
            fillStyle = SVGFillStyleUtils.gradientFillStyle(style, shape)
        }else{
            //clear
            //Swift.print("no fill")
            //fatalError("not implemented yet")
        }
        return fillStyle
    }
    /**
     * Converts SVGStyle to IGradientFillStyle
     */
    class func gradientFillStyle(style:SVGStyle,_ shape:Shape)->IGradientFillStyle{
        let svgGradient:SVGGradient = style.fill as! SVGGradient
        let graphicsGradient:IGraphicsGradient = SVGFillStyleUtils.fillGraphicGradient(shape, svgGradient)
        let gradient:IGradient = graphicsGradient.gradient()
        let gradientFillStyle:IGradientFillStyle = GradientFillStyle(gradient)
        return gradientFillStyle
    }
    /**
     *
     */
    class func fillColor(style:SVGStyle)->NSColor{
        //Swift.print("SVGGraphic.beginFill() color")
        let colorVal:Double = !(style.fill as! Double).isNaN ? style.fill as! Double : Double(0x000000)
        //Swift.print("colorVal: " + "\(colorVal)")
        let opacity:CGFloat = style.fillOpacity != nil && !style.fillOpacity!.isNaN ? style.fillOpacity! : 1
        let color:NSColor = NSColorParser.nsColor(UInt(colorVal), opacity)
        //Swift.print("color: " + "\(color)")
        return color
    }
    /**
     * @NOTE: we use the Shape instance here because we need the frame offset to calculate the correct gradient p1 and p2 when using userspace
     * @NOTE: userspace uses real coordinates, nonuserspace uses relative coordinates 0 - 1 etc
     * @NOTE: userSpaceOnUse — x1, y1, x2, y2 represent coordinates in the current user coordinate system. In other words the values in the gradient are absolute values.
     * @NOTE: objectBoundingBox — x1, y1, x2, y2 represent coordinates in a system established by the bounding box of the element to which the gradient is applied. In other words the gradient scales with the element it’s applied to.
     * TODO: there is also: gradientTransform="rotate(90, 50, 30)" the origin of the rotation would be 50, 30
     * @NOTE: <radialGradient id="grad1" cx="50%" cy="50%" r="50%" fx="50%" fy="50%">
     * @NOTE: The cx, cy and r attributes define the outermost circle and the fx and fy define the innermost circle
     * @DISCUSSION: you cant directly apply the matrix transformation in the Graphics since the graphics class operates in 0,0 space and the matrix transformation that comes in operates it 0,0 space from the point of ciew of the viewbox (this probably isnt true when doing gradientUnits=" 'objectBoundingBox' only when doing: 'userSpaceOnUse' or )
     * TODO: unless you offset it first! try this
     */
    class func fillGraphicGradient(shape:Shape,_ gradient:SVGGradient)->IGraphicsGradient{
        //let gradientType = gradient is SVGLinearGradient ? GradientType.Linear : GradientType.Radial;
        let userSpaceOnUse:Bool = gradient.gradientUnits == "userSpaceOnUse";////The gradientUnits attribute takes two familiar values, userSpaceOnUse and objectBoundingBox, which determine whether the gradient scales with the element that references it or not. It determines the scale of x1, y1, x2, y2.
        //Swift.print("gradientType: " + gradientType);
        //var matrix:Matrix = Utils.matrix(graphic);
        
        //var spreadMethod:String = gradient.spreadMethod || SpreadMethod.PAD;
        //Swift.print("spreadMethod: " + spreadMethod);
        //var interpolationMethod:String = InterpolationMethod.RGB;/*InterpolationMethod.LINEAR_RGB*/
        //Swift.print("interpolationMethod: " + interpolationMethod);
        //let focalPointRatio:CGFloat = 0;/*from -1 to 1;*/
        
        //Swift.print("focalPointRatio: " + focalPointRatio);
        //Swift.print("gradient.colors: " + gradient.colors);
        //Swift.print("gradient.opacities: " + gradient.opacities);
        //Swift.print("gradient.offsets: " + gradient.offsets);
        /**
        * @NOTE: there is no need for transform in the LinearGraphicsGradient, all matrix transformation can be applied to the points
        * @NOTE: you need to be able to derive variables from the svg graphic instance that reflect what should be in the export so base your setting of the gradient on this
        */
        if(gradient is SVGLinearGradient){
            //let gradient:SVGLinearGradient = gradient as! SVGLinearGradient
            
            //TODO: add support for relative values, see old code, you need to use the bounding box etc and test how relative values work in svg etc
            var p1:CGPoint = /*userSpaceOnUse && !gradient.x1.isNaN && !gradient.y1.isNaN ? */CGPoint((gradient as! SVGLinearGradient).x1,(gradient as! SVGLinearGradient).y1).copy()/* :nil*/
            var p2:CGPoint = /*userSpaceOnUse && !gradient.x2.isNaN && !gradient.y2.isNaN ? */CGPoint((gradient as! SVGLinearGradient).x2,(gradient as! SVGLinearGradient).y2).copy()/* :nil*/
            //Swift.print("p1: " + "\(p1)")
            //Swift.print("shape.frame.origin: " + "\(shape.frame.origin)")
            
            //TODO:  the problem is that you do the offset on values that are not yet sccaled. so either do scaling with matrix here or think of something els
            //maybe the graphic gradient is only absolute and you do matrix here instead?, since the offset will always be a problem etc, try this
            //Swift.print("points: " + "\([p1,p2])")
            
            //Swift.print("points after: " + "\([p1,p2])")
            
            if(userSpaceOnUse){/*we offset the p1,p2 to operate in the 0,0 space that the path is drawn in, inside frame*/
                if(gradient.gradientTransform != nil){
                    //Swift.print("drawAxialGradient() gradient.transformation()")
                    //i think you should do tje matrix in Graphics not here
                    p1 = CGPointApplyAffineTransform(p1, gradient.gradientTransform!)
                    p2 = CGPointApplyAffineTransform(p2, gradient.gradientTransform!)
                }
                p1 -= shape.frame.origin
                p2 -= shape.frame.origin
            }else{/*objectBoundingBox*/
                if(gradient.gradientTransform != nil){fatalError("not supported yet")}
                let boundingBox:CGRect = CGPathGetBoundingBox(shape.path)
                p1.x = boundingBox.width * (p1.x / 100)//this code can be compacted into 1 line
                p1.y = boundingBox.height * (p1.y / 100)
                p2.x = boundingBox.width * (p2.x / 100)
                p2.y = boundingBox.height * (p2.y / 100)
                //Swift.print("p1: " + "\(p1)")
                //Swift.print("p2: " + "\(p2)")
            }
            //Swift.print("points after offset: " + "\([p1,p2])")
            let linearGraphicsGradient:IGraphicsGradient = LinearGraphicsGradient(gradient.colors,gradient.offsets,nil/*gradient.gradientTransform*/,p1,p2)
            //Gradient(gradient.colors,gradient.offsets,0,nil,nil,nil,nil,p1,p2,!userSpaceOnUse/*,gradient.gradientTransform*/)
            //fatalError("implment the bellow first")
            return linearGraphicsGradient
        }
            /**
            * @NOTE: it seems you can do the offseting in the matrix transformation
            * @TODO: lets try to scale radial gradient aswell
            */
        else{/*gradient is SVGRadialGradient */
            //Swift.print("drawRadialGradient()")
            let radialGradient:SVGRadialGradient = gradient as! SVGRadialGradient
            //Swift.print("radialGradient.gradientTransform: " + "\(radialGradient.gradientTransform)")
            let startRadius:CGFloat = 0
            var endRadius:CGFloat = radialGradient.r
            //Swift.print("endRadius: " + "\(endRadius)")
            
            var startCenter:CGPoint = CGPoint(!radialGradient.fx.isNaN ? radialGradient.fx : radialGradient.cx,!radialGradient.fy.isNaN ? radialGradient.fy : radialGradient.cy)/*if fx or fy isnt found use cx and cy as replacments*/
            //Swift.print("startCenter: " + "\(startCenter)")
            var endCenter:CGPoint = CGPoint(radialGradient.cx,radialGradient.cy)
            //Swift.print("endCenter: " + "\(endCenter)")
            
            var transformation:CGAffineTransform = CGAffineTransformIdentity
            
            if(userSpaceOnUse){/*we offset the p1,p2 to operate in the 0,0 space that the path is drawn in, inside frame*/
                //Swift.print("userSpaceOnUse")
                if(radialGradient.gradientTransform != nil) {
                    //Swift.print("drawRadialGradient() gradient.transformation()")
                    transformation = radialGradient.gradientTransform!.copy()
                    //Swift.print("transformation: " + "\(transformation)")
                    //matrix.concat(gradient.gradientTransform)
                    //startCenter = CGPointApplyAffineTransform(startCenter, gradient.gradientTransform!)
                    //endCenter = CGPointApplyAffineTransform(endCenter, gradient.gradientTransform!)
                }
                //startCenter -= shape.frame.origin
                //endCenter -= shape.frame.origin
                transformation.concat(CGAffineTransformMakeTranslation(-shape.frame.origin.x, -shape.frame.origin.y))
                //Swift.print("transformation: " + "\(transformation)")
            }else{/*objectBoundingBox*/
                //if(radialGradient.gradientTransform != nil) {fatalError("not supported yet")}
                //TODO: we dont use any transform yet, you need to sort out the scaling first see todolist in the basic svg support article
                let boundingBox:CGRect = CGPathGetBoundingBox(shape.path)//TODO: reuse frame as the bounding box
                startCenter.x = boundingBox.width * (startCenter.x / 100)//this code can be compacted into 1 line
                startCenter.y = boundingBox.height * (startCenter.y / 100)
                endCenter.x = boundingBox.width * (endCenter.x / 100)
                endCenter.y = boundingBox.height * (endCenter.y / 100)
                
                let minAxis:CGFloat = min(boundingBox.width,boundingBox.height)/*We need the smallest axis length, either width or height*/
                let minRadius:CGFloat = minAxis/2/*Radius is half the axis length*/
                endRadius = minRadius * (endRadius/100*2)//needs to be half of minwidth of boundingbox, multiply by 2 since we are using radius not diameter, this can be optimized
                //Swift.print("endRadius: " + "\(endRadius)")
                //Swift.print("startCenter: " + "\(startCenter)")
                //Swift.print("endCenter: " + "\(endCenter)")
            }
            return RadialGraphicsGradient(radialGradient.colors,radialGradient.offsets,transformation/*nil*/,startCenter,endCenter,startRadius,endRadius)
            
        }
    }
}