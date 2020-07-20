//
//  DetailViewController.swift
//  Dictionary
//
//  Created by KazMacBook Pro on 2020/07/16.
//  Copyright © 2020 KAZMA WED. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    //親から受け取るWord
    var word:Word? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //navigationBarTitle
        title = word?.word
        navigationController?.navigationBar.prefersLargeTitles = true
        
        //単語の意味表示
        wordsMeaningLabel.text = word?.meaning

        //意味ラベルのフォントサイズ表示
        fontsizeLabel.text = String(Int(wordsMeaningLabel.font.pointSize))
        
        //スライダーの初期値
        fontsizeSlider.value = Float(Int(wordsMeaningLabel.font.pointSize))
        fontsizeSlider.addTarget(self,
                                 action: #selector(self.sliderChange),
                                 for: .valueChanged)
        
    }
    
    @IBOutlet weak var wordsMeaningLabel: UILabel!
    @IBOutlet weak var fontsizeLabel: UILabel!
    
    @IBOutlet weak var fontsizeSlider: UISlider!
    
    @objc func sliderChange(sender: UISlider) {
        
        //スライダーの値を取得して
        let sliderValue = Float(Int(sender.value))
        //意味ラベルのサイズ変更
        wordsMeaningLabel.font = wordsMeaningLabel.font.withSize(CGFloat(Int(sender.value)))
        //値の表示
        fontsizeLabel.text = String(Int(sliderValue))
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // 戻るボタン押下時の処理を行います
        if let viewControllers = self.navigationController?.viewControllers {
            
            // 戻るタップ時にNavigationControllerの中に自身は存在しないかどうか
            var existSelfInViewControllers = true
            for viewController in viewControllers {
                if viewController == self {
                    // NavigationControllerの中に自分自身が存在した場合
                    existSelfInViewControllers = false
                    break
                }
            }
            
            if existSelfInViewControllers {
                // 戻るボタンがタップされた時
                navigationController?.navigationBar.prefersLargeTitles = false
            }
            
        }
        
        // スーパークラスのメソッド呼び出し
        super.viewWillDisappear(animated)
    }

}
