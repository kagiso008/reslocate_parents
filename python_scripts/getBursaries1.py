import requests
from bs4 import BeautifulSoup

# URL of the bursaries page
url = 'https://studytrust.org.za/bursaries/'

# Send an HTTP GET request to the URL
response = requests.get(url)

# Check if the request was successful
if response.status_code == 200:
    # Parse the HTML content using BeautifulSoup
    soup = BeautifulSoup(response.content, 'html.parser')

    # Find the section containing the bursaries
    bursaries_section = soup.find('div', {'class': 'bursaries-list'})

    # Extract each bursary item
    bursaries = bursaries_section.find_all('div', {'class': 'bursary-item'})

    # Iterate over each bursary item and extract the required information
    for bursary in bursaries:
        title = bursary.find('h3').text.strip()
        link = bursary.find('a')['href']
        requirements = bursary.find('p').text.strip()

        # Print the extracted information
        print(f'Title: {title}')
        print(f'URL: {link}')
        print(f'Requirements: {requirements}')
        print('-' * 40)
else:
    print(f'Failed to retrieve the page. Status code: {response.status_code}')
