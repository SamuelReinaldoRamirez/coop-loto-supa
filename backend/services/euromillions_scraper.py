import re
from datetime import datetime

import requests
from bs4 import BeautifulSoup


EUROMILLIONS_URL = (
    "https://www.tirage-euromillions.net/"
    "euromillions/annees/annee-2026/"
)


def scrape_latest_euromillions_draw():
    response = requests.get(
        EUROMILLIONS_URL,
        timeout=10,
        headers={
            "User-Agent": (
                "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
                "AppleWebKit/537.36 "
                "(KHTML, like Gecko) "
                "Chrome/140.0 Safari/537.36"
            )
        },
    )

    response.raise_for_status()

    soup = BeautifulSoup(response.text, "html.parser")

    container = soup.find("div", id="multi-draws-by-year")
    if container is None:
        raise RuntimeError("Impossible de trouver le conteneur des tirages.")

    table = container.find("table")
    if table is None:
        raise RuntimeError("Impossible de trouver le tableau des tirages.")

    tbody = table.find("tbody")
    if tbody is None:
        raise RuntimeError("Impossible de trouver le tbody du tableau.")

    rows = tbody.find_all("tr")

    for row in rows:
        cells = row.find_all("td")

        # Ignore les lignes "Septembre 2026", etc.
        if len(cells) != 4:
            continue

        # -----------------------------
        # Date : "Vendredi 18/09/2026"
        # -> datetime.date(2026, 9, 18)
        # -----------------------------
        date_text = cells[0].get_text(" ", strip=True)
        date_str = date_text.split()[-1]
        draw_date = datetime.strptime(
            date_str,
            "%d/%m/%Y",
        ).date()

        draw_cell = cells[1]

        number_balls = draw_cell.find_all("span", class_="ball_small")
        star_balls = draw_cell.find_all("span", class_="star_small")

        # Ignore les tirages non publiés
        if len(number_balls) != 5 or len(star_balls) != 2:
            continue

        numbers = [
            int(ball.get_text(strip=True))
            for ball in number_balls
        ]

        stars = [
            int(ball.get_text(strip=True))
            for ball in star_balls
        ]

        if len(numbers) != 5 or len(stars) != 2:
            continue

        winners_text = cells[2].get_text(" ", strip=True)
        jackpot_text = cells[3].get_text(" ", strip=True)

        # "0" -> 0
        winners = int(
            re.sub(r"\D", "", winners_text) or "0"
        )

        # "28 392 426 €" -> 28392426
        jackpot = int(
            re.sub(r"\D", "", jackpot_text)
        )

        return {
            "draw_date": draw_date,
            "n1": numbers[0],
            "n2": numbers[1],
            "n3": numbers[2],
            "n4": numbers[3],
            "n5": numbers[4],
            "e1": stars[0],
            "e2": stars[1],
            "winners": winners,
            "jackpot": jackpot,
        }

    raise RuntimeError("Aucun tirage EuroMillions complet trouvé.")

# def scrape_latest_euromillions_draw():
#     response = requests.get(
#         EUROMILLIONS_URL,
#         timeout=10,
#         headers={
#             "User-Agent": (
#                 "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
#                 "AppleWebKit/537.36 "
#                 "(KHTML, like Gecko) "
#                 "Chrome/140.0 Safari/537.36"
#             )
#         },
#     )

#     response.raise_for_status()

#     soup = BeautifulSoup(response.text, "html.parser")

#     container = soup.find(
#         "div",
#         id="multi-draws-by-year",
#     )

#     if container is None:
#         raise RuntimeError(
#             "Impossible de trouver le conteneur des tirages."
#         )

#     table = container.find("table")

#     if table is None:
#         raise RuntimeError(
#             "Impossible de trouver le tableau des tirages."
#         )

#     tbody = table.find("tbody")

#     if tbody is None:
#         raise RuntimeError(
#             "Impossible de trouver le tbody du tableau."
#         )

#     rows = tbody.find_all("tr")

#     for row in rows:
#         cells = row.find_all("td")

#         # Les lignes contenant uniquement le nom du mois
#         # ne sont pas des tirages.
#         if len(cells) != 4:
#             continue

#         date_cell = cells[0]
#         draw_cell = cells[1]

#         # Récupération de la date
#         date = date_cell.get_text(
#             " ",
#             strip=True,
#         )

#         # Récupération des boules
#         number_balls = draw_cell.find_all(
#             "span",
#             class_="ball_small",
#         )

#         star_balls = draw_cell.find_all(
#             "span",
#             class_="star_small",
#         )

#         # Un tirage complet doit avoir :
#         # 5 numéros + 2 étoiles
#         if len(number_balls) != 5 or len(star_balls) != 2:
#             continue

#         numbers = [
#             ball.get_text(strip=True)
#             for ball in number_balls
#         ]

#         stars = [
#             star.get_text(strip=True)
#             for star in star_balls
#         ]

#         # Si les spans existent mais sont vides,
#         # le tirage n'est pas encore disponible.
#         if not all(numbers) or not all(stars):
#             continue

#         jackpot = cells[3].get_text(
#             " ",
#             strip=True,
#         )

#         winners = cells[2].get_text(
#             " ",
#             strip=True,
#         )

#         return {
#             "date": date,
#             "numbers": numbers,
#             "stars": stars,
#             "winners": winners,
#             "jackpot": jackpot,
#         }

#     raise RuntimeError(
#         "Aucun tirage EuroMillions complet trouvé."
#     )