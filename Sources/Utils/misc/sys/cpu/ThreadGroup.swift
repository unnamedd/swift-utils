import Foundation
/**
 * Sometimes DispatchGroup doesn't work when you need nested groups etc. Mixing async and sync code eetc 
 * ThreadGroup is simple in design and can work as a substitute.
 */
class ThreadGroup {
    typealias CompletionHandler = ()->Void
    private (set) var index : Int = 0
    var onComplete:CompletionHandler
    private var count:Int = 0//when count reaches this count, onAllComplete is executed
    init(onComplete:@escaping CompletionHandler = {fatalError("must have completion handler attached")}){
        self.onComplete = onComplete
    }
    /**
     * Seems to work in both bg and main threads
     */
    func enter(){
        main.async {
            self.count += 1
        }
    }
    /**
     * Seems to work in both bg and main threads
     */
    func leave(){
        
        main.async {
            self.index += 1
            if self.index == self.count {
                self.onComplete()
            }
        }
        
    }
}
