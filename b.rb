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
