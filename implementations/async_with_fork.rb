require "./lib/mailer"
require "benchmark"

POOL_SIZE = (ARGV[0] || 10).to_i

JOBS = (ARGV[1] || 10_000).to_i

chunk_size = JOBS / POOL_SIZE

puts Benchmark.measure{
  POOL_SIZE.times do |chunk|
    offset = chunk * chunk_size
    fork do
      offset.upto(offset + chunk_size - 1) do |i|
        Mailer.deliver do 
          from    "eki_#{i}@eqbalq.com"
          to      "jill_#{i}@example.com"
          subject "Threading and Forking (#{i})"
          body    "Some content"
        end
      end
    end
  end
  Process.waitall
}

