class CakeSlicer
  def initialize(cake_lines)
    @cake = cake_lines.map { |line| line.chars }
    @rows = @cake.length
    @cols = @cake.empty? ? 0 : @cake[0].length
    @raisins = find_raisins
    @num_pieces = @raisins.size
    @total_area = @rows * @cols
    
    if @num_pieces == 0 || @total_area % @num_pieces != 0
      raise "Неможливо розділити: Неправильна кількість родзинок або площа."
    end
    @piece_area = @total_area / @num_pieces
    
    @best_solution = nil
    @max_width_of_first = -1
  end

  def solve
    used_cells = Array.new(@rows) { Array.new(@cols, false) }
    backtrack(used_cells, [])
    return @best_solution
  end

  private

  def find_raisins
    raisins = []
    @rows.times do |r|
      @cols.times do |c|
        raisins << [r, c] if @cake[r][c] == 'O'
      end
    end
    raisins
  end

  def contains_one_raisin?(r1, c1, r2, c2)
    count = 0
    @raisins.each do |r, c|
      if r >= r1 && r < r2 && c >= c1 && c < c2
        count += 1
      end
    end
    count == 1
  end

  def backtrack(used_cells, solution)
    first_r, first_c = -1, -1
    @rows.times do |r|
      @cols.times do |c|
        if !used_cells[r][c]
          first_r, first_c = r, c
          break
        end
      end
      break if first_r != -1
    end

    if first_r == -1
      first_piece_width = solution[0][3] - solution[0][1] 
      
      if @best_solution.nil? || first_piece_width > @max_width_of_first
        @best_solution = solution.map { |r1, c1, r2, c2| generate_piece_output(r1, c1, r2, c2) }
        @max_width_of_first = first_piece_width
      end
      return
    end
    
    (1..(@rows - first_r)).each do |r_span|
      next unless @piece_area % r_span == 0

      c_span = @piece_area / r_span
      
      next unless c_span <= (@cols - first_c)
      
      r2 = first_r + r_span 
      c2 = first_c + c_span
      
      is_available = true
      (first_r...r2).each do |r|
        (first_c...c2).each do |c|
          if used_cells[r][c]
            is_available = false
            break
          end
        end
        break unless is_available
      end
      next unless is_available

      if contains_one_raisin?(first_r, first_c, r2, c2)
        new_used_cells = used_cells.map(&:dup)
        (first_r...r2).each do |r|
          (first_c...c2).each do |c|
            new_used_cells[r][c] = true
          end
        end

        new_solution = solution + [[first_r, first_c, r2, c2]]
        
        backtrack(new_used_cells, new_solution)
      end
    end
  end

  def generate_piece_output(r1, c1, r2, c2)
    piece_lines = []
    (r1...r2).each do |r|
      line = (c1...c2).map { |c| @cake[r][c] }.join
      piece_lines << line
    end
    piece_lines
  end
end

cake_input = [
  "......",
  "..O.O.",
  "...O..",
  "..O.O.",
  "......"
]

begin
  slicer = CakeSlicer.new(cake_input)
  result = slicer.solve

  if result
    puts "Знайдено найкраще розбиття"
    puts "Кількість родзинок (n): #{slicer.instance_variable_get(:@num_pieces)}"
    puts "Площа одного шматочка: #{slicer.instance_variable_get(:@piece_area)}"
    puts "---"
    puts "["
    result.each_with_index do |piece, index|
      puts "  ["
      piece.each { |line| puts "    \"#{line}\"," }
      puts "  ]"
      puts "," unless index == result.size - 1
    end
    puts "]"
  else
    puts "Рішення не знайдено для цих вхідних даних."
  end

rescue StandardError => e
  puts "Помилка:"
  puts e.message
end
