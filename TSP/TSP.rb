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
    nodes = (0...@nodes_quantity).to_a      # array de 0 até quantidade de nós
    nodes_permutations = nodes.permutation
    
    optimal_cost = Float::INFINITY
    optimal_path = []
    time = nil
    
    begin
      Timeout.timeout(300) do
        time = Benchmark.realtime do
          nodes_permutations.each do |path|
            cost = calculate_path(path)
            if cost < optimal_cost
              optimal_cost = cost
              optimal_path = path
            end
          end
        end
  
        print_results(optimal_path, optimal_cost, time)
      end
    rescue Timeout::Error
      puts "Tempo limite de execução atingido (#{300} segundos)."
      return
    end
    
    print_results(optimal_path, optimal_cost, time)
    { path: optimal_path, cost: optimal_cost }
  end

  def held_karp_tsp
    nodes = (0...@nodes_quantity).to_a  
    starting_node = 0 
             
    memo = Array.new(@nodes_quantity) { Array.new(2**@nodes_quantity, nil) }
  end
  
  
  #heurística
  def nearest_neighbor_tsp(starting_node = 0, optimal_cost)
    current_node = starting_node
    unvisited_nodes = (0...@nodes_quantity).to_a - [current_node] # excluindo o current_node que no caso vai ser o starting_node na primeira iteração
    
    path = [current_node] # começando do current_node // aqui vai ser o starting node

    time = Benchmark.realtime do
      while unvisited_nodes.any?
        nearest_node = find_nearest_neighbor(current_node, unvisited_nodes)
        path << nearest_node
        unvisited_nodes.delete(nearest_node)
        current_node = nearest_node
      end
    end

    cost = calculate_path(path)
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
