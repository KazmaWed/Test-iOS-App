//
//  Struct.swift
//  Dictionary
//
//  Created by KazMacBook Pro on 2020/07/15.
//  Copyright © 2020 KAZMA WED. All rights reserved.
//

import UIKit
import Foundation

//iTunesAPI アーティスト名でSearchしたJsonの構造体
struct Artists: Codable {
    
    let resultCount:Int
    let results:[MusicArtist]
    
}

struct MusicArtist: Codable {
    let artistName:String
    let artistLinkUrl:URL?
    let amgArtistId:Int?
    let artistId:Int?
    var primaryGenreName:String?
}

//iTunesAPI AMGアーティストIDでLookupしたJsonの構造体
struct iTunesAlbums: Codable {
    let resultCount: Int
    let results:[Album]
}

struct Album: Codable {
    let albumName:String?
    let artistName:String?
    let artworkUrl100:URL?
    let artworkUrl60:URL?
}

//単語情報の構造体
struct Word: Codable {
    let grade:String
    let group: String
    let word:String
    let meaning:String
    let part:String
    let pronunce:String
    let info1:String
    let info2:String
    let info3:String
    let info4:String
    let exampleen:String
    let examplejp:String
}

//画像URLからUIImageを簡単にするエクステンション
extension UIImage {
    public convenience init(url: URL) {
        do {
            let data = try Data(contentsOf: url)
            self.init(data: data)!
            return
        } catch let err {
            print("Error : \(err.localizedDescription)")
        }
        self.init()
    }
}

//txtファイルをStringにしてReturn
func txtToString(fileName:String) -> String {
    
    //プロジェクト内にあるtxtのパス取得
    guard let fileURL = Bundle.main.url(forResource: fileName, withExtension: "txt")  else {
        print("ファイルが見つからない")
        return ""
    }
    
    //txtファイルの内容をfileContents:Stringに読み込み
    guard let fileContents = try? String(contentsOf: fileURL) else {
        print("ファイル読み込みエラー")
        return ""
    }
    
    return fileContents
    
}
