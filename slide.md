# strscanなしで文字列をスキャンする

## 自己紹介

* 前田修吾
* Textbringerの作者
* ネットワーク応用通信研究所代表取締役社長
* 関西学生フォークソング連盟出身

## 松江Ruby会議11

* 日時: 2024年10月5日(土) 12:30〜
* 場所: 松江オープンソースラボ
* 基調講演: 卜部昌平さん(松江市立母衣小学校卒)

## strscan

```
require "strscan"
s = StringScanner.new("Hello world")
p s.scan(/\w+/)      # -> "Hello"
p s.scan(/\s+/)      # -> " "
p s.scan(/\w+/)      # -> "world"
```

## 「strscanなしで」?

![strscan便利](strscan_convenient.png)

## なぜstrscanを使わないか

* なるべくgemを使いたくない
* 現状はdefault gemだけど

# Proper Semantic Versioning?

* https://github.com/ruby/rexml/issues/131
* rexmlにstrscanへの依存が増えてビルドエラー
* SemVerは関係ない

## LatestVer

* https://latestver.org/
* すべての変更には意味がある
* 常に最新のバージョンを使え

## String#scan

```
s = "Hello world"
p s.scan(/\w+/)      # ["Hello", "world"]
```

# String#scanの不便なところ

* 最後までまとめてスキャンしてしまう
* 一つの正規表現しか使えない
* パーサーの状態によって字句解析の仕方を変えたい

## String#index

## \A

* 正規表現のアンカーの一種
    * アンカーはマッチする位置を指定し、幅をもたない(=長さ0の文字列にマッチ)
* 対象文字列の先頭にのみマッチする
* String#indexやRegexp#matchの第2引数で開始位置を指定した場合も、開始位置が対象文字列の先頭でない場合はマッチしない

## \G

* 正規表現のアンカーの一種
* scanやgsubのときに前回のマッチの直後の位置にマッチする
* String#indexやRegexp#matchの第2引数で開始位置を指定した場合、開始位置にマッチする

## String#indexの問題点

