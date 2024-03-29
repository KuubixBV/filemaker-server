from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import os
import time
from dotenv import load_dotenv

# Load environment variables
load_dotenv("/install/auto/.env")
filemakerUsername = os.getenv('filemakerUsername')
filemakerPassword = os.getenv('filemakerPassword')

# Start chrome driver
chrome_options = Options()
chrome_options.add_argument("--headless") # Ensure Chrome runs headless
chrome_options.add_argument("--ignore-certificate-errors") # Don't enable SSL check
chrome_options.add_argument("--no-sandbox") # Bypass OS security model, REQUIRED for Docker
chrome_options.add_argument("--disable-dev-shm-usage") # Overcome limited resource problems
driver = webdriver.Chrome(options=chrome_options)

# Function to log in
def login():

    # Login using username and password from .env
    print("Trying to login...")
    driver.get("https://localhost/admin-console/signin")
    WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.ID, "inputUserName"))).send_keys(filemakerUsername)
    driver.find_element(By.ID, "inputPassword").send_keys(filemakerPassword)
    driver.find_element(By.ID, "LOGN_Butn_SignIn").click()
    print("Logged in!")

# Function to handle optional onboarding
def handle_onboarding():
    try:

        # Check if onboarding page is in URL
        print("Checking if onboarding page...")
        if driver.current_url != "https://localhost/admin-console/onboarding":
            raise Exception()
        
        # Click on needed buttons
        WebDriverWait(driver, 10).until(EC.url_to_be("https://localhost/admin-console/onboarding"))
        print("Handling onboarding page...")
        driver.find_element(By.ID, "opt-2").click()
        print("Clicked on 'Use the Claris default certificate'")
        save_button = WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.XPATH, "//button[contains(@class, 'btn') and contains(@class, 'btn-submit')]")))
        driver.execute_script("arguments[0].click();", save_button)
        print("Clicked on 'Save'")
        accept_risk_button = WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.XPATH, "//button[contains(@class, 'btn') and contains(@class, 'btn-outline-primary')]")))
        driver.execute_script("arguments[0].click();", accept_risk_button)
        print("Clicked on 'I accept the Risk'")

    except Exception as error:
        print("Onboarding page not encountered.")

# Function to enable ODBC/JDBC connections
def enable_odbc_jdbc():

    # redirect to page
    driver.get("https://localhost/admin-console/app/connectors/xdbc")
    JDBC_checkbox = WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.ID, "ibToggle")))

    # Check if the checkbox is not already checked - wait for auto-check
    time.sleep(5)
    is_checked = driver.execute_script("return arguments[0].checked;", JDBC_checkbox)
    if not is_checked:
        driver.execute_script("arguments[0].click();", JDBC_checkbox)
        print("Checkbox was not checked. Enabled setting \"ODBC / JDBC\".")
    else:
        print("Checkbox was already checked. State not changed.")

# Main execution
if __name__ == "__main__":
    try:
        print("Running python script for setting up Admin Console...")
        login()
        time.sleep(0.5)
        handle_onboarding()
        enable_odbc_jdbc()
    finally:
        driver.quit()
        print("Closing python script...")
