require 'benchmark'
require 'timeout'

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

  def brute_force_tsp
    nodes = (0...@nodes_quantity).to_a      
    nodes_permutations = nodes.permutation
    
    optimal_cost = Float::INFINITY
    optimal_path = []
    time = nil
    
    begin
      Timeout.timeout(600) do
        time = Benchmark.realtime do
          nodes_permutations.each do |path|
            cost = calculate_path(path)
            if cost < optimal_cost
              optimal_cost = cost
              optimal_path = path
            end
          end
        end
      end
    rescue Timeout::Error
      puts "Tempo limite de execução atingido (10 minutos)."
      return
    end
    
    print_results(optimal_path, optimal_cost, time)
    { path: optimal_path, cost: optimal_cost }
  end

  def nearest_neighbor_tsp(starting_node = 0, optimal_cost)
    current_node = starting_node
    unvisited_nodes = (0...@nodes_quantity).to_a - [current_node] 
    
    path = [current_node] 

    time = Benchmark.realtime do
      while unvisited_nodes.any?
        nearest_node = find_nearest_neighbor(current_node, unvisited_nodes)
        path << nearest_node
        unvisited_nodes.delete(nearest_node)
        current_node = nearest_node
      end
    end
    
    cost = calculate_path(path)
    path << starting_node
    print_results(path, cost, time, optimal_cost)

    { path: path, cost: cost }
  end
  
  def print_graph
    puts "------------------------"
    @graph.each do |row|
      puts row.join(" - ")
    end
    puts "------------------------"
  end
  
  def prim(starting_node)
    mst = []       # Array com os nós MST
    visited = []   # Nós já visitados
    queue = []     # Fila

    queue.push({ node: start, weight: 0 })  # Nó de partida

    while !queue.empty?
      queue.sort_by! { |path| path[:weight] }  # Ordena pelo peso, aqui sempre vai pegar a aresta de menor peso

      min_path = queue.shift                   # Pegando a aresta de menor peso
      current_node_key = min_path[:node]
      current_node_weight = min_path[:weight]

      next if visited.include?(current_node_key)  # Nó já foi visitado? Vai embora
      visited.push(current_node_key)

      mst.push(current_node_key)          # Já pode dar o push para o MST, porque se chegou nesse nó, ele já faz parte

      @graph[current_node_key].each_with_index do |weight, neighbor|
        next if weight.zero? || visited.include?(neighbor)

        queue.push({ node: neighbor, weight: weight })
      end
    end

    cost = calculate_path(mst)
    { mst_path: mst, cost: cost }
  end
  
  def tsp_path(staring_node = 0)
    mst_response = prim(starting_node)
    mst_reponse[:mst_path] << staring_node 
    
    cal
  end
  
  private
  
  def print_results(path, cost, time, optimal_cost = nil)
    puts " "
    puts " "
    puts "Path: #{path.join(' -> ')}"
    puts "Cost: #{cost}"
    puts "Execution time: #{time.round(5)} seconds"
    if optimal_cost
      ratio = cost.to_f / optimal_cost.to_f
      puts "#{ratio.round(2)}-aproximado"
    end
    puts " "
    
  end

  def calculate_path(path)
    total_cost = 0

    (0...@nodes_quantity - 1).each do |i|
      total_cost += @graph[path[i]][path[i + 1]] 
    end
    total_cost += @graph[path.last][path.first] 

    total_cost
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
    
    nearest_node
  end
    
  def get_distance_between_two_nodes(first_node, second_node) 
    return @graph[first_node][second_node]
  end
  
end

tsp = TSP.new 
tsp.read_file("./TSP/resources/tsp1_253.txt")
result = tsp.tsp_path
