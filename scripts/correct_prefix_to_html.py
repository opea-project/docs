# Specify the file path
file_path = '_build/html/GenAIComps/README.html'

# Read the file content
with open(file_path, 'r', encoding='utf-8') as file:
    content = file.read()

# Replace .md with .html
content = content.replace('.md', '.html')

# Write the content back to the file
with open(file_path, 'w', encoding='utf-8') as file:
    file.write(content)

print(f'All occurrences of ".md" have been replaced with ".html" in {file_path}')
