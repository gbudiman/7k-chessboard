require "#{File.dirname(__FILE__)}/../src/chessboard"

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
    Thread.abort_on_exception = true
    repeat = 40000
    res = Array.new
    statistics = { feature: 0, skfl: 0, rfs: 0 }
    thread_spawn_completed = false
    thread_spawned_tracker = Hash.new
    thread_completed_tracker = Hash.new

    creator = Thread.new do
      repeat.times do |r|
        res[r] = Thread.new do
          thread_spawned_tracker[r] = Chessboard.new
        end
      end

      thread_spawn_completed = true
      puts "Creator thread completed"
    end

    executor = Thread.new do
      loop do
        sleep 1 unless thread_spawn_completed

        thread_spawned_tracker.keys.each do |thread_id|
          s = thread_spawned_tracker[thread_id].plot
          statistics.each do |k, _junk|
            statistics[k] = statistics[k] + 1 if s.statistics[k] > 0
          end
          thread_completed_tracker[thread_id] = true
          thread_spawned_tracker.delete thread_id
        end

        if thread_completed_tracker.length == repeat
          puts "Executor thread completed"
          break
        end
      end
    end

    monitor = Thread.new do
      loop do
        sleep 1
        puts "Spawned/Completed: #{thread_spawned_tracker.length} / #{thread_completed_tracker.length}"
        break if thread_completed_tracker.length == repeat
      end
    end

    creator.join
    executor.join
    monitor.join
    puts "Creator, Executor, and Monitor threads joined. Run completed"
    ap statistics
  end
end