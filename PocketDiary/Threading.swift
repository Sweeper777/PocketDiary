import Foundation
infix operator ~>

/**
 Executes the lefthand closure on a background thread and,
 upon completion, the righthand closure on the main thread.
 Passes the background closure's output, if any, to the main closure.
 */
func ~> <R> (
    backgroundClosure: @escaping () -> R,
    mainClosure:       @escaping (_ result: R) -> ())
{
    queue.async {
        let result = backgroundClosure()
        DispatchQueue.main.async(execute: {
            mainClosure(result)
        })
    }
}

/** Serial dispatch queue used by the ~> operator. */
private let queue = DispatchQueue(label: "serial-worker", attributes: [])
