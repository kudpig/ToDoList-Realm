//
//  ViewViewController.swift
//  ToDoList-Realm
//
//  Created by Shinichiro Kudo on 2021/08/18.
//

import UIKit
import RealmSwift

class DetailViewController: UIViewController {
    
    private let realm = try! Realm()
    public var item: ToDoListItem?
    public var deletionHandler: ( () -> Void )?
    
    @IBOutlet weak var itemLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
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
