require 'csv'

def population population, size
  for i in (0..99) do
    for j in (0..size) do
      population[i][j] = (rand < 0.5) ? 0 : 1
    end
  end
  return population
end

def compatibility population, compartments, capacitys
  population.each_with_index do |chromesome, i|
    compartments.each_with_index do |compartment, j|
      sum = sum chromesome, compartment
      while sum > capacitys[j] do
        population[i] = check chromesome
        sum = sum chromesome, compartment
      end
    end
  end
  return population
end

def check chromesome
  index = rand(0..(chromesome.size-1))
  while chromesome[index] == 0
    index = rand(0..(chromesome.size-1))
  end
  chromesome[index] = 0
  return chromesome
end

def sum chromesome, compartment
  sum = 0
  compartment.each_with_index do |weight, i|
    sum = sum + (weight*chromesome[i].to_i)
  end
  return sum
end

def fitness population, profit
  fitness = []
  population.each_with_index do |chromesome, i|
    fitness[i] = sum chromesome, profit
  end
  return fitness
end

def roulette fitness, population
  sum = []
  selected = Array.new(50)
  
  for i in (0..99) do
    if i == 0
      sum[i] = fitness[i]
    else
      sum[i] = sum[i-1] + fitness[i]
    end
  end

  max = sum.max

  for i in (0..49) do 
    raffled = rand 0...max
    for j in (0..99) do
      if sum[j] >= raffled
        selected[i] = population[j]
        break
      end
    end
  end
  return selected
end

def reproduction selected, population
  for i in (0..49) do
    population[i], population[i+1] = crossover selected
  end
  return population
end

def crossover selected
  sons = Array.new(2)
  tail = rand(0..99)
  dad = selected[rand(0..49)]
  mom = selected[rand(0..49)]
  sons[0] = dad
  sons[1] = mom

  if rand < 1
    for i in (tail..99) do
      sons[0][i] = mom[i]
      sons[1][i] = dad[i]
    end
  end
  return sons
end

def mutation population, rate
  for i in (0..99) do
    for j in (0..99) do
      population[i][j] = invert(population[i][j]) if rand < rate
    end
  end
  return population
end

def invert gene
  gene = (gene == 0) ? 1 : 0
  return gene
end

def to_integer compartments, profit, capacitys
  compartments.each_with_index do |compartment, i|
    compartment.each_with_index do |weight, j|
      compartments[i][j] = weight.to_i
    end
    capacitys[i] = capacitys[i].to_i
  end
  for i in (0..(profit.size-1)) do
    profit[i] = profit[i].to_i
  end
  return compartments, profit, capacitys
end

def best fitness, best_global
  best = -500
  best = fitness.max if best < fitness.max
  best_global = best if best_global < best
  return best_global
end

def chosse_best profit, population
  best = population[0]
  best_fitness = sum best, profit
  for i in (1..(population.size-1)) do
    if best_fitness < sum(population[i], profit)
      best = population[i]
      best_fitness = sum population[i], profit
    end
  end
  return best
end

def elitism population, profit
  best = chosse_best profit, population
  population[0] = best
  return population
end

def run population, fitness, sum_fitness, selected, compartments, profit, capacitys, elements, rate
  best = -500
  population = population population, elements
  population = compatibility population, compartments, capacitys
  fitness = fitness population, profit
  best = best fitness, best
  generation = 0
  best_solution = Array.new(100)

  while generation < 1000 do
    selected = roulette fitness, population
    population = reproduction selected, population
    population = compatibility population, compartments, capacitys
    population = elitism population, profit
    population = mutation population, rate
    population = compatibility population, compartments, capacitys
    fitness = fitness population, profit
    best = best fitness, best
    generation = generation + 1
    best_solution = chosse_best profit, population
    puts generation
  end
  return best, best_solution
end

def results population, fitness, sum_fitness, selected, compartments, profit, capacitys, elements, rate, instance
  
  best = []
  bests = Array.new(20)
  best_solution = Array.new(100){Array.new(20)}
  description = []

  for j in (0..19) do
  #for j in (0..2) do
    bests[j], best_solution[j] = run population, fitness, sum_fitness, selected, compartments, profit, capacitys, elements, rate
  end

  best = best_solution[bests.index(bests.max)]
  description << instance
  description << bests.max

  for i in (0..(bests.size-1)) do
    description << "Objeto#{i}" if best[i] != 0
  end

  CSV.open("GenetickKnapsack_rate#{rate}.csv", "a", col_sep: ';') do |csv|
    csv << description
  end

end

rates = [0.2, 0.1, 0.008]

file1 = File.open("mknapcb1.txt", "r")
instances = file1.readline.strip.to_i
bag = file1.readline.strip.split

rates.each do |rate|
  for i in (1..instances-1) do
    elements = bag[0].to_i
    compartments_size = bag[1].to_i
    compartments = Array.new(elements){Array.new(compartments_size)}
    cache = []
    capacitys = []
    profit = Array.new(compartments_size){Array.new(elements)}
    population = Array.new(elements){Array.new(100)}
    fitness = Array.new(elements)
    sum_fitness = Array.new(100)
    selected = Array.new(50)

    while cache.size < elements
      cache = cache + file1.readline.strip.split
    end

    profit = cache

    for j in (0..(compartments_size-1)) do
      cache = []
      while cache.size < elements
        cache = cache + file1.readline.strip.split
      end

      compartments[j] = cache
    end

    while capacitys.size < compartments_size
      capacitys = capacitys + file1.readline.strip.split
    end

    compartments, profit, capacitys = to_integer compartments, profit, capacitys
    results population, fitness, sum_fitness, selected, compartments, profit, capacitys, elements, rate, i
    bag = file1.readline.strip.split
  end

  file1.close
  file2 = File.open("mknapcb9.txt", "r")
  instances = file2.readline.strip.to_i
  bag = file2.readline.strip.split

  for i in ((instances+1)..(instances*2)) do
    elements = bag[0].to_i
    compartments_size = bag[1].to_i
    compartments = Array.new(elements){Array.new(compartments_size)}
    cache = []
    capacitys = []
    profit = Array.new(compartments_size){Array.new(elements)}
    population = Array.new(elements){Array.new(100)}
    fitness = Array.new(elements)
    sum_fitness = Array.new(100)
    selected = Array.new(50)

    while cache.size < elements
      cache = cache + file2.readline.strip.split
    end

    profit = cache

    for j in (0..(compartments_size-1)) do
      cache = []
      while cache.size < elements
        cache = cache + file2.readline.strip.split
      end

      compartments[j] = cache
    end

    while capacitys.size < compartments_size
      capacitys = capacitys + file2.readline.strip.split
    end

    compartments, profit, capacitys = to_integer compartments, profit, capacitys
    #results population, fitness, sum_fitness, selected, compartments, profit, capacitys, elements, rate, i
    bag = file2.readline.strip.split
  end

  file2.close
end
