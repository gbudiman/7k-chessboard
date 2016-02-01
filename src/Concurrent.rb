require "#{File.dirname(__FILE__)}/../src/chessboard"
require 'ruby-prof'

class Concurrent
  def initialize **h
    @repeat = h[:repeat] || 25000
    @concurrency_limit = h[:concurrency_limit] || 512
    @queue = Array.new
    @statistics = { feature: 0, skfl: 0, rfs: 0}
    @acquisitions = Hash.new(0)
    @do_profiling = h[:do_profiling] || false
    @blank_board = initialize_blank_board
    @srand = Random.new

    @concurrents_spawned = 0
    @concurrents_completed = 0
  end

  def run_by_threads
    puts
    puts "Begin multithreading with #{@repeat} instances..."

    RubyProf.start if @do_profiling

    t1 = Time.new
    creator = Thread.new do
      loop do
        if @queue.length > @concurrency_limit
          sleep 0.1
          next
        end

        (@concurrency_limit / 2).times do
          @queue.push(Chessboard.new @srand, board: @blank_board.dup)
          @concurrents_spawned += 1
        end

        break if @concurrents_spawned >= @repeat
      end
    end

    executor = Thread.new do
      loop do
        if @queue.length == 0
          sleep 0.1
          next
        end

        s = @queue.pop.plot

        @statistics.each do |k, _junk|
          @statistics[k] = @statistics[k] + 1 if s.statistics[k] > 0
        end

        s.acquisitions.each do |data, count|
          @acquisitions[data] += count
        end

        @concurrents_completed += 1

        break if @concurrents_completed == @repeat
      end
    end

    monitor = Thread.new do
      latched_count = 0
      loop do
        sleep 0.5
        processed = (@concurrents_completed - latched_count) * 2
        printf "%10d / %10d [ %6d ] [ %6d instances/s]\n", 
               @concurrents_spawned, 
               @concurrents_completed, 
               @queue.length, 
               processed

        latched_count = @concurrents_completed
        break if @concurrents_spawned >= @repeat and @concurrents_completed >= @repeat
      end
    end

    creator.join
    executor.join
    monitor.join
    t2 = Time.new

    delta_time_s = sprintf("%4.2f", t2 - t1)
    speed_s = sprintf("%8.2f", @repeat / (t2 - t1))
    puts "Creator, Executor, and Monitor threads joined. Run completed"
    puts "Time elapsed:      #{delta_time_s} s"
    puts "Average speed: #{speed_s} instances/s"

    if @do_profiling
      result = RubyProf.stop 
      printer = RubyProf::GraphPrinter.new(result)
      printer.print
    end

    #ap @statistics
    #ap Hash[@acquisitions.sort{|a,b| b[1] <=> a[1]}]
  end

private
  def initialize_blank_board
    s = Hash.new
    (0..90).each { |i| s[i] = nil}
    return s
  end
end