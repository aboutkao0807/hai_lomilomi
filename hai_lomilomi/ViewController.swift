//
//  ViewController.swift
//  hai_lomilomi
//
//  Created by Macintosh on 2025/8/22.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


}



extension UIViewController {
    /// 鍵盤升起
      func enableTapToDismissKeyboard() {
          let tap = UITapGestureRecognizer(target: self, action: #selector(__dismissKeyboard))
          tap.cancelsTouchesInView = false
          view.addGestureRecognizer(tap)
      }

      /// 鍵盤下降
      @objc private func __dismissKeyboard() {
          view.endEditing(true)
      }
    
}
