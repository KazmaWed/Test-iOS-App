import Foundation
import Alamofire

class iTunesSearchAPIClass: NSObject {
    
    //アーティスト情報配列
    var iTunesAPI:Artists?
    var artists:[MusicArtist] = []
    
    //人気アルバム情報配列
    var iTunesLookupAPI:iTunesAlbums?
    var popularAlbums:[Album] = []
    var albumArtworkImages:[UIImage] = []
    
    //URL
    let baseUrl = "https://itunes.apple.com/"
    //json形式で取得
    let headers: HTTPHeaders = ["Content-Type": "application/json"]
    //通信エラー
    var ifError = false
    
    //アーティスト名検索
    func search(artistName:String, closure: @escaping () -> Void) -> Void {
        
        let searchUrl = "\(baseUrl)search"
        
        let parameters = ["term": artistName, //検索キーワード
            "media":"music", //検索する作品ジャンル
            "attribute":"artistTerm", //アーティスト名で検索する
            "entity":"musicArtist", //該当するアーティストを表示する
            "limit":"100"] //表示件数
        
        AF.request(searchUrl,
                   method: .get,
                   parameters: parameters,
                   encoding: URLEncoding(destination: .queryString),
                   headers: headers).responseJSON { response in
                    
                    //dataがあるかどうか確認ガード
                    guard let data = response.data else {
                        // self.alert(title: "Error", message: "Couldn't Connect")
                        return
                    }
                        
                    do {
                        
                        //data中のjsonを配列にして格納
                        self.iTunesAPI = try JSONDecoder().decode(Artists.self, from: data)
                        self.artists = self.iTunesAPI!.results as [MusicArtist]
                        print("\(self.artists.count) artists found")
                        closure()
                        
                    } catch let error {
                        
                        self.ifError = true
                        print("Error: \(error)")
                        closure()
                        
                    }
                    
        }
    }
    
    //アーティストの人気作品のアルバムアートワーク取得
    func lookup(closure: @escaping () -> Void) -> Void {
        
        //URL
        let searchUrl = "\(baseUrl)lookup"
        
        var parameters:[String : Any] = [
            "sort":"mostPopular", //人気順で検索する
            "entity":"album", //該当するアルバムを表示する
            "limit":"20" //調べる件数
        ]
        
        //アートワーク配列初期化
        for _ in 0...artists.count-1 {
            albumArtworkImages.append(UIImage())
        }
        
        for n in 0...artists.count-1 {
            
            //無ヒット時の仮画像
            self.albumArtworkImages[n] = UIImage(named:"blank100x100")!
            
            //アーティストIDがなければAMGIDで検索
            if let artistId = artists[n].artistId {
                parameters.updateValue(artistId, forKey: "id")
            } else if let amgArtistId = artists[n].amgArtistId {
                parameters.updateValue(amgArtistId, forKey: "amgArtistId")
            } else {
                albumArtworkImages[n] = UIImage(named:"blank100x100")!
                break
            }
            
            //リクエスト
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
                            let artistNameFixed = self.artists[n].artistName.replacingOccurrences(of: "+", with: " ")
                            
                            //アーティスト名義のアルバムURLがあるかどうか
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
                                }
                            }
                            
                            //closure(tableView更新)
                            if n == self.artists.count - 1 {
                                print("closure in lookup")
                                closure()
                            }
                            
                        } catch let error {
                            
                            self.ifError = true
                            print("Error: \(error)")
                            closure()
                            
                        }
                        
            }
            
        }
        
    }
    
}
