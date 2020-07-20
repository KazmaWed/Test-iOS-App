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

let readMeText = """
彼は背後にひそかな足音を聞いた。それはあまり良い意味を示すものではない。誰がこんな夜更けに、しかもこんな街灯のお粗末な港街の狭い小道で彼をつけて来るというのだ。人生の航路を捻じ曲げ、その獲物と共に立ち去ろうとしている、その丁度今。
彼のこの仕事への恐れを和らげるために、数多い仲間の中に同じ考えを抱き、彼を見守り、待っている者がいるというのか。それとも背後の足音の主は、この街に無数にいる法監視役で、強靭な罰をすぐにも彼の手首にガシャンと下すというのか。彼は足音が止まったことに気が着いた。あわてて辺りを見回す。ふと狭い抜け道に目が止まる。 彼は素早く右に身を翻し、建物の間に消え去った。その時彼は、もう少しで道の真中に転がっていたごみバケツに躓き転ぶところだった。 彼は暗闇の中で道を確かめようとじっと見つめた。どうやら自分の通ってきた道以外にこの中庭からの出道はないようだ。 足音はだんだん近づき、彼には角を曲がる黒い人影が見えた。彼の目は夜の闇の中を必死にさまよい、逃げ道を探す。もうすべては終わりなのか。すべての苦労と準備は水の泡だというのか。 突然、彼の横で扉が風に揺らぎ、ほんのわずかにきしむのを聞いた時、彼は背中を壁に押し付け、追跡者に見付けられないことを願った。この扉は望みの綱として投げかけられた、彼のジレンマからの出口なのだろうか。背中を壁にぴったり押し付けたまま、ゆっくりと彼は開いている扉の方へと身を動かして行った。この扉は彼の救いとなるのだろうか。
彼は背後にひそかな足音を聞いた。それはあまり良い意味を示すものではない。誰がこんな夜更けに、しかもこんな街灯のお粗末な港街の狭い小道で彼をつけて来るというのだ。人生の航路を捻じ曲げ、その獲物と共に立ち去ろうとしている、その丁度今。 彼のこの仕事への恐れを和らげるために、数多い仲間の中に同じ考えを抱き、彼を見守り、待っている者がいるというのか。それとも背後の足音の主は、この街に無数にいる法監視役で、強靭な罰をすぐにも彼の手首にガシャンと下すというのか。彼は足音が止まったことに気が着いた。あわてて辺りを見回す。ふと狭い抜け道に目が止まる。 彼は素早く右に身を翻し、建物の間に消え去った。その時彼は、もう少しで道の真中に転がっていたごみバケツに躓き転ぶところだった。 彼は暗闇の中で道を確かめようとじっと見つめた。どうやら自分の通ってきた道以外にこの中庭からの出道はないようだ。 足音はだんだん近づき、彼には角を曲がる黒い人影が見えた。彼の目は夜の闇の中を必死にさまよい、逃げ道を探す。もうすべては終わりなのか。すべての苦労と準備は水の泡だというのか。 突然、彼の横で扉が風に揺らぎ、ほんのわずかにきしむのを聞いた時、彼は背中を壁に押し付け、追跡者に見付けられないことを願った。この扉は望みの綱として投げかけられた、彼のジレンマからの出口なのだろうか。背中を壁にぴったり押し付けたまま、ゆっくりと彼は開いている扉の方へと身を動かして行った。この扉は彼の救いとなるのだろうか。
"""
