# frozen_string_literal: true

# ExpenseTracker - консольний облік витрат (Ruby 3.x, без зовнішніх гемів)
# Запуск: ruby expense_tracker.rb [шлях_до_файлу.json]

require 'json'
require 'date'

# Працюємо в UTF-8 незалежно від налаштувань терміналу
Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = nil
$stdin.set_encoding(Encoding::UTF_8)
$stdout.set_encoding(Encoding::UTF_8)

DATA_FILE  = ARGV[0] || 'expenses.json'
CATEGORIES = %w[food transport study entertainment other].freeze
FIELDS     = %w[id date amount_in_kopecks category description].freeze

# ---------- Допоміжні функції ----------

# 12550 -> "125.50"
def money(kopecks)
  format('%d.%02d', kopecks / 100, kopecks % 100)
end

# Повертає Date або nil, якщо рядок не є реальною датою YYYY-MM-DD
def parse_date(text)
  return nil unless text.is_a?(String) && text.match?(/\A\d{4}-\d{2}-\d{2}\z/)

  y, m, d = text.split('-').map(&:to_i)
  Date.valid_date?(y, m, d) ? Date.new(y, m, d) : nil
end

# Перевірка одного запису. Повертає текст помилки або nil, якщо все гаразд.
def record_error(rec, need_id:)
  return 'запис не є об\'єктом' unless rec.is_a?(Hash)

  required = need_id ? FIELDS : FIELDS - ['id']
  missing  = required - rec.keys
  return "відсутні поля: #{missing.join(', ')}" unless missing.empty?

  extra = rec.keys - FIELDS
  return "невідомі поля: #{extra.join(', ')}" unless extra.empty?

  if rec.key?('id') && !(rec['id'].is_a?(Integer) && rec['id'].positive?)
    return 'id має бути додатним цілим числом'
  end
  return 'date має бути реальною датою YYYY-MM-DD' unless parse_date(rec['date'])

  unless rec['amount_in_kopecks'].is_a?(Integer) && rec['amount_in_kopecks'].positive?
    return 'amount_in_kopecks має бути додатним цілим числом'
  end
  return "category має бути однією з: #{CATEGORIES.join(', ')}" unless CATEGORIES.include?(rec['category'])

  desc = rec['description']
  return 'description має бути текстом' unless desc.is_a?(String)

  desc = desc.strip
  return 'description не може бути порожнім' if desc.empty?
  return 'description довший за 200 символів' if desc.length > 200

  nil
end

def clean_record(rec)
  {
    'date' => rec['date'],
    'amount_in_kopecks' => rec['amount_in_kopecks'],
    'category' => rec['category'],
    'description' => rec['description'].strip
  }
end

def ask(prompt)
  print prompt
  line = $stdin.gets
  if line.nil?
    puts "\nВвід завершено. Вихід."
    exit 0
  end
  line.strip
end

# ---------- Збереження / завантаження ----------

# Повертає масив записів або завершує програму, не чіпаючи файл.
def load_expenses(path)
  return [] unless File.exist?(path)

  text = File.read(path, encoding: 'UTF-8')
  abort "Помилка: файл '#{path}' порожній. Виправте або видаліть його вручну." if text.strip.empty?

  data = JSON.parse(text)
  abort "Помилка: файл '#{path}' має містити JSON-масив." unless data.is_a?(Array)

  ids = {}
  data.each_with_index do |rec, i|
    err = record_error(rec, need_id: true)
    err ||= "id #{rec['id']} повторюється" if ids[rec['id']]
    abort "Помилка у файлі '#{path}', запис №#{i + 1}: #{err}. Файл не змінено." if err
    ids[rec['id']] = true
  end
  data.map { |r| r.merge('description' => r['description'].strip) }
rescue JSON::ParserError, EncodingError
  abort "Помилка: файл '#{path}' пошкоджений (некоректний JSON). Файл не змінено."
rescue SystemCallError, IOError => e
  abort "Помилка читання файлу '#{path}': #{e.message}"
end

# Записує через тимчасовий файл, щоб не пошкодити наявні дані. Повертає true/false.
def save_expenses(expenses, path)
  tmp = "#{path}.tmp"
  File.write(tmp, JSON.pretty_generate(expenses), encoding: 'UTF-8')
  File.rename(tmp, path)
  true
rescue SystemCallError, IOError => e
  puts "Помилка збереження: #{e.message}"
  File.delete(tmp) if File.exist?(tmp) rescue nil
  false
end

# ---------- Вивід ----------

def sorted(expenses)
  expenses.sort_by { |e| [e['date'], e['id']] }
end

def print_table(expenses)
  rows = sorted(expenses)
  puts format('%-5s %-10s %12s  %-14s %s', 'ID', 'Дата', 'Сума, грн', 'Категорія', 'Опис')
  puts '-' * 70
  rows.each do |e|
    puts format('%-5d %-10s %12s  %-14s %s',
                e['id'], e['date'], money(e['amount_in_kopecks']), e['category'], e['description'])
  end
  puts '-' * 70
  puts "Разом: #{money(rows.sum { |e| e['amount_in_kopecks'] })} грн (записів: #{rows.size})"
end

# ---------- Введення даних ----------

# Порожній рядок = скасування (повертає nil)
def read_date(prompt, optional: false)
  loop do
    s = ask(prompt)
    return nil if s.empty?

    d = parse_date(s)
    return d if d

    puts 'Невірна дата. Потрібна реальна дата у форматі YYYY-MM-DD (наприклад, 2025-03-14).'
  end
end

def read_amount
  loop do
    s = ask('Сума в копійках (ціле число > 0, наприклад 12550): ')
    return nil if s.empty?
    return s.to_i if s.match?(/\A\d+\z/) && s.to_i.positive?

    puts 'Невірна сума. Введіть додатне ціле число копійок.'
  end
end

def read_category(prompt, allow_empty: false)
  loop do
    s = ask(prompt)
    return (allow_empty ? :any : nil) if s.empty?
    return s.downcase if CATEGORIES.include?(s.downcase)

    puts "Невідома категорія. Доступні: #{CATEGORIES.join(', ')}."
  end
end

def read_description
  loop do
    s = ask('Опис (1-200 символів): ')
    return nil if s.empty?
    return s if s.length <= 200

    puts "Опис задовгий (#{s.length} символів). Максимум - 200."
  end
end

# ---------- Дії меню ----------

def next_id(expenses)
  (expenses.map { |e| e['id'] }.max || 0) + 1
end

# Додає записи, зберігає; при помилці збереження повертає стан назад.
def commit(expenses, new_list)
  backup = expenses.dup
  expenses.replace(new_list)
  return true if save_expenses(expenses, DATA_FILE)

  expenses.replace(backup)
  puts 'Зміни НЕ збережено, попередній стан відновлено.'
  false
end

def add_expense(expenses)
  puts '(порожній рядок - скасувати)'
  date = read_date('Дата (YYYY-MM-DD): ') or return puts('Скасовано.')
  amount = read_amount or return puts('Скасовано.')
  category = read_category("Категорія (#{CATEGORIES.join('/')}): ") or return puts('Скасовано.')
  desc = read_description or return puts('Скасовано.')

  rec = { 'id' => next_id(expenses), 'date' => date.to_s, 'amount_in_kopecks' => amount,
          'category' => category, 'description' => desc.strip }
  if rec['description'].empty?
    puts 'Опис не може складатися лише з пробілів.'
    return
  end
  puts "Витрату додано (id #{rec['id']})." if commit(expenses, expenses + [rec])
end

def show_all(expenses)
  return puts('Список витрат порожній.') if expenses.empty?

  print_table(expenses)
end

def filter_expenses(expenses)
  puts '(порожній рядок - без обмеження)'
  category = read_category('Категорія: ', allow_empty: true)
  from = nil
  to = nil
  loop do
    from = read_date('Початкова дата (YYYY-MM-DD): ')
    to   = read_date('Кінцева дата (YYYY-MM-DD): ')
    break unless from && to && from > to

    puts 'Початкова дата не може бути пізнішою за кінцеву. Спробуйте ще раз.'
  end

  result = expenses.select do |e|
    d = Date.parse(e['date'])
    (category == :any || e['category'] == category) && (from.nil? || d >= from) && (to.nil? || d <= to)
  end
  if result.empty?
    puts 'За цими умовами витрат не знайдено. Сума: 0.00 грн.'
  else
    print_table(result)
  end
end

def delete_expense(expenses)
  return puts('Список витрат порожній.') if expenses.empty?

  s = ask('ID витрати для видалення: ')
  return puts('Скасовано.') if s.empty?
  return puts('ID має бути додатним цілим числом.') unless s.match?(/\A\d+\z/)

  rec = expenses.find { |e| e['id'] == s.to_i }
  return puts("Витрату з id #{s.to_i} не знайдено.") unless rec

  print_table([rec])
  answer = ask('Видалити? (y/n): ').downcase
  return puts('Видалення скасовано.') unless %w[y yes т так д да].include?(answer)

  puts 'Витрату видалено.' if commit(expenses, expenses.reject { |e| e['id'] == rec['id'] })
end

def show_statistics(expenses)
  if expenses.empty?
    puts 'Даних немає. Загальна сума: 0.00 грн.'
  else
    puts "Загальна сума: #{money(expenses.sum { |e| e['amount_in_kopecks'] })} грн"
    puts 'За категоріями:'
    CATEGORIES.each do |c|
      sum = expenses.select { |e| e['category'] == c }.sum { |e| e['amount_in_kopecks'] }
      puts format('  %-14s %12s грн', c, money(sum))
    end
    max = expenses.map { |e| e['amount_in_kopecks'] }.max
    puts "Найбільша витрата (#{money(max)} грн):"
    sorted(expenses.select { |e| e['amount_in_kopecks'] == max }).each do |e|
      puts "  id #{e['id']}, #{e['date']}, #{e['category']}, #{e['description']}"
    end
  end

  puts 'Сума за період (порожній рядок - пропустити):'
  loop do
    from = read_date('  Початкова дата: ') or break
    to   = read_date('  Кінцева дата: ') or break
    if from > to
      puts '  Початкова дата не може бути пізнішою за кінцеву.'
      next
    end
    part = expenses.select { |e| (from..to).cover?(Date.parse(e['date'])) }
    if part.empty?
      puts '  За цей період витрат немає. Сума: 0.00 грн.'
    else
      puts "  Сума за період #{from} - #{to}: #{money(part.sum { |e| e['amount_in_kopecks'] })} грн (записів: #{part.size})"
    end
    break
  end
end

def import_expenses(expenses)
  path = ask('Шлях до JSON-файла (порожній рядок - скасувати): ')
  return puts('Скасовано.') if path.empty?
  return puts("Файл '#{path}' не знайдено.") unless File.file?(path)

  data = begin
    JSON.parse(File.read(path, encoding: 'UTF-8'))
  rescue JSON::ParserError, EncodingError
    return puts('Файл пошкоджений або порожній (некоректний JSON). Нічого не імпортовано.')
  rescue SystemCallError, IOError => e
    return puts("Не вдалося прочитати файл: #{e.message}")
  end

  return puts('Файл має містити JSON-масив. Нічого не імпортовано.') unless data.is_a?(Array)
  return puts('У файлі немає записів. Нічого не імпортовано.') if data.empty?

  errors = data.each_with_index.filter_map do |rec, i|
    err = record_error(rec, need_id: false) if !rec.is_a?(Hash) || !rec.key?('id')
    err = record_error(rec, need_id: true) if rec.is_a?(Hash) && rec.key?('id')
    "  запис №#{i + 1}: #{err}" if err
  end
  unless errors.empty?
    puts 'Імпорт скасовано, у файлі є помилки (наявні дані не змінено):'
    puts errors.first(10)
    puts "  ...і ще #{errors.size - 10}" if errors.size > 10
    return
  end

  # Нові id призначаємо самі, id із файлу ігноруємо, щоб не було конфліктів.
  id = next_id(expenses)
  added = data.map do |rec|
    r = { 'id' => id }.merge(clean_record(rec))
    id += 1
    r
  end
  puts "Імпортовано записів: #{added.size}." if commit(expenses, expenses + added)
end

# ---------- Головне меню ----------

MENU = <<~TEXT

  === ExpenseTracker ===
  1. Додати витрату
  2. Переглянути всі витрати
  3. Фільтр за категорією та періодом
  4. Видалити витрату
  5. Статистика
  6. Імпорт з JSON-файла
  0. Вихід
TEXT

def main
  expenses = load_expenses(DATA_FILE)
  puts "Завантажено записів: #{expenses.size} (файл: #{DATA_FILE})"

  loop do
    puts MENU
    case ask('Оберіть дію: ')
    when '1' then add_expense(expenses)
    when '2' then show_all(expenses)
    when '3' then filter_expenses(expenses)
    when '4' then delete_expense(expenses)
    when '5' then show_statistics(expenses)
    when '6' then import_expenses(expenses)
    when '0'
      puts 'До побачення!'
      break
    else
      puts 'Невідома команда. Введіть число від 0 до 6.'
    end
  end
end

main
