import time
import os
import sys
import re
import pandas as pd
import openpyxl
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.chrome.options import Options
from PyQt5.uic import loadUi
from PyQt5 import QtWidgets
from PyQt5.QtWidgets import QDialog, QApplication, QWidget, QTableWidget,  QTableWidgetItem, qApp, QAction, QShortcut, QMessageBox
from PyQt5.QtGui import QPixmap, QKeySequence

fileName = "./UnmessagedFriendsList.xlsx"

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
        self.pauseSendMessages = False
        self.stopSendMessages = False
        self.switchToSendMessageView()

    def switchToSendMessageView(self):
        self.updateText.setText("Please Input The Credentials and Message")
        global userName, password, message, widget

        # Buttons
        self.sendButton.clicked.connect(self.startProgramTrigger) # Start from begining
        self.restartButton.clicked.connect(self.restartProgramTrigger) # Start from where it left
        self.pauseButton.clicked.connect(self.pauseSendMessagesTrigger) # Pause program the data will remain saved
        self.stopButton.clicked.connect(self.stopSendMessagesTrigger) #  The data will be erased and the program will start from the begining
        self.closeButton.clicked.connect(self.closeButtonTrigger) # Close program
    
    def restartProgramTrigger(self):
        self.enableAllButtons()
        self.showCurrentProgramProgress()
    
    def closeButtonTrigger(self):
        try:
            QApplication.quit()
        except:
            print("Exiting")

    
    def pauseSendMessagesTrigger(self):
        self.enableAllButtons()
        self.pauseSendMessages = True
        self.enableSettingsForPausePressedButtons()

    def stopSendMessagesTrigger(self):
        self.enableAllButtons()
        self.stopSendMessages = True
        self.resetExcelFile()
        self.enableSettingsForStopPressedButtons()

    def countdown(self, time_sec, message):
        while time_sec:
            mins, secs = divmod(time_sec, 60)
            timeformat = f'{message} -> {mins}:{secs} '
            self.updateText.setText(timeformat)
            time.sleep(1)
            QApplication.processEvents()
            time_sec -= 1
        print("stop")

    def resetExcelFile(self):
        historyData = openpyxl.load_workbook(fileName)
        historySheet = historyData.active
        historySheet.delete_rows(1, 1000000000)
        historyData.save(fileName)

    def enableSettingsForStopPressedButtons(self):
        self.pauseSendMessages = False
        self.restartButton.setEnabled(False)
        self.sendButton.setEnabled(True)
        self.pauseButton.setEnabled(False)
        self.stopButton.setEnabled(False)

    def enableSettingsForPausePressedButtons(self):
        self.stopSendMessages = False
        self.restartButton.setEnabled(True)
        self.sendButton.setEnabled(False)
        self.pauseButton.setEnabled(False)
        self.stopButton.setEnabled(False)

    def enableAllButtons(self):
        self.restartButton.setEnabled(True)
        self.sendButton.setEnabled(True)
        self.pauseButton.setEnabled(True)
        self.stopButton.setEnabled(True)
        self.pauseSendMessages = False
        self.stopSendMessages = False
    
    def startProgramTrigger(self):
        self.stopSendMessagesTrigger()
        self.enableAllButtons()
        self.showCurrentProgramProgress()


    def showCurrentProgramProgress(self):
        self.sendButton.setEnabled(False)
        self.restartButton.setEnabled(False)

        # Values
        self.userName = self.userNameInput.toPlainText()
        self.password = self.passwordInput.text()
        self.message = self.messageInput.toPlainText()
        self.delayTimeSeconds = int(self.messageDelayTimeInput.value())
        self.findNextFriendsDelay = int(self.findNextFriendsDelayInput.value())

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
        self.countdown(4, "Logging in")

        historyData = ""
        try:
            historyData = pd.read_excel(fileName)
        except Exception as error:
            print(error)
            self.resetExcelFile()
            self.countdown(1, "Waiting for file creation")
            historyData = pd.read_excel(fileName)


        friendsUrl=f'https://www.facebook.com/{self.userName}/friends'
        totalFriends = ""

        if(historyData.empty):
            self.updateText.setText("....Gathering friends list....")
            driver.get(friendsUrl)
            self.countdown(10, "Logging in")

            try:
                totalFriends = (re.findall(r'\d+',driver.find_element(by=By.XPATH, value='//*[@class="oajrlxb2 g5ia77u1 qu0x051f esr5mh6w e9989ue4 r7d6kgcz rq0escxv nhd2j8a9 nc684nl6 p7hjln8o kvgmc6g5 cxmmr5t8 oygrvhab hcukyx3x jb3vyjys rz4wbd8a qt6c0cv9 a8nywdso i1ao9s8h esuyzwwr f1sip0of lzcic4wl gpro0wi8 m9osqain lrazzd5p"]').text) )
                totalFriends = int(totalFriends[0])
            except Exception as error:
                print(error)
                print("Couldnt find friends")
            friendsListBeforeScrolling = ""
            lastFriendsNumber = ""
            countNumber = 0
            self.countdown(5, "First Collecting friends, please dont press stop or pause at this stage because its not saving data")
            while(True):
                if(self.stopSendMessages or self.pauseSendMessages):
                    return
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

            self.countdown(5, "2nd Adding the friends in the excel file to message, at this stage you can press stop or pause")
            for i in range(len(friendsListBeforeScrolling)):
                try:
                    if(self.stopSendMessages or self.pauseSendMessages):
                        return
                    attrs = driver.execute_script('var items = {}; for (index = 0; index < arguments[0].attributes.length; ++index) { items[arguments[0].attributes[index].name] = arguments[0].attributes[index].value }; return items;', friendsListBeforeScrolling[i])
                    new_row = {'Name': attrs['href']}
                    historyData = historyData.append(new_row, ignore_index=True)
                    df_result = pd.ExcelWriter(fileName)
                    historyData.to_excel(df_result,index = False)
                    df_result.save()
                except:
                    print(f'Couldnt find an href{friendsListBeforeScrolling[i]}')

        #Removing duplicates if any
        friendsNamesList = historyData['Name'].tolist()
        friendsNamesList = list(set(friendsNamesList)) 
        print(friendsNamesList)
        i = 0
        self.updateText.setText("....Sending Message To Friends....")
        historyData = openpyxl.load_workbook(fileName)
        historySheet = historyData.active
        for userName in friendsNamesList:
            
            if(self.stopSendMessages or self.pauseSendMessages):
                return
            if(i == 0):
                self.message = self.messageInput.toPlainText()
                i+=1
            elif(i == 1):
                self.message = self.messageInput_2.toPlainText()
                i+=1
            elif(i == 2):
                self.message = self.messageInput_3.toPlainText()
                i=0
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
            historySheet.delete_rows(historySheet.min_row + 1, 1)
            historyData.save(fileName)
            self.countdown(self.delayTimeSeconds, "After this time the next message will be sent")

        self.updateText.setText("....Messages Sent to all friends....")
        self.enableAllButtons()

app = QApplication(sys.argv)
widget = QtWidgets.QStackedWidget()
widget.addWidget(InitialWindow())
widget.setFixedWidth(596)
widget.setFixedHeight(530)
widget.show()
try:
    sys.exit(app.exec_())
except:
    print("Exiting")