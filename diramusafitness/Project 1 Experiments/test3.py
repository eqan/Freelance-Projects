from time import sleep
import re
import time
import pandas as pd
import os
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options

def countdown(time_sec):
    while time_sec:
        mins, secs = divmod(time_sec, 60)
        timeformat = 'Your Have-> {:02d}:{:02d} to enter 2FA Code Via SMS or Authenticator App'.format(mins, secs)
        print(timeformat, end='\r')
        time.sleep(1)
        time_sec -= 1

    print("stop")

def clear():
    if os.name == 'nt':
        _ = os.system('cls')
    else:
        _ = os.system('clear')


print("....Importing Credentials....")
f = open("credentials.txt", "r")
email = (f.readline()).strip()
password = (f.readline()).strip()
f.close()

print("....Logging In....")
usernam=email
# message = input("Hello from bot")
message = "Hello from bot"
s = Service('./chromedriver')

driver = webdriver.Chrome(service=s)
driver.maximize_window()
driver.get ('https://www.facebook.com/')
driver.find_element_by_id("email").send_keys(usernam)
driver.find_element_by_id('pass').send_keys(password)
driver.find_element_by_name("login").click()

clear()
countdown(10)

print("....Importing Friends ID List....")

friendsUrl=f'https://www.facebook.com/{usernam}/friends'
driver.get(friendsUrl)
time.sleep(4)
try:
    WebDriverWait(driver, 5).until (EC.alert_is_present())
    alert = driver.switch_to.alert
    alert.accept()
except Exception as error:
    print(error)
    print("Couldnt remove popup!")
totalFriends = (re.findall(r'\d+',driver.find_element(by=By.XPATH, value='//*[@class="oajrlxb2 g5ia77u1 qu0x051f esr5mh6w e9989ue4 r7d6kgcz rq0escxv nhd2j8a9 nc684nl6 p7hjln8o kvgmc6g5 cxmmr5t8 oygrvhab hcukyx3x jb3vyjys rz4wbd8a qt6c0cv9 a8nywdso i1ao9s8h esuyzwwr f1sip0of lzcic4wl gpro0wi8 m9osqain lrazzd5p"]').text) )
totalFriends = int(totalFriends[0])
print(totalFriends)
friendsListBeforeScrolling = ""
while(True):
    friendsListBeforeScrolling = driver.find_elements(by=By.XPATH, value='//*[@class="oajrlxb2 gs1a9yip g5ia77u1 mtkw9kbi tlpljxtp qensuy8j ppp5ayq2 goun2846 ccm00jje s44p3ltw mk2mc5f4 rt8b4zig n8ej3o3l agehan2d sk4xxmp2 rq0escxv nhd2j8a9 mg4g778l pfnyh3mw p7hjln8o kvgmc6g5 oygrvhab hcukyx3x tgvbjcpo hpfvmrgz jb3vyjys rz4wbd8a qt6c0cv9 a8nywdso i1ao9s8h esuyzwwr f1sip0of du4w35lb n00je7tq arfg74bv qs9ysxi8 k77z8yql btwxx1t3 abiwlrkh p8dawk7l q9uorilb lzcic4wl pioscnbf wkznzc2l l9j0dhe7 etr7akla"]')
    # friendsListBeforeScrolling = driver.find_elements(by=By.XPATH, value='//*[@class="buofh1pr hv4rvrfc"]')
    driver.execute_script("window.scrollTo(0,document.body.scrollHeight)")
    print(len(friendsListBeforeScrolling))
    if(len(friendsListBeforeScrolling) >= totalFriends-100):
        break
    sleep(3)
friendsNamesList = []
for i in range(len(friendsListBeforeScrolling)):
    attrs = driver.execute_script('var items = {}; for (index = 0; index < arguments[0].attributes.length; ++index) { items[arguments[0].attributes[index].name] = arguments[0].attributes[index].value }; return items;', friendsListBeforeScrolling[i])
    print(attrs['href'])
    friendsNamesList.append(attrs['href'])

# print(friendsNamesList)

print("....Sending Message To Friends....")
for userName in friendsNamesList:
    print(f'Sending Message to {userName}')
    driver.get(userName)
    time.sleep(4)
    try:
        driver.find_element(by=By.XPATH, value='/html/body/div[1]/div/div[1]/div/div[3]/div/div/div/div[1]/div[1]/div/div/div[1]/div[2]/div/div/div/div[4]/div/div/div[2]/div/div/div').click()
    except Exception as error:
        print(error)
        print("Message Icon Not Found")
    time.sleep(4)
    try:
        driver.find_element(by=By.XPATH, value='/html/body/div[1]/div/div[1]/div/div[5]/div/div[1]/div[1]/div/div/div/div/div[2]/div[2]/div/div/div[4]/div[2]/div/div/div[1]/p').send_keys(message, Keys.ENTER)
    except Exception as error:
        print(error)
        print("Couldnt send message")
    sleep(20)

print("....Messages Sent to all friends....")