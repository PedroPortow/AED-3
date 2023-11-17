class TSP
  def initialize()
    @graph = []
  end
  
  def read_file(path)
    lines = File.readlines(path)
    @graph = Array.new(lines.length) { Array.new(lines.length, 0) }
    
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
  
  def aproxim_algo
    mst = prim(0)
    
    puts mst
  end
  
  def prim(start_node = 0)
    mst = [] 
    visited = Array.new(@graph.length, false) 
    queue = []  
    
    visited[start_node] = true # começando no nó passado por param
    queue << [start_node, start_node, 0] # precisa botar 2 vezes pq é uma matriz
    
    while !queue.empty?
      queue.sort! { |a, b| a[2] <=> b[2] } # ordena pelo peso, 2 => index do peso da aresta na queue 
      
      current_path = queue.shift # pegando 1 elemento
      previous_node, next_node, weight = current_path 

      next if visited[next_node] 

    end
    
    puts mst
    mst
  end
end

tsp = TSP.new
tsp.read_file("./TSP/resources/tsp1_253.txt")
# tsp.print_graph

tsp.aproxim_algo


