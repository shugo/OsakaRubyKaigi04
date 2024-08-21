require "benchmark"
require "net/imap"

HEADER = <<EOF
Subject: テスト
Date: Wed, 21 Aug 2024 15:48:01 +0900
From: Shugo Maeda <shugo@ruby-lang.org>
To: shugo@ruby-lang.org
User-Agent: Mournmail/1.0.5 Textbringer/1.4.1 Ruby/3.4.0
Content-Type: text/plain; charset=utf-8

EOF

MAIL = (HEADER + "これはテストです。\n" * 1000).gsub(/\n/, "\r\n")

RESPONSE = <<EOF
* 7906 FETCH (UID 228707 FLAGS (\Seen) BODY[] {#{MAIL.bytesize}}\r
#{MAIL} BODY[] {#{MAIL.bytesize}}\r
#{MAIL} BODY[] {#{MAIL.bytesize}}\r
#{MAIL} BODY[] {#{MAIL.bytesize}}\r
#{MAIL} BODY[] {#{MAIL.bytesize}}\r
#{MAIL} BODY[] {#{MAIL.bytesize}}\r
#{MAIL} BODY[] {#{MAIL.bytesize}}\r
#{MAIL} BODY[] {#{MAIL.bytesize}}\r
#{MAIL} BODY[] {#{MAIL.bytesize}}\r
#{MAIL} BODY[] {#{MAIL.bytesize}}\r
#{MAIL})\r
EOF

parser = Net::IMAP::ResponseParser.new

Benchmark.bmbm do |b|
  b.report("parse") do
    10000.times do
      parser.parse(RESPONSE.b)
    end
  end
end

