import UIKit
import PlaygroundSupport

// based on: https://talk.objc.io/episodes/S01E26-generic-table-view-controllers-part-2

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

typealias GenericTableModel<Item> = [(title:String,items:[Item])]

// cannot define delegates in extensions:
// "@objc is not supported within extensions of generic classes" - https://bugs.swift.org/browse/SR-4173
// so define delegate functions within the body of the class declaration
final class GenericTableViewController<Item>: UITableView, UITableViewDataSource, UITableViewDelegate {
    var items: GenericTableModel<Item> = []
    let cellDescriptor: (Item) -> CellDescriptor
    var didSelect: (Item) -> () = { _ in }
    var reuseIdentifiers: Set<String> = []
    
    init(items: GenericTableModel<Item>, cellDescriptor: @escaping (Item) -> CellDescriptor) {
        self.cellDescriptor = cellDescriptor
        super.init(frame: CGRect.zero, style: .grouped)
        self.items = items
        self.dataSource = self
        self.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UITableViewDataSource
    @objc func numberOfSections(in tableView: UITableView) -> Int {
        return items.count
    }
    
    @objc func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items[section].items.count
    }
    
    @objc func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return items[section].title
    }
    
    @objc func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = itemForIndexPath(indexPath)
        let descriptor = cellDescriptor(item)
        if !reuseIdentifiers.contains(descriptor.reuseIdentifier) {
            register(descriptor.cellClass, forCellReuseIdentifier: descriptor.reuseIdentifier)
            reuseIdentifiers.insert(descriptor.reuseIdentifier)
        }
        
        let cell = dequeueReusableCell(withIdentifier: descriptor.reuseIdentifier, for: indexPath)
        descriptor.configure(cell)
        return cell
    }
    
    // MARK: - UITableViewDelegate
    @objc func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = itemForIndexPath(indexPath)
        didSelect(item)
    }
    
    // MARK: -
    func itemForIndexPath(_ indexPath: IndexPath) -> Item {
        return items[indexPath.section].items[indexPath.row]
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

let model: GenericTableModel<RecentItem> = [
    ("Artists", artists.map { .artist($0) } ),
    ("Albums", albums.map { .album($0) } ),
    ("Recent Items", recentItems)
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

let frame = CGRect(x: 0, y: 0, width: 400, height: 600)

let recentItemsVC = UIViewController()
recentItemsVC.title = "ViewController"
let recentItemsTableView = GenericTableViewController(items: model, cellDescriptor: { $0.cellDescriptor })
recentItemsTableView.frame = frame
recentItemsVC.view.addSubview(recentItemsTableView)

let nc = UINavigationController(rootViewController: recentItemsVC)

nc.view.frame = frame
PlaygroundPage.current.liveView = nc.view


print("💣💣💣💣")
