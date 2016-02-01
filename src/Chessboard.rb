require 'ap'
require "#{File.dirname(__FILE__)}/rngesus"

class Chessboard
  CHESSBOARD_SIZE = 90
  FEATURED = %w(f1)
  SEVEN_KNIGHTS = %w(7k1 7k2 7k3 7k4 7k5 7k6 7k7)
  FOUR_LORDS = %w(4l1)
  REGULAR_FOUR_STARS = (0..32).map{|i| "r4s#{i}"}.collect.to_a
  REGULAR_THREE_STARS = (0..100).map{|i| "r3s#{i}"}.collect.to_a

  attr_reader :board, :statistics, :acquisitions
  
  def initialize _srand = Random.new, **h
    @board = h[:board] || initialize_board
    @srand = _srand
    @statistics = { feature: 0, skfl: 0, rfs: 0 }
    @acquisitions = Hash.new 0

    return self
  end

  def validate!
    assert(@board.select{|k,v| v =~ /^f/}.collect{|k,v| v}.length == 1, "Must have exactly 1 featured hero")
    assert(@board.is_full?, "Board must be completely filled")
  end

  def is_full?
    return !(@board.value? nil)
  end

  def plot
    @statistics[:feature] = _plot FEATURED, limit: 1
    @statistics[:skfl] = _plot SEVEN_KNIGHTS + FOUR_LORDS, probability: 0.00001
    @statistics[:rfs] = _plot REGULAR_FOUR_STARS, probability: 0.01
    _plot REGULAR_THREE_STARS, fill_remainder: true

    #validate!
    summarize_acquisitions

    return self
  end

  def summarize_acquisitions
    @board.each do |i, d|
      @acquisitions[d] += 1
    end
  end

  def _debug_fill_all
    @board.each { |k,v| @board[k] = 'mock_1' }
  end

  def inspect
    puts "FEATURED: " + @board.select { |k, v| v =~ /^f/ }.collect{|k,v| v}.join(',')
    puts "SEVEN_KNIGHTS: " + @board.select { |k, v| v =~ /^7k/ }.collect{|k,v| v}.join(',')
    puts "FOUR_LORDS: " + @board.select { |k, v| v =~ /^4l/ }.collect{|k,v| v}.join(',')
    puts "R4S: " + @board.select { |k, v| v =~ /^r4s/ }.collect{|k,v| v}.join(',')
    puts "R3S: " + @board.select { |k, v| v =~ /^r3s/ }.collect{|k,v| v}.join(',')
  end

private
  def initialize_board
    s = Hash.new
    (0..CHESSBOARD_SIZE).each { |i| s[i] = nil }
    return s
  end

  def _plot _pool, **h
    RNGesus.plot @board, _pool, @srand, h
  end
end