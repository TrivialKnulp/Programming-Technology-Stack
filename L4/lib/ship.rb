class Ship
  attr_reader :cells

  def initialize(cells)
    @cells = cells
    @hits = 0
  end

  def size
    @cells.size
  end

  def hit
    @hits += 1
  end

  def sunk?
    @hits == size
  end

  # Клітинки навколо корабля, де не може стояти інший корабель
  def surrounding_cells
    result = []
    @cells.each do |cell|
      Coordinates.neighbors(cell).each do |neighbor|
        next if @cells.include?(neighbor) || result.include?(neighbor)
        result << neighbor
      end
    end
    result
  end
end
