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
        when 1 # Move right
          node.right_child.nil? ? node.right_child = item : node = node.right_child
        end
      end
    end
    root
  end

  def insert value, node = @root
    if (value < node.value) # Move left
      node.left_child.nil? ? node.left_child = Node.new(value) : insert(value, node.left_child)
    elsif (value > node.value) # Move right
      node.right_child.nil? ? node.right_child = Node.new(value) : insert(value, node.right_child)
    end
    @data << value unless @data[-1] == value
  end

  def delete value
  end
end
a = Tree.new
p a.build_tree [4, 7, 6]
# p Tree.new.build_tree [4, 7, 6, 2, 1, 3, 5]
# p Tree.new.build_tree [1, 7, 4, 23, 8, 9, 4, 3, 5, 7, 9, 67, 6345, 324]