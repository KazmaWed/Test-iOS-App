//
//  ViewController.swift
//  Dictionary
//
//  Created by KazMacBook Pro on 2020/07/15.
//  Copyright © 2020 KAZMA WED. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //navigationBarTitle
        title = "Spreadsheet"
        
        //Seach Barのdelegate
        searchText.delegate = self
        
        //Table ViewのdataSource
        tableView.dataSource = self
        //Table ViewのDelegate
        tableView.delegate = self
        //ドラッグでキーボード退避
        tableView.keyboardDismissMode = .onDrag
        
        getAPI()
        
    }

    @IBOutlet weak var searchText: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //単語情報タプル配列
    var wordList:[Word] = []
    //検索対象語
    var filteredWordList:[Word] = []
    //選択した単語
    var selectedWord:Word? = nil
    
    //----------------------------------------API取得----------------------------------------
    
    func getAPI() {
        
        //アクティビティインジケータ表示
        self.activityIndicator.startAnimating()
        
        //テーブルビュー一時非表示
        self.tableView.isHidden = true
        //テキストエリア、表示
        self.searchText.placeholder = "Wait for API call to finish..."
        
        let url: URL = URL(string: "https://script.google.com/macros/s/AKfycbxnuGrSsTpDb59I1IkRD-iM_wG7kf26b4s3V51vEvs75jQKsaoi/exec")!
        let task: URLSessionTask = URLSession.shared.dataTask(with: url, completionHandler: {(data, response, error) in
            
            do{
                //wordList配列に格納
                self.wordList = try JSONDecoder().decode([Word].self, from: data!)
                self.filteredWordList = self.wordList
                
                //Table Viewを更新
                DispatchQueue.main.async {
                    //セルを更新
                    self.tableView.reloadData()
                    //テーブルビュー表示
                    self.tableView.isHidden = false
                    //テキストエリア、表示
                    self.searchText.placeholder = "Enter"
                    
                    //アクティビティインジケータ非表示
                    self.activityIndicator.stopAnimating()
                }
                
            } catch {
                print(error)
            }
        })
        //実行
        task.resume()
    }
    
    //----------------------------------------テキストフィールド----------------------------------------
    
    //検索ボタンタップ時
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //キーボードを閉じる
        view.endEditing(true)
    }
    
    //テキストフィールドの値の更新時
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        //文字が入力されてる時
        if let searchWord = searchBar.text {
            
            //検索リスト更新
            filteredWordList = []
            
            //頭が一致する単語だけ抜き出し
            let searchWordLength = searchWord.count
            for eachWord in wordList {
                if eachWord.word.prefix(searchWordLength) == searchWord.lowercased() {
                    filteredWordList.append(eachWord)
                }
            }
            
        } else { //検索後がない時
            filteredWordList = wordList
            
            print("No Search Word...")
        }
        
        //更新
        tableView.reloadData()
        
    }
    
    //----------------------------------------テーブルビュー----------------------------------------
    
    
    //tableView設定
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredWordList.count
    }
    
    //tableViewセルの設定
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //セルオブジェクト1行取得
        let cell = tableView.dequeueReusableCell(withIdentifier: "wordCell", for: indexPath)
        //セルのタイトル
        cell.textLabel?.text = filteredWordList[indexPath.row].word
        
        return cell
    }
    
    //tableViewセル選択時
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //セルのハイライト解除
        tableView.deselectRow(at: indexPath, animated: true)
        
        //選択した単語を格納
        self.selectedWord = filteredWordList[indexPath.row]
        //画面遷移
        performSegue(withIdentifier: "showDetailView",sender: nil)
        
    }
 
    //遷移先に単語情報を渡す
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showDetailView")
        {
            let detailVC = segue.destination as! DetailViewController
            detailVC.word = selectedWord
        }
    }
    
}

