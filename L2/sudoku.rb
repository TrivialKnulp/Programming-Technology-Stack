# Консольна гра «Судоку» 4x4 (блоки 2x2)
# Запуск: ruby sudoku.rb
START = [
  [1, 0, 0, 4],
  [0, 4, 1, 0],
  [2, 0, 0, 3],
  [0, 3, 2, 0]
]

def copy_board(board)
  board.map { |row| row.dup }
end

def show_board(board)
  puts
  puts "     1 2   3 4"
  board.each_with_index do |row, r|
    puts "   +-----+-----+" if r % 2 == 0
    line = ""
    row.each_with_index do |value, c|
      line += "| " if c % 2 == 0
      line += (value == 0 ? "." : value.to_s) + " "
    end
    puts " #{r + 1} " + line + "|"
  end
  puts "   +-----+-----+"
end

def find_conflict(board, r, c, n)
  4.times do |i|
    return "Число #{n} уже є в цьому рядку." if i != c && board[r][i] == n
    return "Число #{n} уже є в цьому стовпці." if i != r && board[i][c] == n
  end

  # Верхній лівий кут блока 2x2
  block_r = r / 2 * 2
  block_c = c / 2 * 2
  2.times do |i|
    2.times do |j|
      rr = block_r + i
      cc = block_c + j
      next if rr == r && cc == c
      return "Число #{n} уже є в цьому блоці 2x2." if board[rr][cc] == n
    end
  end

  nil
end

def solved?(board)
  4.times do |r|
    4.times do |c|
      value = board[r][c]
      return false if value == 0
      return false if find_conflict(board, r, c, value)
    end
  end
  true
end

def read_move(text)
  parts = text.split
  return nil unless parts.size == 3
  return nil unless parts.all? { |p| p =~ /\A\d+\z/ }
  parts.map { |p| p.to_i }
end

def show_stats(moves, errors)
  puts "Вдалих ходів: #{moves}, помилок: #{errors}"
end

def play
  board = copy_board(START)
  moves = 0
  errors = 0

  puts "=== Судоку 4x4 ==="
  puts "Введіть хід: рядок стовпець число (наприклад: 1 2 3)."
  puts "Число 0 очищає клітинку, q - вийти з гри."

  loop do
    show_board(board)
    print "Ваш хід: "
    input = $stdin.gets

    if input.nil? || input.strip.downcase == "q"
      puts "Гру завершено достроково."
      show_stats(moves, errors)
      break
    end

    move = read_move(input)
    if move.nil?
      puts "Помилка: введіть три числа через пропуск, наприклад: 1 2 3"
      errors += 1
      next
    end

    row, col, num = move
    unless (1..4).include?(row) && (1..4).include?(col) && (0..4).include?(num)
      puts "Помилка: рядок і стовпець мають бути від 1 до 4, число - від 0 до 4."
      errors += 1
      next
    end

    r = row - 1
    c = col - 1

    if START[r][c] != 0
      puts "Помилка: початкові числа змінювати заборонено."
      errors += 1
      next
    end

    if num != 0
      problem = find_conflict(board, r, c, num)
      if problem
        puts "Помилка: #{problem}"
        errors += 1
        next
      end
    end

    board[r][c] = num
    moves += 1

    if solved?(board)
      show_board(board)
      puts "Вітаємо, ви перемогли!"
      show_stats(moves, errors)
      break
    end
  end
end

play
