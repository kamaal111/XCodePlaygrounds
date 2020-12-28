import UIKit

struct CellConfigurator<Model, Cell: UITableViewCell> {
    let model: Model
    let configurator: (Cell) -> Void

    func callAsFunction(_ cell: Cell) {
        configurator(cell)
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

configurator(cell)
