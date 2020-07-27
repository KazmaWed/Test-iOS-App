import UIKit
import SafariServices
import Alamofire

class FirstViewController: UIViewController, UISearchBarDelegate, SFSafariViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //navigationBarTitle
        title = "iTunes Artist Search"
        
        //バーボタンアイテムの追加
        navibarButtonItem = UIBarButtonItem(title: "Modal", style: .done, target: self,
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
    
    //IBアウトレット
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
        
        //キーボードを閉じる
        view.endEditing(true)
        
        //テキスト無変更時、セルを更新しない
        guard lastSearchedText != searchBar.text! else { return }
        
        //テキストバー空白時、セルを空白に
        guard searchBar.text! != "" else { artists = []; tableView.reloadData(); return }
        
        //アクティビティインジケータ表示
        tableViewDeactivate()
        
        //検索したテキスト保存
        lastSearchedText = searchBar.text!
        
        //API通信開始
        getiTunesArtist(closure: {() -> Void in
            
            //通信エラー時アラート
            guard !self.iTunesSearchAPI.ifError else {
                //アラート表示
                self.alert(title: "Error", message: "Something went wrong...")
                //テーブルビュー更新
                self.tableViewActivate()
                return
            }
            
            //検索に1件もヒットしてない場合
            guard self.artists.count != 0 else {
                //アラート
                self.alert(title: "Error", message: "No Artists Hit")
                //テーブルビュー更新
                self.tableViewActivate()
                return
            }
                
            //ヒットした場合はアートワーク取得
            self.getAlbumArtworkURL(closure: {() -> Void in
                //テーブルビュー更新
                self.tableViewActivate()
            })
            
            
            
        })
                
        //キーボードを閉じる
        view.endEditing(true)
    }
    
    //テキストフィールドの値の更新時
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        //リスト・最終検索語初期化
        artists = []
        lastSearchedText = ""
        
        //更新
        tableView.reloadData()
        
    }
    
    
    //------------------------------iTunes Search API取得------------------------------
    
    
    //iTunesSearchAPIクラス
    let iTunesSearchAPI = iTunesSearchAPIClass()
    
    //アーティスト情報配列
    var artists:[MusicArtist] = []
    //人気アルバム情報配列
    var albumArtworkImages:[UIImage] = []
    
    //アーティスト情報取得
    func getiTunesArtist(closure: @escaping () -> Void) {

        iTunesSearchAPI.search(artistName: searchText.text!, closure: {() -> () in
            
            self.artists = self.iTunesSearchAPI.artists
            closure()
            
        })
    }

    //アーティストのIDから人気アルバムの画像URL取得
    func getAlbumArtworkURL(closure: @escaping () -> Void) {
        
        //アートワーク配列初期化
        albumArtworkImages = []
        
        //アーティストがいなければ
        guard artists.count != 0 else {
            //空のtableView表示
            tableViewActivate()
            return
        }
        
        iTunesSearchAPI.lookup(closure: {() -> Void in
            
            self.albumArtworkImages = self.iTunesSearchAPI.albumArtworkImages
            closure()
            
        })
        
    }
    
    //------------------------------アラート表示簡易化------------------------------
    
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


//------------------------------テーブルビュー------------------------------


extension FirstViewController: UITableViewDelegate, UITableViewDataSource {

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
    
    //通信開始時にテーブルビューを無効化
    func tableViewDeactivate() {
        activityIndicator.startAnimating()
        tableView.isHidden = true
    }
    
    //テーブルビュー有効化
    func tableViewActivate() {
        activityIndicator.stopAnimating()
        tableView.reloadData()
        tableView.isHidden = false
    }
    
}
