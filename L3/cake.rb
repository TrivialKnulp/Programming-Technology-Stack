# Пиріг з родзинками: розрізати на n рівних прямокутників (n = кількість родзинок),
# у кожному шматку рівно одна родзинка.

RAISINS = ["o", "O", "\u043E", "\u041E"]

# Читає пиріг з тексту: беремо тільки рядки з крапок і родзинок
def read_cake(text)
  cake = []
  text.each_line do |line|
    line = line.gsub("\uFEFF", "").gsub(" ", "").strip
    next if line == ""

    ok = true
    line.each_char do |ch|
      ok = false if ch != "." && !RAISINS.include?(ch)
    end
    cake << line if ok
  end
  cake
end

# Скільки родзинок у прямокутнику
def count_raisins(cake, top, left, h, w)
  count = 0
  h.times do |i|
    w.times do |j|
      count += 1 if RAISINS.include?(cake[top + i][left + j])
    end
  end
  count
end

# Чи вся ділянка ще вільна
def free?(used, top, left, h, w)
  h.times do |i|
    w.times do |j|
      return false if used[top + i][left + j]
    end
  end
  true
end

# Позначає ділянку зайнятою (true) або вільною (false)
def mark(used, top, left, h, w, value)
  h.times do |i|
    w.times do |j|
      used[top + i][left + j] = value
    end
  end
end

# Перша вільна клітинка (зверху вниз, зліва направо). Якщо немає, повертає nil
def find_first_free(used)
  used.size.times do |r|
    used[0].size.times do |c|
      return [r, c] if used[r][c] == false
    end
  end
  nil
end

# Підбір шматків. Перша вільна клітинка = лівий верхній кут нового шматка.
# Ширину пробуємо від більшої до меншої, тому перше знайдене рішення
# має найбільшу ширину першого шматка.
def search(cake, used, area, pieces)
  cell = find_first_free(used)
  return true if cell.nil?

  top = cell[0]
  left = cell[1]

  w = area
  while w >= 1
    if area % w == 0
      h = area / w
      fits = left + w <= cake[0].size && top + h <= cake.size

      if fits && free?(used, top, left, h, w) && count_raisins(cake, top, left, h, w) == 1
        mark(used, top, left, h, w, true)
        pieces << [top, left, h, w]
        return true if search(cake, used, area, pieces)
        pieces.pop
        mark(used, top, left, h, w, false)
      end
    end
    w -= 1
  end

  false
end

# Головна функція: повертає масив шматків (кожен шматок = масив рядків)
def cut(cake)
  rows = cake.size
  cols = cake[0].size
  n = count_raisins(cake, 0, 0, rows, cols)
  total = rows * cols

  return [] if n == 0 || total % n != 0

  area = total / n
  used = Array.new(rows) { Array.new(cols, false) }
  pieces = []
  return [] if !search(cake, used, area, pieces)

  result = []
  pieces.each do |p|
    top = p[0]
    left = p[1]
    h = p[2]
    w = p[3]
    piece = []
    h.times do |i|
      piece << cake[top + i][left, w]
    end
    result << piece
  end
  result
end

def show(result)
  if result.empty?
    puts "Рішення немає"
    return
  end

  puts "["
  result.each_with_index do |piece, i|
    puts "  ," if i > 0
    piece.each { |row| puts "    " + row }
  end
  puts "]"
end

def main
  if ARGV[0]
    text = File.read(ARGV[0], encoding: "bom|utf-8")
  else
    text = $stdin.read
  end

  cake = read_cake(text)

  if cake.empty?
    puts "Помилка: пиріг не знайдено. Потрібні рядки з крапок і родзинок (o)."
    return
  end

  if cake.map { |row| row.size }.uniq.size != 1
    puts "Помилка: усі рядки пирога мають бути однакової довжини."
    return
  end

  show(cut(cake))
end

main