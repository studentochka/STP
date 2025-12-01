sum3 = ->(a,b,c) { a + b + c }

def curry3(proc_or_lambda)
  # рекурсивна лямбда з накопиченням аргументів
  f = ->(*args_so_far) do
    lambda do |*new_args|
      all_args = args_so_far + new_args

      if all_args.size > 3
        raise ArgumentError, "Забагато аргументів: #{all_args.size} (макс 3)"
      elsif all_args.size == 3
        proc_or_lambda.call(*all_args)
      else
        f.call(*all_args) 
      end
    end
  end

  f.call
end


cur = curry3(sum3)

puts cur.call(1).call(2).call(3)   # => 6
puts cur.call(1, 2).call(3)        # => 6
puts cur.call(1).call(2, 3)        # => 6
puts cur.call(1, 2, 3)             # => 6

begin
  cur.call(1,2,3,4)
rescue ArgumentError => e
  puts e.message                    # "ззабагато аргументів: 4 (макс 3)"
end

f = ->(a, b, c) { "#{a}-#{b}-#{c}" }
cF = curry3(f)
puts cF.call('A').call('B', 'C')   # => "A-B-C"
puts cF.call('X', 'Y').call('Z')   # => "X-Y-Z"
puts cF.call('P').call('Q').call('R') # => "P-Q-R"
