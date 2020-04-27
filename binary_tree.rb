require_relative 'node'

class Tree
  def initialize data = []
    @root = build_tree
  end
end