class TSP
  def initialize()
    @graph = []
  end
  
  def read_file(path)
    lines = File.readlines(path)
    
    # Inicializa a matriz com zeros
    @graph = Array.new(lines.length) { Array.new(lines.length, 0) }
    
    # Preenche a matriz com as informações do arquivo
    lines.each_with_index do |line, i|
      values = line.split.map(&:to_i)
      values.each_with_index do |value, j|
        @graph[i][j] = value if @graph[i]
      end
    end
  end
  
  def print_graph
    @graph.each do |row|
      puts row.join(" ")
    end
  end
  
end

tsp = TSP.new
tsp.read_file("./resources/tsp1_253.txt")
tsp.print_graph
