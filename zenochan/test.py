import re

url = input("Enter URL: ")
id = url.split('/')[-1]
wordToRemove = "watch?v="
if wordToRemove in id:
    id= id.replace(wordToRemove, '')

print(id)