# Патерн «Декоратор» на прикладі кави
# Запуск: ruby coffee_decorator.rb

# 1. Спільне правило для всіх напоїв (компонент)
class Drink
  def cost
    raise NotImplementedError, 'Реалізуйте cost'
  end

  def description
    raise NotImplementedError, 'Реалізуйте description'
  end
end

# 2. Звичайна кава (конкретний компонент) — те, що ми будемо «обгортати»
class Coffee < Drink
  def cost = 5.0
  def description = 'Кава'
end

# 3. Заготовка обгортки (базовий декоратор):
#    тримає напій всередині й передає йому всі питання
class DrinkDecorator < Drink
  def initialize(drink)
    @drink = drink
  end

  def cost = @drink.cost
  def description = @drink.description
end

# 4. Готові обгортки (конкретні декоратори)
class MilkDecorator < DrinkDecorator
  def cost = super + 1.0                      # ціна того, що всередині, + 1
  def description = "#{super}, з молоком"     # опис того, що всередині, + «з молоком»
end

class SugarDecorator < DrinkDecorator
  def cost = super + 0.5
  def description = "#{super}, з цукром"
end

# 5. Клієнт: збираємо напій із шарів і друкуємо результат
coffee      = Coffee.new
milk_coffee = MilkDecorator.new(coffee)
sweet       = SugarDecorator.new(milk_coffee)

[coffee, milk_coffee, sweet].each do |drink|
  puts "#{drink.description}: #{drink.cost} грн."
end
