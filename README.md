AnalyseHatenaBookmarkHDPLDA
===========================
[はてブ記事を用いた興味分析](http://d.hatena.ne.jp/ni66ling/20141223/1419323806 "はてブ記事を用いた興味分析")の[HDP-LDAによるトピック解析](http://d.hatena.ne.jp/ni66ling/ "HDP-LDAによるトピック解析")のためのスクリプトです．  
事前に[データの準備](https://github.com/KenshoFujisaki/CreateHatenaBookmarkLogDB "データ準備")が完了していることを前提とします．  

以前にこちらと類似したソースコード[AnalyseHatenaBookmarkLDA](https://github.com/KenshoFujisaki/AnalyseHatenaBookmarkLDA "AnalyseHatenaBookmarkLDA")を公開しました．  
そちらとの相違点は，ハイパーパラメータであったトピック数(K)を自動決定することができるようになっています．  
したがって，こちらのコードでは実用上，パラメータ設定を行う必要がありません．計算の反復回数や初期値設定について設定可能な定数が存在しますが，それらは指定しなくてもそれなりに動作できます．  
この処理(HDP-LDA)は[David M. Blei - Topic modeling](http://www.cs.princeton.edu/~blei/topicmodeling.html "David M. Blei - Topic modeling")に公開されている[hdp](http://www.cs.cmu.edu/~chongw/software/hdp.tar.gz "hdp")を利用しています．  

本スクリプトにより，はてブ記事のトピック解析結果を下のようなワードクラウドに出力できます．
![HDP-LDAによるはてブのトピック解析結果](http://f.st-hatena.com/images/fotolife/n/ni66ling/20141231/20141231050519.png?1419970118)  
またこの図の見方は下のとおりです．
![ワードクラウドの見方](http://f.st-hatena.com/images/fotolife/n/ni66ling/20141231/20141231050954.png?1419970209)

# 事前準備
MacOSX環境を前提に説明します．
##### 1. 解析対象のはてブ記事群のデータ準備
[データの準備](https://github.com/KenshoFujisaki/CreateHatenaBookmarkLogDB "データ準備")に従って，はてブ記事群をMySQLに登録します．
##### 2. HDP-LDAのインストール
[David M. Blei - Topic modeling](http://www.cs.princeton.edu/~blei/topicmodeling.html "David M. Blei - Topic modeling")より[hdp](http://www.cs.cmu.edu/~chongw/software/hdp.tar.gz "hdp")をダウンロードし，コンパイルしたバイナリを「./HDP_LDA/hdp」に配置します．
具体的には次のような手順を行います．ただし，hdpをmakeするにはGSLライブラリがインストールされている必要があります．
```sh
$ cd ./HDP_LDA
$ wget http://www.cs.cmu.edu/~chongw/software/hdp.tar.gz
$ tar xvf hdp.tar.gz 
$ tar xvf hdp-split-merge.tar.gz
$ cd hdp
$ make #GSLライブラリが必要
$ cp hdp ../hdp
$ cd ..
$ rm -Rf ./hdp hdp-faster.zip hdp-split-merge.tar.gz
```
##### 3. [d3-cloud](https://github.com/jasondavies/d3-cloud "d3-cloud")のインストール  
```sh
$ cd ./HDP_LDA
$ git clone https://github.com/jasondavies/d3-cloud.git wordcloud
```
##### 4. wkhtmltoimageのインストール
[wkhtmltopdf](http://wkhtmltopdf.org/ "wkhtmltopdf")の「Download」からダウンロードし，インストールします．  
インストール後`$ wkhtmltoimage`が実行できれば完了です．
##### 5. 1.〜4.により，以下の様なディレクトリ構成になっていればOKです．
```sh
$ cd ./HDP_LDA
$ tree
.
├── hdp
├── mkhdpinput.sh
├── mkwordcloudhtml.sh
├── parseBeta.sh
├── parseResult.sh
├── topicsDat2beta.sh
├── wordAssignments2alpha.sh
└── wordcloud
    ├── LICENSE
    ├── README.md
    ├── d3.layout.cloud.js
    ├── index.js
    ├── lib
    │   └── d3
    │       ├── LICENSE
    │       └── d3.js
    └── package.json
```

# 使い方
##### 1. HDP-LDAの入力ファイルの作成
```sh
$ cd ./HDP_LDA
$ ./mkhdpinput.sh > hdp_input.dat
```
ここではリダイレクト先に「./HDP_LDA/hdp_input.dat」を指定していますが，任意に指定できます．
##### 2. HDP-LDAの実行
```sh
$ cd ./HDP_LDA
$ ./hdp --algorithm train --data hdp_input.dat --directory hdp_output --split_merge yes --max_iter 1001
```
ここでは出力ディレクトリ「--directory」に「./HDP_LDA/hdp_output」を指定していますが，任意に指定できます．
また，計算の反復回数「--max_iter」に「1001」を指定していますが，これも任意に指定できます．
##### 3. HDP-LDAの実行結果（トピックごとの単語の分布）の可視化（ワードクラウド化）
```sh
$ cd ./HDP_LDA
$ ./parseResult.sh ./hdp_output/[number_of_iterations]-topics.dat [number_of_rankings]
```
[number_of_iterations]には，2.における計算の反復回数を指定します．具体的には，「./HDP_LDA/hdp_output_dir」内における「\*-topics.dat」ファイルについて，「\*」の値が最大のものを指定します．例えば「01000-topics.dat」など．  
[number_of_rankings]には，ワードクラウドに表示する単語数を指定します．例えば「1000」など．
##### 4. 結果の確認
結果は「./HDP_LDA/wordcloud/visualize_csv/hdp_output/[number_of_iterations]-topics/topic[トピック番号].png」に出力されます．
これが上図のワードクラウドです．
