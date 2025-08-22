#!/usr/bin/env python3
"""
Merge all individual year box office CSV files into one master file.
"""

import csv
import glob
import os
from typing import List, Dict
import re

def get_year_from_filename(filename: str) -> int:
    """Extract year from filename like 'boxoffice_2023.csv'"""
    match = re.search(r'boxoffice_(\d{4})\.csv', filename)
    return int(match.group(1)) if match else 0

def merge_boxoffice_files():
    """Merge all boxoffice_YYYY.csv files into all_boxoffice.csv"""
    
    # Find all boxoffice CSV files
    csv_files = glob.glob("boxoffice_*.csv")
    
    if not csv_files:
        print("No boxoffice CSV files found!")
        return
    
    # Sort files by year
    csv_files.sort(key=get_year_from_filename)
    
    print(f"Found {len(csv_files)} boxoffice files to merge")
    
    all_rows = []
    header_written = False
    
    for csv_file in csv_files:
        year = get_year_from_filename(csv_file)
        print(f"Processing {csv_file} (year {year})...")
        
        try:
            with open(csv_file, 'r', encoding='utf-8') as f:
                reader = csv.DictReader(f)
                
                # Check if we have the expected headers
                if reader.fieldnames is None:
                    print(f"  ⚠️ No headers found in {csv_file}, skipping")
                    continue
                
                expected_headers = ['Title', 'Domestic', 'International', 'Worldwide', 'ImdbID', 'URL']
                if not all(header in reader.fieldnames for header in expected_headers):
                    print(f"  ⚠️ Missing expected headers in {csv_file}: {reader.fieldnames}")
                    continue
                
                # Add year column to each row
                rows_added = 0
                for row in reader:
                    if row['Title'].strip():  # Skip empty rows
                        row['Year'] = year
                        all_rows.append(row)
                        rows_added += 1
                
                print(f"  ✅ Added {rows_added} movies from {year}")
                
        except Exception as e:
            print(f"  ❌ Error reading {csv_file}: {e}")
            continue
    
    # Write merged data
    if all_rows:
        output_file = "all_boxoffice.csv"
        fieldnames = ['Year', 'Title', 'Domestic', 'International', 'Worldwide', 'ImdbID', 'URL']
        
        with open(output_file, 'w', newline='', encoding='utf-8') as f:
            writer = csv.DictWriter(f, fieldnames=fieldnames)
            writer.writeheader()
            
            # Sort by year, then by worldwide box office (descending)
            all_rows.sort(key=lambda x: (
                x['Year'], 
                -int(x['Worldwide'].replace('$', '').replace(',', '')) if x['Worldwide'] != '$0' else 0
            ))
            
            for row in all_rows:
                writer.writerow({
                    'Year': row['Year'],
                    'Title': row['Title'],
                    'Domestic': row['Domestic'], 
                    'International': row['International'],
                    'Worldwide': row['Worldwide'],
                    'ImdbID': row['ImdbID'],
                    'URL': row['URL']
                })
        
        print(f"\n🎉 Successfully merged {len(all_rows)} movies into {output_file}")
        
        # Show some statistics
        years_covered = sorted(set(row['Year'] for row in all_rows))
        print(f"📊 Years covered: {min(years_covered)} - {max(years_covered)}")
        print(f"📈 Total movies: {len(all_rows)}")
        
        # Show top 5 movies by worldwide box office
        top_movies = sorted(all_rows, key=lambda x: -int(x['Worldwide'].replace('$', '').replace(',', '')) if x['Worldwide'] != '$0' else 0)[:5]
        print(f"\n🏆 Top 5 movies by worldwide box office:")
        for i, movie in enumerate(top_movies, 1):
            print(f"  {i}. {movie['Title']} ({movie['Year']}) - {movie['Worldwide']}")
            
    else:
        print("❌ No data found to merge!")

if __name__ == "__main__":
    merge_boxoffice_files()