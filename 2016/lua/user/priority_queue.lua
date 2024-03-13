local M = {}

function M.new()
  return { heap = {} }
end

function M.push(self, item, priority)
  local heap = self.heap
  local index = #heap + 1

  while index > 1 do
    local parent_index = math.floor(index / 2)
    local parent = heap[parent_index]
    if priority >= parent.priority then
      break
    end
    heap[index] = parent
    index = parent_index
  end

  heap[index] = { item = item, priority = priority }
end

function M.pop(self)
  local heap = self.heap
  local heap_size = #heap

  if heap_size == 0 then
    return nil
  end

  local top = heap[1]
  local bottom = heap[heap_size]
  heap[heap_size] = nil
  heap_size = heap_size - 1

  if heap_size > 0 then
    local index = 1
    while true do
      local left_child_index = index * 2
      local right_child_index = left_child_index + 1
      if left_child_index > heap_size then
        break
      end
      local smaller_child_index = left_child_index
      if
        right_child_index <= heap_size
        and heap[right_child_index].priority
          < heap[left_child_index].priority
      then
        smaller_child_index = right_child_index
      end
      if heap[smaller_child_index].priority >= bottom.priority then
        break
      end
      heap[index] = heap[smaller_child_index]
      index = smaller_child_index
    end
    heap[index] = bottom
  end

  return top.item
end

function M.peek(self)
  if #self.heap > 0 then
    return self.heap[1].item
  else
    return nil
  end
end

function M.is_empty(self)
  return #self.heap == 0
end

return M
