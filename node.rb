class Node
  include Comparable
  attr_accessor :value, :left, :right, :parent

  def initialize value = nil, parent = nil, left = nil, right = nil
    @value  = value
    @left   = left
    @right  = right
    @parent = parent
  end

  def is_leaf?
    self.left.nil? && self.right.nil?
  end

  def has_two_children?
    (self.left && self.right) ? true : false
  end

  def has_one_child?
    (self.left.nil? || self.right.nil?) && !self.is_leaf?
  end
  
  def <=> node 
    self.value <=> node.value
  end
end