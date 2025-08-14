import requests
from bs4 import BeautifulSoup
import csv
import time
import re
import argparse
from urllib.parse import urljoin, parse_qs, urlparse

class IMDbMovieScraper:
    def __init__(self):
        self.base_url = "https://www.imdb.com"
        self.session = requests.Session()
        self.session.headers.update({
            'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
            'Accept-Language': 'en-US,en;q=0.9',
            'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8'
        })
        
    def get_movies_by_year(self, year, start=1):
        """Get movies for a specific year with pagination support"""
        movies = []
        
        # IMDb Advanced Search URL for movies by year
        url = f"https://www.imdb.com/search/title/?title_type=feature&release_date={year},{year}&sort=num_votes,desc&start={start}"
        
        print(f"Fetching movies from {year}, page starting at {start}...")
        
        try:
            response = self.session.get(url, timeout=10)
            response.raise_for_status()
            
            soup = BeautifulSoup(response.content, 'html.parser')
            
            # Find movie containers - IMDb now uses new interface
            movie_containers = soup.find_all('li', class_='ipc-metadata-list-summary-item')
            
            # Fallback to old interface if new one not found
            if not movie_containers:
                movie_containers = soup.find_all('div', class_='lister-item')
                print(f"  Using old interface, found {len(movie_containers)} containers")
            else:
                print(f"  Using new interface, found {len(movie_containers)} containers")
            
            for container in movie_containers:
                try:
                    title = None
                    imdb_id = None
                    
                    # New interface extraction
                    if 'ipc-metadata-list-summary-item' in container.get('class', []):
                        # Look for the title link wrapper
                        title_link = container.find('a', class_='ipc-title-link-wrapper')
                        if title_link:
                            title_text = title_link.get_text(strip=True)
                            # Remove ranking number (e.g., "1. Dune: Part Two" -> "Dune: Part Two")
                            title = re.sub(r'^\d+\.\s*', '', title_text)
                            
                            href = title_link.get('href', '')
                            imdb_id_match = re.search(r'/title/(tt\d+)/', href)
                            if imdb_id_match:
                                imdb_id = imdb_id_match.group(1)
                    
                    # Old interface extraction (fallback)
                    else:
                        title_element = container.find('h3', class_='lister-item-header')
                        if title_element:
                            title_link = title_element.find('a')
                            if title_link:
                                title = title_link.get_text(strip=True)
                                href = title_link.get('href', '')
                                imdb_id_match = re.search(r'/title/(tt\d+)/', href)
                                if imdb_id_match:
                                    imdb_id = imdb_id_match.group(1)
                    
                    # Only add if we found both title and IMDb ID
                    if title and imdb_id:
                        movies.append({
                            'title': title,
                            'imdb_id': imdb_id,
                            'year': year,
                            'year_text': str(year)
                        })
                    
                except Exception as e:
                    print(f"  Error processing movie container: {e}")
                    continue
            
            # Check if there's a next page (try both old and new selectors)
            next_button = soup.find('a', class_='lister-page-next')  # Old interface
            if not next_button:
                # Try new interface next button patterns
                next_button = soup.find('a', {'aria-label': 'Next'})
            if not next_button:
                next_button = soup.find('a', string=re.compile(r'Next', re.I))
            
            has_next_page = next_button is not None
            
            print(f"  Found {len(movies)} movies on this page")
            return movies, has_next_page
            
        except requests.RequestException as e:
            print(f"  Error fetching data for year {year}: {e}")
            return [], False
    
    def get_all_movies_for_year(self, year, max_pages=None):
        """Get all movies for a specific year across all pages"""
        all_movies = []
        start = 1
        page = 1
        
        while True:
            if max_pages and page > max_pages:
                break
                
            movies, has_next_page = self.get_movies_by_year(year, start)
            
            if not movies:
                break
                
            all_movies.extend(movies)
            print(f"  Found {len(movies)} movies on page {page} (total: {len(all_movies)})")
            
            # Stop if we got fewer than 25 movies (indicates last page)
            # This is more reliable than next button detection for new interface
            if len(movies) < 25:
                break
                
            # For new interface, next page detection may not work reliably
            # So we continue unless we hit max pages or get no results
            
            # IMDb shows 25 results per page, start increments by 50 for some reason
            start += 50
            page += 1
            
            # Be respectful to the server
            time.sleep(1)
        
        return all_movies
    
    def scrape_years_range(self, start_year, end_year, max_pages_per_year=None, output_file=None):
        """Scrape movies for a range of years"""
        if not output_file:
            output_file = f"movies_{start_year}_{end_year}.csv"
        
        all_movies = []
        total_years = end_year - start_year + 1
        
        print(f"Starting to scrape movies from {start_year} to {end_year}")
        print(f"Output file: {output_file}")
        print("=" * 50)
        
        for year in range(start_year, end_year + 1):
            try:
                current_year_index = year - start_year + 1
                print(f"\n[{current_year_index}/{total_years}] Processing year {year}...")
                
                year_movies = self.get_all_movies_for_year(year, max_pages_per_year)
                
                if year_movies:
                    all_movies.extend(year_movies)
                    print(f"  ✅ Year {year}: {len(year_movies)} movies")
                else:
                    print(f"  ⚠️  Year {year}: No movies found")
                
                # Save progress every 10 years or at the end
                if year % 10 == 0 or year == end_year:
                    self.save_to_csv(all_movies, output_file)
                    print(f"  💾 Progress saved: {len(all_movies)} total movies")
                
            except Exception as e:
                print(f"  ❌ Error processing year {year}: {e}")
                continue
        
        # Final save
        self.save_to_csv(all_movies, output_file)
        
        print("\n" + "=" * 50)
        print(f"✅ Scraping completed!")
        print(f"📁 Output file: {output_file}")
        print(f"🎬 Total movies collected: {len(all_movies)}")
        print(f"📅 Years covered: {start_year}-{end_year}")
        
        return all_movies
    
    def save_to_csv(self, movies, filename):
        """Save movies to CSV file"""
        try:
            with open(filename, 'w', newline='', encoding='utf-8') as csvfile:
                fieldnames = ['title', 'imdb_id', 'year', 'imdb_url']
                writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
                
                writer.writeheader()
                for movie in movies:
                    writer.writerow({
                        'title': movie['title'],
                        'imdb_id': movie['imdb_id'],
                        'year': movie['year'],
                        'imdb_url': f"https://www.imdb.com/title/{movie['imdb_id']}/"
                    })
            
        except Exception as e:
            print(f"Error saving to CSV: {e}")

def main():
    parser = argparse.ArgumentParser(description="Scrape IMDb for comprehensive movie data since 1927")
    
    parser.add_argument('--start-year', '-s', type=int, default=1927, 
                       help='Starting year (default: 1927)')
    
    parser.add_argument('--end-year', '-e', type=int, default=2024,
                       help='Ending year (default: 2024)')
    
    parser.add_argument('--output', '-o', type=str, default=None,
                       help='Output CSV filename (default: movies_STARTYEAR_ENDYEAR.csv)')
    
    parser.add_argument('--max-pages', '-p', type=int, default=None,
                       help='Maximum pages per year (default: unlimited, ~50 movies per page)')
    
    parser.add_argument('--test', action='store_true',
                       help='Test mode: only scrape 2020-2022 with 1 page per year')
    
    args = parser.parse_args()
    
    scraper = IMDbMovieScraper()
    
    if args.test:
        print("🧪 Running in test mode...")
        movies = scraper.scrape_years_range(2020, 2022, max_pages_per_year=1, output_file="movies_test.csv")
    else:
        start_year = args.start_year
        end_year = args.end_year
        
        # Validate years
        if start_year > end_year:
            print("❌ Error: Start year must be less than or equal to end year")
            return
        
        if start_year < 1927:
            print("❌ Error: Start year must be 1927 or later (when movies began)")
            return
        
        movies = scraper.scrape_years_range(
            start_year, 
            end_year, 
            max_pages_per_year=args.max_pages,
            output_file=args.output
        )
    
    print(f"\n🎭 Sample movies collected:")
    for i, movie in enumerate(movies[:5]):
        print(f"  {i+1}. {movie['title']} ({movie['year']}) - {movie['imdb_id']}")
    
    if len(movies) > 5:
        print(f"  ... and {len(movies) - 5} more movies")

if __name__ == "__main__":
    main()