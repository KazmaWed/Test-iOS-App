//
//  ContainerViewController.swift
//  Dictionary
//
//  Created by KazMacBook Pro on 2020/07/20.
//  Copyright © 2020 KAZMA WED. All rights reserved.
//

import UIKit

class ContainerViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        textInContainer.text = txtToString(fileName: "README")
    }
    
    override func viewDidLayoutSubviews() {
        sizeFitToContents()
    }
    
    @IBOutlet weak var textInContainer: UILabel!
    
    func sizeFitToContents() {
        
        //メインスレッドてUIリサイズ
        DispatchQueue.main.async {
            //ラベルのサイズを調整
            self.textInContainer.sizeToFit()
            //ラベルの高さを取得
            let contentHeight = self.textInContainer.frame.size.height
            //スクロールビューのコンテンツサイズを調整
            self.view.frame.size.height = contentHeight
            
            //スクロールビュー(親ビュー内)のコンテンツ高さ調整
            let parentVC = self.parent as! ModalViewController
            parentVC.scrollView.contentSize.height = contentHeight
            
        }
        
    }
    
    @objc func sizeFitToContents(_ notification: NSNotification) {
        sizeFitToContents()
    }

}
