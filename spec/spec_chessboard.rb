require "#{File.dirname(__FILE__)}/../src/chessboard"
require 'ruby-prof'

RSpec.describe Chessboard do
  before :each do
    @chessboard = Chessboard.new
  end

  context "initialization" do
    it "should have 90 tiles" do
      expect(@chessboard.board.keys.sort).to eq((0..90).to_a)
    end
  end

  context "fill" do
    it "should raise RuntimeError if no empty tile available" do
      @chessboard._debug_fill_all
      expect(@chessboard.board.value? nil).to be(false)
      expect { @chessboard.plot }.to raise_error(RuntimeError, /Board full/)
    end

    it "should fill board with no empty space" do
      @chessboard.plot
      expect(@chessboard.is_full?).to be(true)
    end
  end

  context "multithreading" do
    before :each do
      Thread.abort_on_exception = true
    end

    it "should run correctly" do
      repeat = 1000000
      thread_concurrency_limit = 512
      queue = Array.new
      statistics = { feature: 0, skfl: 0, rfs: 0 }
      threads_spawned = 0
      threads_completed = 0
      acquisitions = Hash.new 0

      puts "Begin multithreading test with #{repeat} instances..."

      RubyProf.start

      creator = Thread.new do
        loop do
          if queue.length > thread_concurrency_limit
            sleep 0.1 
            next
          end

          (thread_concurrency_limit / 2).times do
            queue.push Chessboard.new
            threads_spawned += 1
          end

          break if threads_spawned >= repeat
        end
      end

      executor = Thread.new do
        loop do
          if queue.length == 0
            sleep 0.1 
            puts "Executor Thread sleeping..."
            next
          end

          s = queue.pop.plot
          statistics.each do |k, _junk|
            statistics[k] = statistics[k] + 1 if s.statistics[k] > 0
          end
          s.acquisitions.each do |data, count|
            acquisitions[data] += count
          end
          threads_completed += 1

          break if threads_completed == repeat
        end
      end

      monitor = Thread.new do
        loop do
          sleep 0.5
          printf "%10d / %10d [ %6d ]\n", threads_spawned, threads_completed, queue.length
          break if threads_spawned >= repeat and threads_completed >= repeat
        end
      end

      creator.join
      executor.join
      monitor.join

      result = RubyProf.stop
      puts "Creator, Executor, and Monitor threads joined. Run completed"
      ap statistics
      ap acquisitions.sort_by{|k, v| v}

      printer = RubyProf::GraphPrinter.new(result)
      printer.print
    end
  end
end