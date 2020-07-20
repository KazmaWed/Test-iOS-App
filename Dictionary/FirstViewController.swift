//
//  FirstViewController.swift
//  Dictionary
//
//  Created by KazMacBook Pro on 2020/07/17.
//  Copyright © 2020 KAZMA WED. All rights reserved.
//

import UIKit
import SafariServices
import Alamofire

class FirstViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, SFSafariViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //navigationBarTitle
        title = "iTunes Artist Search"
        
        //バーボタンアイテムの追加
        navibarButtonItem = UIBarButtonItem(title: "Read Me", style: .done, target: self,
                                            action: #selector(navibarButtonTapped(_:)))
        self.navigationItem.rightBarButtonItems = [navibarButtonItem]
        
        //Seach Textのdelegate
        searchText.delegate = self
        //プレイスホルダー
        searchText.placeholder = "Artist Name"
        
        //Table ViewのdataSource
        tableView.dataSource = self
        //Table ViewのDelegate
        tableView.delegate = self
        
        //ドラッグでキーボードを閉じる
        tableView.keyboardDismissMode = .onDrag
        
    }
    
    @IBOutlet weak var searchText: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var navibarButtonItem :UIBarButtonItem!
    
    
    //------------------------------ナビゲーションバーのボタン------------------------------
    
    
    @objc func navibarButtonTapped(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "toFirstviewNaviitem", sender: nil)
    }
    
    
    //------------------------------テキストフィールド------------------------------
    
    
    //最後に検索したテキスト
    var lastSearchedText = ""
    
    //検索ボタンタップ時
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        //テキスト無変更時、セルを更新せずキーボードを閉じる
        guard lastSearchedText != searchBar.text! else {
            //キーボードを閉じる
            view.endEditing(true)
            return
        }
        
        //テキストバーが空かチェック
        if searchBar.text! != "" {
            //アクティビティインジケータ表示
            activityIndicator.startAnimating()
            tableView.isHidden = true
            //検索したテキスト保存
            lastSearchedText = searchBar.text!
            //API通信開始
            getiTunesArtist(artistName: searchBar.text!)
        } else {
            artists = []
            tableView.reloadData()
        }
                
        //キーボードを閉じる
        view.endEditing(true)
    }
    
    //テキストフィールドの値の更新時
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        //検索リスト更新
        artists = []
        
        //更新
        tableView.reloadData()
        
    }
    
    
    //------------------------------テーブルビュー------------------------------
    
    
    //tableView設定
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return artists.count
    }
    
    //tableViewセルの設定
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //セルオブジェクト1行取得
        let cell = tableView.dequeueReusableCell(withIdentifier: "artistCell", for: indexPath)
        //セルのタイトル
        cell.textLabel?.text = artists[indexPath.row].artistName
        //
        cell.imageView?.image = albumArtworkImages[indexPath.row]
        
        return cell
    }
    
    //tableViewタップ時
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //セルのハイライト解除
        tableView.deselectRow(at: indexPath, animated: true)
        
        //アーティストページのURL
        let artistPageUrl = artists[indexPath.row].artistLinkUrl!
        //サファリを開く
        let safariViewController = SFSafariViewController(url: artistPageUrl)
        //delegate
        safariViewController.delegate = self
        present(safariViewController, animated: true, completion: nil)
        
    }
    
    
    //------------------------------iTunes Search API取得------------------------------
    
    
    //アーティスト情報配列
    var iTunesAPI:Artists?
    var artists:[MusicArtist] = []
    //人気アルバム情報配列
    var iTunesLookupAPI:iTunesAlbums?
    var popularAlbums:[Album] = []
    var albumArtworkImages:[UIImage] = []
    
    //アーティスト情報取得
    func getiTunesArtist(artistName:String) {

        //URL
        let baseUrl = "https://itunes.apple.com/"
        let searchUrl = "\(baseUrl)search"
        
        //json形式で取得
        let headers: HTTPHeaders = ["Content-Type": "application/json"]
        
        let parameters = ["term": artistName, //検索キーワード
            "media":"music", //検索する作品ジャンル
            "attribute":"artistTerm", //アーティスト名で検索する
            "entity":"musicArtist", //該当するアーティストを表示する
            "limit":"50"] //表示件数
        
        //直列キュー
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "queue")
        
        //リクエスト
        dispatchGroup.enter()
        dispatchQueue.async(group: dispatchGroup) {
            AF.request(searchUrl, method: .get, parameters: parameters,
                       encoding: URLEncoding(destination: .queryString),
                       headers: headers).responseJSON { response in
                        
                        //dataがあるかどうか確認ガード
                        guard let data = response.data else {
                            self.alert(title: "Error", message: "Couldn't Connect")
                            dispatchGroup.leave()
                            return
                        }
                        do {
                            //data中のjsonを配列にして格納
                            self.iTunesAPI = try JSONDecoder().decode(Artists.self, from: data)
                            self.artists = self.iTunesAPI!.results as [MusicArtist]
                            
                            dispatchGroup.leave()
                            
                        } catch let error {
                            //正しく取得できなかった時
                            self.alert(title: "Error", message: "Something Went Wrong")
                            print("Error: \(error)")
                            
                            dispatchGroup.leave()
                        }
                        
            }
        }
        
        //アートワークURLを取得
        dispatchGroup.notify(queue: .main) {
            //検索に1件もヒットしてない場合はアラート
            if self.artists.count == 0 {
                self.alert(title: "Error", message: "No Artists Hit")
                self.activityIndicator.stopAnimating()
                self.tableView.isHidden = false
            } else {
                self.getAlbumArtworkURL()
            }
        }
        
    }

    //AMGIDから人気アルバムの画像URL取得
    func getAlbumArtworkURL() {
        
        //直列キュー
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "queue")
        
        //アートワーク配列初期化
        albumArtworkImages = []
        
        //アーティストがいなければ
        guard artists.count != 0 else {
            //空のtableView表示
            self.tableView.reloadData()
            self.tableView.isHidden = false
            return
        }
        
        for _ in 0...artists.count-1 {
            albumArtworkImages.append(UIImage())
        }
        
        for n in 0...artists.count-1 {
            
            //アーティスト名
            let artistName:String = artists[n].artistName
            
            //URL
            let baseUrl = "https://itunes.apple.com/"
            let searchUrl = "\(baseUrl)lookup"
            
            //json形式で取得
            let headers: HTTPHeaders = ["Content-Type": "application/json"]
            
            var parameters:[String : Any] = [
                "sort":"mostPopular", //人気順で検索する
                "entity":"album", //該当するアルバムを表示する
                "limit":"20" //調べる件数
            ]
            
            if let artistId = artists[n].artistId {
                parameters.updateValue(artistId, forKey: "id")
            } else if let amgArtistId = artists[n].amgArtistId {
                parameters.updateValue(amgArtistId, forKey: "amgArtistId")
            } else {
                albumArtworkImages[n] = UIImage(named:"blank100x100")!
                break
            }
            
            //リクエスト
            dispatchGroup.enter()
            dispatchQueue.async(group: dispatchGroup) {
                AF.request(searchUrl, method: .get, parameters: parameters,
                           encoding: URLEncoding(destination: .queryString),
                           headers: headers).responseJSON { response in
                            
                            //dataがあるかどうか確認ガード
                            guard let data = response.data else { return }
                            do {
                                //data中のjsonを配列にして格納
                                self.iTunesLookupAPI = try JSONDecoder().decode(iTunesAlbums.self, from: data)
                                self.popularAlbums = self.iTunesLookupAPI!.results as [Album]
                                
                                //アルバムにアーティスト名が完全一致する作品があるかどうか
                                let artistNameFixed = artistName.replacingOccurrences(of: "+", with: " ")
                                
                                //アーティスト名義のアルバムURL
                                var ifSoloAlbumArtworkFound = false
                                //参加アルバムがが見つかったかどうか
                                var ifCompAlbumArtworkFound = false
                                var compAlbumArtworkUrl:URL? = nil
                                
                                //すべてのアルバムについて
                                for eachAlbum in self.popularAlbums {
                                    
                                    //アルバムアートワークURLもあれば配列に格納
                                    if eachAlbum.artworkUrl100 != nil || eachAlbum.artworkUrl60 != nil {
                                        
                                        var albumartUrlFound:URL
                                        if eachAlbum.artworkUrl100 != nil {
                                            albumartUrlFound = eachAlbum.artworkUrl100!
                                        } else {
                                            albumartUrlFound = eachAlbum.artworkUrl60!
                                        }
                                        
                                        //アーティスト名が完全一致したら
                                        if eachAlbum.artistName == artistNameFixed {
                                            
                                            //配列に格納
                                            self.albumArtworkImages[n] = UIImage(url: albumartUrlFound)
                                            //ループ終了
                                            ifSoloAlbumArtworkFound = true
                                            break
                                            
                                        } else if !ifCompAlbumArtworkFound { //アーティスト名一致しないアルバム一時保存
                                            
                                            //参加アルバムアートのURL一時保存
                                            compAlbumArtworkUrl = albumartUrlFound
                                            ifCompAlbumArtworkFound = true
                                        }
                                        
                                    }
                                    
                                }
                                
                                //ソロ作品アルバムアートワークが見つからなかった場合
                                if !ifSoloAlbumArtworkFound {
                                    //参加作品アルバムアートワークがあれば格納
                                    if ifCompAlbumArtworkFound {
                                        self.albumArtworkImages[n] = UIImage(url: compAlbumArtworkUrl!)
                                    } else { //アートワークが見つからなければ画像
                                        self.albumArtworkImages[n] = UIImage(named:"blank100x100")!
                                    }
                                }
                                
                                dispatchGroup.leave()
                                
                            } catch let error {
                                print("Error: \(error)")
                                
                                dispatchGroup.leave()
                            }
                }
            }
            
        }
        
        dispatchGroup.notify(queue: .main) {
            //tableView更新
            self.tableView.reloadData()
            self.tableView.isHidden = false
        }
        
    }
  
    
    //------------------------------アラート表示簡易化ファンクション------------------------------
    
    
    func alert(title:String, message:String) {
        let alertController = UIAlertController(title: title,
                                            message: message,
                                            preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK",
                                                style: .default,
                                                handler: nil))
        present(alertController, animated: true)
    }
    
    
    
}


