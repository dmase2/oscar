import requests
from bs4 import BeautifulSoup
import csv
import time

BASE_URL = "https://www.boxofficemojo.com"
YEAR_URL = f"{BASE_URL}/year/2024/"
HEADERS = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3"
}


def get_movie_links():
    resp = requests.get(YEAR_URL, headers=HEADERS)
    soup = BeautifulSoup(resp.text, "html.parser")
    table = soup.find("table")
    links = []
    if table:
        for row in table.find_all("tr")[1:]:
            a = row.find("a")
            if a and a.get("href", "").startswith("/release/"):
                links.append(BASE_URL + a["href"])
    return links


def get_box_office(url):
    resp = requests.get(url, headers=HEADERS)
    soup = BeautifulSoup(resp.text, "html.parser")
    title = soup.find("h1").text.strip() if soup.find("h1") else ""
    domestic = ""
    worldwide = ""
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
    return title, domestic, worldwide


def main():
    links = get_movie_links()
    print(f"Found {len(links)} movies for 2024.")
    with open("boxoffice_2024.csv", "w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow(["Title", "Domestic", "Worldwide", "URL"])
        for url in links[:25]:
            title, domestic, worldwide = get_box_office(url)
            print(f"{title}: Domestic={domestic}, Worldwide={worldwide}")
            writer.writerow([title, domestic, worldwide, url])
            time.sleep(1)  # Be polite to the server

if __name__ == "__main__":
    main()
