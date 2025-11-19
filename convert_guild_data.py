import os

def simple_parse_guild_data(input_file, output_file):
    print("Используем упрощенный парсер...")
    
    with open(input_file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Разбиваем на строки и ищем данные участников
    lines = content.split('\n')
    members = []
    current_member = {}
    in_member = False
    
    for line in lines:
        line = line.strip()
        
        # Начало данных участника
        if line.startswith('[') and '=' in line and '{' in line and not 'members' in line:
            if current_member and 'name' in current_member:
                members.append(current_member)
            current_member = {}
            in_member = True
            continue
            
        # Конец данных участника
        if in_member and line == '},':
            if current_member and 'name' in current_member:
                members.append(current_member)
            current_member = {}
            in_member = False
            continue
            
        # Парсим поля
        if in_member:
            if '["name"]' in line:
                try:
                    name = line.split('= "')[1].split('"')[0]
                    current_member['name'] = name
                except:
                    pass
            elif '["level"]' in line:
                try:
                    level = line.split('= ')[1].split(',')[0]
                    current_member['level'] = level
                except:
                    pass
            elif '["rank"]' in line:
                try:
                    rank = line.split('= "')[1].split('"')[0]
                    current_member['rank'] = rank
                except:
                    pass
            elif '["note"]' in line:
                try:
                    note = line.split('= "')[1].split('"')[0]
                    current_member['note'] = note
                except:
                    pass
            elif '["officernote"]' in line:
                try:
                    officernote = line.split('= "')[1].split('"')[0]
                    current_member['officernote'] = officernote
                except:
                    pass
    
    # Добавляем последнего участника
    if current_member and 'name' in current_member:
        members.append(current_member)
    
    # Сортируем по имени
    members.sort(key=lambda x: x.get('name', ''))
    
    # Записываем результат
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write("Ник / Уровень / Звание / Гильдейская заметка / Офицерская заметка\n")
        for member in members:
            line = f"{member.get('name', '')} / {member.get('level', '')} / {member.get('rank', '')} / {member.get('note', '')} / {member.get('officernote', '')}\n"
            f.write(line)
    
    print(f"Готово! Обработано {len(members)} участников")

# Запуск
desktop = os.path.join(os.path.expanduser("~"), "Desktop")
input_file = os.path.join(desktop, "GuildExporter.lua")
output_file = os.path.join(desktop, "guild_roster.txt")

if os.path.exists(input_file):
    simple_parse_guild_data(input_file, output_file)
else:
    print(f"Файл {input_file} не найден!")