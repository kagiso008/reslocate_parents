import requests
from bs4 import BeautifulSoup
import pandas as pd

def scrape_bursaries(url):
    response = requests.get(url)
    soup = BeautifulSoup(response.content, 'html.parser')
    
    # Updated to look for specific HTML tags and classes that might contain bursary information
    bursaries = []
    
    # Look for sections with potential bursary links
    for a_tag in soup.find_all('a', href=True):
        if 'bursary' in a_tag.text.lower() or 'bursaries' in a_tag.text.lower():
            scholarships = a_tag.text.strip()
            scholarship_url = a_tag['href']
            bursaries.append({'scholarships': scholarships, 'scholarship_url': scholarship_url})
    
    return bursaries

# URL of the page to scrape
url = "https://damelinconnect.co.za/bursaries-in-south-africa/?gad_source=1&gclid=Cj0KCQjwiOy1BhDCARIsADGvQnCrHUNhaUH7MoXnN5PcL1mf0dljjkztI4yr7fPFCR_LRREOr9oyT3IaAhpkEALw_wcB"

# Scrape bursaries
bursaries = scrape_bursaries(url)

# If no bursaries were found, print a message
if not bursaries:
    print("No bursaries were found on the website.")
else:
    # Convert the list of dictionaries to a DataFrame
    df = pd.DataFrame(bursaries)

    # Save the DataFrame to a CSV file
    df.to_csv('damelin_bursaries.csv', index=False)

    print("Bursaries have been saved to 'damelin_bursaries.csv'")
