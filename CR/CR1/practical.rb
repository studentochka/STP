
# 1. Зовнішній ітератор для читання великого файлу батчами по N рядків
class FileBatchEnumerator
    include Enumerable
  
    def initialize(file_path, batch_size)
      @file_path = file_path
      @batch_size = batch_size
    end
  
    def each
      return enum_for(:each) unless block_given?
  
      batch = []
      File.foreach(@file_path) do |line|
        batch << line.chomp
        if batch.size >= @batch_size
          yield batch
          batch = []
        end
      end
      yield batch unless batch.empty?
    end
  end
  
  # 2. Сервіс Notifier
  class Notifier
    def initialize(delivery_object)
      @delivery_object = delivery_object
    end
  
    def notify(message)
      @delivery_object.deliver(message)
    end
  end
  
  # Адаптер Email
  class EmailAdapter
    def deliver(message)
      puts "[Email] Sent message: #{message}"
    end
  end
  
  # Адаптер Slack
  class SlackAdapter
    def deliver(message)
      puts "[Slack] Sent message: #{message}"
    end
  end
  
  # Створюємо тестовий файл з 25 рядками
  file_name = "data.txt"
  File.open(file_name, "w") do |f|
    25.times { |i| f.puts("Line #{i + 1}") }
  end
  
  puts "=== Тест FileBatchEnumerator ==="
  enumerator = FileBatchEnumerator.new(file_name, 10)
  enumerator.each_with_index do |batch, index|
    puts "Batch ##{index + 1}: #{batch.inspect}"
  end
  
  puts "\n=== Тест Notifier ==="
  email_notifier = Notifier.new(EmailAdapter.new)
  slack_notifier = Notifier.new(SlackAdapter.new)
  
  email_notifier.notify("Hello via Email!")
  slack_notifier.notify("Hello via Slack!")
  
  puts "\n=== Надсилання батчів через Notifier ==="
  
  enumerator.each_with_index do |batch, index|
    email_notifier.notify("Batch ##{index + 1}: #{batch.join(', ')}")
  end

  
