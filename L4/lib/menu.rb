module Menu
  RULES = <<~TEXT
    ПРАВИЛА
    - Поле 10x10: стовпці A-J, рядки 1-10.
    - Флот: 1 корабель на 4 клітинки, 2 - на 3, 3 - на 2, 4 - на 1.
    - Кораблі не перетинаються і не торкаються, навіть по діагоналі.
    - Ходи по черзі. Введіть координати пострілу, наприклад B5.
    - Гра повідомляє: промах, влучання або знищення корабля.
    - Перемагає той, хто першим знищить усі кораблі суперника.
  TEXT

  def self.run
    wins = 0
    losses = 0
    puts "МОРСЬКИЙ БІЙ"

    loop do
      puts ""
      puts "1. Нова гра"
      puts "2. Правила"
      puts "3. Статистика"
      puts "4. Вихід"
      print "Ваш вибір: "

      line = $stdin.gets
      break if line.nil?
      choice = line.scrub.strip

      if choice == "1"
        result = Game.new.play
        if result == :win
          wins += 1
          puts "Ви перемогли!"
        elsif result == :lose
          losses += 1
          puts "Комп'ютер переміг. Спробуйте ще раз!"
        else
          puts "Гру перервано, результат не зараховано."
        end
      elsif choice == "2"
        puts RULES
      elsif choice == "3"
        puts "Перемог: #{wins}, поразок: #{losses}"
      elsif choice == "4"
        break
      else
        puts "Невірний вибір. Введіть число від 1 до 4."
      end
    end

    puts "До побачення!"
  end
end
