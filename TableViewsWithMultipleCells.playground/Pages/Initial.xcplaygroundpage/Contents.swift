import UIKit
import PlaygroundSupport

// from: https://github.com/weissi/swift-undefined
public func undefined<T>(hint: String = "", file: StaticString = #file, line: UInt = #line) -> T {
    let message = hint == "" ? "" : ": \(hint)"
    fatalError("undefined \(T.self)\(message)", file:file, line:line)
}

struct Album {
    var title: String
}

struct Artist {
    var name: String
}


struct CellDescriptor {
    let cellClass: UITableViewCell.Type
    let configure: (UITableViewCell) -> ()
    var reuseIdentifier:String { return String(describing: cellClass) }
    
    init<Cell: UITableViewCell>(configure: @escaping (Cell) -> ()) {
        self.cellClass = Cell.self
        self.configure = { cell in
            configure(cell as! Cell)
        }
    }
}

// cannot define delegates in extensions:
// "@objc is not supported within extensions of generic classes" - https://bugs.swift.org/browse/SR-4173
// so define delegate functions within the body of the class declaration
final class GenericTableViewController<Item>: UITableView, UITableViewDataSource, UITableViewDelegate {
    var items: [Item] = []
    let cellDescriptor: (Item) -> CellDescriptor
    var didSelect: (Item) -> () = { _ in }
    var reuseIdentifiers: Set<String> = []
    
    init(items: [Item], cellDescriptor: @escaping (Item) -> CellDescriptor) {
        self.cellDescriptor = cellDescriptor
        super.init(frame: CGRect.zero, style: .plain)
        self.items = items
        self.dataSource = self
        self.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UITableViewDataSource
    @objc func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    @objc func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    @objc func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.row]
        let descriptor = cellDescriptor(item)
        if !reuseIdentifiers.contains(descriptor.reuseIdentifier) {
            self.register(descriptor.cellClass, forCellReuseIdentifier: descriptor.reuseIdentifier)
            reuseIdentifiers.insert(descriptor.reuseIdentifier)
        }
        
        let cell = self.dequeueReusableCell(withIdentifier: descriptor.reuseIdentifier, for: indexPath)
        descriptor.configure(cell)
        return cell
    }
    
    // MARK: - UITableViewDelegate
    @objc func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        didSelect(item)
    }
}

final class ArtistCell: UITableViewCell {
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class AlbumCell: UITableViewCell {
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .value2, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


let artists: [Artist] = [
    Artist(name: "Prince"),
    Artist(name: "Glen Hansard"),
    Artist(name: "I Am Oak")
]

let albums: [Album] = [
    Album(title: "Blue Lines"),
    Album(title: "Oasem"),
    Album(title: "Bon Iver")
]

enum RecentItem {
    case artist(Artist)
    case album(Album)
}

let recentItems: [RecentItem] = [
    .artist(artists[0]),
    .artist(artists[1]),
    .album(albums[1])
]

extension Artist {
    func configureCell(_ cell: ArtistCell) {
        cell.textLabel?.text = name
    }
}

extension Album {
    func configureCell(_ cell: AlbumCell) {
        cell.textLabel?.text = title
    }
}

extension RecentItem {
    var cellDescriptor: CellDescriptor {
        switch self {
        case .artist(let artist):
            return CellDescriptor(configure: artist.configureCell)
        case .album(let album):
            return CellDescriptor(configure: album.configureCell)
        }
    }
}

let frame = CGRect(x: 0, y: 0, width: 200, height: 300)

let recentItemsVC = UIViewController()
recentItemsVC.title = "ViewController"
let recentItemsTableView = GenericTableViewController(items: recentItems, cellDescriptor: { $0.cellDescriptor })
recentItemsTableView.frame = frame
recentItemsVC.view.addSubview(recentItemsTableView)

let nc = UINavigationController(rootViewController: recentItemsVC)

nc.view.frame = frame
PlaygroundPage.current.liveView = nc.view


print("💣💣💣💣")
