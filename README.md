＜このアプリについて＞


◇ご提示いただいた以下の要件を満たしたアプリです。

・NavigationController, TabBarControllerを理解する
・NavigationでのPush遷移とPopUpなどのModal遷移の違いを理解する
・StoryboardとAutoLayoutを使えるようにする
・TableViewかCollectionViewを使えるようにする
・CocoaPodを使えるようにする
・AlamofireかMoyaを使い、API通信を行い、JsonをパースするCodableを使用する
・githubにてコードを管理し、提出


＜機能について＞


Appleが提供する「iTunes Search API」と、私が作成と公開をした「Googleスプレッドシート」の英単語のAPIをコールできます。
２つの機能はタブバーより切り替えできます。


＜iTunes Search API＞


iTunesで曲を販売している音楽アーティストの中から、テキストフィールドに入力した名前に一致するアーティストの一覧を表示します。
各セル左に表示されているのは、アーティストの一番人気のアルバムのアートワークです。
ここでのAPI通信はすべて、CocoaPodでインストールしたAlamofireで実行しています。

・コードの流れ

(1) getitunesArtists(artistName:String)で、テキストに名前が一致するアーティスト情報(アーティスト名やHPのURL)を最大100件まで取得し、配列に格納

(2) getAlbumArtworkURL()で、(1)で取得した各アーティストの人気アルバムのアートワークのURLを取得し、配列に格納

(3) (1)と(2)で取得した情報でテーブルビューを作成、セルをタップでiTunesのアーティストページをSafariで開く

・補足１

(1)ではHTTPSessionではなくAlamofireでAPI通信
検索は完全一致のみヒット(検索キー”arian”ではAriana Grandeはヒットせず。正規表現などを試したが、iTunes Search APIでは部分一致での検索はできない模様)
テキストが入力されていない、変更されていないまま再検索した時などは、無駄な通信をしないようguardしています。

(1)のレスポンスを待って(2)を実行
また(2)では各アーティストについて個別に非同期処理でAPIコールしているが、情報は正しい順番で配列に格納
テーブルビューのセルの更新は、(2)のレスポンスを待ってから行う

また(2)で取得するアルバムアートは、ソロ作品を優先(ソロ作品がない場合は他アーティスト名義作品で参加しているもの)
音楽のアルバム作品には参加してないなどの理由でアルバムアートが見つからない場合は替わりに”blank100x100.png”という画像ファイルを表示

・補足２

右上にナビゲーションバーアイテムとして、モーダル画面遷移するボタンを配置
コンテンツのサイズに合わせてスクロール量が変わる機能について一次面接でお話が出ていたので実装しました。
コードによるコンテンツのサイズや座標の計算などは極力減らし、ストーリーボードのオートレイアウトを使用しています
(端末向きが変わっと時のみ、UIラベルに合わせて高さを再計算)


＜Googleスプレッドシートの英単語のAPI＞


私が自身のアプリ「カナタン」のために制作した単語リストの情報の一部をGASを使ってAPIとして公開し、本アプリから閲覧できるようにしたものです。
（一次面接の時にお話に出たGASを触ってみました）

・コードの流れ

(1) 下のタブを選択してビューが表示されると最初にAPIをコールし、すべての単語情報を取得し配列に格納
(2) セルをタップで画面遷移(プッシュ)で意味を表示（スライダーなどは無意味だが、ストーリーボードやUIを触る練習として実装）

・補足

iTunes Searechの時とは異なり、テキストが変わるたびに配列にフィルターをかける仕様
またAlamofireではなくHTTPSessionでコールしており、エラー処理などはきちんとしていないので、例えば機内モードだとアプリが落ちます
あくまでタブを使ったビュー遷移、GASの利用、スプレッドシートのAPI公開を目的として作成しました


＜最後に＞


API通信→テーブルビュー化するアプリを制作する際に必要になる機能は、ほぼ正しく実装できていると思います。
課題として挙げられた点以外にも、キーボードの退避するタイミングなど、UI/UXに関わる部分に必要最低限の配慮はした作りにしています。

以上
