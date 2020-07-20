//
//  ModalViewController.swift
//  Dictionary
//
//  Created by KazMacBook Pro on 2020/07/19.
//  Copyright © 2020 KAZMA WED. All rights reserved.
//

import UIKit

class ModalViewController: UIViewController {

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    func resizeScrollContent() {
        scrollView.contentSize.height = containerView.frame.size.height
    }
    
}
