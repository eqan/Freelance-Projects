import time
import os
import sys
import re
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.chrome.options import Options
from PyQt5.uic import loadUi
from PyQt5 import QtWidgets
from PyQt5.QtWidgets import QDialog, QApplication, QWidget, QTableWidget,  QTableWidgetItem, qApp, QAction, QShortcut,  QMessageBox
from PyQt5.QtGui import QPixmap, QKeySequence

def clear():
    if os.name == 'nt':
        _ = os.system('cls')
    else:
        _ = os.system('clear')

class InitialWindow(QDialog):
    def __init__(self):
        super(InitialWindow, self).__init__()
        loadUi("initialwindow.ui",self)
        self.userName = ""
        self.password = ""
        self.delayTimeSeconds = 30
        self.findNextFriendsDelay = 3
        self.message = ""
        self.switchToSendMessageView()

    def switchToSendMessageView(self):
        self.updateText.setText("Please Input The Credentials and Message")
        self.sendButton.clicked.connect(self.getUserInputs)

    def getUserInputs(self):
        global userName, password, message, widget
        self.userName = self.userNameInput.toPlainText()
        self.password = self.passwordInput.text()
        self.message = self.messageInput.toPlainText()
        self.delayTimeSeconds = int(self.messageDelayTimeInput.value())
        self.findNextFriendsDelay = int(self.findNextFriendsDelayInput.value())
        self.showCurrentProgramProgress()

    def countdown(self, time_sec, message):
        while time_sec:
            mins, secs = divmod(time_sec, 60)
            timeformat = f'{message} -> {mins}:{secs} '
            self.updateText.setText(timeformat)
            time.sleep(1)
            QApplication.processEvents()
            time_sec -= 1
        print("stop")

    def showCurrentProgramProgress(self):
        self.sendButton.setEnabled(False)
        chrome_options = webdriver.ChromeOptions()
        prefs = {"profile.default_content_setting_values.notifications" : 2}
        chrome_options.add_experimental_option("prefs",prefs)
        self.updateText.setText("....Logging In....")
        s = Service('./chromedriver')
        driver = webdriver.Chrome(chrome_options=chrome_options, service=s)
        driver.maximize_window()

        driver.get('https://www.facebook.com/')
        driver.find_element_by_id("email").send_keys(self.userName)
        driver.find_element_by_id('pass').send_keys(self.password)
        driver.find_element_by_name("login").click()
        self.countdown(4, "Loggin in")

        self.updateText.setText("....Gathering friends list....")
        friendsUrl=f'https://www.facebook.com/{self.userName}/friends'
        driver.get(friendsUrl)
        self.countdown(10, "Logging in")

        totalFriends = ""
        try:
            totalFriends = (re.findall(r'\d+',driver.find_element(by=By.XPATH, value='//*[@class="oajrlxb2 g5ia77u1 qu0x051f esr5mh6w e9989ue4 r7d6kgcz rq0escxv nhd2j8a9 nc684nl6 p7hjln8o kvgmc6g5 cxmmr5t8 oygrvhab hcukyx3x jb3vyjys rz4wbd8a qt6c0cv9 a8nywdso i1ao9s8h esuyzwwr f1sip0of lzcic4wl gpro0wi8 m9osqain lrazzd5p"]').text) )
            totalFriends = int(totalFriends[0])
        except Exception as error:
            print(error)
            print("Couldnt find friends")
        friendsListBeforeScrolling = ""
        lastFriendsNumber = ""
        countNumber = 0
        while(True):
            friendsListBeforeScrolling = driver.find_elements(by=By.XPATH, value='//*[@class="oajrlxb2 gs1a9yip g5ia77u1 mtkw9kbi tlpljxtp qensuy8j ppp5ayq2 goun2846 ccm00jje s44p3ltw mk2mc5f4 rt8b4zig n8ej3o3l agehan2d sk4xxmp2 rq0escxv nhd2j8a9 mg4g778l pfnyh3mw p7hjln8o kvgmc6g5 oygrvhab hcukyx3x tgvbjcpo hpfvmrgz jb3vyjys rz4wbd8a qt6c0cv9 a8nywdso i1ao9s8h esuyzwwr f1sip0of du4w35lb n00je7tq arfg74bv qs9ysxi8 k77z8yql btwxx1t3 abiwlrkh p8dawk7l q9uorilb lzcic4wl pioscnbf wkznzc2l l9j0dhe7 etr7akla"]')
            driver.execute_script("window.scrollTo(0,document.body.scrollHeight)")
            if(lastFriendsNumber != len(friendsListBeforeScrolling)):
                lastFriendsNumber = len(friendsListBeforeScrolling)
                countNumber = 0
            else:
                countNumber+=1
            if(countNumber >= 8):
                self.countdown(0, f'current found friends {totalFriends}')
                break
            self.countdown(self.findNextFriendsDelay, f'current found friends {len(friendsListBeforeScrolling)}')
        friendsNamesList = []
        for i in range(len(friendsListBeforeScrolling)):
            try:
                attrs = driver.execute_script('var items = {}; for (index = 0; index < arguments[0].attributes.length; ++index) { items[arguments[0].attributes[index].name] = arguments[0].attributes[index].value }; return items;', friendsListBeforeScrolling[i])
                # print(attrs['href'])
                friendsNamesList.append(attrs['href'])
            except:
                print(f'Couldnt find an href{friendsListBeforeScrolling[i]}')

        self.updateText.setText("....Sending Message To Friends....")
        for userName in friendsNamesList:
            self.updateText.setText(f'Sending Message to {userName}')
            driver.get(userName)
            time.sleep(4)
            QApplication.processEvents()
            try:
                driver.find_element(by=By.XPATH, value='/html/body/div[1]/div/div[1]/div/div[3]/div/div/div/div[1]/div[1]/div/div/div[1]/div[2]/div/div/div/div[4]/div/div/div[2]/div/div/div').click()
            except Exception as error:
                print(error)
                print("message icon not found")
            time.sleep(4)
            QApplication.processEvents()
            try:
                driver.find_element(by=By.XPATH, value='/html/body/div[1]/div/div[1]/div/div[5]/div/div[1]/div[1]/div/div/div/div/div[2]/div[2]/div/div/div[4]/div[2]/div/div/div[1]/p').send_keys(self.message, Keys.ENTER)
            except Exception as error:
                print(error)
                print("Couldnt send message")
            self.countdown(self.delayTimeSeconds, "After this time the next message will be sent")
        self.updateText.setText("....Messages Sent to all friends....")
        self.sendButton.setEnabled(True)

app = QApplication(sys.argv)
widget = QtWidgets.QStackedWidget()
widget.addWidget(InitialWindow())
widget.setFixedWidth(596)
widget.setFixedHeight(415)
widget.show()
try:
    sys.exit(app.exec_())
except:
    print("Exiting")