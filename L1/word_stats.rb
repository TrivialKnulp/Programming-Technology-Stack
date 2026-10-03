# encoding: utf-8

def word_stats(text)
  words = text.scan(/[[:alpha:]][[:alpha:]'’-]*/)

  count   = words.size
  longest = words.max_by(&:length)
  unique  = words.map(&:downcase).uniq.size

  puts "#{count} слів, найдовше: #{longest || '-'}, унікальних: #{unique}"
end

word_stats("Ruby is fun and ruby is powerful")

print "\nВведіть рядок тексту: "
input = gets.to_s.chomp
word_stats(input)
