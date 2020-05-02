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
          node.right.parent = node  if node.right == item
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

  def delete value
    node = find(value)
    return nil if node.nil?
    parent = node.parent

    # no children
    if node.left.nil? && node.right.nil?
      parent.left  == node ? parent.left = nil : parent.right = nil
      node.parent = nil
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
    if node.left && node.right
      # in-order successor --- right child's left most child
      replacement = node.right
      replacement = replacement.left while replacement.left
      # covers case where the in-order successor     eg. delete 50;  50
      # is a child of the node to be deleted                           \
      #                                    successor has no children -  70
      if replacement == node.right
        replacement.parent = node.parent
        replacement.left   = node.left
        node.left.parent   = replacement
        node.parent.left   = replacement if node.parent.left  == node
        node.parent.right  = replacement if node.parent.right == node
        node.left, node.right, node.parent = nil, nil, nil
        return root
      end
      # case where replacement node has no children
      replacement.right.parent = replacement.parent unless replacement.right.nil?
      replacement.right.nil? ? replacement.parent.left = nil : replacement.parent.left = replacement.right

      # change replacement's children & parent nodes to node's children and parent nodes
      # accounts for the case of the replacement being a child of the removed node
      replacement.right  = node.right
      replacement.left   = node.left
      replacement.parent = node.parent
      # change node's children to point to replacement as a parent
      node.left.parent  = replacement
      node.right.parent = replacement 
      # change node's parent to point to replacement
      node.parent.left  = replacement if node.parent.left  == node
      node.parent.right = replacement if node.parent.right == node
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
end
# a = Tree.new
# p a.build_tree [4, 7, 6]
# p Tree.new.build_tree [4, 7, 6, 2, 1, 3, 5]
# p Tree.new.build_tree [1, 7, 4, 23, 8, 9, 4, 3, 5, 7, 9, 67, 6345, 324]