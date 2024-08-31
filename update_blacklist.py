import os
import json
import urllib.request
from enum import Enum


class UpdateUrl(Enum):
    CT = "https://reestr.rublacklist.net/api/v3/ct-domains/"
    DPI = "https://reestr.rublacklist.net/api/v3/dpi/"


class Blacklist:
    def __init__(self, url: UpdateUrl):
        self.url = url.value
        self.domains = set()

    def update(self, file_path):
        self.domains = self._get_domain_list()
        existing_domains = self._load_existing_domains(file_path)
        new_domains = self.domains - existing_domains
        if new_domains:
            self._save_domains(file_path, new_domains)
        else:
            print("No new domains to add.")

    def _get_domain_list(self):
        json_data = self._http_request(self.url)
        if self.url == UpdateUrl.DPI.value:
            return self._extract_dpi_domains(json_data)
        elif self.url == UpdateUrl.CT.value:
            return self._extract_ct_domains(json_data)

    def _http_request(self, url):
        headers = {
            "Content-Type": "application/json",
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3",
        }
        request = urllib.request.Request(url, headers=headers)
        with urllib.request.urlopen(request) as response:
            data = response.read()
            json_data = json.loads(data.decode("utf-8"))
            return json_data

    def _extract_dpi_domains(self, json_data):
        domains = set()
        for entry in json_data:
            domains.update(entry.get("domains", []))
        return domains

    def _extract_ct_domains(self, json_data):
        return set(json_data)

    def _load_existing_domains(self, file_path):
        if not os.path.exists(file_path):
            return set()
        with open(file_path, "r") as file:
            return set(line.strip() for line in file)

    def _save_domains(self, file_path, domains):
        with open(file_path, "a") as file:
            for domain in sorted(domains):
                file.write(f"{domain}\n")
        print(f"Added {len(domains)} new domains to {file_path}.")


def main():
    print("Выберите список доменов, который хотите обновить:")
    print("  1. Домены используемые в Censor Tracker")
    print("  2. Домены заблокированные ТСПУ")

    choice = input("Введите число от 1 до 2: ")

    while True:
        if choice == "1":
            blacklist = Blacklist(UpdateUrl.CT)
            file_path = "blacklist-ct.txt"
            break
        elif choice == "2":
            blacklist = Blacklist(UpdateUrl.DPI)
            file_path = "blacklist-dpi.txt"
            break
        else:
            print("Некорректный выбор")

    blacklist.update(file_path)


if __name__ == "__main__":
    main()
