require "set"

class Game
  def initialize(rng = Random.new)
    @rng = rng
    @player_board = Board.new(rng)
    @computer_board = Board.new(rng)
    @computer_cells = Set.new(Coordinates.all) # куди комп'ютер ще не стріляв
    @targets = []                              # клітинки поруч із влучанням
  end

  # Повертає :win, :lose або :quit
  def play
    puts "Кораблі розставлено. Починаємо!"

    loop do
      show_boards(false)

      return :quit unless player_turn
      return finish(:win) if @computer_board.all_sunk?

      computer_turn
      return finish(:lose) if @player_board.all_sunk?
    end
  end

  private

  # Запитує координати, поки вони не будуть правильними.
  # Повертає false, якщо гравець вирішив вийти.
  def player_turn
    loop do
      print "Ваш постріл (напр. B5, q - вийти в меню): "
      line = $stdin.gets
      return false if line.nil? || line.scrub.strip.downcase == "q"

      begin
        cell = Coordinates.parse(line)
        outcome, ship = @computer_board.shoot(cell)
        puts "Ваш постріл у #{Coordinates.to_text(cell)}: #{describe(outcome, ship)}"
        return true
      rescue InvalidInputError => e
        puts "Помилка: #{e.message}"
      end
    end
  end

  def computer_turn
    cell = computer_pick
    outcome, ship = @player_board.shoot(cell)
    puts "Комп'ютер стріляє в #{Coordinates.to_text(cell)}: #{describe(outcome, ship)}"

    if outcome == :sunk
      # Кораблі не торкаються, тому навколо потопленого стріляти не треба
      ship.surrounding_cells.each { |c| @computer_cells.delete(c) }
      @targets = []
    elsif outcome == :hit
      Coordinates.side_neighbors(cell).each do |neighbor|
        @targets << neighbor if @computer_cells.include?(neighbor)
      end
    end
  end

  # Спочатку добиваємо корабель, інакше стріляємо у випадкову нову клітинку
  def computer_pick
    cell = nil
    until cell || @targets.empty?
      candidate = @targets.shift
      cell = candidate if @computer_cells.include?(candidate)
    end

    cell ||= @computer_cells.to_a.sample(random: @rng)
    @computer_cells.delete(cell)
    cell
  end

  def describe(outcome, ship)
    if outcome == :miss
      "промах."
    elsif outcome == :hit
      "влучання!"
    else
      "знищено #{ship.size}-палубний корабель!"
    end
  end

  def finish(result)
    show_boards(true)
    result
  end

  def show_boards(reveal)
    left = @player_board.render(true)
    right = @computer_board.render(reveal)

    puts ""
    puts "ВАШЕ ПОЛЕ".ljust(22) + "    ПОЛЕ КОМП'ЮТЕРА"
    left.each_with_index do |line, i|
      puts line.ljust(22) + "    " + right[i]
    end
    puts "S - корабель, X - влучання, o - промах, . - невідомо"
    puts ""
  end
end
