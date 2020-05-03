require_relative 'node'

class Tree
  attr_reader :root

  def initialize data = []
    @root = build_tree data
    @data = data
  end

  def build_tree data_set = []
    data = data_set.uniq.map {|e| Node.new(e)}
    root = data.first
    
    data.each_with_index do |item, index|
      next if index == 0
      node = root
      until node.left == item || node.right == item
        case (item <=> node)
        when -1 # Move left
          node.left.nil? ? node.left = item : node = node.left
          node.left.parent = node if node.left == item
        when 1 # Move right
          node.right.nil? ? node.right = item : node = node.right
          node.right.parent = node if node.right == item
        end
      end
    end
    root
  end

  def insert value, node = @root
    if (value < node.value) # Move left
      node.left.nil? ? node.left = Node.new(value, node) : insert(value, node.left)
    elsif (value > node.value) # Move right
      node.right.nil? ? node.right = Node.new(value, node) : insert(value, node.right)
    end
    @data << value unless @data[-1] == value
  end

  def delete value, node = @root
    node = value.is_a?(Node) ? value : find(value)
    return nil if node.nil?
    parent = node.parent
    # delete root node
    if node == root
      replacement = node.right
      replacement = replacement.left while replacement.left
      delete(replacement)
      node.left.parent  = replacement if node.left
      node.right.parent = replacement if node.right
      replacement.left  = node.left
      replacement.right = node.right
      replacement.parent = nil
      @root = replacement
      return root
    end
    # no children
    if node.is_leaf?
      parent.left == node ? parent.left = nil : parent.right = nil
      return root
    end
    # one child
    if node.left && node.right.nil?
      parent.left == node ? parent.left = node.left : parent.right = node.left
      node.left.parent = node.parent
      return root
    elsif node.right && node.left.nil?  
      parent.left == node ? parent.left = node.right : parent.right = node.right
      node.right.parent = node.parent
      return root
    end
    # two children
    if node.has_two_children?
      # in-order successor --- right child's left most child
      replacement = node.right
      replacement = replacement.left while replacement.left
      # delete replacement node from it's current position, and point any
      # existing children to replacement's parent by passing it into #delete
      delete(replacement.value, replacement)
      # change replacement's children & parent node pointers to node's children and parent nodes
      replacement.right  = node.right
      replacement.left   = node.left
      replacement.parent = node.parent
      # change node's children to point to replacement as a parent
      node.left.parent  = replacement if node.left
      node.right.parent = replacement if node.right
      # change node's parent to point to replacement
      node.parent.left  = replacement if node.parent.left  == node
      node.parent.right = replacement if node.parent.right == node
      node.value, node.parent, node.left, node.right = nil, nil, nil, nil
    end   
    root
  end

  def find value, node = @root
    until node.value == value
      value < node.value ? node = node.left : node = node.right
      return nil if node.nil?
    end
    node
  end

  def level_order node = @root
    queue = []
    values = []
    
    queue << node
    until queue.empty?
      current = queue.shift
      yield(current) if block_given?
      queue << current.left  unless current.left.nil?
      queue << current.right unless current.right.nil?
      values << current.value
    end
    block_given? ? nil : values
  end

  def level_order_rec node = @root, values = [], &block
    return if node.nil?
    yield(node) if block_given?
    values << node.value
    level_order_rec(node.left, values, &block)
    level_order_rec(node.right, values, &block)
    block_given? ? nil : values
  end

  def inorder node = @root, values = [], &block
    return if node.nil?
    inorder(node.left, values, &block)
    yield(node) if block_given?
    values << node.value
    inorder(node.right, values, &block)
    block_given? ? nil : values
  end

  def preorder node = @root, values = [], &block
    return if node.nil?
    yield(node) if block_given?
    values << node.value
    preorder(node.left, values, &block)
    preorder(node.right, values, &block)
    block_given? ? nil : values
  end

  def postorder node = @root, values = [], &block
    return if node.nil?
    postorder(node.left, values, &block)
    postorder(node.right, values, &block)
    yield(node) if block_given?
    values << node.value
    block_given? ? nil : values
  end

  def depth node_value
    return 0 if node_value.nil?
    node = node_value.is_a?(Node) ? node_value : find(node_value)
    
    left_child  = depth(node.left)
    right_child = depth(node.right)
    left_child <= right_child ? right_child + 1 : left_child + 1
  end

  def balanced? node = @root
    left = depth node.left
    right = depth node.right
    (left - right).abs > 1 ? false : true
  end
end
# a = Tree.new
# p a.build_tree [4, 7, 6]
# p Tree.new.build_tree [4, 7, 6, 2, 1, 3, 5]
# p Tree.new.build_tree [1, 7, 4, 23, 8, 9, 4, 3, 5, 7, 9, 67, 6345, 324]