#!/usr/bin/env python3

"""
Simple Python script to analyze the Oscar CSV data for 2000s-2010s without Flutter dependencies
"""

import csv
import sys
import os

def analyze_oscar_csv():
    csv_path = "assets/data/oscar_nominee.csv"
    
    if not os.path.exists(csv_path):
        print(f"ERROR: CSV file not found at {csv_path}")
        return
    
    print(f"Reading CSV data from: {csv_path}")
    
    decade_counts = {}
    year_samples = {}
    total_records = 0
    
    try:
        with open(csv_path, 'r', encoding='utf-8') as file:
            reader = csv.DictReader(file)
            fieldnames = reader.fieldnames
            print(f"CSV columns: {fieldnames}")
            
            for row in reader:
                total_records += 1
                
                # Get year and handle "1927/28" format
                year_str = row.get('Year', '').strip()
                if not year_str:
                    continue
                    
                # Handle slash format like "1927/28" 
                if '/' in year_str:
                    year = int(year_str.split('/')[0])
                else:
                    year = int(year_str)
                
                # Calculate decade
                decade = (year // 10) * 10
                
                if decade not in decade_counts:
                    decade_counts[decade] = 0
                    year_samples[decade] = []
                
                decade_counts[decade] += 1
                
                # Keep samples for debugging
                if len(year_samples[decade]) < 3:
                    year_samples[decade].append({
                        'year': year,
                        'year_ceremony': row.get('Ceremony', ''),
                        'category': row.get('Category', ''),
                        'name': row.get('Name', '')[:50] + '...' if len(row.get('Name', '')) > 50 else row.get('Name', '')
                    })
        
        print(f"\nTotal records processed: {total_records}")
        print("\n=== DECADE BREAKDOWN ===")
        
        for decade in sorted(decade_counts.keys()):
            print(f"{decade}s: {decade_counts[decade]} records")
            for sample in year_samples[decade]:
                print(f"  - {sample['year']} ({sample['year_ceremony']}) {sample['category']} - {sample['name']}")
        
        print(f"\n=== SPECIFIC DECADES ===")
        print(f"2000s (2000-2009): {decade_counts.get(2000, 0)} records")
        print(f"2010s (2010-2019): {decade_counts.get(2010, 0)} records")
        print(f"1990s (1990-1999): {decade_counts.get(1990, 0)} records")
        print(f"2020s (2020-2029): {decade_counts.get(2020, 0)} records")
        
        # Check if 2000s/2010s data exists
        has_2000s = decade_counts.get(2000, 0) > 0
        has_2010s = decade_counts.get(2010, 0) > 0
        
        print(f"\n=== ANALYSIS ===")
        print(f"2000s data present: {has_2000s}")
        print(f"2010s data present: {has_2010s}")
        
        if has_2000s and has_2010s:
            print("✓ Both 2000s and 2010s data found in CSV")
        else:
            print("⚠️  Missing 2000s or 2010s data in CSV")
    
    except Exception as e:
        print(f"ERROR: Failed to read CSV: {e}")

if __name__ == "__main__":
    analyze_oscar_csv()