# Робота з координатами. Клітинка - масив [рядок, стовпець] з нуля: B5 -> [4, 1]
module Coordinates
  SIZE = 10
  LETTERS = %w[A B C D E F G H I J]

  # "b5" -> [4, 1]. Якщо ввід неправильний - кидає InvalidInputError
  def self.parse(input)
    text = input.to_s.scrub.strip.upcase
    col = LETTERS.index(text[0])
    number = text[1..-1].to_s

    if col.nil? || number !~ /\A\d{1,2}\z/
      raise InvalidInputError, "Невірний формат. Приклад: B5 (літера A-J і число 1-10)."
    end

    row = number.to_i - 1
    if row < 0 || row >= SIZE
      raise InvalidInputError, "Число має бути від 1 до 10."
    end

    [row, col]
  end

  # [4, 1] -> "B5"
  def self.to_text(cell)
    "#{LETTERS[cell[1]]}#{cell[0] + 1}"
  end

  def self.inside?(cell)
    cell[0] >= 0 && cell[0] < SIZE && cell[1] >= 0 && cell[1] < SIZE
  end

  def self.all
    cells = []
    SIZE.times do |row|
      SIZE.times { |col| cells << [row, col] }
    end
    cells
  end

  # 8 сусідніх клітинок (разом з діагоналями)
  def self.neighbors(cell)
    result = []
    [-1, 0, 1].each do |dr|
      [-1, 0, 1].each do |dc|
        next if dr == 0 && dc == 0
        neighbor = [cell[0] + dr, cell[1] + dc]
        result << neighbor if inside?(neighbor)
      end
    end
    result
  end

  # 4 сусіди: вгору, вниз, ліворуч, праворуч
  def self.side_neighbors(cell)
    result = []
    [[-1, 0], [1, 0], [0, -1], [0, 1]].each do |dr, dc|
      neighbor = [cell[0] + dr, cell[1] + dc]
      result << neighbor if inside?(neighbor)
    end
    result
  end
end
