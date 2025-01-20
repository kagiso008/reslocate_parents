import requests
from bs4 import BeautifulSoup
import csv

# URL to scrape
url = 'https://stanglobal.net/engineering-bursaries-in-south-africa-closing/'

# Send a GET request to the URL
response = requests.get(url)

# Check if the request was successful
if response.status_code == 200:
    # Parse the HTML content
    soup = BeautifulSoup(response.text, 'html.parser')
    
    # Open a CSV file for writing
    with open('engineering_bursaries.csv', 'w', newline='', encoding='utf-8') as csvfile:
        csvwriter = csv.writer(csvfile)
        
        # Write a header row
        csvwriter.writerow(['Heading', 'URL'])
        
        # Example: Assuming headings are within <h2> tags and links are within <a> tags
        bursary_items = soup.find_all('a', href=True)  # Adjust the tag and class if necessary
        
        # Extract and write each heading and URL
        for item in bursary_items:
            heading = item.get_text(strip=True)
            link_url = item['href']
            
            # Write to the CSV
            csvwriter.writerow([heading, link_url])
    
    print("Data has been written to engineering_bursaries.csv")
else:
    print(f"Failed to retrieve the webpage. Status code: {response.status_code}")
