import Foundation

enum LinkedList<Element> {
    case empty
    indirect case node(Element, LinkedList<Element>)
}

let linkedList: LinkedList<Int> = .node(1, .node(4, .empty))
