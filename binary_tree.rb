require_relative 'node'

class Tree
  attr_reader :root

  def initialize data = []
    @root = build_tree data
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
  end

  def delete value
    node = value.is_a?(Node) ? value : find(value)
    return nil if node.nil?
    parent = node.parent
    # delete root node
    if node == root
      delete_root node
      return root
    end
    # no children
    if node.is_leaf?
      no_children_delete node
      return root
    end
    # one child
    if node.has_one_child?
      one_child_delete node
      return root
    end
    # two children
    if node.has_two_children?
      two_children_delete node
    end   
    root
  end

  def no_children_delete node
    node.parent.left == node ? node.parent.left = nil : node.parent.right = nil
  end

  def one_child_delete node
    parent = node.parent
    if node.left && node.right.nil?
      parent.left == node ? parent.left = node.left : parent.right = node.left
      node.left.parent = node.parent
    elsif node.right && node.left.nil?  
      parent.left == node ? parent.left = node.right : parent.right = node.right
      node.right.parent = node.parent
    end
  end

  def two_children_delete node
    # in-order successor --- right child's left most child
    replacement = node.right
    replacement = replacement.left while replacement.left
    # delete replacement node from it's current position, and point any
    # existing children to replacement's parent by passing it into #delete
    delete(replacement)
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

  def delete_root node
    replacement = node.right
    replacement = replacement.left while replacement.left
    delete(replacement)
    node.left.parent  = replacement if node.left
    node.right.parent = replacement if node.right
    replacement.left  = node.left
    replacement.right = node.right
    replacement.parent = nil
    @root = replacement
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

  # this creates the above three methods
  ["pre", "in", "post"].each do |prefix|
    define_method("#{prefix}order") do |node=@root, values=[], &block|
      return if node.nil?
      if prefix == "post"
        postorder(node.left, values, &block)
        postorder(node.right, values, &block)
      end
      inorder(node.left, values, &block) if prefix == "in"
      block.call(node) if block
      values << node.value
      inorder(node.right, values, &block) if prefix == "in"
      if prefix == "pre"
        preorder(node.left, values, &block)
        preorder(node.right, values, &block)
      end
      block ? nil : values
    end
  end

  def depth node_value
    return -1 if node_value.nil?
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

  def rebalance! arr = [], new_tree_values = []
    values = arr.empty? ? self.inorder : arr
    return values.each { |e| new_tree_values << e } if values.size <= 2
    middle = values.size/2
    left = values[0..(middle - 1)]
    right = values.size == 2 ? values[1..-1] : values[(middle + 1)..-1]
    new_tree_values << values[middle]
    rebalance! left, new_tree_values
    rebalance! right, new_tree_values
    @root = build_tree new_tree_values
  end
end