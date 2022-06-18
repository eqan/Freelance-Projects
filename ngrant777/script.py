import time
import os
import pandas as pd
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.chrome.service import Service

secureDirectory = './'
chromeDriverPath = './chromedriver'
fileName = "book.xlsx"
url = "https://www.namebase.io/domains?page=1#marketplace"
columnName = "Names"

def convert_all_xlsx_to_onefile():
	if os.path.exists(fileName):
		os.remove(fileName)
	else:
		print("The file does not exist")
	cwd = os.path.abspath('') 
	files = os.listdir(cwd) 
	df = pd.DataFrame()
	for file in files:
	    if file.endswith('.xlsx'):
	        df = df.append(pd.read_excel(file), ignore_index=True) 
	df.head() 
	df.to_excel(fileName)

print("Importing your data!..")
convert_all_xlsx_to_onefile()

df = pd.read_excel(fileName, sheet_name='Sheet1', usecols="B")
domainNames = list(df[columnName])

bid = 0
blind = 0.44

f = open("abc.txt", "r")
email = (f.readline()).strip()
password = (f.readline()).strip()
f.close()
print(email)
print(password)

s = Service('./chromedriver')
driver = webdriver.Chrome(service=s)
driver.maximize_window()

driver.execute_script("window.open()")
driver.switch_to.window(driver.window_handles[1])
driver.get(url)

try:
    time.sleep(2)
    not_logged_in = driver.find_element(by=By.XPATH, value='//*[@href="/login"]')
    not_logged_in.click()
    time.sleep(1)
    try:
        login_area = driver.find_element(by=By.XPATH, value='//*[@placeholder="Email"]').send_keys(email)
        password_area = driver.find_element(by=By.XPATH, value='//*[@placeholder="Password"]').send_keys(password)
        time.sleep(2)
        submit_btn = driver.find_element(by=By.XPATH, value='//*[@type="submit"]').click()
        print('Login Successful')
    except Exception as error:
        print(error)
        print('Login Unsuccesful')
except Exception as error:
    print(error)
    print('Already Logged In')

domainNames = list(set(domainNames))

print(domainNames)
z = 0
for domainName in domainNames:
    print(f'Processing for domain {domainName}')
    time.sleep(2)
    try:
        dashboard_search = driver.find_element(by=By.XPATH, value='//*[@href="/domains"]').click() 
        textarea = driver.find_element(by=By.XPATH,value=f"//*[contains(@placeholder,'Search for your personal TLD')]").send_keys(domainName)
        textarea = driver.find_element(by=By.XPATH,value=f"//*[contains(@placeholder,'Search for your personal TLD')]").send_keys(Keys.ENTER)
        # powersearch = driver.find_element(by=By.XPATH,value='/html/body/div[1]/div[4]/div[1]/div/div/div[2]/button[1]/div').click()
        # textarea = driver.find_element(by=By.XPATH, value='/html/body/div[1]/div[4]/div[1]/textarea').send_keys(domainName)
        # search = driver.find_element(by=By.XPATH, value="/html/body/div[1]/div[4]/div[1]/div/span/button[2]").click()
        driver.execute_script("window.scrollTo(0, 300)")
    except Exception as error:
        print(error)
        print("Error occured on dashboard search")

    time.sleep(2)
    driver.execute_script("window.scrollTo(0, 300)")
    time.sleep(2)
    alreadyTakenBid = False
    try:
        your_bid = driver.find_element(by=By.XPATH, value=f"//*[text()='Auction over']")
        alreadyTakenBid = True
    except:
    	print("Bid already taken!")
    if not alreadyTakenBid:
	    try:
	        # buy_btn = driver.find_element(by=By.XPATH, value=f'//*[@href="/domains/{domainName}"]').click() 
	        # time.sleep(2)
	        your_bid = driver.find_element(by=By.XPATH, value=f'//*[contains(@placeholder,"Your Bid")]').send_keys(bid)
	        your_bid = driver.find_element(by=By.XPATH, value=f'//*[contains(@placeholder,"Your blind (optional)")]').send_keys(blind)
	        submit_btn = driver.find_element(by=By.XPATH, value=f'//*[@type="submit"]').click()
	        print('Bid Taken!')
	        time.sleep(2)
	        try:
	            click_place_bid = driver.find_element(by=By.XPATH, value=f"//*[text()='Place bid']").click() 
	            try:
	                view_receipt = driver.find_element(by=By.XPATH, value=f'//*[@href="/receipts/{domainName}"]').click() 
	                time.sleep(2)
	            except:
	                print("Recipts details viewed!")
	        except:
	            print("place bid clicked")
	    except Exception as error:
	        print(error)
	        print('Bid Not Taken!')
    z+=1
    driver.execute_script("window.open()")
    driver.switch_to.window(driver.window_handles[z+1])
    driver.get(url)
    try:
        print (driver.window_handles[z+1], driver.title, driver.current_url)
    except:
        print("Couldnt print line")
    time.sleep(1)

    try:
        time.sleep(2)
        not_logged_in = driver.find_element(by=By.XPATH, value='//*[@href="/login"]')
        not_logged_in.click()
        time.sleep(1)
        try:
            login_area = driver.find_element(by=By.XPATH, value='//*[@placeholder="Email"]').send_keys(email)
            password_area = driver.find_element(by=By.XPATH, value='//*[@placeholder="Password"]').send_keys(password)
            time.sleep(1)
            submit_btn = driver.find_element(by=By.XPATH, value='//*[@type="submit"]').click()
            print('Login Successful')
        except Exception as error:
            print(error)
            print('Login Unsuccesful')
    except Exception as error:
        print(error)
        print('Already Logged In')