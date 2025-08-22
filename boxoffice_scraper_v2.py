#!/usr/bin/env python3

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
                links.append(a["href"])
    return links

def get_box_office(url):
    resp = requests.get(url, headers=HEADERS)
    soup = BeautifulSoup(resp.text, "html.parser")
    title = soup.find("h1").text.strip() if soup.find("h1") else ""
    
    domestic = "$0"
    international = "$0" 
    worldwide = "$0"
    imdb_id = ""
    
    # Extract IMDb ID
    imdb_links = soup.find_all("a", href=re.compile(r"imdb\.com/title/tt\d+"))
    if imdb_links:
        match = re.search(r"tt(\d+)", imdb_links[0].get("href", ""))
        if match:
            imdb_id = f"tt{match.group(1)}"
    
    print(f"Scraping: {url}")
    
    # Find the summary table - this contains the main box office figures
    summary_table = soup.find("div", class_="a-section a-spacing-none mojo-gutter mojo-summary-table")
    
    if summary_table:
        # Get all text from the summary table
        summary_text = summary_table.get_text(separator="|").lower()
        
        # Find all money values in the summary
        money_pattern = r'\$[\d,]+'
        money_matches = re.findall(money_pattern, summary_table.get_text())
        
        # Clean and convert to numbers for analysis
        money_values = []
        for match in money_matches:
            clean_value = match.replace('$', '').replace(',', '')
            if clean_value.isdigit() and len(clean_value) >= 6:  # At least $100,000
                money_values.append((int(clean_value), match))
        
        # Sort by value (descending)
        money_values.sort(reverse=True)
        
        # Strategy: Look for the three distinct largest values
        # Typically: 1st = Worldwide, 2nd = Domestic, 3rd = International
        # Or if only 2 values: 1st = Domestic, 2nd might be International or Worldwide
        
        unique_values = []
        seen_values = set()
        for value, formatted in money_values:
            if value not in seen_values:
                unique_values.append((value, formatted))
                seen_values.add(value)
        
        if len(unique_values) >= 2:
            # Look for the mathematical relationship: worldwide = domestic + international
            found_combination = False
            
            # Try different combinations
            for i in range(len(unique_values)):
                for j in range(len(unique_values)):
                    for k in range(len(unique_values)):
                        if i != j and j != k and i != k:  # All different indices
                            val_i, val_j, val_k = unique_values[i][0], unique_values[j][0], unique_values[k][0]
                            
                            # Check if val_i = val_j + val_k (worldwide = domestic + international)
                            if abs(val_i - (val_j + val_k)) < val_i * 0.05:
                                worldwide = unique_values[i][1]
                                
                                # For modern blockbusters, international can be larger than domestic
                                # We need to identify which is which based on the title or other context
                                # For now, let's look at which value appears to be more "rounded" 
                                # as domestic figures are often more precise
                                
                                # Assign based on position in the summary (domestic usually comes first)
                                # Since we're getting values in descending order, we need to be smarter
                                
                                # The most reliable approach: check the raw HTML order
                                summary_html = summary_table.get_text()
                                
                                # Find positions of both values in the HTML
                                pos_j = summary_html.find(unique_values[j][1].replace('$', '').replace(',', ''))
                                pos_k = summary_html.find(unique_values[k][1].replace('$', '').replace(',', ''))
                                
                                # The value that appears first in HTML is typically domestic
                                if pos_j < pos_k and pos_j != -1:
                                    domestic = unique_values[j][1]
                                    international = unique_values[k][1]
                                elif pos_k < pos_j and pos_k != -1:
                                    domestic = unique_values[k][1]
                                    international = unique_values[j][1]
                                else:
                                    # Fallback: assume smaller is domestic (not always true)
                                    if val_j <= val_k:
                                        domestic = unique_values[j][1]
                                        international = unique_values[k][1]
                                    else:
                                        domestic = unique_values[k][1]
                                        international = unique_values[j][1]
                                
                                found_combination = True
                                break
                    if found_combination:
                        break
                if found_combination:
                    break
            
            # Fallback: if we only have 2 values, assume one is domestic
            if not found_combination and len(unique_values) >= 2:
                # Take the two largest values
                val1, val2 = unique_values[0][0], unique_values[1][0]
                
                # If one is much larger, it might be worldwide, smaller is domestic
                if val1 > val2 * 1.8:  # First value is much larger
                    worldwide = unique_values[0][1]
                    domestic = unique_values[1][1] 
                    international_val = val1 - val2
                    if international_val > 0:
                        international = f"${international_val:,}"
                else:
                    # Two similar values - likely domestic and international
                    domestic = unique_values[0][1] 
                    international = unique_values[1][1]
                    worldwide_val = val1 + val2
                    worldwide = f"${worldwide_val:,}"
        
        elif len(unique_values) == 1:
            # Only one value - likely domestic only for older/smaller releases
            domestic = unique_values[0][1]
    
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