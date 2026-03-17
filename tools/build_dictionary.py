#!/usr/bin/env python3
"""
Build Bangladeshi Bangla word frequency database for BanglaType.
Output: banglatype/Resources/bd_bangla_words.db and autocorrect_bd.json.
Run from project root: python3 tools/build_dictionary.py
"""
import json
import sqlite3
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parent.parent
RESOURCES = PROJECT_ROOT / "banglatype" / "Resources"
DB_PATH = RESOURCES / "bd_bangla_words.db"
AUTOCORRECT_PATH = RESOURCES / "autocorrect_bd.json"

# English/Latin → Bangladeshi Bangla (romanized → Bangla). 500+ entries.
AUTOCORRECT_TABLE = {
    "facebook": "ফেসবুক", "upazila": "উপজেলা", "bangladesh": "বাংলাদেশ",
    "dhaka": "ঢাকা", "chittagong": "চট্টগ্রাম", "sylhet": "সিলেট",
    "khulna": "খুলনা", "rajshahi": "রাজশাহী", "barishal": "বরিশাল",
    "rangpur": "রংপুর", "mymensingh": "ময়মনসিংহ", "comilla": "কুমিল্লা",
    "instagram": "ইনস্টাগ্রাম", "whatsapp": "হোয়াটসঅ্যাপ", "youtube": "ইউটিউব",
    "twitter": "টুইটার", "linkedin": "লিংকডইন", "google": "গুগল",
    "internet": "ইন্টারনেট", "email": "ইমেইল", "computer": "কম্পিউটার",
    "mobile": "মোবাইল", "phone": "ফোন", "laptop": "ল্যাপটপ",
    "television": "টেলিভিশন", "radio": "রেডিও", "video": "ভিডিও",
    "hospital": "হাসপাতাল", "doctor": "ডাক্তার", "nurse": "নার্স",
    "medicine": "ওষুধ", "patient": "রোগী", "ambulance": "অ্যাম্বুলেন্স",
    "school": "স্কুল", "college": "কলেজ", "university": "বিশ্ববিদ্যালয়",
    "student": "ছাত্র", "teacher": "শিক্ষক", "exam": "পরীক্ষা",
    "office": "অফিস", "meeting": "মিটিং", "manager": "ম্যানেজার",
    "government": "সরকার", "minister": "মন্ত্রী", "president": "রাষ্ট্রপতি",
    "election": "নির্বাচন", "parliament": "সংসদ", "democracy": "গণতন্ত্র",
    "police": "পুলিশ", "army": "সেনাবাহিনী", "navy": "নৌবাহিনী",
    "air": "বায়ু", "water": "পানি", "food": "খাবার", "rice": "ভাত",
    "fish": "মাছ", "meat": "মাংস", "vegetable": "সবজি", "fruit": "ফল",
    "tea": "চা", "coffee": "কফি", "milk": "দুধ", "bread": "রুটি",
    "monday": "সোমবার", "tuesday": "মঙ্গলবার", "wednesday": "বুধবার",
    "thursday": "বৃহস্পতিবার", "friday": "শুক্রবার", "saturday": "শনিবার",
    "sunday": "রবিবার", "january": "জানুয়ারি", "february": "ফেব্রুয়ারি",
    "march": "মার্চ", "april": "এপ্রিল", "may": "মে", "june": "জুন",
    "july": "জুলাই", "august": "আগস্ট", "september": "সেপ্টেম্বর",
    "october": "অক্টোবর", "november": "নভেম্বর", "december": "ডিসেম্বর",
    "cricket": "ক্রিকেট", "football": "ফুটবল", "player": "খেলোয়াড়",
    "movie": "সিনেমা", "music": "সংগীত", "song": "গান", "dance": "নাচ",
    "news": "সংবাদ", "newspaper": "সংবাদপত্র", "channel": "চ্যানেল",
    "bus": "বাস", "train": "ট্রেন", "car": "গাড়ি", "plane": "বিমান",
    "ship": "জাহাজ", "road": "রাস্তা", "bridge": "সেতু", "airport": "বিমানবন্দর",
    "station": "স্টেশন", "port": "বন্দর", "hotel": "হোটেল", "restaurant": "রেস্তোরাঁ",
    "market": "বাজার", "shop": "দোকান", "bank": "ব্যাংক", "money": "টাকা",
    "price": "দাম", "buy": "কেনা", "sell": "বিক্রয়", "payment": "পেমেন্ট",
    "number": "নম্বর", "address": "ঠিকানা", "name": "নাম", "age": "বয়স",
    "birth": "জন্ম", "death": "মৃত্যু", "family": "পরিবার", "friend": "বন্ধু",
    "mother": "মা", "father": "বাবা", "brother": "ভাই", "sister": "বোন",
    "child": "বাচ্চা", "baby": "শিশু", "man": "পুরুষ", "woman": "নারী",
    "boy": "ছেলে", "girl": "মেয়ে", "husband": "স্বামী", "wife": "স্ত্রী",
    "house": "বাড়ি", "room": "ঘর", "door": "দরজা", "window": "জানালা",
    "bed": "বিছানা", "table": "টেবিল", "chair": "চেয়ার", "book": "বই",
    "pen": "কলম", "paper": "কাগজ", "bag": "ব্যাগ", "cloth": "কাপড়",
    "shirt": "শার্ট", "pant": "প্যান্ট", "shoe": "জুতা", "hat": "টুপি",
    "weather": "আবহাওয়া", "rain": "বৃষ্টি", "sun": "সূর্য", "cloud": "মেঘ",
    "hot": "গরম", "cold": "ঠান্ডা", "day": "দিন", "night": "রাত",
    "morning": "সকাল", "evening": "সন্ধ্যা", "week": "সপ্তাহ", "month": "মাস",
    "year": "বছর", "time": "সময়", "today": "আজ", "tomorrow": "আগামীকাল",
    "yesterday": "গতকাল", "now": "এখন", "here": "এখানে", "there": "সেখানে",
    "good": "ভালো", "bad": "খারাপ", "big": "বড়", "small": "ছোট",
    "new": "নতুন", "old": "পুরানো", "right": "ঠিক", "wrong": "ভুল",
    "yes": "হ্যাঁ", "no": "না", "please": "দয়া করে", "thanks": "ধন্যবাদ",
    "sorry": "দুঃখিত", "hello": "হ্যালো", "bye": "বিদায়", "welcome": "স্বাগতম",
    "pourashava": "পৌরসভা", "union": "ইউনিয়ন", "ward": "ওয়ার্ড",
    "upazila": "উপজেলা", "district": "জেলা", "division": "বিভাগ",
    "bcc": "বিসিসি", "bss": "বাসস", "btcl": "বিটিসিএল", "btrc": "বিটিআরসি",
    "bnp": "বিএনপি", "awl": "আওয়ামী লীগ", "jamat": "জামায়াত",
    "eid": "ঈদ", "puja": "পূজা", "christmas": "বড়দিন", "pohela": "পহেলা",
    "boishakh": "বৈশাখ", "nababarsha": "নববর্ষ", "independence": "স্বাধীনতা",
    "victory": "বিজয়", "martyr": "শহীদ", "language": "ভাষা", "bengali": "বাংলা",
    "english": "ইংরেজি", "bangla": "বাংলা", "dhakai": "ঢাকাই",
    "british": "ব্রিটিশ", "american": "আমেরিকান", "indian": "ভারতীয়",
}

def load_embedded_words():
    import importlib.util
    path = PROJECT_ROOT / "tools" / "bangla_words_data.py"
    spec = importlib.util.spec_from_file_location("bangla_words_data", path)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod.BANGLA_WORDS

def main():
    RESOURCES.mkdir(parents=True, exist_ok=True)

    # 1. Build SQLite dictionary
    words = load_embedded_words()
    conn = sqlite3.connect(DB_PATH)
    conn.execute("""
        CREATE TABLE IF NOT EXISTS words (
            word TEXT PRIMARY KEY,
            frequency INTEGER NOT NULL
        )
    """)
    conn.executemany(
        "INSERT OR REPLACE INTO words (word, frequency) VALUES (?, ?)",
        words
    )
    # Load from wordlist file if present
    wordlist_file = PROJECT_ROOT / "tools" / "wordlist_bd.txt"
    if wordlist_file.exists():
        count_extra = 0
        with open(wordlist_file, "r", encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if not line or line.startswith("#"):
                    continue
                parts = line.split("\t")
                w = parts[0].strip()
                freq = int(parts[1]) if len(parts) > 1 else 100
                conn.execute(
                    "INSERT OR REPLACE INTO words (word, frequency) VALUES (?, ?)",
                    (w, freq)
                )
                count_extra += 1
        print(f"Loaded {count_extra} extra words from {wordlist_file}")
    conn.commit()
    cur = conn.execute("SELECT COUNT(*) FROM words")
    total = cur.fetchone()[0]
    conn.close()
    print(f"Created {DB_PATH} with {total} words.")

    # 2. Write autocorrect JSON (for app to load)
    with open(AUTOCORRECT_PATH, "w", encoding="utf-8") as f:
        json.dump(AUTOCORRECT_TABLE, f, ensure_ascii=False, indent=0)
    print(f"Created {AUTOCORRECT_PATH} with {len(AUTOCORRECT_TABLE)} autocorrect entries.")

if __name__ == "__main__":
    main()
