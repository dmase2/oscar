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
    international = ""
    worldwide = ""
    imdb_id = ""
    
    # Extract IMDb ID
    imdb_links = soup.find_all("a", href=re.compile(r"imdb\.com/title/tt\d+"))
    if imdb_links:
        match = re.search(r"tt(\d+)", imdb_links[0].get("href", ""))
        if match:
            imdb_id = f"tt{match.group(1)}"
    
    print(f"Scraping: {url}")
    
    # Extract all money values from spans on the page
    all_spans = soup.find_all('span')
    money_values = []
    
    for span in all_spans:
        text = span.get_text(strip=True)
        # Look for money values that start with $ and contain commas
        if text.startswith('$') and ',' in text:
            # Use a more robust regex to extract just the money part
            money_pattern = re.findall(r'\$[\d,]+', text)
            for match in money_pattern:
                # Additional validation: ensure it's a reasonable box office figure
                try:
                    numeric_value = int(match.replace('$', '').replace(',', ''))
                    # Box office figures should be at least $10K and less than $10B
                    if 10000 <= numeric_value <= 10000000000:
                        money_values.append(match)
                except ValueError:
                    continue
    
    # Remove duplicates while preserving order
    seen = set()
    unique_money_values = []
    for value in money_values:
        if value not in seen:
            seen.add(value)
            unique_money_values.append(value)
    
    # From analysis, Box Office Mojo typically shows money values in this order:
    # 1. Domestic box office
    # 2. International box office (if available)  
    # 3. Worldwide box office
    
    if len(unique_money_values) >= 3:
        # We have 3+ values - likely domestic, international, worldwide
        # But sometimes the order might be domestic, worldwide, other
        domestic = unique_money_values[0]
        second_value = unique_money_values[1] 
        third_value = unique_money_values[2]
        
        # Check if second value might actually be worldwide (very close to domestic + small amount)
        try:
            domestic_num = int(domestic.replace('$', '').replace(',', ''))
            second_num = int(second_value.replace('$', '').replace(',', ''))
            third_num = int(third_value.replace('$', '').replace(',', ''))
            
            # If second value is only slightly larger than domestic, it's likely worldwide
            if second_num > domestic_num and second_num < domestic_num * 1.5:
                # Second value is likely worldwide, calculate international
                worldwide = second_value
                international_num = second_num - domestic_num
                international = f"${international_num:,}"
            else:
                # Standard order: domestic, international, worldwide  
                international = second_value
                worldwide = third_value
        except ValueError:
            # Fallback to standard order
            international = second_value
            worldwide = third_value
        
    elif len(unique_money_values) == 2:
        # We have 2 values - could be domestic + worldwide (no international breakdown)
        domestic = unique_money_values[0] 
        worldwide = unique_money_values[1]
        
        # Calculate international if possible
        try:
            domestic_num = int(domestic.replace('$', '').replace(',', ''))
            worldwide_num = int(worldwide.replace('$', '').replace(',', ''))
            if worldwide_num > domestic_num:
                international_num = worldwide_num - domestic_num
                international = f"${international_num:,}"
            else:
                international = "$0"
        except ValueError:
            international = "$0"
            
    elif len(unique_money_values) == 1:
        # Only one value - assume it's domestic only
        domestic = unique_money_values[0]
        international = "$0"
        worldwide = domestic  # If no international, worldwide = domestic
    
    else:
        # No money values found
        domestic = "$0"
        international = "$0"
        worldwide = "$0"
    
    # Final validation and correction
    try:
        domestic_num = int(domestic.replace('$', '').replace(',', '')) if domestic != "$0" else 0
        international_num = int(international.replace('$', '').replace(',', '')) if international != "$0" else 0
        worldwide_num = int(worldwide.replace('$', '').replace(',', '')) if worldwide != "$0" else 0
        
        # Detect corrupted international data (common in pre-1985 Box Office Mojo pages)
        international_corrupted = False
        
        # Check for obvious corruption patterns
        if international != "$0":
            # Pattern 1: International value contains malformed comma formatting
            # Valid format: $X,XXX,XXX (groups of 3 digits)
            if not re.match(r'^\$\d{1,3}(,\d{3})*$', international):
                international_corrupted = True
                print(f"    ⚠️ Malformed international format: {international}")
            
            # Pattern 2: International value is suspiciously large (>$1B for older movies)
            elif international_num > 1000000000:
                international_corrupted = True
                print(f"    ⚠️ Impossible international value: ${international_num:,}")
            
            # Pattern 3: International is more than 50x domestic (unrealistic ratio)
            elif domestic_num > 0 and international_num > domestic_num * 50:
                international_corrupted = True
                print(f"    ⚠️ Unrealistic international ratio: {international_num/domestic_num:.1f}x domestic")
        
        # If international data is corrupted, reset to conservative estimate
        if international_corrupted:
            print(f"    🔧 Resetting corrupted international data to $0")
            international = "$0"
            international_num = 0
            worldwide = domestic  # Conservative: use domestic only when international is unreliable
            print(f"    🔧 Using domestic-only worldwide: {domestic}")
        else:
            # Standard validation: ensure worldwide = domestic + international
            expected_worldwide = domestic_num + international_num
            if worldwide_num != expected_worldwide and expected_worldwide > 0:
                worldwide = f"${expected_worldwide:,}"
            
    except ValueError:
        pass
    
    return title, domestic, international, worldwide, imdb_id
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
            writer.writerow(["Title", "Domestic", "International", "Worldwide", "ImdbID", "URL"])
            
            for i, link in enumerate(movie_links, 1):
                title, domestic, international, worldwide, imdb_id = get_box_office(f"{BASE_URL}{link}")
                print(f"[{i}/{movies_to_scrape}] {title}: Domestic={domestic}, International={international}, Worldwide={worldwide}, IMDb={imdb_id}")
                writer.writerow([title, domestic, international, worldwide, imdb_id, f"{BASE_URL}{link}"])
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
