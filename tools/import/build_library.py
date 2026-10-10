"""Builds Citadelle/Citadelle/Resources/hisn.json from its sources.

Sources:
- Arabic text, repetition counts and hadith references: asellam/HisnElMuslim
  (MIT License, (c) 2021 Abdellah SELLAM), https://github.com/asellam/HisnElMuslim
- chapters_fr.json: our own short French titles and search keywords,
  keyed by the book's official chapter number (1 to 132).
- hisnmuslim husn_en.json (optional third argument): only its per-dua audio
  URLs (recitation by Hamad Al-Durayhim, streamed from hisnmuslim.com), used
  where its chapter splits the duas exactly like the Arabic source.
- translit_fr.json (optional): our own French-alphabet transliterations.
- translations_fr.json (optional): our own French translations, made from the
  Arabic, keyed by dua id: {"text", "source" (reference in French), "note"?}.

Chapter ids follow the book's official numbering. The source splits morning
and evening remembrances, so evening gets its own chapter, EVENING_ID.
Dua ids are chapter id * 100 + position (e.g. 2703 is the 3rd dua of 27).

Usage: python3 -I build_library.py <asellam hisn.json> <output hisn.json> [husn_en.json]
"""
import json
import pathlib
import re
import sys

HERE = pathlib.Path(__file__).parent
EVENING_ID = 1027

CATEGORIES = [
    ("matin-soir", "Matin, soir et sommeil", "sun.horizon",
     [1, 27, EVENING_ID, 28, 29, 30, 31]),
    ("maison", "Maison et vêtements", "house", [10, 11, 2, 3, 4, 5, 6, 7]),
    ("priere", "Ablutions, mosquée et prière", "building.columns",
     [8, 9, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 32, 33, 42]),
    ("epreuves", "Épreuves et inquiétudes", "heart",
     [34, 35, 43, 46, 126, 122, 124, 82, 41, 36, 37, 38, 39, 40, 44, 45, 128, 125, 94, 92, 88]),
    ("maladie", "Maladie et décès", "bandage",
     [49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60]),
    ("nature", "Nature et météo", "cloud.sun.rain",
     [64, 63, 65, 66, 61, 62, 67, 132, 110, 111]),
    ("repas", "Repas et jeûne", "fork.knife", [69, 70, 68, 71, 72, 73, 74, 75, 76]),
    ("relations", "Famille et relations", "person.2",
     [77, 78, 108, 109, 87, 86, 93, 89, 113, 114, 112, 106, 123, 83, 84, 85,
      90, 91, 47, 48, 79, 80, 81]),
    ("voyage", "Voyage et déplacements", "car",
     [95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105]),
    ("hajj", "Hajj, Omra et sacrifice", "sparkles",
     [115, 116, 117, 118, 119, 120, 121, 127]),
    ("rappel", "Rappel d'Allah et repentir", "hands.sparkles", [107, 129, 130, 131]),
]

# Wording fixes on the generated titles: keep "vous" throughout.
TITLE_OVERRIDES = {
    27: "Évocations du matin",
    EVENING_ID: "Évocations du soir",
    86: "Réponse à « Qu'Allah vous pardonne »",
    89: "Quand on vous dit « je vous aime pour Allah »",
    90: "Quand on vous offre une part de ses biens",
    93: "Quand on vous dit « Barakallahu fik »",
    99: "Quand votre véhicule tombe en panne",
}
KEYWORD_OVERRIDES = {
    27: ["matin", "adhkar du matin", "azkar", "athkar", "dhikr", "rappel", "fajr", "aube"],
    EVENING_ID: ["soir", "adhkar du soir", "azkar", "athkar", "dhikr", "rappel", "asr", "maghrib"],
}


def official_chapter_id(position):
    """Source chapter position (1-based) to the book's chapter number."""
    if position <= 27:
        return position
    if position == 28:
        return EVENING_ID
    return position - 1


def clean_text(text):
    text = text.replace("*", "")
    lines = [re.sub(r"[ \t ]+", " ", line).strip() for line in text.splitlines()]
    return "\n".join(line for line in lines if line)


def https(url):
    return re.sub(r"^http://", "https://", url.strip()) if url else None


def per_dua_audio(recitations):
    """Official chapter id -> list of per-dua audio URLs, from husn_en.json."""
    if not recitations:
        return {}
    return {c["ID"]: [https(t.get("AUDIO")) for t in c["TEXT"]] for c in recitations["English"]}


def build(source, recitations=None):
    chapters_fr = {int(k): v for k, v in json.loads((HERE / "chapters_fr.json").read_text()).items()}
    translations_path = HERE / "translations_fr.json"
    translations = json.loads(translations_path.read_text()) if translations_path.exists() else {}
    translit_path = HERE / "translit_fr.json"
    transliterations = json.loads(translit_path.read_text()) if translit_path.exists() else {}
    dua_audio = per_dua_audio(recitations)

    category_of, order_of = {}, {}
    for category_id, _, _, chapter_ids in CATEGORIES:
        for order, chapter_id in enumerate(chapter_ids, 1):
            category_of[chapter_id] = category_id
            order_of[chapter_id] = order

    chapters, duas = [], []
    for position, (_, entry) in enumerate(source.items(), 1):
        chapter_id = official_chapter_id(position)
        info = chapters_fr.get(27 if chapter_id == EVENING_ID else chapter_id, {})
        recited = dua_audio.get(chapter_id, []) if chapter_id != EVENING_ID else []
        if len(recited) != len(entry["Adhkar"]):
            recited = []  # different split: per-dua audio would not line up
        chapters.append({
            "id": chapter_id,
            "audio": https(entry.get("Audio")),
            "categoryId": category_of[chapter_id],
            "order": order_of[chapter_id],
            "title": {"fr": TITLE_OVERRIDES.get(chapter_id, info.get("titleFrShort", ""))},
            "keywords": {"fr": KEYWORD_OVERRIDES.get(chapter_id, info.get("keywordsFr", []))},
        })
        for index, adhkar in enumerate(entry["Adhkar"], 1):
            dua_id = chapter_id * 100 + index
            french = translations.get(str(dua_id), {})
            dua = {
                "id": dua_id,
                "chapterId": chapter_id,
                "order": index,
                "arabic": clean_text(adhkar["Text"]),
                "translation": {"fr": french["text"]} if french.get("text") else {},
                "repeatCount": max(1, int(adhkar.get("Count") or 1)),
                # The French rendering of the reference when we have one,
                # otherwise the original Arabic reference.
                "source": french.get("source") or clean_text(adhkar.get("Reference", "")),
            }
            if french.get("note"):
                dua["note"] = {"fr": french["note"]}
            if transliterations.get(str(dua_id), "").strip():
                dua["transliteration"] = {"fr": transliterations[str(dua_id)].strip()}
            if recited and recited[index - 1]:
                dua["audio"] = recited[index - 1]
            duas.append(dua)

    return {
        "version": 2,
        "categories": [
            {"id": cid, "order": i, "icon": icon, "title": {"fr": title}}
            for i, (cid, title, icon, _) in enumerate(CATEGORIES, 1)
        ],
        "chapters": chapters,
        "duas": duas,
    }


if __name__ == "__main__":
    source = json.loads(pathlib.Path(sys.argv[1]).read_text(encoding="utf-8-sig"))
    recitations = None
    if len(sys.argv) > 3:
        recitations = json.loads(pathlib.Path(sys.argv[3]).read_text(encoding="utf-8-sig"))
    library = build(source, recitations)
    pathlib.Path(sys.argv[2]).write_text(json.dumps(library, ensure_ascii=False, indent=1) + "\n")
    print(f"{len(library['categories'])} categories, {len(library['chapters'])} chapters, "
          f"{len(library['duas'])} duas, "
          f"{sum(1 for d in library['duas'] if d['translation'])} translated, "
          f"{sum(1 for d in library['duas'] if d.get('transliteration'))} transliterated, "
          f"{sum(1 for d in library['duas'] if d.get('audio'))} with their own audio")
