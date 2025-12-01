require 'fileutils'
require 'digest'
require 'json'
require 'find'

class DuplicateScanner

  def scan_directory(root_dir)
    scanned_files_count = 0
    file_data = []

    Find.find(root_dir) do |path|
      next unless File.file?(path)

      scanned_files_count += 1
      
      stat = File.stat(path)
      
      file_data << {
        full_path: path, 
        report_path: path.gsub(root_dir + File::SEPARATOR, ''), 
        size: stat.size,
        inode: stat.ino
      }
    end

    potential_groups = file_data.group_by { |f| f[:size] }.values
    groups_to_check = potential_groups.select { |group| group.size > 1 }

    [groups_to_check, scanned_files_count]
  end

  def confirm_duplicates(potential_groups)
    final_groups = []

    potential_groups.each do |group|
      hashed_groups = group.group_by do |file|
        Digest::SHA256.file(file[:full_path]).hexdigest
      end.values
      
      hashed_groups.each do |h_group|
        if h_group.size > 1
          size_bytes = h_group[0][:size]
          saved_if_dedup_bytes = (h_group.size - 1) * size_bytes
          
          final_groups << {
            size_bytes: size_bytes,
            saved_if_dedup_bytes: saved_if_dedup_bytes,
            files: h_group.map { |f| f[:report_path] } 
          }
        end
      end
    end
    
    final_groups
  end

  def generate_report(groups, scanned_count, output_filename)
    total_saved_bytes = groups.sum { |g| g[:saved_if_dedup_bytes] }
    
    report = {
      scanned_files: scanned_count,
      total_saved_bytes: total_saved_bytes,
      groups: groups
    }
    
    File.write(output_filename, JSON.pretty_generate(report))
  end
end

def create_test_environment(root_dir)
  puts "Створення тестової файлової системи у #{root_dir}..."
  
  FileUtils.rm_rf(root_dir)
  FileUtils.mkdir_p("#{root_dir}/photos/backup")
  
  content_a = "Це файл А. Дублікат!"
  content_b = "Це файл Б. Не дублікат."
  content_c = "Це файл C. Ще один дублікат!"
  
  File.write("#{root_dir}/photos/a.jpg", content_a)
  File.write("#{root_dir}/photos/a_copy.jpg", content_a)
  File.write("#{root_dir}/photos/backup/a_copy2.jpg", content_a)

  File.write("#{root_dir}/photos/b.jpg", content_b)

  File.write("#{root_dir}/c.png", content_c)
  File.write("#{root_dir}/c_copy.png", content_c)
  
  File.write("#{root_dir}/photos/fake_dup.txt", content_a.sub('!', '?')) 
  
  puts "Тестові файли створено."
end

TEST_ROOT = "temp_scan_root"
OUTPUT_FILE = "duplicates.json"

create_test_environment(TEST_ROOT)

scanner = DuplicateScanner.new

potential_groups, scanned_count = scanner.scan_directory(TEST_ROOT)
puts "Знайдено #{scanned_count} файлів, #{potential_groups.size} груп потенційних дублікатів."

final_groups = scanner.confirm_duplicates(potential_groups)
puts "Знайдено #{final_groups.size} груп справжніх дублікатів."

scanner.generate_report(final_groups, scanned_count, OUTPUT_FILE)
puts "Звіт збережено у файлі: #{OUTPUT_FILE}"
