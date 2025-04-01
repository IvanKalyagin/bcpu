#!/bin/sh

file1="../zero_hex/zero.hex"
file2="../source_tests/immediate.hex"
output="immediate.hex"  # Результат

# Получаем количество строк во втором файле
lines_in_file2=$(wc -l < "$file2")

# Вычисляем, сколько строк взять из первого файла
lines_to_take=$((16384 - lines_in_file2))

# Проверяем, что lines_to_take не отрицательное
if [ "$lines_to_take" -lt 0 ]; then
    echo "Ошибка: во втором файле больше 16384 строк, невозможно выполнить условие."
    exit 1
fi

# Создаём новый файл:
# 1. Берём первые $lines_to_take строк из file1
# 2. Добавляем все строки из file2
cat "$file2" > "$output"
head -n "$lines_to_take" "$file1" >> "$output"
cat "$file2" >> "$output"
head -n "$lines_to_take" "$file1" >> "$output"
cat "$file2" >> "$output"
head -n "$lines_to_take" "$file1" >> "$output"
cat "$file2" >> "$output"
head -n "$lines_to_take" "$file1" >> "$output"

echo "Файлы успешно объединены в $output"
echo "Количество строк в итоговом файле: $(wc -l < "$output")"