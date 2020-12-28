import Foundation

extension URL {
    init(staticString: StaticString) {
        self.init(string: "\(staticString)")!
    }
}

let path = "maps"
let url = URL(staticString: "https://www.google.com/")
