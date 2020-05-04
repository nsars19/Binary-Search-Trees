require_relative 'binary_tree'

def print_order tree
  print "\nlevel-order: #{tree.level_order}\n"
  print "inorder: #{tree.inorder}\n"
  print "preorder: #{tree.preorder}\n"
  print "postorder: #{tree.postorder}\n"
end

values = Array.new(20) { rand(1..100) }
print "the values are: #{values}\n"

tree = Tree.new values

tree.balanced? ? (puts "the tree is balanced\n") : (puts "the tree is not balanced\n")

print_order tree

if tree.balanced?
  puts "\nadding elements to unbalance tree..."
  10.times {|i| tree.insert((i+1) * (1 + rand(50)))}
else
  puts "\nbalancing tree..."
  tree.rebalance!
end

tree.rebalance! until tree.balanced?

tree.balanced? ? (puts "tree balanced") : (puts "tree unbalanced")
print_order tree