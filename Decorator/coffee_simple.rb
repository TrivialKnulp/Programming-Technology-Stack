# Найпростіша версія Декоратора: кава, молоко, цукор
# Запуск: ruby coffee_simple.rb

class Coffee
  def cost = 5.0
  def description = 'Кава'
end

# Молоко «обгортає» напій: питає його ціну й опис і додає своє
class Milk
  def initialize(drink)
    @drink = drink
  end

  def cost = @drink.cost + 1.0
  def description = "#{@drink.description}, з молоком"
end

class Sugar
  def initialize(drink)
    @drink = drink
  end

  def cost = @drink.cost + 0.5
  def description = "#{@drink.description}, з цукром"
end

drink = Coffee.new
puts "#{drink.description}: #{drink.cost} грн."

drink = Milk.new(drink)     # загорнули каву в молоко
puts "#{drink.description}: #{drink.cost} грн."

drink = Sugar.new(drink)    # загорнули ще й у цукор
puts "#{drink.description}: #{drink.cost} грн."
