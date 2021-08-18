//
//  EntryViewController.swift
//  ToDoList-Realm
//
//  Created by Shinichiro Kudo on 2021/08/18.
//

import UIKit
import RealmSwift

class EntryViewController: UIViewController {
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    
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
    
    @objc func didTapSaveButton() {
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
