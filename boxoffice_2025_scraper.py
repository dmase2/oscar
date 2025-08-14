import requests
from bs4 import BeautifulSoup
import csv
import time
import re
import sys
import argparse

BASE_URL = "https://www.boxofficemojo.com"
HEADERS = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3"
}


def get_movie_links(year):
    year_url = f"{BASE_URL}/year/{year}/"
    resp = requests.get(year_url, headers=HEADERS)
    soup = BeautifulSoup(resp.text, "html.parser")
    table = soup.find("table")
    links = []
    if table:
        for row in table.find_all("tr")[1:]:
            a = row.find("a")
            if a and a.get("href", "").startswith("/release/"):
                links.append(a["href"])  # Just store the relative path
    return links


def get_box_office(url):
    resp = requests.get(url, headers=HEADERS)
    soup = BeautifulSoup(resp.text, "html.parser")
    title = soup.find("h1").text.strip() if soup.find("h1") else ""
    
    domestic = ""
    worldwide = ""
    imdb_id = ""
    
    # Extract IMDb ID
    imdb_links = soup.find_all("a", href=re.compile(r"imdb\.com/title/tt\d+"))
    if imdb_links:
        match = re.search(r"tt(\d+)", imdb_links[0].get("href", ""))
        if match:
            imdb_id = f"tt{match.group(1)}"
    
    # Debug: Print URL and look for different selectors
    print(f"Scraping: {url}")
    
    # Try multiple selector approaches
    # Method 1: Original selector
    for div in soup.find_all("div", class_="a-section a-spacing-none mojo-summary-values mojo-hidden-from-mobile"):
        for row in div.find_all("div"):
            label = row.find("span", class_="a-size-small")
            value = row.find("span", class_="a-size-medium")
            if label and value:
                label_text = label.text.strip().lower()
                if "domestic" in label_text:
                    domestic = value.text.strip()
                if "worldwide" in label_text:
                    worldwide = value.text.strip()
    
    # Method 2: Try different selector patterns
    if not domestic or not worldwide:
        # Look for mojo-summary-table
        summary_table = soup.find("div", class_="a-section mojo-summary-table")
        if summary_table:
            for row in summary_table.find_all("div", class_="a-section a-spacing-none"):
                label = row.find("span", class_="a-size-small")
                value = row.find("span", class_="a-size-medium")
                if label and value:
                    label_text = label.text.strip().lower()
                    if "domestic" in label_text:
                        domestic = value.text.strip()
                    if "worldwide" in label_text:
                        worldwide = value.text.strip()
    
    # Method 3: Look for any span with money values
    if not domestic or not worldwide:
        money_spans = soup.find_all("span", string=lambda text: text and "$" in text and "," in text)
        if len(money_spans) >= 2:
            domestic = money_spans[0].text.strip()
            worldwide = money_spans[1].text.strip() if len(money_spans) > 1 else ""
    
    return title, domestic, worldwide, imdb_id


def main():
    parser = argparse.ArgumentParser(description="Scrape box office data from Box Office Mojo")
    parser.add_argument("--year", "-y", type=int, default=2024, 
                       help="Year to scrape box office data for (default: 2024)")
    parser.add_argument("--years", type=str,
                       help="Multiple years or year ranges (e.g., '2020,2021,2022' or '2020-2022' or '2018,2020-2022')")
    parser.add_argument("--limit", "-l", type=int, default=50,
                       help="Maximum number of movies to scrape per year (default: 50)")
    
    args = parser.parse_args()
    
    # Determine which years to scrape
    years_to_scrape = []
    
    if args.years:
        # Parse multiple years or ranges
        years_to_scrape = parse_years_input(args.years)
    else:
        # Single year
        years_to_scrape = [args.year]
    
    # Validate years
    for year in years_to_scrape:
        if year < 1977 or year > 2025:
            print(f"Error: Year must be between 1977 and 2025. Got: {year}")
            sys.exit(1)
    
    # Validate limit
    if args.limit < 1 or args.limit > 200:
        print(f"Error: Limit must be between 1 and 200. Got: {args.limit}")
        sys.exit(1)
    
    if len(years_to_scrape) == 1:
        print(f"Scraping box office data for {years_to_scrape[0]} (top {args.limit} movies)")
    else:
        print(f"Scraping box office data for {len(years_to_scrape)} years: {', '.join(map(str, years_to_scrape))} (top {args.limit} movies each)")
    
    total_movies_scraped = 0
    
    for year in years_to_scrape:
        print(f"\n{'='*50}")
        print(f"Scraping {year}...")
        print(f"{'='*50}")
        
        movie_links = get_movie_links(year)
        available_movies = len(movie_links)
        print(f"Found {available_movies} movies for {year}.")
        
        if available_movies == 0:
            print(f"No movies found for {year}. Skipping...")
            continue
        
        # Show data availability warning for early years
        if year < 1985 and available_movies < 50:
            print(f"⚠️  Note: {year} has limited data ({available_movies} movies available)")
        
        # Limit to specified number of movies
        movies_to_scrape = min(args.limit, available_movies)
        movie_links = movie_links[:movies_to_scrape]
        
        # Generate filename based on year
        filename = f"boxoffice_{year}.csv"
        
        with open(filename, "w", newline="", encoding="utf-8") as f:
            writer = csv.writer(f)
            writer.writerow(["Title", "Domestic", "Worldwide", "ImdbID", "URL"])
            
            for i, link in enumerate(movie_links, 1):
                title, domestic, worldwide, imdb_id = get_box_office(f"{BASE_URL}{link}")
                print(f"[{i}/{movies_to_scrape}] {title}: Domestic={domestic}, Worldwide={worldwide}, IMDb={imdb_id}")
                writer.writerow([title, domestic, worldwide, imdb_id, f"{BASE_URL}{link}"])
                time.sleep(0.5)  # Be polite to the server
        
        print(f"✅ {year} completed! Data saved to: {filename}")
        print(f"   Movies scraped: {movies_to_scrape}")
        total_movies_scraped += movies_to_scrape
    
    print(f"\n{'='*50}")
    print(f"🎉 All scraping completed!")
    print(f"Total years scraped: {len(years_to_scrape)}")
    print(f"Total movies scraped: {total_movies_scraped}")
    print(f"{'='*50}")


def parse_years_input(years_input):
    """
    Parse years input string into a list of years.
    Supports formats like:
    - '2020,2021,2022'
    - '2020-2022'  
    - '2018,2020-2022,2024'
    """
    years = []
    parts = years_input.split(',')
    
    for part in parts:
        part = part.strip()
        if '-' in part:
            # Handle range (e.g., '2020-2022')
            start, end = part.split('-')
            start_year = int(start.strip())
            end_year = int(end.strip())
            if start_year > end_year:
                raise ValueError(f"Invalid range: {part}. Start year must be <= end year")
            years.extend(range(start_year, end_year + 1))
        else:
            # Handle single year
            years.append(int(part))
    
    # Remove duplicates and sort
    return sorted(list(set(years)))

if __name__ == "__main__":
    main()
