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
      until node.left_child == item || node.right_child == item
        case (item <=> node)
        when -1 # Move left
          node.left_child.nil? ? node.left_child = item : node = node.left_child
          node.left_child.parent = node if node.left_child == item
        when 1 # Move right
          node.right_child.nil? ? node.right_child = item : node = node.right_child
          node.right_child.parent = node  if node.right_child == item
        end
      end
    end
    root
  end

  def insert value, node = @root
    if (value < node.value) # Move left
      node.left_child.nil? ? node.left_child = Node.new(value, node) : insert(value, node.left_child)
    elsif (value > node.value) # Move right
      node.right_child.nil? ? node.right_child = Node.new(value, node) : insert(value, node.right_child)
    end
    @data << value unless @data[-1] == value
  end

  def delete value
    node = find(value)
    return nil if node.nil?
    parent = node.parent

    # no children
    if node.left_child.nil? && node.right_child.nil?
      parent.left_child = nil if parent.left_child  == node
      parent.left_child = nil if parent.right_child == node
      node.parent = nil
      return @root
    end
    # one child
    if parent.left_child == node
      parent.left_child = node.left_child  if node.left_child && node.right_child.nil?
      parent.left_child = node.right_child if node.right_child && node.left_child.nil?
      node.left_child.parent =  parent.left_child if node.left_child
      node.right_child.parent = parent.left_child if node.right_child
    else
      parent.right_child = node.left_child  if node.left_child && node.right_child.nil?
      parent.right_child = node.right_child if node.right_child && node.left_child.nil?
      node.left_child.parent  = parent.right_child if node.left_child
      node.right_child.parent = parent.right_child if node.right_child
    end
    # two children
    if node.left_child && node.right_child
      # in-order successor --- right child's left most child
      replacement = node.right_child
      replacement = replacement.left_child while replacement.left_child

      # covers case where the in-order successor     eg. delete 50;  50
      # is a child of the node to be deleted                           \
      #                                    successor has no children -  70
      if replacement == node.right_child
        replacement.parent = node.parent
        replacement.left_child = node.left_child
        node.left_child.parent = replacement
        node.parent.left_child  = replacement if node.parent.left_child  == node
        node.parent.right_child = replacement if node.parent.right_child == node
        node.left_child, node.right_child, node.parent = nil, nil, nil
        return @root
      end
      # case where replacement node has no children
      replacement.right_child.parent = replacement.parent unless replacement.right_child.nil?
      replacement.right_child.nil? ? replacement.parent.left_child = nil : replacement.parent.left_child = replacement.right_child

      # change replacement's children & parent nodes to node's children and parent nodes
      # accounts for the case of the replacement being a child of the removed node
      replacement.right_child = node.right_child
      replacement.left_child  = node.left_child
      replacement.parent      = node.parent
      # change node's children to point at replacement as a parent
      node.left_child.parent  = replacement
      node.right_child.parent = replacement 
      # change node's parent to point to replacement
      node.parent.left_child  = replacement if parent.left_child  == node
      node.parent.right_child = replacement if parent.right_child == node
    end   
    @root
  end

  def find value, node = @root
    until node.value == value
      value < node.value ? node = node.left_child : node = node.right_child
      return nil if node.nil?
    end
    node
  end
end
# a = Tree.new
# p a.build_tree [4, 7, 6]
# p Tree.new.build_tree [4, 7, 6, 2, 1, 3, 5]
# p Tree.new.build_tree [1, 7, 4, 23, 8, 9, 4, 3, 5, 7, 9, 67, 6345, 324]