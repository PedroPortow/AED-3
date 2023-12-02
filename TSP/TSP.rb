class TSP
  def initialize
    @graph = []
    @nodes_quantity = 0
  end

  def read_file(path)
    lines = File.readlines(path)
    @nodes_quantity = lines.length
    @graph = Array.new(@nodes_quantity) { Array.new(@nodes_quantity, 0) }

    lines.each_with_index do |line, i|
      values = line.split.map(&:to_i)
      values.each_with_index do |value, j|
        @graph[i][j] = value if @graph[i]
      end
    end
  end

  def print_graph
    puts "------------------------"
    @graph.each do |row|
      puts row.join(" - ")
    end
    puts "------------------------"
  end
  
  def brute_force_tsp
    nodes = (0...@nodes_quantity).to_a      # array de 0 até quantidade de nós
    nodes_permutations = nodes.permutation
    
    optimal_cost = Float::INFINITY
    optimal_path = []
    
    nodes_permutations.each do |path|       # .permutation gera todas permutações possiveis do array de 
      cost = calculate_path(path)
      if cost < optimal_cost
        optimal_cost = cost
        optimal_path = path
      end
    end
    
    puts "Brute force TSP optimal path: #{optimal_path.join(' -> ')}"
    puts "Brute force TSP optimal cost: #{optimal_cost}"

    { route: optimal_path, cost: optimal_cost }
  end


  
  def held_karp_tsp
    nodes = (0...@nodes_quantity).to_a  
    starting_node = 0 
             
    
    memo = Array.new(@nodes_quantity) { Array.new(2**@nodes_quantity, nil) }
    
  end
  
  def nearest_neighbor_tsp(starting_node = 0)
    current_node = starting_node
    unvisited_nodes = (0...@nodes_quantity).to_a - [current_node] # excluindo o current_node que no caso vai ser o starting_node na primeira iteração
    
    path = [current_node] # começando do current_node // aqui vai ser o starting node

    nearest_node = find_nearest_neighbor(current_node, unvisited_nodes)
    
    while unvisited_nodes.any?
 
    end

  end
  
  def find_nearest_neighbor(current_node, unvisited_nodes) 
    #vai retornar o nó com menor caminho entre o current_node para o unvisited_nodes
    min_distance = Float::INFINITY
    nearest_node = nil
  
    unvisited_nodes.each do |unvisited_node|
      distance = self.get_distance_between_two_nodes(current_node, unvisited_node)
      if distance < min_distance
        min_distance = distance
        nearest_node = unvisited_node
      end
    end
    
    puts nearest_node
  
    nearest_node
  end
  
  def get_distance_between_two_nodes(first_node, second_node) 
    puts "Distancia do #{first_node} pro #{second_node} => #{@graph[first_node][second_node]}"
    return @graph[first_node][second_node]
  end
  
  private

  def calculate_path(path)
    # path = array com a permutação atual dos nós (ordem que os nós vão ser visitados)
    
    total_cost = 0
    (0...@nodes_quantity - 1).each do |i|
      # Exemplo do que preciso fazer aqui:
      # path = [0, 1, 3, 4]
      # pegar no graph custo pra ir do 0 -> 1, na proxima iteração do 1 -> 2...
      
      total_cost += @graph[path[i]][path[i + 1]] 
    end
    total_cost += @graph[path.last][path.first] # adicionando o custo de ir do ultimo nó pro primeiro
    total_cost
  end
  

  
end

tsp = TSP.new
tsp.read_file("./TSP/resources/tsp1_253.txt") # custo ótimo é 253
# tsp.read_file("./TSP/resources/tsp_exemplo.txt") # custo ótimo é 253
# result = tsp.brute_force_tsp
tsp.nearest_neighbor_tsp
