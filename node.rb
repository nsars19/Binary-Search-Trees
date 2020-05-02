class Node
  include Comparable
  attr_accessor :value, :left, :right, :parent

  def initialize value = nil, parent = nil, left = nil, right = nil
    @value  = value
    @left   = left
    @right  = right
    @parent = parent
  end

  def <=> node 
    self.value <=> node.value
  end
end