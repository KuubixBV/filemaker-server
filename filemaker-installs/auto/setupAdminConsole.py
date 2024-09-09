#############################
# Tested and works on versions
## 20.3.2.205 by Indy Hendrickx - Approved
## 21.0.1.51 by Indy Hendrickx - Approved
##
##
##
#############################

from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.by import By
from dotenv import load_dotenv
from selenium import webdriver
import time
import os

# Globals
FM_USERNAME = ""
FM_PASSWORD = ""
chrome_options = None
driver = None

# Function to init module
def init():
    global FM_USERNAME, FM_PASSWORD, chrome_options, driver

    # Load environment variables
    load_dotenv("/install/auto/.env")
    FM_USERNAME = os.getenv('FM_USERNAME')
    FM_PASSWORD = os.getenv('FM_PASSWORD')

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
    WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.ID, "inputUserName"))).send_keys(FM_USERNAME)
    driver.find_element(By.ID, "inputPassword").send_keys(FM_PASSWORD)
    driver.find_element(By.ID, "LOGN_Butn_SignIn").click()
    print("Logged in!")

# Function to handle optional onboarding
def handle_onboarding():

    # Check if onboarding page is in URL
    try:
        print("Checking if onboarding page..." + driver.current_url)
        if driver.current_url != "https://localhost/admin-console/onboarding":
            raise Exception()
    except Exception as error:
        print("Onboarding page not encountered")
        return ""
        
    # Click on needed buttons
    print("Handling onboarding page...")
    option = driver.find_element(By.ID, "opt-2")
    driver.execute_script("arguments[0].click();", option)
    print("Clicked on 'Use the Claris default certificate'")
    save_button = WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.XPATH, "//button[contains(@class, 'btn') and contains(@class, 'btn-submit')]")))
    driver.execute_script("arguments[0].click();", save_button)
    print("Clicked on 'Save'")
    accept_risk_button = WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.XPATH, "//button[contains(@class, 'btn') and contains(@class, 'btn-outline-primary')]")))
    driver.execute_script("arguments[0].click();", accept_risk_button)
    print("Clicked on 'I accept the Risk'")



# Function to enable ODBC/JDBC connections
def enable_odbc_jdbc():

    # Redirect to page
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

# Load the backup schedules backup
def load_backup_schedules():

    # Redirect to page
    driver.get("https://localhost/admin-console/app/backups/backupschedules")
    print("Trying to restore backup schedules...")

    # Check for old FMS version <=v20 or new FMS version (different implementation)
    if driver.current_url != "https://localhost/admin-console/app/backups/backupschedules":
        driver.get("https://localhost/admin-console/app/configuration/schedules")
        restore_schedules("/install/schedules/backups/fms_settings.settings")
        return True
    
    # Old FMS version        
    restore_schedules_old("/install/schedules/backups/fms_settings.settings")
    return False
    

# Load the script schedules backup
def load_script_schedules(new_impl = True):

    # Redirect to page
    driver.get("https://localhost/admin-console/app/configuration/schedules")
    print("Trying to restore script schedules...")

    # Check for old FMS version <=v20 or new FMS version (different implementation)
    if new_impl:
        restore_schedules("/install/schedules/scripts/fms_settings.settings")
        return True
    
    # Old FMS version        
    restore_schedules_old("/install/schedules/scripts/fms_settings.settings")
    return False

# Loads or saves a backup schedule or script schedule for the old implementation
def restore_schedules_old(file):

    # Check if the backup file exists
    if not os.path.exists(file):
        print(f"Backup file {file} does not exist - skipping")
        return

    # Wait for the "Save or Load" dropdown menu to be clickable
    save_or_load_button = WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.ID, "dropdownMenu0")))

    # Click the "Save or Load" button to reveal options
    driver.execute_script("arguments[0].click();", save_or_load_button)

    # Find the button by its tabindex
    load_option = WebDriverWait(driver, 10).until(
        EC.presence_of_element_located((By.XPATH, "//button[contains(@class, 'dropdown-item') and contains(text(), 'Load All Schedules')]"))
    )
    driver.execute_script("arguments[0].click();", load_option)

    # Find the input field by its ID and send the file path
    driver.execute_script(f'document.getElementById("scheduleFile").style.display = "block";')
    WebDriverWait(driver, 10).until(
        EC.presence_of_element_located((By.ID, "scheduleFile"))
    ).send_keys(file)

    # Click on the first button child of the element with class "modal-footer"
    modal_footer_button = WebDriverWait(driver, 10).until(
        EC.element_to_be_clickable((By.CSS_SELECTOR, ".modal-footer button:first-child"))
    )
    driver.execute_script("arguments[0].click();", modal_footer_button)

# Loads or saves a backup schedule or script schedule for the new implementation
def restore_schedules(file):

    # Check if the backup file exists
    if not os.path.exists(file):
        print(f"Backup file {file} does not exist - skipping")
        return

    # Wait for the "Save or Load" dropdown menu to be clickable
    load_button = WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.ID, "CONF_Butn_Load")))

    # Click the "Save or Load" button to reveal options
    driver.execute_script("arguments[0].click();", load_button)

    # Find the input field by its ID and send the file path
    driver.execute_script(f'document.getElementById("scheduleFile").style.display = "block";')
    WebDriverWait(driver, 10).until(
        EC.presence_of_element_located((By.ID, "scheduleFile"))
    ).send_keys(file)

    # Click on the first button child of the element with class "modal-footer"
    modal_footer_button = WebDriverWait(driver, 10).until(
        EC.presence_of_element_located((By.CSS_SELECTOR, ".modal-footer button:first-child"))
    )
    driver.execute_script("arguments[0].click();", modal_footer_button)

# Main execution
init()
if __name__ == "__main__":
    try:
        print("Running python script for setting up Admin Console...")
        login()
        time.sleep(2.5)
        handle_onboarding()
        enable_odbc_jdbc()
        new_impl = load_backup_schedules()
        load_script_schedules(new_impl)
    finally:
        driver.quit()
        print("Closing python script...")