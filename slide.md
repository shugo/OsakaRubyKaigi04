# strscanなしで文字列をスキャンする

author
:   Shugo Maeda

# Self introduction

* 前田修吾
* Textbringerの作者
* ネットワーク応用通信研究所代表取締役社長

# strscan

* なるべくgemを使いたくない

# LatestVer

# String#scan

* 最後までまとめてスキャンしてしまう
* 一つの正規表現しか使えない
* パーサーの状態によって字句解析の仕方を変える必要がある

# String#index

# \A

* 正規表現のアンカーの一種
    * アンカーはマッチする位置を指定し、幅をもたない(=長さ0の文字列にマッチ)
* 対象文字列の先頭にのみマッチする
* String#indexやRegexp#matchの第2引数で開始位置を指定した場合も、開始位置が対象文字列の先頭でない場合はマッチしない

# \G

* 正規表現のアンカーの一種
* scanやgsubのときに前回のマッチの直後の位置にマッチする
* String#indexやRegexp#matchの第2引数で開始位置を指定した場合、開始位置にマッチする

# String#indexの問題点

