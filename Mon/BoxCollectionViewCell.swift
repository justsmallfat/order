//
//  BoxCollectionViewCell.swift
//  BowlingApp
//
//  Created by 小胖 on 2019/6/12.
//  Copyright © 2019 smallfat5566. All rights reserved.
//

import UIKit


protocol orderSetDelegate {
    func orderSet(index:Int, name:String?, count:Int?)
}
class BoxCollectionViewCell: UICollectionViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var count: UITextField!
    
    var delegate : orderSetDelegate?
    
    var boxScore = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func initWithData(data:[String:Any]) {
        self.name.text = data["name"] as? String
        
        let num = data["count"] as! Int
        self.count.text = String(num)
        
        self.count.delegate = self
        self.name.delegate = self
    }
    func textFieldDidBeginEditing(_ textField: UITextField) -> Bool {
        let index = textField.tag
//        textField.becomeFirstResponder()
        textField.selectAll(nil)

        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let index = textField.tag
        let value = textField.text
        if index>=100 {
            // count
            let tempIndex = index-100
            let tempValue = Int(value ?? "")
            self.delegate?.orderSet(index: tempIndex, name: nil, count: tempValue)
        }else{
            // name
            self.delegate?.orderSet(index: index, name: value, count: nil)
        }
        
        print("index : \(index)} value \(String(describing: value))")
        textField.resignFirstResponder()
        return true
    }

}
