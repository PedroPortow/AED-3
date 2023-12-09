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

  def brute_force_tsp(iteration_limit)
    nodes = (0...@nodes_quantity).to_a
    nodes_permutations = nodes.permutation

    optimal_cost = Float::INFINITY
    optimal_path = []
    execution_time = nil

    iteration_count = 0
    time_exceeded_flag = false

    execution_time = Benchmark.realtime do
      nodes_permutations.each do |path|
        if iteration_count == iteration_limit
          time_exceeded_flag = true
          break
        end

        cost = calculate_path(path)
        if cost < optimal_cost
          optimal_cost = cost
          optimal_path = path
        end

        iteration_count += 1
      end
    end

    if time_exceeded_flag
      estimate_execution_time(execution_time, iteration_limit, nodes_permutations.size)
    else
      print_results(optimal_path, optimal_cost, execution_time)
      { path: optimal_path, cost: optimal_cost }
    end
  end

  # def estimate_execution_time(execution_time, iteration_limit, total_permutations)
  #   estimated_time = ((total_permutations / iteration_limit) * execution_time)
  #   puts "Tempo estimado de execução (segunods): #{estimated_time.round(2)}"
  #   puts "Tempo estimado de execução (minutos): #{(estimated_time / 60).round(2)}"
  #   puts "Tempo estimado de execução (horas): #{(estimated_time / 3600).round(2)}"
  #   puts "Tempo estimado de execução (dias): #{(estimated_time / (3600 * 24)).round(2)}"
  #   estimated_time
  # end

  def estimate_execution_time(execution_time, iteration_limit, total_permutations)
    completed_iterations = iteration_limit
    remaining_iterations = total_permutations - completed_iterations

    time_per_iteration = execution_time / completed_iterations
    estimated_remaining_time = remaining_iterations * time_per_iteration

    puts "Estimated remaining time (seconds): #{estimated_remaining_time.round(2)}"
    puts "Estimated remaining time (minutes): #{(estimated_remaining_time / 60).round(2)}"
    puts "Estimated remaining time (hours): #{(estimated_remaining_time / 3600).round(2)}"
    puts "Estimated remaining time (days): #{(estimated_remaining_time / (3600 * 24)).round(2)}"
    puts "Estimated remaining time (months): #{(estimated_remaining_time / (3600 * 24 * 30)).round(2)}"

  estimated_remaining_time
  end
  
  def print_graph
    puts "------------------------"
    @graph.each do |row|
      puts row.join(" - ")
    end
    puts "------------------------"
  end
  
  def prim(starting_node = 0)
    mst = []
    visited_nodes = [starting_node]
    
    # vai sempre pegar a smallest aresta conectada a un nó que ainda n foi visitado
    while visited_nodes.length != @nodes_quantity
      min_path_weight = Float::INFINITY
      min_path = nil 
      
      #pra cada nó visitado tenho que achar a smallest aresta
      visited_nodes.each do |node|
        @graph[node].each_with_index do |weight, connected_node|  #iterando pela linha do nó visitado
          puts "Nó: #{node}  -- #{weight} --  Nó: #{connected_node} "
          next if visited_nodes.include?(connected_node) || weight == 0
          
          if weight < min_path_weight
            min_path_weight = weight
            min_path = {start_node: node, end_node: connected_node, weight: weight}
          end
        end
      end
      
      mst << min_path
      visited_nodes << min_path[:end_node]
    end
    
    print_mst(mst)
    return mst
  end

  def approx_tsp_tour(starting_node = 0, optimal_cost = nil)
    dfs_tour = nil
    mst = nil 
    approximated_cost = nil
    
    time = Benchmark.realtime do
      mst = prim(starting_node)
      dfs_tour = dfs(mst, starting_node)
  
      approximated_cost = calculate_path(dfs_tour)
      dfs_tour << starting_node
    end
  
    print_results(dfs_tour, approximated_cost, time, optimal_cost)
  end
  
  def dfs(mst, starting_node)
    stack = [starting_node]
    visited_nodes = []
    
    while stack.length > 0
      current_node = stack.pop
      
      unless visited_nodes.include?(current_node) 
        visited_nodes << current_node
        
        mst.each do |path|
          if path[:start_node] == current_node && !visited_nodes.include?(path[:end_node])
            stack.push(path[:end_node])
          elsif path[:end_node] == current_node && !visited_nodes.include?(path[:start_node])
            stack.push(path[:start_node])
          end
        end
      end
    end
    
    visited_nodes 
  end
  
  private
  
  def print_mst(mst)
    puts "= MST ="
    mst.each do |edge|
      puts "Edge: #{edge[:start_node]} - #{edge[:end_node]}, Weight: #{edge[:weight]}"
    end
  end
  
 
  def print_results(path, cost, time, optimal_cost = nil)
    puts " "
    puts " "
    puts "Path: #{path.join(' -> ')}"
    puts "Cost: #{cost}"
    puts "Execution time: #{(time * 1000).round(5)} milliseconds"
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
  
  def nearest_neighbor_tsp(optimal_cost)
    unvisited_nodes = (0...@nodes_quantity).to_a

    starting_node = unvisited_nodes.sample
    current_node = starting_node
    unvisited_nodes.delete(starting_node)

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

    { path: path, cost: cost, time: time }
  end
  
   
  def average_nearest_neighbor_tsp(n)
    total_cost = 0
    total_time = 0
  
    n.times do |i|
      puts "Run #{i + 1}:"
      result = nearest_neighbor_tsp(nil)
      total_cost += result[:cost]
      total_time += result[:time]
      puts "------------------------"
    end
  
    average_cost = total_cost / n
    average_time_ms = (total_time / n * 1000).round(5)
    puts "Average Cost: #{average_cost}"
    puts "Average Execution Time: #{average_time_ms} milliseconds"
    { average_cost: average_cost, average_time: average_time_ms }
  end
    
  def get_distance_between_two_nodes(first_node, second_node) 
    return @graph[first_node][second_node]
  end
  
end

tsp = TSP.new 
tsp.read_file("./TSP/resources/tsp1_253.txt")
# tsp.approx_tsp_tour(0, 1248)
tsp.brute_force_tsp(1000000)
