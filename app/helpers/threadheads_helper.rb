module ThreadheadsHelper

  @@x

  def children_in(parent_nodes, treenodes)
    treenodes.where(parent_node_id: parent_nodes)
  end

  def put_node_and_children_in_matrix(node, y, treenodes, matrix)
    matrix[y] = Array.new(1) {nil} if matrix[y].nil?
    matrix[y][@@x] = node
    y = y + 1
    i = 0
    
    children_in(node, treenodes).each do |nd|
      @@x = @@x + 1 if i > 0
      put_node_and_children_in_matrix(nd, y, treenodes, matrix)
      i = i + 1
    end
    
  end


  def nodes_in_matrix(treenodes)

    matrix = Array.new(1) {Array.new(1) {nil}} # changer y par profondeur_max 

    first_node = treenodes.where(obj_type: Threadhead.to_s).first.children_nodes.first
    
    @@x = 0
    y = 0
    
    put_node_and_children_in_matrix(first_node, y, treenodes, matrix)
    
    return matrix
  end


  

end
