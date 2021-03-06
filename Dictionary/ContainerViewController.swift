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
    
    //オートレイアウト時に実行
    override func viewDidLayoutSubviews() {
        sizeFitToContents()
    }
    
    //IBアウトレット
    @IBOutlet weak var textInContainer: UILabel!
    
    //スクロールビューのコンテンツサイズをUIラベルにフィットさせる
    func sizeFitToContents() {
        
        //メインスレッドてUIリサイズ
        DispatchQueue.main.async {
            //ラベルのサイズを調整
            self.textInContainer.sizeToFit()
            //ラベルの高さを取得
            let contentsHeight = self.textInContainer.frame.size.height
            //スクロールビューのコンテンツサイズを調整
            self.view.frame.size.height = contentsHeight
            
            //スクロールビュー(親ビュー内)のコンテンツ高さ調整
            let parentVC = self.parent as! ModalViewController
            parentVC.scrollView.contentSize.height = contentsHeight
            
        }
        
    }

}
