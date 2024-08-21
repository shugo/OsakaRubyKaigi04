# strscanなしで文字列をスキャンする

## 自己紹介

* 前田修吾
* 株式会社ネットワーク応用通信研究所代表取締役社長
* Textbringerの作者
* 関西学生フォークソング連盟のコンサート以来の中之島

## [PR] 松江Ruby会議11

* 日時: 2024年10月5日(土) 12:30〜
* 場所: 松江オープンソースラボ
* 基調講演: 卜部昌平さん(松江市立母衣小学校卒)

## strscan

* StringScannerクラスを提供
* StringScanner.newの引数でスキャン対象の文字列を受け取る
* StringScannerは現在の位置(スキャンポインタ)をもつ

## StringScanner#scan(regexp)

* 現在の位置から正規表現によるマッチを行う
* マッチした部分文字列、または、nilを返す
* マッチした部分の末尾にスキャンポインタを進める

## StringScanner#match?(regexp)

* 現在の位置から正規表現によるマッチを行う
* マッチした部分文字列の長さ、または、nilを返す
* スキャンポインタは変更しない

## strscanの利用例

```
require "strscan"
s = StringScanner.new("Hello world")
p s.scan(/\w+/)      # -> "Hello"
p s.scan(/\s+/)      # -> " "
p s.match?(/\w+/)    # 5
p s.scan(/\w+/)      # -> "world"
```

## strscanなしで文字列をスキャンする?

![strscan便利](strscan_convenient.png)

## なぜstrscanを使わないか

* なるべくgemを使いたくない
* 現状はdefault gemだけど

## きっかけ

* Proper Semantic Versioning
    * https://github.com/ruby/rexml/issues/131
* rexmlにstrscanへの依存が増えてビルドエラー

## SemVerは関係ない

> What should I do if I update my own dependencies without changing the public API?
> That would be considered compatible since it does not affect the public API.

## All bugfixes are incompatibilities

![All bugfixes are incompatibilities](all_bugfixes_are_incompatibilities.png)

## LatestVer

* https://latestver.org/
* 常に最新のバージョンを使え
* すべての変更には意味がある

## String#scan

```
s = "Hello world"
p s.scan(/\w+/)      # ["Hello", "world"]
```

## String#scanの不便なところ

* 最後までまとめてスキャンしてしまう
* 一つの正規表現しか使えない
* パーサーの状態によって字句解析の仕方を変えたい

## String#index(regexp, offset = 0)

* offsetで指定した位置からマッチを行い、マッチした位置を返す
* StringScannerと違い、offsetより後の位置でもマッチする
    * `"foo bar".index(/bar/, 2) #=> 4`

## \A

* 正規表現のアンカーの一種
    * アンカーはマッチする位置を指定する
        * 幅をもたない(=長さ0の文字列にマッチ)
* 対象文字列の先頭にのみマッチする
* String#indexやRegexp#matchの第2引数で開始位置を指定した場合も、
  開始位置が対象文字列の先頭でない場合はマッチしない
    * `"foo bar".index(/\Abar/, 4) #=> nil`

## \G

* 正規表現のアンカーの一種
* scanやgsubのときに前回のマッチの直後の位置にマッチする
* String#indexやRegexp#matchの第2引数で開始位置を指定した場合、
  開始位置にマッチする
    * `"foo bar".index(/\Gbar/, 4) #=> 4`

## net-imapの例

```ruby
      BEG_REGEXP = /\G(?:\
(?# 1:  SPACE   )( )|\
(?# 2:  LITERAL8)#{Patterns::LITERAL8}|\
(?# 3:  ATOM prefixed with a compatible subtype)\
...
(?# 19: EOF     )(\z))/ni
...
      def next_token
        case @lex_state
        when EXPR_BEG
          if @str.index(BEG_REGEXP, @pos)
            @pos = $~.end(0)
            if $1
              return Token.new(T_SPACE, $+)
            elsif $2
              len = $+.to_i
              val = @str[@pos, len]
              @pos += len
              return Token.new(T_LITERAL8, val)
            elsif $3 && $7
              # greedily match ATOM, prefixed with NUMBER, NIL, or PLUS.
              return Token.new(T_ATOM, $3)
            ...
```

## String#indexの問題点

* 開始位置の指定が文字(コードポイント)単位
* 開始位置の計算時間がO(n)
    * マルチバイト文字を含む場合

## UTF-8の例

```
0        1        2        3        4  5  6  7   # 文字単位
た       の       し       い       R  u  b  y
E3 81 9F E3 81 AE E3 81 97 E3 81 84 52 75 62 79
0  1  2  3  4  5  6  7  8  9  10 11 12 13 14 15  # バイト単位
```

## なぜ普段困らないのか

* たいていは文字列を先頭から末尾まで処理する
    * gsubとかscanとか
* 困るケース
    * ランダムアクセスする場合
    * StringScannerのように一気になめない場合

## String#byteindex(regexp, offset)

* String#indexと似ているが、offsetはバイト単位で指定する

## ベンチマーク

```ruby
require "benchmark"

S = "あ" * 10240

Benchmark.bmbm do |b|
  b.report("index") do
    pos = 0
    while S.index(/\Gあ/, pos)
      pos = $~.offset(0).last
    end
  end

  b.report("byteindex") do
    pos = 0
    while S.byteindex(/\Gあ/, pos)
      pos = $~.byteoffset(0).last
    end
  end
end
```

## ベンチマーク結果

```
                user     system      total        real
index       0.815832   0.000000   0.815832 (  0.815845)
byteindex   0.002050   0.000000   0.002050 (  0.002050)
```

## [Feature #20576] Add MatchData#bytebegin and MatchData#byteend

* MatchData#begin/MatchData#endのバイトオフセット版
* 既存のMatchData#byteoffsetでも同じ情報が取れる
    * ただし、無駄な配列が生成されてしまう
        * `$~.byteoffset(0) #=> [4, 7]`
* 大阪Ruby会議04をきっかけに提案してRuby 3.4で導入予定

## net-imapの修正

* https://github.com/ruby/net-imap/pull/286

## 速くなっていない?

* Socketから読んだ文字列はASCII-8BIT
* ASCII-8BITだとString#indexでもO(n)

## ベンチマーク

```
$ ruby -I ~/src/net-imap/lib b2.rb   # master
Rehearsal -----------------------------------------
parse   0.661723   0.003435   0.665158 (  0.665231)
-------------------------------- total: 0.665158sec

            user     system      total        real
parse   0.658998   0.000000   0.658998 (  0.659019)
$ ruby -I ~/src/net-imap/lib b2.rb   # use_byteindex
Rehearsal -----------------------------------------
parse   0.641354   0.000000   0.641354 (  0.641432)
-------------------------------- total: 0.641354sec

            user     system      total        real
parse   0.662438   0.000000   0.662438 (  0.664375)
```

## まとめ

* String#byteindexにはテキストエディタ以外のユースケースもありえる
    * 理論的には
* 計測重要
* strscan便利
