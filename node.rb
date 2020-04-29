class Node
  include Comparable
  attr_accessor :value, :left_child, :right_child, :parent

  def initialize value = nil, left_child = nil, right_child = nil, parent = nil
    @value       = value
    @left_child  = left_child
    @right_child = right_child
    @parent      = parent
  end

  def <=> node 
    self.value <=> node.value
  end
end