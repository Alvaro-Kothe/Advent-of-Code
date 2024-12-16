# frozen_string_literal: true

# https://github.com/rubyworks/pqueue
class PriorityQueue
  attr_reader :que, :cmp

  def initialize(&block)
    @que = []
    @cmp = block || ->(x, y) { (x <=> y) == -1 }
  end

  def size
    @que.size
  end

  def empty?
    @que.empty?
  end

  def inspect
    "<#{self.class}: size=#{size}, top=#{top || 'nil'}>"
  end

  def push(ele)
    @que << ele
    reheap(@que.size - 1)
    self
  end

  alias << push

  def pop
    return nil if empty?

    @que.pop
  end

  def peek
    return nil if empty?

    @que.last
  end

  def reheap(k)
    return self if size <= 1

    que = @que.dup

    v = que.delete_at(k)
    i = binary_index(que, v)

    que.insert(i, v)

    @que = que

    self
  end

  def binary_index(que, target)
    upper = que.size - 1
    lower = 0

    while upper >= lower
      idx  = lower + (upper - lower) / 2
      comp = @cmp.call(target, que[idx])

      case comp
      when 0, nil
        return idx
      when 1, true
        lower = idx + 1
      when -1, false
        upper = idx - 1
      end
    end
    lower
  end
end
