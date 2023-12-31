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
  def set_graph(matrix)
    @graph = matrix
    @nodes_quantity = @graph.length
  end

  def brute_force_tsp(iteration_limit = 100000000)
    nodes = (0...@nodes_quantity).to_a
    nodes_permutations = nodes.permutation

    optimal_cost = Float::INFINITY
    optimal_path = []
    start_time = Time.now

    iteration_count = 0
    time_exceeded_flag = false

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

    end_time = Time.now
    execution_time = end_time - start_time

    if time_exceeded_flag
      estimate_execution_time(execution_time, iteration_limit, nodes_permutations.size)
    else
      print_results(optimal_path, optimal_cost, execution_time)
      { path: optimal_path, cost: optimal_cost }
    end
  end

  def estimate_execution_time(execution_time, iteration_limit, total_permutations)
    estimated_time = ((total_permutations / iteration_limit) * execution_time)
    puts "Tempo estimado de execução (segundos): #{estimated_time.round(2)}"
    puts "Tempo estimado de execução (minutos): #{(estimated_time / 60).round(2)}"
    puts "Tempo estimado de execução (horas): #{(estimated_time / 3600).round(2)}"
    puts "Tempo estimado de execução (dias): #{(estimated_time / (3600 * 24)).round(2)}"
    estimated_time
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
    
    while visited_nodes.length != @nodes_quantity
      min_path_weight = Float::INFINITY
      min_path = nil 
      
      visited_nodes.each do |node|
        puts node
        @graph[node].each_with_index do |weight, connected_node| 
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
    
    mst = prim(starting_node)
    dfs_tour = dfs(mst, starting_node)

    approximated_cost = calculate_path(dfs_tour)
    dfs_tour << starting_node
  
    print_results(dfs_tour, approximated_cost, nil, optimal_cost)
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
    puts "Execution time: #{(time * 1000).round(5)} milliseconds" if time
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
    
    while unvisited_nodes.any?
      nearest_node = find_nearest_neighbor(current_node, unvisited_nodes)
      path << nearest_node
      unvisited_nodes.delete(nearest_node)
      current_node = nearest_node
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

tsp_253= [
  [0, 29, 20, 21, 16, 31, 100, 12, 4, 31, 18],
  [29, 0, 15, 29, 28, 40, 72, 21, 29, 41, 12],
  [20, 15, 0, 15, 14, 25, 81, 9, 23, 27, 13],
  [21, 29, 15, 0, 4, 12, 92, 12, 25, 13, 25],
  [16, 28, 14, 4, 0, 16, 94, 9, 20, 16, 22],
  [31, 40, 25, 12, 16, 0, 95, 24, 36, 3, 37],
  [100, 72, 81, 92, 94, 95, 0, 90, 101, 99, 84],
  [12, 21, 9, 12, 9, 24, 90, 0, 15, 25, 13],
  [4, 29, 23, 25, 20, 36, 101, 15, 0, 35, 18],
  [31, 41, 27, 13, 16, 3, 99, 25, 35, 0, 38],
  [18, 12, 13, 25, 22, 37, 84, 13, 18, 38, 0]
]

tsp_1248 = [
  [0, 64, 378, 519, 434, 200],
  [64, 0, 318, 455, 375, 164],
  [378, 318, 0, 170, 265, 344],
  [519, 455, 170, 0, 223, 428],
  [434, 375, 265, 223, 0, 273],
  [200, 164, 344, 428, 273, 0]
]


tsp_1194 = [
  [0, 141, 134, 152, 173, 289, 326, 329, 285, 401, 388, 366, 343, 305, 276],
  [141, 0, 152, 150, 153, 312, 354, 313, 249, 324, 300, 272, 247, 201, 176],
  [134, 152, 0, 24, 48, 168, 210, 197, 153, 280, 272, 257, 237, 210, 181],
  [152, 150, 24, 0, 24, 163, 206, 182, 133, 257, 248, 233, 214, 187, 158],
  [173, 153, 48, 24, 0, 160, 203, 167, 114, 234, 225, 210, 190, 165, 137],
  [289, 312, 168, 163, 160, 0, 43, 90, 124, 250, 264, 270, 264, 267, 249],
  [326, 354, 210, 206, 203, 43, 0, 108, 157, 271, 290, 299, 295, 303, 287],
  [329, 313, 197, 182, 167, 90, 108, 0, 70, 164, 183, 195, 194, 210, 201],
  [285, 249, 153, 133, 114, 124, 157, 70, 0, 141, 147, 148, 140, 147, 134],
  [401, 324, 280, 257, 234, 250, 271, 164, 141, 0, 36, 67, 88, 134, 150],
  [388, 300, 272, 248, 225, 264, 290, 183, 147, 36, 0, 33, 57, 104, 124],
  [366, 272, 257, 233, 210, 270, 299, 195, 148, 67, 33, 0, 26, 73, 96],
  [343, 247, 237, 214, 190, 264, 295, 194, 140, 88, 57, 26, 0, 48, 71],
  [305, 201, 210, 187, 165, 267, 303, 210, 147, 134, 104, 73, 48, 0, 30],
  [276, 176, 181, 158, 137, 249, 287, 201, 134, 150, 124, 96, 71, 30, 0]
]

tsp_7013 = [
  [0, 509, 501, 312, 1019, 736, 656, 60, 1039, 726, 2314, 479, 448, 479, 619, 150, 342, 323, 635, 604, 596, 202, 0, 509, 501, 312, 1019, 736, 656, 60, 1039, 726, 2314, 479, 448, 479, 619, 150, 342, 323, 635, 604, 596, 202],
  [509, 0, 126, 474, 1526, 1226, 1133, 532, 1449, 1122, 2789, 958, 941, 978, 1127, 542, 246, 510, 1047, 1021, 1010, 364, 509, 0, 126, 474, 1526, 1226, 1133, 532, 1449, 1122, 2789, 958, 941, 978, 1127, 542, 246, 510, 1047, 1021, 1010, 364],
  [501, 126, 0, 541, 1516, 1184, 1084, 536, 1371, 1045, 2728, 913, 904, 946, 1115, 499, 321, 577, 976, 952, 941, 401, 501, 126, 0, 541, 1516, 1184, 1084, 536, 1371, 1045, 2728, 913, 904, 946, 1115, 499, 321, 577, 976, 952, 941, 401],
  [312, 474, 541, 0, 1157, 980, 919, 271, 1333, 1029, 2553, 751, 704, 720, 783, 455, 228, 37, 936, 904, 898, 171, 312, 474, 541, 0, 1157, 980, 919, 271, 1333, 1029, 2553, 751, 704, 720, 783, 455, 228, 37, 936, 904, 898, 171],
  [1019, 1526, 1516, 1157, 0, 478, 583, 996, 858, 855, 1504, 677, 651, 600, 401, 1033, 1325, 1134, 818, 808, 820, 1179, 1019, 1526, 1516, 1157, 0, 478, 583, 996, 858, 855, 1504, 677, 651, 600, 401, 1033, 1325, 1134, 818, 808, 820, 1179],
  [736, 1226, 1184, 980, 478, 0, 115, 740, 470, 379, 1581, 271, 289, 261, 308, 687, 1077, 970, 342, 336, 348, 932, 736, 1226, 1184, 980, 478, 0, 115, 740, 470, 379, 1581, 271, 289, 261, 308, 687, 1077, 970, 342, 336, 348, 932],
  [656, 1133, 1084, 919, 583, 115, 0, 667, 455, 288, 1661, 177, 216, 207, 343, 592, 997, 913, 236, 226, 237, 856, 656, 1133, 1084, 919, 583, 115, 0, 667, 455, 288, 1661, 177, 216, 207, 343, 592, 997, 913, 236, 226, 237, 856],
  [60, 532, 536, 271, 996, 740, 667, 0, 1066, 759, 2320, 493, 454, 479, 598, 206, 341, 278, 666, 634, 628, 194, 60, 532, 536, 271, 996, 740, 667, 0, 1066, 759, 2320, 493, 454, 479, 598, 206, 341, 278, 666, 634, 628, 194],
  [1039, 1449, 1371, 1333, 858, 470, 455, 1066, 0, 328, 1387, 591, 650, 656, 776, 933, 1367, 1333, 408, 438, 447, 1239, 1039, 1449, 1371, 1333, 858, 470, 455, 1066, 0, 328, 1387, 591, 650, 656, 776, 933, 1367, 1333, 408, 438, 447, 1239],
  [726, 1122, 1045, 1029, 855, 379, 288, 759, 328, 0, 1697, 333, 400, 427, 622, 610, 1046, 1033, 96, 128, 133, 922, 726, 1122, 1045, 1029, 855, 379, 288, 759, 328, 0, 1697, 333, 400, 427, 622, 610, 1046, 1033, 96, 128, 133, 922],
  [2314, 2789, 2728, 2553, 1504, 1581, 1661, 2320, 1387, 1697, 0, 1838, 1868, 1841, 1789, 2248, 2656, 2540, 1755, 1777, 1789, 2512, 2314, 2789, 2728, 2553, 1504, 1581, 1661, 2320, 1387, 1697, 0, 1838, 1868, 1841, 1789, 2248, 2656, 2540, 1755, 1777, 1789, 2512],
  [479, 958, 913, 751, 677, 271, 177, 493, 591, 333, 1838, 0, 68, 105, 336, 417, 821, 748, 243, 214, 217, 680, 479, 958, 913, 751, 677, 271, 177, 493, 591, 333, 1838, 0, 68, 105, 336, 417, 821, 748, 243, 214, 217, 680],
  [448, 941, 904, 704, 651, 289, 216, 454, 650, 400, 1868, 68, 0, 52, 287, 406, 789, 698, 311, 281, 283, 645, 448, 941, 904, 704, 651, 289, 216, 454, 650, 400, 1868, 68, 0, 52, 287, 406, 789, 698, 311, 281, 283, 645],
  [479, 978, 946, 720, 600, 261, 207, 479, 656, 427, 1841, 105, 52, 0, 237, 449, 818, 712, 341, 314, 318, 672, 479, 978, 946, 720, 600, 261, 207, 479, 656, 427, 1841, 105, 52, 0, 237, 449, 818, 712, 341, 314, 318, 672],
  [619, 1127, 1115, 783, 401, 308, 343, 598, 776, 622, 1789, 336, 287, 237, 0, 636, 932, 764, 550, 528, 535, 785, 619, 1127, 1115, 783, 401, 308, 343, 598, 776, 622, 1789, 336, 287, 237, 0, 636, 932, 764, 550, 528, 535, 785],
  [150, 542, 499, 455, 1033, 687, 592, 206, 933, 610, 2248, 417, 406, 449, 636, 0, 436, 470, 525, 496, 486, 319, 150, 542, 499, 455, 1033, 687, 592, 206, 933, 610, 2248, 417, 406, 449, 636, 0, 436, 470, 525, 496, 486, 319],
  [342, 246, 321, 228, 1325, 1077, 997, 341, 1367, 1046, 2656, 821, 789, 818, 932, 436, 0, 265, 959, 930, 921, 148, 342, 246, 321, 228, 1325, 1077, 997, 341, 1367, 1046, 2656, 821, 789, 818, 932, 436, 0, 265, 959, 930, 921, 148],
  [323, 510, 577, 37, 1134, 970, 913, 278, 1333, 1033, 2540, 748, 698, 712, 764, 470, 265, 0, 939, 907, 901, 201, 323, 510, 577, 37, 1134, 970, 913, 278, 1333, 1033, 2540, 748, 698, 712, 764, 470, 265, 0, 939, 907, 901, 201],
  [635, 1047, 976, 936, 818, 342, 236, 666, 408, 96, 1755, 243, 311, 341, 550, 525, 959, 939, 0, 33, 39, 833, 635, 1047, 976, 936, 818, 342, 236, 666, 408, 96, 1755, 243, 311, 341, 550, 525, 959, 939, 0, 33, 39, 833],
  [604, 1021, 952, 904, 808, 336, 226, 634, 438, 128, 1777, 214, 281, 314, 528, 496, 930, 907, 33, 0, 14, 803, 604, 1021, 952, 904, 808, 336, 226, 634, 438, 128, 1777, 214, 281, 314, 528, 496, 930, 907, 33, 0, 14, 803],
  [596, 1010, 941, 898, 820, 348, 237, 628, 447, 133, 1789, 217, 283, 318, 535, 486, 921, 901, 39, 14, 0, 794, 596, 1010, 941, 898, 820, 348, 237, 628, 447, 133, 1789, 217, 283, 318, 535, 486, 921, 901, 39, 14, 0, 794],
  [202, 364, 401, 171, 1179, 932, 856, 194, 1239, 922, 2512, 680, 645, 672, 785, 319, 148, 201, 833, 803, 794, 0, 202, 364, 401, 171, 1179, 932, 856, 194, 1239, 922, 2512, 680, 645, 672, 785, 319, 148, 201, 833, 803, 794, 1],
  [1, 509, 501, 312, 1019, 736, 656, 60, 1039, 726, 2314, 479, 448, 479, 619, 150, 342, 323, 635, 604, 596, 202, 0, 509, 501, 312, 1019, 736, 656, 60, 1039, 726, 2314, 479, 448, 479, 619, 150, 342, 323, 635, 604, 596, 202],
  [509, 0, 126, 474, 1526, 1226, 1133, 532, 1449, 1122, 2789, 958, 941, 978, 1127, 542, 246, 510, 1047, 1021, 1010, 364, 509, 0, 126, 474, 1526, 1226, 1133, 532, 1449, 1122, 2789, 958, 941, 978, 1127, 542, 246, 510, 1047, 1021, 1010, 364],
  [501, 126, 0, 541, 1516, 1184, 1084, 536, 1371, 1045, 2728, 913, 904, 946, 1115, 499, 321, 577, 976, 952, 941, 401, 501, 126, 0, 541, 1516, 1184, 1084, 536, 1371, 1045, 2728, 913, 904, 946, 1115, 499, 321, 577, 976, 952, 941, 401],
  [312, 474, 541, 0, 1157, 980, 919, 271, 1333, 1029, 2553, 751, 704, 720, 783, 455, 228, 37, 936, 904, 898, 171, 312, 474, 541, 0, 1157, 980, 919, 271, 1333, 1029, 2553, 751, 704, 720, 783, 455, 228, 37, 936, 904, 898, 171],
  [1019, 1526, 1516, 1157, 0, 478, 583, 996, 858, 855, 1504, 677, 651, 600, 401, 1033, 1325, 1134, 818, 808, 820, 1179, 1019, 1526, 1516, 1157, 0, 478, 583, 996, 858, 855, 1504, 677, 651, 600, 401, 1033, 1325, 1134, 818, 808, 820, 1179],
  [736, 1226, 1184, 980, 478, 0, 115, 740, 470, 379, 1581, 271, 289, 261, 308, 687, 1077, 970, 342, 336, 348, 932, 736, 1226, 1184, 980, 478, 0, 115, 740, 470, 379, 1581, 271, 289, 261, 308, 687, 1077, 970, 342, 336, 348, 932],
  [656, 1133, 1084, 919, 583, 115, 0, 667, 455, 288, 1661, 177, 216, 207, 343, 592, 997, 913, 236, 226, 237, 856, 656, 1133, 1084, 919, 583, 115, 0, 667, 455, 288, 1661, 177, 216, 207, 343, 592, 997, 913, 236, 226, 237, 856],
  [60, 532, 536, 271, 996, 740, 667, 0, 1066, 759, 2320, 493, 454, 479, 598, 206, 341, 278, 666, 634, 628, 194, 60, 532, 536, 271, 996, 740, 667, 0, 1066, 759, 2320, 493, 454, 479, 598, 206, 341, 278, 666, 634, 628, 194],
  [1039, 1449, 1371, 1333, 858, 470, 455, 1066, 0, 328, 1387, 591, 650, 656, 776, 933, 1367, 1333, 408, 438, 447, 1239, 1039, 1449, 1371, 1333, 858, 470, 455, 1066, 0, 328, 1387, 591, 650, 656, 776, 933, 1367, 1333, 408, 438, 447, 1239],
  [726, 1122, 1045, 1029, 855, 379, 288, 759, 328, 0, 1697, 333, 400, 427, 622, 610, 1046, 1033, 96, 128, 133, 922, 726, 1122, 1045, 1029, 855, 379, 288, 759, 328, 0, 1697, 333, 400, 427, 622, 610, 1046, 1033, 96, 128, 133, 922],
  [2314, 2789, 2728, 2553, 1504, 1581, 1661, 2320, 1387, 1697, 0, 1838, 1868, 1841, 1789, 2248, 2656, 2540, 1755, 1777, 1789, 2512, 2314, 2789, 2728, 2553, 1504, 1581, 1661, 2320, 1387, 1697, 0, 1838, 1868, 1841, 1789, 2248, 2656, 2540, 1755, 1777, 1789, 2512],
  [479, 958, 913, 751, 677, 271, 177, 493, 591, 333, 1838, 0, 68, 105, 336, 417, 821, 748, 243, 214, 217, 680, 479, 958, 913, 751, 677, 271, 177, 493, 591, 333, 1838, 0, 68, 105, 336, 417, 821, 748, 243, 214, 217, 680],
  [448, 941, 904, 704, 651, 289, 216, 454, 650, 400, 1868, 68, 0, 52, 287, 406, 789, 698, 311, 281, 283, 645, 448, 941, 904, 704, 651, 289, 216, 454, 650, 400, 1868, 68, 0, 52, 287, 406, 789, 698, 311, 281, 283, 645],
  [479, 978, 946, 720, 600, 261, 207, 479, 656, 427, 1841, 105, 52, 0, 237, 449, 818, 712, 341, 314, 318, 672, 479, 978, 946, 720, 600, 261, 207, 479, 656, 427, 1841, 105, 52, 0, 237, 449, 818, 712, 341, 314, 318, 672],
  [619, 1127, 1115, 783, 401, 308, 343, 598, 776, 622, 1789, 336, 287, 237, 0, 636, 932, 764, 550, 528, 535, 785, 619, 1127, 1115, 783, 401, 308, 343, 598, 776, 622, 1789, 336, 287, 237, 0, 636, 932, 764, 550, 528, 535, 785],
  [150, 542, 499, 455, 1033, 687, 592, 206, 933, 610, 2248, 417, 406, 449, 636, 0, 436, 470, 525, 496, 486, 319, 150, 542, 499, 455, 1033, 687, 592, 206, 933, 610, 2248, 417, 406, 449, 636, 0, 436, 470, 525, 496, 486, 319],
  [342, 246, 321, 228, 1325, 1077, 997, 341, 1367, 1046, 2656, 821, 789, 818, 932, 436, 0, 265, 959, 930, 921, 148, 342, 246, 321, 228, 1325, 1077, 997, 341, 1367, 1046, 2656, 821, 789, 818, 932, 436, 0, 265, 959, 930, 921, 148],
  [323, 510, 577, 37, 1134, 970, 913, 278, 1333, 1033, 2540, 748, 698, 712, 764, 470, 265, 0, 939, 907, 901, 201, 323, 510, 577, 37, 1134, 970, 913, 278, 1333, 1033, 2540, 748, 698, 712, 764, 470, 265, 0, 939, 907, 901, 201],
  [635, 1047, 976, 936, 818, 342, 236, 666, 408, 96, 1755, 243, 311, 341, 550, 525, 959, 939, 0, 33, 39, 833, 635, 1047, 976, 936, 818, 342, 236, 666, 408, 96, 1755, 243, 311, 341, 550, 525, 959, 939, 0, 33, 39, 833],
  [604, 1021, 952, 904, 808, 336, 226, 634, 438, 128, 1777, 214, 281, 314, 528, 496, 930, 907, 33, 0, 14, 803, 604, 1021, 952, 904, 808, 336, 226, 634, 438, 128, 1777, 214, 281, 314, 528, 496, 930, 907, 33, 0, 14, 803],
  [596, 1010, 941, 898, 820, 348, 237, 628, 447, 133, 1789, 217, 283, 318, 535, 486, 921, 901, 39, 14, 0, 794, 596, 1010, 941, 898, 820, 348, 237, 628, 447, 133, 1789, 217, 283, 318, 535, 486, 921, 901, 39, 14, 0, 794],
  [202, 364, 401, 171, 1179, 932, 856, 194, 1239, 922, 2512, 680, 645, 672, 785, 319, 148, 201, 833, 803, 794, 0, 202, 364, 401, 171, 1179, 932, 856, 194, 1239, 922, 2512, 680, 645, 672, 785, 319, 148, 201, 833, 803, 794, 0],
]

tsp_27603 = [
  [0, 74, 4110, 3048, 2267, 974, 4190, 3302, 4758, 3044, 3095, 3986, 5093, 6407, 5904, 8436, 6963, 6694, 6576, 8009, 7399, 7267, 7425, 9639, 9230, 8320, 9300, 8103, 7799],
  [74, 0, 4070, 3000, 2214, 901, 4138, 3240, 4702, 2971, 3021, 3915, 5025, 6338, 5830, 8369, 6891, 6620, 6502, 7939, 7326, 7193, 7351, 9571, 9160, 8249, 9231, 8030, 7725],
  [4110, 4070, 0, 1173, 1973, 3496, 892, 1816, 1417, 3674, 3778, 2997, 2877, 3905, 5057, 5442, 4991, 5151, 5316, 5596, 5728, 5811, 5857, 6675, 6466, 6061, 6523, 6165, 6164],
  [3048, 3000, 1173, 0, 817, 2350, 1172, 996, 1797, 2649, 2756, 2317, 2721, 3974, 4548, 5802, 4884, 4887, 4960, 5696, 5537, 5546, 5634, 7045, 6741, 6111, 6805, 6091, 5977],
  [2267, 2214, 1973, 817, 0, 1533, 1924, 1189, 2498, 2209, 2312, 2325, 3089, 4401, 4558, 6342, 5175, 5072, 5075, 6094, 5755, 5712, 5828, 7573, 7222, 6471, 7289, 6374, 6187],
  [974, 901, 3496, 2350, 1533, 0, 3417, 2411, 3936, 2114, 2175, 3014, 4142, 5450, 4956, 7491, 5990, 5725, 5615, 7040, 6430, 6304, 6459, 8685, 8268, 7348, 8338, 7131, 6832],
  [4190, 4138, 892, 1172, 1924, 3417, 0, 1233, 652, 3086, 3185, 2203, 1987, 3064, 4180, 4734, 4117, 4261, 4425, 4776, 4844, 4922, 4971, 5977, 5719, 5228, 5780, 5302, 5281],
  [3302, 3240, 1816, 996, 1189, 2411, 1233, 0, 1587, 1877, 1979, 1321, 1900, 3214, 3556, 5175, 4006, 3947, 3992, 4906, 4615, 4599, 4700, 6400, 6037, 5288, 6105, 5209, 5052],
  [4758, 4702, 1417, 1797, 2498, 3936, 652, 1587, 0, 3286, 3374, 2178, 1576, 2491, 3884, 4088, 3601, 3818, 4029, 4180, 4356, 4469, 4497, 5331, 5084, 4645, 5143, 4761, 4787],
  [3044, 2971, 3674, 2649, 2209, 2114, 3086, 1877, 3286, 0, 107, 1360, 2675, 3822, 2865, 5890, 4090, 3723, 3560, 5217, 4422, 4257, 4428, 7000, 6514, 5455, 6587, 5157, 4802],
  [3095, 3021, 3778, 2756, 2312, 2175, 3185, 1979, 3374, 107, 0, 1413, 2725, 3852, 2826, 5916, 4088, 3705, 3531, 5222, 4402, 4229, 4403, 7017, 6525, 5451, 6598, 5142, 4776],
  [3986, 3915, 2997, 2317, 2325, 3014, 2203, 1321, 2178, 1360, 1413, 0, 1315, 2511, 2251, 4584, 2981, 2778, 2753, 4031, 3475, 3402, 3531, 5734, 5283, 4335, 5355, 4143, 3897],
  [5093, 5025, 2877, 2721, 3089, 4142, 1987, 1900, 1576, 2675, 2725, 1315, 0, 1323, 2331, 3350, 2172, 2275, 2458, 3007, 2867, 2935, 2988, 4547, 4153, 3400, 4222, 3376, 3307],
  [6407, 6338, 3905, 3974, 4401, 5450, 3064, 3214, 2491, 3822, 3852, 2511, 1323, 0, 2350, 2074, 1203, 1671, 2041, 1725, 1999, 2213, 2173, 3238, 2831, 2164, 2901, 2285, 2397],
  [5904, 5830, 5057, 4548, 4558, 4956, 4180, 3556, 3884, 2865, 2826, 2251, 2331, 2350, 0, 3951, 1740, 1108, 772, 2880, 1702, 1450, 1650, 4779, 4197, 2931, 4270, 2470, 2010],
  [8436, 8369, 5442, 5802, 6342, 7491, 4734, 5175, 4088, 5890, 5916, 4584, 3350, 2074, 3951, 0, 2222, 2898, 3325, 1276, 2652, 3019, 2838, 1244, 1089, 1643, 1130, 2252, 2774],
  [6963, 6891, 4991, 4884, 5175, 5990, 4117, 4006, 3601, 4090, 4088, 2981, 2172, 1203, 1740, 2222, 0, 684, 1116, 1173, 796, 1041, 974, 3064, 2505, 1368, 2578, 1208, 1201],
  [6694, 6620, 5151, 4887, 5072, 5725, 4261, 3947, 3818, 3723, 3705, 2778, 2275, 1671, 1108, 2898, 684, 0, 432, 1776, 706, 664, 756, 3674, 3090, 1834, 3162, 1439, 1120],
  [6576, 6502, 5316, 4960, 5075, 5615, 4425, 3992, 4029, 3560, 3531, 2753, 2458, 2041, 772, 3325, 1116, 432, 0, 2174, 930, 699, 885, 4064, 3469, 2177, 3540, 1699, 1253],
  [8009, 7939, 5596, 5696, 6094, 7040, 4776, 4906, 4180, 5217, 5222, 4031, 3007, 1725, 2880, 1276, 1173, 1776, 2174, 0, 1400, 1770, 1577, 1900, 1332, 510, 1406, 1002, 1499],
  [7399, 7326, 5728, 5537, 5755, 6430, 4844, 4615, 4356, 4422, 4402, 3475, 2867, 1999, 1702, 2652, 796, 706, 930, 1400, 0, 371, 199, 3222, 2611, 1285, 2679, 769, 440],
  [7267, 7193, 5811, 5546, 5712, 6304, 4922, 4599, 4469, 4257, 4229, 3402, 2935, 2213, 1450, 3019, 1041, 664, 699, 1770, 371, 0, 220, 3583, 2970, 1638, 3037, 1071, 560],
  [7425, 7351, 5857, 5634, 5828, 6459, 4971, 4700, 4497, 4428, 4403, 3531, 2988, 2173, 1650, 2838, 974, 756, 885, 1577, 199, 220, 0, 3371, 2756, 1423, 2823, 852, 375],
  [9639, 9571, 6675, 7045, 7573, 8685, 5977, 6400, 5331, 7000, 7017, 5734, 4547, 3238, 4779, 1244, 3064, 3674, 4064, 1900, 3222, 3583, 3371, 0, 620, 1952, 560, 2580, 3173],
  [9230, 9160, 6466, 6741, 7222, 8268, 5719, 6037, 5084, 6514, 6525, 5283, 4153, 2831, 4197, 1089, 2505, 3090, 3469, 1332, 2611, 2970, 2756, 620, 0, 1334, 74, 1961, 2554],
  [8320, 8249, 6061, 6111, 6471, 7348, 5228, 5288, 4645, 5455, 5451, 4335, 3400, 2164, 2931, 1643, 1368, 1834, 2177, 510, 1285, 1638, 1423, 1952, 1334, 0, 1401, 648, 1231],
  [9300, 9231, 6523, 6805, 7289, 8338, 5780, 6105, 5143, 6587, 6598, 5355, 4222, 2901, 4270, 1130, 2578, 3162, 3540, 1406, 2679, 3037, 2823, 560, 74, 1401, 0, 2023, 2617],
  [8103, 8030, 6165, 6091, 6374, 7131, 5302, 5209, 4761, 5157, 5142, 4143, 3376, 2285, 2470, 2252, 1208, 1439, 1699, 1002, 769, 1071, 852, 2580, 1961, 648, 2023, 0, 594],
  [7799, 7725, 6164, 5977, 6187, 6832, 5281, 5052, 4787, 4802, 4776, 3897, 3307, 2397, 2010, 2774, 1201, 1120, 1253, 1499, 440, 560, 375, 3173, 2554, 1231, 2617, 594, 0],
]

tsp.set_graph(tsp_253)
tsp.brute_force_tsp
tsp.approx_tsp_tour(0, 253)

# tsp.set_graph(tsp_1248)
# tsp.brute_force_tsp
# tsp.approx_tsp_tour(0, 1248)

# tsp.set_graph(tsp_1194)
# tsp.brute_force_tsp
# tsp.approx_tsp_tour(0, 1194)

# tsp.set_graph(tsp_7013)
# tsp.brute_force_tsp
# tsp.approx_tsp_tour(0, 7013)

# tsp.set_graph(tsp_27603)
# tsp.brute_force_tsp
# tsp.approx_tsp_tour(0, 27603)
