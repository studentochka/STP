def word_stats(text)
  # Розбиваємо рядок на слова (лише букви та цифри)
  words = text.scan(/\w+/)

  # Кількість слів
  total_words = words.length
  # Найдовше слово
  longest_word = words.max_by(&:length)

  # Кількість унікальних слів без урахування регістру
  unique_words = words.map(&:downcase).uniq.length

  {
    total_words: total_words,
    longest_word: longest_word,
    unique_count: unique_words
  }
end

# Приклад використання
text = "Ruby is fun and ruby is powerful"
stats = word_stats(text)

puts "#{stats[:total_words]} слів, найдовше: #{stats[:longest_word]}, унікальних: #{stats[:unique_count]}"
