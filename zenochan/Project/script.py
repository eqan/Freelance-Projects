from youtube_transcript_api import YouTubeTranscriptApi
import re
import language_tool_python

characterLimit = 1000

url = input("Enter URL: ")
id = url.split('/')[-1]
wordToRemove = "watch?v="
if wordToRemove in id:
    id= id.replace(wordToRemove, '')

print("......Downloading Subtitles....")
tool = language_tool_python.LanguageTool('en-US')
srt = YouTubeTranscriptApi.get_transcript(id)
fileName = "subtitles.txt"
 
with open(fileName, "w") as f:
    for i in srt:
        line = i['text']
        if "Music" not in line:
            f.write("{} ".format(line))


print(f'......Correcting Grammar Of Subtitles + Splitting it to {characterLimit}....')
text_file = open(fileName, "r")
data = text_file.read()
data = re.sub("(.{1000})", "\\1\n\n", data, 0, re.DOTALL)
correct_text = tool.correct(data)
text_file.close()


print(f'......Writing File in {fileName}......')
with open(fileName, "w") as f:
    f.write(correct_text)

print("......Program Ended......")