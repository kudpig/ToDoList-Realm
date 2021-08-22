# ToDoList-Realm
Realm使ってみた。簡易ToDo機能

## プレビュー

<img src="https://i.gyazo.com/c465fa221081e3e80b34222ec6ce6e3a.gif" width="400">

## コード

### Realm-Data

```swift
class ToDoListItem: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var date: Date = Date()
}
```

### ViewController

```swift
import UIKit
import RealmSwift

final class ViewController: UIViewController {

    @IBOutlet private weak var table: UITableView!
    
    private let realm = try! Realm()
    private var data = [ToDoListItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "ToDoList"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                            target: self,
                                                            action: #selector(didTapAddButton))
        
        data = realm.objects(ToDoListItem.self).map { $0 }
            
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.delegate = self
        table.dataSource = self
    }

}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = data[indexPath.row].title
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Open the screen where we can see item info and delete
        let item = data[indexPath.row]
        
        guard let vc = storyboard?.instantiateViewController(identifier: "detail") as? DetailViewController else {
            return
        }
        
        vc.item = item
        vc.deletionHandler = { [weak self] in
            self?.refresh()
        }
        vc.title = item.title
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func didTapAddButton() {
        guard let vc = storyboard?.instantiateViewController(identifier: "entry") as? EntryViewController else {
            return
        }
        vc.completionHandler = { [weak self] in
            self?.refresh()
        }
        
        vc.title = "New Item"
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func refresh() {
        data = realm.objects(ToDoListItem.self).map { $0 } // realm.objectsの中のToDoListItem.typeをmapで取り出して配列にして返している
        table.reloadData()
    }
    
}
```

### EntryViewController (ToDO作成画面)

```swift
import UIKit
import RealmSwift

final class EntryViewController: UIViewController {
    
    @IBOutlet private weak var textField: UITextField!
    @IBOutlet private weak var datePicker: UIDatePicker!
    
    private let realm = try! Realm()
    public var completionHandler: ( () -> Void )?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.becomeFirstResponder()
        textField.delegate = self
        datePicker.setDate(Date(), animated: true)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didTapSaveButton))
    }
    
    @objc private func didTapSaveButton() {
        if let text = textField.text, !text.isEmpty {
            let date = datePicker.date
            
            realm.beginWrite()  // トランザクションの開始
            let newItem = ToDoListItem()
            newItem.date = date
            newItem.title = text
            realm.add(newItem)
            try! realm.commitWrite() // トランザクションの終了
            
            completionHandler?()
            navigationController?.popToRootViewController(animated: true)
        }
        else {
            print("Add something")
        }
        
    }
    
}

extension EntryViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
```

### DetailViewController (詳細表示/ToDo削除)

```swift
import UIKit
import RealmSwift

final class DetailViewController: UIViewController {
    
    private let realm = try! Realm()
    public var item: ToDoListItem?
    public var deletionHandler: ( () -> Void )?
    
    @IBOutlet private weak var itemLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    
    static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return dateFormatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        itemLabel.text = item?.title
        dateLabel.text = DetailViewController.dateFormatter.string(from: item!.date)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash,
                                                            target: self,
                                                            action: #selector(didTapDelete))
    }

    @objc private func didTapDelete() {
        guard let myItem = self.item else {
            return
        }
        
        realm.beginWrite()
        realm.delete(myItem)
        try! realm.commitWrite()
        
        deletionHandler?()
        navigationController?.popToRootViewController(animated: true)
    }   
}
```
