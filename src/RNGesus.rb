class RNGesus
  MAX_THRESHOLD = 2 ** 64

  def self.plot _chessboard, _pool, _rand, **h
    # valid options:
    # limit: integer
    # probability: integer
    # fill_remainder: boolean

    check_options h
    
    raise RuntimeError, 'Board full' unless _chessboard.value?(nil)

    if h[:probability]
      counter = 0
      threshold = MAX_THRESHOLD * h[:probability]
      _chessboard.select{ |k, v| v == nil }.keys.each do |ci|
        rand = _rand.rand MAX_THRESHOLD
        if rand < threshold
          _chessboard[ci] = pick_one_from(_pool, _rand)
          counter += 1
        end
      end

      return counter
    end

    if h[:limit]
      limit = 0
      _chessboard.each do |k, _junk|
        _chessboard[k] = pick_one_from(_pool, _rand)
        limit += 1
        break if limit == h[:limit]
      end

      return limit
    end

    if h[:fill_remainder]
      _chessboard.select{ |k, v| v == nil }.keys.each do |ci|
        _chessboard[ci] = pick_one_from(_pool, _rand)
      end
    end
  end

private
  def self.pick_one_from _pool, _rand
    return _pool[_rand.rand(_pool.length)]
  end

  def self.check_options h
    if h[:limit] and h[:probability]
      raise RuntimeError, ':limit and :probability are mutually exclusive'
    end

    if h[:fill_remainder] and (h[:limit] or h[:probability])
      raise RuntimeError, ':fill_remainder cannot be used with any other options'
    end
  end
end