import time
import os
import openpyxl
import pandas as pd
from datetime import date
from os.path import exists
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException
import itertools


waitTimeForMultiFactorAuthentication = 50

chromeDriverPath = './chromedriver'
url = "https://www.namebase.io/domains?page=1#marketplace"

f = open("credentials.txt", "r")
email = (f.readline()).strip()
password = (f.readline()).strip()
f.close()

try:
    domainsData = pd.read_excel('./DomainsData.xlsx')
except:
    historyData = openpyxl.load_workbook(fileName)
    historySheet = historyData.active
    historySheet.delete_rows(1, 1000000000)
    historyData.save(fileName)
    domainsData = pd.read_excel('./DomainsData.xlsx')

s = Service('./chromedriver')
prefs = {"profile.default_content_setting_values.notifications": 2}
chrome_options = webdriver.ChromeOptions()
chrome_options.add_experimental_option("prefs", prefs)
driver = webdriver.Chrome(chrome_options=chrome_options, service=s)
driver.maximize_window()

driver.execute_script("window.open()")
driver.switch_to.window(driver.window_handles[1])
driver.get(url)

try:
    time.sleep(2)
    not_logged_in = driver.find_element(
        by=By.XPATH, value='//*[@href="/login"]')
    not_logged_in.click()
    time.sleep(1)
    try:
        login_area = driver.find_element(
            by=By.XPATH, value='//*[@placeholder="Email"]').send_keys(email)
        password_area = driver.find_element(
            by=By.XPATH, value='//*[@placeholder="Password"]').send_keys(password)
        time.sleep(2)
        submit_btn = driver.find_element(
            by=By.XPATH, value='//*[@type="submit"]').click()
        print('Login Successful')

    except Exception as error:
        print(error)
        print('Login Unsuccessful')

except Exception as error:
    print(error)
    print('Already Logged In')

time.sleep(waitTimeForMultiFactorAuthentication)
driver.get('https://www.namebase.io/dashboard')

time.sleep(4)
totalNumberOfDomains = 0
try:
    wait = WebDriverWait(driver, 10)
    totalNumberOfDomains = wait.until(EC.visibility_of_element_located(
        (By.XPATH, '//*[@class="Text__TextStyledElement-sc-9cd9ed-0 hgkqQk"]')))
    totalNumberOfDomains = totalNumberOfDomains.text
    totalNumberOfDomains = totalNumberOfDomains.replace(',', '')
    totalNumberOfDomains = int(totalNumberOfDomains)
    print(totalNumberOfDomains)
except Exception as error:
    totalNumberOfDomains = 1
    print(error)
    print("Number of domains not found!")

totalDomainsOnASinglePage = 100
totalNumberOfPages = int(totalNumberOfDomains / totalDomainsOnASinglePage)

totalNumberOfPages += 1

ownedDomainsList = []
sellDomainsList = []
sellDomainsCurrentSoldPrice = []
sellDomainsHighestLockout = []
soldDomainsList = []
soldDomainsCurrentSoldPrice = []
soldDomainsHighestLockout = []

# Capture your domains
domains = ""
for i in range(totalNumberOfPages):
    driver.get(f'https://www.namebase.io/manage/owned?page={i+1}')
    if(i == 0):
        time.sleep(7)
    time.sleep(3)
    try:
        end = driver.find_element(
            by=By.XPATH, value='//*[contains(text(),"You don")]')
        print("End Reached!")
        break
    except Exception as error:
        print("End Not Reached!")
    domains = driver.find_elements(
        by=By.XPATH, value='//*[@class="RowWrapper-sc-106hm5o-0 ddJllY"]')
    for domain in domains:
        text = domain.text
        text = text.split('/')[0]
        ownedDomainsList.append(text)

# print(ownedDomainsList)

''' 
 capture sale domains info which includes
  a.	Capture the TLD
  b.	Capture Current Sale Price
  c.	Capture Highest Lockout
'''
time.sleep(4)
for i in range(totalNumberOfPages):
    try:
        driver.get(
            f'https://www.namebase.io/manage/listed?page={i+1}#marketplace')
        if(i == 0):
            time.sleep(7)
        time.sleep(3)
        domains = driver.find_elements(
            by=By.XPATH, value='//*[@class="RowWrapper-sc-106hm5o-0 ddJllY"]')

        try:
            end = driver.find_element(
                by=By.XPATH, value='//*[contains(text(),"Keep track of the names you have listed for sale here.")]')
            print("End Reached!")
            break
        except Exception as error:
            print("End Not Reached!")

        for i, domain in enumerate(domains):
            name = domain.text
            name = name.split("/")[0]
            sellDomainsList.append(name)
    except Exception as error:
        print(error)
        print("Sell domains not found!")

# print(sellDomainsList)
time.sleep(4)

for i, domain in enumerate(sellDomainsList):
    driver.get(f'https://www.namebase.io/domains/{domain}')
    time.sleep(4)
    currentSalePrice = "Not Found"
    highestLockOut = "Not Found"
    try:
        currentSalePrice = driver.find_element(
            by=By.XPATH, value='//*[@class="Text__TextStyledElement-sc-9cd9ed-0 kNJsFb"]')
        currentSalePrice = currentSalePrice.text
    except Exception as error:
        print("Current Sale price not found!")
    try:
        highestLockOut = driver.find_elements(
            by=By.XPATH, value='//*[@class="Text__TextStyledElement-sc-9cd9ed-0 irQJOb"]')[1]
        highestLockOut = highestLockOut.text
    except Exception as error:
        print("highest lockout price not found!")
    sellDomainsCurrentSoldPrice.append(currentSalePrice)
    sellDomainsHighestLockout.append(highestLockOut)
'''
 Capture sold domains
    1.  Capture TLD
    2.	Capture Sold For price 
    3.	Capture your highest lockout
'''

time.sleep(4)
for i in range(totalNumberOfPages):
    driver.get(f'https://www.namebase.io/manage/sold?page={i+1}')
    if(i == 0):
        time.sleep(7)
    time.sleep(4)
    try:
        end = driver.find_element(
            by=By.XPATH, value='//*[contains(text(),"A domains of names you have sold will show up here.")]')
        print("End Reached!")
        break
    except Exception as error:
        print("End Not Reached!")
    time.sleep(2)
    domains = driver.find_elements(
        by=By.XPATH, value='//*[@class="RowWrapper-sc-106hm5o-0 SoldTableRow___StyledRowWrapper-ke5nwk-0 bQCjyu"]')
    for i in range(len(domains)):
        text = domains[i].text
        text = text.split('/')
        domains[i] = text[0]
        soldDomainsList.append(domains[i])
        text = text[1].split(' ')
        currentSoldPrice = text[0].strip() + ' HNS'
        soldDomainsCurrentSoldPrice.append(currentSoldPrice)

for domain in soldDomainsList:
    driver.get(f'https://www.namebase.io/domains/{domain}')
    time.sleep(3)
    highestLockOut = "Not Found"
    try:
        highestLockOut = driver.find_elements(
            by=By.XPATH, value='//*[@class="Text__TextStyledElement-sc-9cd9ed-0 irQJOb"]')[2]
        highestLockOut = highestLockOut.text
    except Exception as error:
        print("Highest lockout not found!")
    soldDomainsHighestLockout.append(highestLockOut)

# print(soldDomainsList)
# print(soldDomainsCurrentSoldPrice)
# print(soldDomainsHighestLockout)
for item in itertools.zip_longest(ownedDomainsList, sellDomainsList, sellDomainsCurrentSoldPrice, sellDomainsHighestLockout, soldDomainsList, soldDomainsCurrentSoldPrice, soldDomainsHighestLockout):
    new_row = {
        'Owned Domain': item[0], 'Sell Domain': item[1], 'Sell Domain Current Sold Price': item[2], 'Sell Domain Highest Lockout': item[3],
        'Sold Domain': item[4], 'Sold Domain Sold Price': item[5], 'Sold Domain Highest Lockout': item[6]
    }
    domainsData = domainsData.append(new_row, ignore_index=True)
    df_result = pd.ExcelWriter('./DomainsData.xlsx')
    domainsData.to_excel(df_result, index=False)
    df_result.save()

# print(finalResult)
print("Program Ended")
