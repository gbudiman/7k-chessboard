require "#{File.dirname(__FILE__)}/../src/chessboard"
require "#{File.dirname(__FILE__)}/../src/concurrent"

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
      c = Concurrent.new repeat: 1000000
      c.run_by_threads 
    end
  end
end