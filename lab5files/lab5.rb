module UnitConverter
  # Перетворення одиниць у базові
  def self.to_base(qty, unit)
    case unit
    when 'kg' then [qty * 1000, 'g']
    when 'l'  then [qty * 1000, 'ml']
    when 'g','ml','pcs' then [qty, unit]
    else
      raise "Невідома одиниця: #{unit}"
    end
  end
end

class Ingredient
  attr_reader :name, :unit, :calories_per_unit

  def initialize(name, unit, calories_per_unit)
    @name = name
    @unit = unit
    @calories_per_unit = calories_per_unit.to_f
  end
end

class Recipe
  attr_reader :name, :steps, :items

  def initialize(name, steps, items)
    @name = name
    @steps = steps
    @items = items
  end

  # Повертає потребу в базових одиницях
  def need
    needs = Hash.new { |h,k| h[k] = { qty: 0, unit: nil, ingredient: nil } }
    @items.each do |item|
      qty_base, unit_base = UnitConverter.to_base(item[:qty], item[:unit])
      ing_name = item[:ingredient].name
      needs[ing_name][:qty] += qty_base
      needs[ing_name][:unit] = unit_base
      needs[ing_name][:ingredient] = item[:ingredient]
    end
    needs
  end
end

class Pantry
  def initialize
    @items = {}
  end

  def add(name, qty, unit)
    qty_base, unit_base = UnitConverter.to_base(qty, unit)
    if @items.key?(name)
      @items[name][:qty] += qty_base
    else
      @items[name] = { qty: qty_base, unit: unit_base }
    end
  end

  def available_for(name)
    @items.fetch(name, { qty: 0, unit: nil })[:qty]
  end
end

class Planner
  def self.plan(recipes, pantry, price_list)
    total_needs = Hash.new { |h,k| h[k] = { need: 0, have: 0, deficit: 0, unit: nil, ingredient: nil } }

    # Підрахунок потреб по всіх рецептах
    recipes.each do |recipe|
      recipe.need.each do |name, item|
        total_needs[name][:need] += item[:qty]
        total_needs[name][:unit] = item[:unit]
        total_needs[name][:ingredient] = item[:ingredient]
      end
    end

    total_calories = 0.0
    total_cost = 0.0

    # Обчислення дефіциту, калорій та вартості
    total_needs.each do |name, data|
      have = pantry.available_for(name)
      deficit = [data[:need] - have, 0].max
      data[:have] = have
      data[:deficit] = deficit

      ingredient = data[:ingredient]
      price = price_list.fetch(name, 0.0)

      total_calories += data[:need] * ingredient.calories_per_unit
      total_cost += data[:need] * price
    end

    [total_needs, total_calories, total_cost]
  end
end

# Створення інгредієнтів
egg = Ingredient.new('Яйце', 'pcs', 72)
milk = Ingredient.new('Молоко', 'ml', 0.06)
flour = Ingredient.new('Борошно', 'g', 3.64)
pasta = Ingredient.new('Паста', 'g', 3.5)
sauce = Ingredient.new('Соус', 'ml', 0.2)
cheese = Ingredient.new('Сир', 'g', 4.0)

# Комора
pantry = Pantry.new
pantry.add('Борошно', 1, 'kg')
pantry.add('Молоко', 0.5, 'l')
pantry.add('Яйце', 6, 'pcs')
pantry.add('Паста', 300, 'g')
pantry.add('Сир', 150, 'g')

# Ціни за базові одиниці
price_list = {
  'Борошно' => 0.02,
  'Молоко' => 0.015,
  'Яйце' => 6.0,
  'Паста' => 0.03,
  'Соус' => 0.025,
  'Сир' => 0.08
}

# Рецепти
omelette = Recipe.new(
  'Омлет',
  ['Змішати', 'Смажити'],
  [
    { ingredient: egg, qty: 3, unit: 'pcs' },
    { ingredient: milk, qty: 100, unit: 'ml' },
    { ingredient: flour, qty: 20, unit: 'g' }
  ]
)

spaghetti = Recipe.new(
  'Паста',
  ['Варити пасту', 'Змішати соус'],
  [
    { ingredient: pasta, qty: 200, unit: 'g' },
    { ingredient: sauce, qty: 150, unit: 'ml' },
    { ingredient: cheese, qty: 50, unit: 'g' }
  ]
)

recipes_to_make = [omelette, spaghetti]

# Планування
needs_deficits, total_calories, total_cost = Planner.plan(recipes_to_make, pantry, price_list)

# Вивід
puts "--- ЗВІТ PLANNER ---"
puts "Загальні калорії: #{format('%.2f', total_calories)} Ккал"
puts "Загальна вартість: #{format('%.2f', total_cost)} $"
puts "\n--- Потреба / Є / Дефіцит ---"
needs_deficits.each do |name, data|
  puts "#{name}: потрібно #{data[:need]} #{data[:unit]}, є #{data[:have]} #{data[:unit]}, дефіцит #{data[:deficit]} #{data[:unit]}"
end
