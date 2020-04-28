require_relative 'node'

class Tree
  def initialize data = []
    @root = build_tree
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
          if node.left_child.nil?
            node.left_child = item 
          else
            node = node.left_child
          end
        when 1 # Move right
          if node.right_child.nil?
            node.right_child = item 
          else
            node = node.right_child
          end
        end
      end
      # until node.left_child == item || node.right_child == item
      #   comparison = item <=> node
      #   if comparison == -1 && !node.left_child
      #     node.left_child = item
      #   elsif comparison == 1 && !node.right_child
      #     node.right_child = item
      #   else
      #     node = node.left_child  if comparison == -1
      #     node = node.right_child if comparison == 1
      #   end
      # end
    end
    root
  end
end

p Tree.new.build_tree [4, 7, 6, 2, 1, 3, 5]
# p Tree.new.build_tree [1, 7, 4, 23, 8, 9, 4, 3, 5, 7, 9, 67, 6345, 324]