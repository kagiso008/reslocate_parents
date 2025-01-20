import requests
from bs4 import BeautifulSoup
import pandas as pd
from datetime import datetime
import time
import logging
import os
from typing import List, Dict, Optional, Set, Tuple
from dataclasses import dataclass
from concurrent.futures import ThreadPoolExecutor
import json
from urllib.parse import urljoin
import re
from requests.exceptions import RequestException

@dataclass
class Bursary:
    """Data class to store bursary information"""
    title: str
    link: Optional[str]
    description: Optional[str]
    closing_date: Optional[str]
    company: Optional[str]
    requirements: Optional[str]
    field_of_study: Optional[str]
    scraped_date: str
    is_valid: bool = True

class BursaryScraperWithValidation:
    def __init__(
        self, 
        base_url: str,
        output_dir: str = "outputs",
        max_retries: int = 3,
        delay: float = 1.0,
        concurrent_requests: int = 3,
        url_check_timeout: int = 10
    ):
        """Initialize with same parameters as before"""
        self.base_url = base_url
        self.output_dir = output_dir
        self.max_retries = max_retries
        self.delay = delay
        self.concurrent_requests = concurrent_requests
        self.url_check_timeout = url_check_timeout
        self.invalid_urls: Set[str] = set()
        self.removed_entries: List[Dict] = []  # Track removed entries
        self.setup_environment()
        self.setup_logging()

    def setup_logging(self) -> None:
        """Configure logging with both file and console handlers"""
        log_file = os.path.join(
            self.output_dir, 
            "logs", 
            f'scraper_{datetime.now().strftime("%Y%m%d_%H%M%S")}.log'
        )
        
        logging.basicConfig(
            level=logging.INFO,
            format='%(asctime)s - %(levelname)s - %(message)s',
            handlers=[
                logging.FileHandler(log_file),
                logging.StreamHandler()
            ]
        )

    def setup_environment(self) -> None:
        """Create necessary directories including one for removed entries"""
        os.makedirs(self.output_dir, exist_ok=True)
        os.makedirs(os.path.join(self.output_dir, "logs"), exist_ok=True)
        os.makedirs(os.path.join(self.output_dir, "data"), exist_ok=True)
        os.makedirs(os.path.join(self.output_dir, "removed"), exist_ok=True)

    def save_removed_entries(self) -> None:
        """Save information about removed entries"""
        if not self.removed_entries:
            return
            
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        removed_file = os.path.join(
            self.output_dir, 
            "removed", 
            f'removed_entries_{timestamp}.json'
        )
        
        with open(removed_file, 'w', encoding='utf-8') as f:
            json.dump({
                'timestamp': timestamp,
                'total_removed': len(self.removed_entries),
                'entries': self.removed_entries
            }, f, indent=2)
            
        logging.info(f"Saved {len(self.removed_entries)} removed entries to {removed_file}")

    def clean_invalid_urls(self, df: pd.DataFrame) -> Tuple[pd.DataFrame, pd.DataFrame]:
        """
        Remove invalid URLs from the dataset and return both valid and invalid dataframes
        
        Returns:
            Tuple[pd.DataFrame, pd.DataFrame]: (valid_entries, invalid_entries)
        """
        # Load existing data if available
        existing_data_path = self.get_latest_data_file()
        if existing_data_path:
            existing_df = pd.read_csv(existing_data_path)
            # Update validity status for URLs that are no longer valid
            existing_df.loc[existing_df['link'].isin(self.invalid_urls), 'is_valid'] = False
            # Merge new and existing data
            df = pd.concat([existing_df, df]).drop_duplicates(subset=['link'], keep='last')
        
        # Split into valid and invalid entries
        invalid_df = df[~df['is_valid']].copy()
        valid_df = df[df['is_valid']].copy()
        
        # Store removed entries for logging
        self.removed_entries.extend(invalid_df.to_dict('records'))
        
        return valid_df, invalid_df

    def save_results(self, bursaries: List[Bursary]) -> None:
        """Save results with separate handling for valid and invalid entries"""
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        
        # Convert to DataFrame
        df = pd.DataFrame([vars(b) for b in bursaries])
        
        # Clean invalid URLs and get both valid and invalid dataframes
        valid_df, invalid_df = self.clean_invalid_urls(df)
        
        # Save valid entries as CSV
        csv_path = os.path.join(self.output_dir, "data", f'valid_bursaries_{timestamp}.csv')
        valid_df.to_csv(csv_path, index=False)
        logging.info(f"Saved {len(valid_df)} valid entries to CSV: {csv_path}")
        
        # Save valid entries as JSON
        json_path = os.path.join(self.output_dir, "data", f'valid_bursaries_{timestamp}.json')
        with open(json_path, 'w', encoding='utf-8') as f:
            json.dump(valid_df.to_dict('records'), f, indent=2)
        logging.info(f"Saved valid entries to JSON: {json_path}")
        
        # Save removed entries
        self.save_removed_entries()
        
        # Generate enhanced HTML report
        html_path = os.path.join(self.output_dir, "data", f'bursary_report_{timestamp}.html')
        html_content = self.generate_html_report(valid_df, invalid_df)
        with open(html_path, 'w', encoding='utf-8') as f:
            f.write(html_content)
        logging.info(f"Saved HTML report to {html_path}")

    def generate_html_report(self, valid_df: pd.DataFrame, invalid_df: pd.DataFrame) -> str:
        """Generate an enhanced HTML report showing both valid and removed entries"""
        return f"""
        <html>
            <head>
                <title>Bursary Scraping Results</title>
                <style>
                    body {{ font-family: Arial, sans-serif; margin: 20px; }}
                    table {{ border-collapse: collapse; width: 100%; margin-bottom: 20px; }}
                    th, td {{ border: 1px solid #ddd; padding: 8px; text-align: left; }}
                    th {{ background-color: #f2f2f2; }}
                    tr:nth-child(even) {{ background-color: #f9f9f9; }}
                    .summary {{ margin: 20px 0; padding: 10px; background-color: #f8f9fa; }}
                    .removed-section {{ margin-top: 30px; background-color: #fff3f3; padding: 20px; }}
                </style>
            </head>
            <body>
                <h1>Bursary Scraping Results</h1>
                <p>Generated on: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}</p>
                
                <div class="summary">
                    <h2>Summary</h2>
                    <p>Total valid bursaries: {len(valid_df)}</p>
                    <p>Total removed entries: {len(invalid_df)}</p>
                </div>
                
                <h2>Valid Bursaries</h2>
                {valid_df.to_html(classes='table')}
                
                <div class="removed-section">
                    <h2>Removed Entries</h2>
                    <p>The following entries were removed due to invalid URLs:</p>
                    {invalid_df.to_html(classes='table')}
                </div>
            </body>
        </html>
        """

    # [Rest of the methods remain the same as in the previous version]

def main():
    """Main entry point"""
    url = "https://studytrust.org.za/bursaries/"  # Replace with your URL
    scraper = BursaryScraperWithValidation(
        base_url=url,
        output_dir="bursary_results",
        max_retries=3,
        delay=1.0,
        concurrent_requests=3,
        url_check_timeout=10
    )
    bursaries = scraper.run()
    
    # Print summary
    print(f"\nScraping Complete!")
    valid_count = len([b for b in bursaries if b.is_valid])
    print(f"Total valid bursaries: {valid_count}")
    print(f"Total removed entries: {len(scraper.removed_entries)}")
    print("\nResults have been saved in the 'bursary_results' directory:")
    print("- CSV file containing only valid entries")
    print("- JSON file containing only valid entries")
    print("- Removed entries log in the 'removed' directory")
    print("- Comprehensive HTML report showing both valid and removed entries")

if __name__ == "__main__":
    main()