# encoding: utf-8

def play_game
  secret   = rand(1..100)
  attempts = 0

  puts "Я загадав число від 1 до 100. Спробуй вгадати!"

  loop do
    print "Ваше припущення: "
    input = gets
    break if input.nil? 

    guess = Integer(input.strip, exception: false)
    if guess.nil? || guess < 1 || guess > 100
      puts "Введіть ціле число від 1 до 100."
      next
    end

    attempts += 1

    if guess < secret
      puts "Більше"
    elsif guess > secret
      puts "Менше"
    else
      puts "Вгадано! Кількість спроб: #{attempts}"
      break
    end
  end
end

play_game
