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
  
  def held_karp_tsp
    nodes = (0...@nodes_quantity).to_a  
    starting_node = 0
    
    memo_table = Array.new(@nodes_quantity) { Array.new(2**@nodes_quantity, nil) }
    
  end
  
end

tsp = TSP.new
# tsp.read_file("./resources/tsp1_253.txt") # custo ótimo é 253
tsp.read_file("./resources/tsp_exemplo.txt") # custo ótimo é 253
# result = tsp.brute_force_tsp
tsp.held_karp_tsp
