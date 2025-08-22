#!/usr/bin/env python3

import requests
from bs4 import BeautifulSoup
import re

HEADERS = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3"
}

def debug_page_structure(url):
    print(f"\n{'='*60}")
    print(f"DEBUGGING: {url}")
    print(f"{'='*60}")
    
    resp = requests.get(url, headers=HEADERS)
    soup = BeautifulSoup(resp.text, "html.parser")
    
    # Get title
    title_elem = soup.find("h1")
    print(f"TITLE: {title_elem.text.strip() if title_elem else 'NOT FOUND'}")
    
    print(f"\n--- LOOKING FOR SUMMARY SECTIONS ---")
    
    # Look for all divs that might contain box office data
    summary_divs = soup.find_all("div", class_=re.compile(r".*summary.*", re.I))
    print(f"Found {len(summary_divs)} divs with 'summary' in class name")
    
    for i, div in enumerate(summary_divs[:3]):  # Show first 3 only
        print(f"\nSummary Div {i+1}: {div.get('class', 'NO CLASS')}")
        # Look for spans with money values
        spans = div.find_all("span")
        for span in spans:
            text = span.get_text(strip=True)
            if "$" in text and "," in text:
                print(f"  Money span: {text}")
        
        # Look for any text with box office labels
        all_text = div.get_text(separator=" | ").lower()
        if any(keyword in all_text for keyword in ["domestic", "international", "worldwide", "foreign"]):
            print(f"  Contains box office keywords: {all_text[:200]}...")
    
    print(f"\n--- LOOKING FOR TABLES ---")
    tables = soup.find_all("table")
    print(f"Found {len(tables)} tables")
    
    for i, table in enumerate(tables[:2]):  # Show first 2 tables
        print(f"\nTable {i+1}:")
        rows = table.find_all("tr")
        for j, row in enumerate(rows[:5]):  # First 5 rows only
            cells = row.find_all(["td", "th"])
            if len(cells) >= 2:
                cell1 = cells[0].get_text(strip=True)
                cell2 = cells[1].get_text(strip=True)
                if "$" in cell2 or any(keyword in cell1.lower() for keyword in ["domestic", "international", "worldwide"]):
                    print(f"  Row {j+1}: {cell1} | {cell2}")
    
    print(f"\n--- ALL MONEY VALUES ON PAGE ---")
    # Find all elements containing money values
    money_pattern = re.compile(r'\$[\d,]+')
    all_text_elements = soup.find_all(string=money_pattern)
    
    money_values = set()
    for elem in all_text_elements:
        matches = money_pattern.findall(elem)
        for match in matches:
            # Clean the match and make sure it's valid
            clean_match = match.replace('$', '').replace(',', '')
            if clean_match.isdigit() and len(clean_match) > 3:  # Only values > $1,000
                money_values.add(match)
    
    sorted_money = sorted(list(money_values), key=lambda x: int(x.replace('$', '').replace(',', '')), reverse=True)
    print(f"Found {len(sorted_money)} unique money values:")
    for value in sorted_money[:10]:  # Show top 10
        print(f"  {value}")
    
    print(f"\n--- CONTEXT FOR TOP MONEY VALUES ---")
    # For the top 3 money values, try to find their context
    for value in sorted_money[:3]:
        elements = soup.find_all(string=re.compile(re.escape(value)))
        for elem in elements[:1]:  # Just first occurrence
            parent = elem.parent
            if parent:
                # Get surrounding context
                context = ""
                current = parent
                for _ in range(3):  # Go up 3 levels to find context
                    if current:
                        siblings_text = []
                        if current.parent:
                            for sibling in current.parent.find_all(text=True):
                                text = sibling.strip()
                                if text and not text.isspace():
                                    siblings_text.append(text)
                        if siblings_text:
                            context = " | ".join(siblings_text[:10])  # First 10 text nodes
                            break
                        current = current.parent
                
                print(f"  {value}: ...{context[:150]}...")

# Test on a few different movies
test_urls = [
    "https://www.boxofficemojo.com/release/rl3059975681/?ref_=bo_yld_table_1",  # Avengers Endgame 2019
    "https://www.boxofficemojo.com/release/rl3428288001/?ref_=bo_yld_table_23",  # Hairspray 2007
]

for url in test_urls:
    debug_page_structure(url)