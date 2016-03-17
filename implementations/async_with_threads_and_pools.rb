require "./lib/mailer"
require "benchmark"
require 'thread'

POOL_SIZE = (ARGV[0] || 10).to_i

# Create a Queue data structure for the jobs needs to be done. 
# Queue is thread-safe so if multiple threads
# access it at the same time, it will maintain consistency
jobs = Queue.new

# Push the IDs of mailers to the job queue
(ARGV[1] || 10_000).to_i.times{|i| jobs.push i}

workers = nil

puts Benchmark.measure {
  # Transform an array of 10 numbers into an array of workers
  workers = (POOL_SIZE).times.map do
    Thread.new do
      begin
        while x = jobs.pop(true)
          Mailer.deliver do 
            from    "eki_#{x}@eqbalq.com"
            to      "jill_#{x}@example.com"
            subject "Threading and Forking (#{x})"
            body    "Some content"
          end        
        end
      rescue ThreadError
      end
    end
  end

  workers.map(&:join)
}
