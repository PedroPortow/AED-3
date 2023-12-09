require_relative 'tsp'

class Execution
  def initialize
    @tsp = TSP.new
  end

  def run_execution_menu
    loop do
      clear_console
      puts "1. TSP - Custo ótimo: 253"
      puts "2. TSP - Custo ótimo: 1248"
      puts "3. TSP - Custo ótimo: 1194"
      puts "4. TSP - Custo ótimo: 7013"
      puts "5. TSP - Custo ótimo: 27603"
      puts "6. Sair"

      choice = gets.chomp

      case choice
      when '1'
        execute_tsp("./TSP/resources/tsp1_253.txt", 253)
      when '2'
        execute_tsp("./TSP/resources/tsp2_1248.txt", 1248)
      when '3'
        execute_tsp("./TSP/resources/tsp3_1194.txt", 1194)
      when '4'
        execute_tsp("./TSP/resources/tsp4_7013.txt", 7013)
      when '5'
        execute_tsp("./TSP/resources/tsp5_27603.txt", 27603)
      when '6'
        break
      end
    end
  end

  private
  
  def clear_console
    system('clear') || system('cls')
  end

  def execute_tsp(file_path, optimal_cost)
    clear_console
    @tsp.read_file(file_path)

    loop do
      puts "Escolha uma opção para resolver o TSP de custo ótimo #{optimal_cost}:"
      puts "1. Força Bruta"
      puts "2. Aproximativo"
      puts "3. Rodar aproximativo 50.000 vezes"
      puts "4. Voltar ao menu principal"

      tsp_choice = gets.chomp

      case tsp_choice
      when '1'
        clear_console
        @tsp.brute_force_tsp(1000000)
      when '2'
        clear_console
         @tsp.nearest_neighbor_tsp(optimal_cost)
      when '3'
        @tsp.average_nearest_neighbor_tsp(50000)
      when '4'
        break
      else
        puts "Opção inválida"
      end
    end
  end
end

Execution.new.run_execution_menu
