import requests
from bs4 import BeautifulSoup
import csv

# URL of the page to scrape
url = "https://www.zabursaries.co.za/computer-science-it-bursaries-south-africa/"

# Make a GET request to fetch the raw HTML content
response = requests.get(url)
response.raise_for_status()  # Check if the request was successful

# Parse the HTML content using BeautifulSoup
soup = BeautifulSoup(response.content, 'html.parser')

# Find all bursary listings (bursaries are likely inside <h3> or <a> tags)
bursaries = soup.find_all('h3')  # Adjust based on the actual HTML structure

# Create a CSV file and write the header
with open('sabursaries.csv', mode='w', newline='', encoding='utf-8') as file:
    writer = csv.writer(file)
    writer.writerow(['Bursary Title', 'Link'])

    # Extract and write the bursary titles and links
    for bursary in bursaries:
        title = bursary.get_text(strip=True)
        link = bursary.find('a')['href'] if bursary.find('a') else None
        writer.writerow([title, link])

print("Scraping completed. Results saved in 'bursaries.csv'.")
