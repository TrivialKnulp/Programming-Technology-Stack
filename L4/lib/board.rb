class Board
  # Розміри кораблів: один на 4, два на 3, три на 2, чотири на 1
  FLEET = [4, 3, 3, 2, 2, 2, 1, 1, 1, 1]

  def initialize(rng)
    @rng = rng
    @ships = []
    @ship_at = {} # клітинка => корабель
    @shots = {}   # клітинка => :hit або :miss
    place_fleet
  end

  # Постріл. Повертає результат (:miss, :hit або :sunk) і корабель (або nil)
  def shoot(cell)
    if @shots.key?(cell)
      raise InvalidInputError, "У клітинку #{Coordinates.to_text(cell)} вже стріляли. Оберіть іншу."
    end

    ship = @ship_at[cell]
    if ship.nil?
      @shots[cell] = :miss
      return :miss, nil
    end

    ship.hit
    @shots[cell] = :hit
    ship.sunk? ? [:sunk, ship] : [:hit, ship]
  end

  def all_sunk?
    @ships.all? { |ship| ship.sunk? }
  end

  # Рядки для друку поля. Кораблі суперника ховаємо (show_ships = false)
  def render(show_ships)
    lines = ["   " + Coordinates::LETTERS.join(" ")]

    Coordinates::SIZE.times do |row|
      symbols = []
      Coordinates::SIZE.times do |col|
        cell = [row, col]
        if @shots[cell] == :hit
          symbols << "X"
        elsif @shots[cell] == :miss
          symbols << "o"
        elsif show_ships && @ship_at[cell]
          symbols << "S"
        else
          symbols << "."
        end
      end
      lines << format("%2d", row + 1) + " " + symbols.join(" ")
    end

    lines
  end

  private

  # Розставляємо всі кораблі. Якщо не вийшло - пробуємо спочатку
  def place_fleet
    loop do
      @ships = []
      @ship_at = {}
      break if FLEET.all? { |size| place_ship(size) }
    end
  end

  def place_ship(size)
    200.times do
      cells = random_cells(size)
      next unless free?(cells)

      ship = Ship.new(cells)
      @ships << ship
      cells.each { |cell| @ship_at[cell] = ship }
      return true
    end
    false
  end

  def random_cells(size)
    max = Coordinates::SIZE
    horizontal = @rng.rand(2) == 0

    if horizontal
      row = @rng.rand(max)
      col = @rng.rand(max - size + 1)
    else
      row = @rng.rand(max - size + 1)
      col = @rng.rand(max)
    end

    cells = []
    size.times do |i|
      cells << (horizontal ? [row, col + i] : [row + i, col])
    end
    cells
  end

  # Корабель можна поставити, якщо ні його клітинки, ні сусідні
  # (разом з діагоналями) не зайняті іншими кораблями
  def free?(cells)
    cells.each do |cell|
      return false if @ship_at[cell]
      Coordinates.neighbors(cell).each do |neighbor|
        return false if @ship_at[neighbor]
      end
    end
    true
  end
end
