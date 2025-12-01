# guess_number.rb

def play_game
  secret = rand(1..100)
  attempts = 0

  puts "Я загадав число від 1 до 100. Спробуй вгадати!"

  loop do
    print "Твоє припущення: "
    input = gets&.strip

    # якщо користувач натиснув Ctrl+D або ввів пусто
    if input.nil? || input.empty?
      puts "\nВведення відсутнє. Гра завершена."
      return
    end

    # чи це ціле число
    begin
      guess = Integer(input)
    rescue ArgumentError
      puts "Будь ласка, введи ціле число від 1 до 100."
      next
    end

    # Перевірка діапазону
    unless (1..100).include?(guess)
      puts "Число має бути від 1 до 100."
      next
    end

    attempts += 1

    if guess < secret
      puts "Більше."
    elsif guess > secret
      puts "Менше."
    else
      puts "Вгадано! Це число #{secret}."
      puts "Кількість спроб: #{attempts}."
      break
    end
  end
end

if __FILE__ == $0
  play_game
end
