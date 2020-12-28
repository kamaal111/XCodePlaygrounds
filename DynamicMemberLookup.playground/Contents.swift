import UIKit

@dynamicMemberLookup
struct CellConfigurator<Model, Cell: UITableViewCell> {
    let model: Model
    let configurator: (Cell) -> Void

    func configure(_ cell: Cell) {
        configurator(cell)
    }

    subscript<T>(dynamicMember keyPath: KeyPath<Model, T>) -> T {
        model[keyPath: keyPath]
    }
}

struct Person {
    let name: String
}

let cell = UITableViewCell()
let me = Person(name: "Kamaal")

let configurator = CellConfigurator(model: me) { (cell: UITableViewCell) in
    cell.textLabel?.text = me.name
}

configurator.configure(cell)

configurator.name
