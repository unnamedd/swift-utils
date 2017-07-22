import Foundation
@testable import Utils
/**
 * .onComplete .onFrame .onStop .onStart
 add spring and ease as well
 animate(view, duration: 1, curve: .bezier(1, 0.4, 1, 0.5)) {
 $0.x = finalValue
 }
 case 4:
 spring(view, delay: 0.5, spring: 800, friction: 10, mass: 10) {
 
 also loop?
 
 where do you start? at the end!
 
 //continue here: 🏀
    //make FrameAnimator2 that does not extend EventSender
    //make LoopAnimator2
    //Animate a ball 👈
    //look at other Libs and Future promis hydra etc
 
 
 */
class Animator2:FrameAnimator {
    var frameTick:FrameTick
    var currentFrameCount:CGFloat = 0/*curFrameCount, this is needed in order to know when the animation is complete*/
    var initValues:InitValues
    //(CGFloat) -> Animator2 /*Makes the return type less verbose*/
    init(initValues:Animator.InitValues, closure: @escaping FrameTick) {
        self.initValues = initValues
        self.frameTick = closure
        //return TestingClass()
        super.init(AnimProxy.shared)
    }
    /**
     * Fires on every frame tick
     */
    override func onFrame(){
        //let val:CGFloat = easing(currentFrameCount, from, to-from, framesToEnd)
        frameTick(0)/*Call the callBack onFrame method*/
        if(currentFrameCount == framesToEnd){
            stop()/*Stop the animation*/
            //_ = completed(Animator.initValues, {_ in})//the animation completed, call the completed closure
            completed as? Animator2 != nil ? (completed as! Animator2).start() : (completed as! () -> Void)()//enables completed to be different callbacks
        }
        self.currentFrameCount += 1
    }
    func pause(durInSec:CGFloat, closure: () -> Void) -> Self {
        sleep(durInSec.int.uint32)//pause
        closure()/*Call the method*/
        return self
     }
    
//    typealias Completed = (_ initValues:Animator.InitValues, _ closure: @escaping FrameTick) -> Animator2
//    
//    lazy var completed:Completed = {_,_ in return self}
//    typealias Completed = () -> Void
    var completed:Any?//any enables completed to be different callbacks
    
//    /**
//     * ⚠️️ too many onComplet methods can clutter up the code. you  can just launch another Animator with zero animation
//     */
//    func onComplete(closure: () -> Void) -> Self{
//        closure()
//        return self/*Always return self so we can chain*/
//    }
    /**
     *
     */
//    func onFrame(closure: () -> Void) -> Self{
//        closure()/*execute the closure*/
//        return self/*Always return self so we can chain*/
//    }
    
    /**
     *
     */
//    func onFrame(_ value:CGFloat) -> Animator2{
//        return self
//    }
    
}

extension Animator2 {
    typealias InitValues = (duration:CGFloat,from:CGFloat,to:CGFloat)/*Signature for initValues*/
    static var initValues:InitValues = (duration:0.5,from:0,to:1)/*Default init values*/
    static var fps:CGFloat = 60//<--TODO: ⚠️️ this should be derived from a device variable
    var duration:CGFloat {get{return initValues.duration}set{initValues.duration = newValue}}/*In seconds*/
    var from:CGFloat {get{return initValues.from}set{initValues.from = newValue}}/*From this value*/
    var to:CGFloat {get{return initValues.to}set{initValues.to = newValue}}/*To this value*/
    var framesToEnd:CGFloat {return Animator.fps * duration}/*totFrameCount*/
}