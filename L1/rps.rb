CHOICES = {
  "1" => "Камінь",
  "2" => "Ножиці",
  "3" => "Папір"
}.freeze

BEATS = {
  "Камінь" => "Ножиці",
  "Ножиці" => "Папір",
  "Папір"  => "Камінь"
}.freeze

stats = { wins: 0, losses: 0, draws: 0, rounds: 0 }

puts "=== Камінь, ножиці, папір ==="

loop do
  puts "\n1 - Камінь, 2 - Ножиці, 3 - Папір, 0 - Вихід"
  print "Ваш вибір: "
  input = gets
  break if input.nil?
  input = input.strip

  break if input == "0"

  unless CHOICES.key?(input)
    puts "Невірний ввід, спробуйте ще раз."
    next
  end

  player   = CHOICES[input]
  computer = CHOICES.values.sample

  puts "Ви: #{player}"
  puts "Вибір комп'ютера: #{computer}"

  stats[:rounds] += 1

  if player == computer
    stats[:draws] += 1
    puts "Нічия!"
  elsif BEATS[player] == computer
    stats[:wins] += 1
    puts "Ви перемогли!"
  else
    stats[:losses] += 1
    puts "Комп'ютер переміг!"
  end

  puts "--- Статистика ---"
  puts "Перемоги користувача: #{stats[:wins]}"
  puts "Перемоги комп'ютера:  #{stats[:losses]}"
  puts "Нічиї:                #{stats[:draws]}"
  puts "Усього раундів:       #{stats[:rounds]}"
end

puts "\nДякую за гру! Фінальний рахунок: ви #{stats[:wins]} : #{stats[:losses]} комп'ютер, нічиїх: #{stats[:draws]}"
