#!/usr/bin/env python3
"""Refresh the offline snapshot bundled with the app.

Downloads the public MMC API (events, speakers, programs), trims fields the
app doesn't use, and writes assets/data/mmc_snapshot.json.

Usage (from the project root):
    python tool/update_snapshot.py
    python tool/update_snapshot.py --base https://moroccomicrosoftcommunity.com/api
"""
import argparse
import datetime as dt
import json
import pathlib
import re
import urllib.request

ROOT = pathlib.Path(__file__).resolve().parent.parent
OUT = ROOT / "assets" / "data" / "mmc_snapshot.json"


def get(base: str, path: str):
    req = urllib.request.Request(f"{base.rstrip('/')}/{path}",
                                 headers={"Accept": "application/json",
                                          "User-Agent": "mmc-mobile-snapshot"})
    with urllib.request.urlopen(req, timeout=60) as r:
        return json.loads(r.read().decode("utf-8"))


def strip_html(html: str) -> str:
    s = re.sub(r"<br\s*/?>", "\n", html or "", flags=re.I)
    s = re.sub(r"</(p|li|h\d)>", "\n", s, flags=re.I)
    s = re.sub(r"<li[^>]*>", "• ", s, flags=re.I)
    s = re.sub(r"<[^>]+>", "", s)
    s = s.replace("&nbsp;", " ").replace("&amp;", "&").replace("&#39;", "'")
    s = re.sub(r"[ \t]+\n", "\n", s)
    return re.sub(r"\n{3,}", "\n\n", s).strip()


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--base", default="https://moroccomicrosoftcommunity.com/api")
    args = ap.parse_args()

    events = [e for e in get(args.base, "events") if e.get("status", "published") == "published"]
    speakers = get(args.base, "speakers")
    programs = get(args.base, "programs")

    events.sort(key=lambda e: (e.get("date") or "") + (e.get("time") or ""), reverse=True)
    slim_events = [{
        "id": e["id"], "title": (e.get("title") or "").strip(), "slug": e.get("slug"),
        "description": strip_html(e.get("description"))[:1200],
        "date": e.get("date"), "endDate": e.get("endDate"), "time": e.get("time"),
        "location": (e.get("location") or "").strip(), "city": (e.get("city") or "").strip(),
        "isOnline": e.get("isOnline"), "coverMediaUrl": e.get("coverMediaUrl"),
        "registrationMode": e.get("registrationMode"),
        "externalRegistrationUrl": e.get("externalRegistrationUrl"),
        "programId": e.get("programId"), "isFeatured": e.get("isFeatured"),
        "media": [{"type": m.get("type"), "url": m.get("url"), "thumbnail": m.get("thumbnail")}
                  for m in (e.get("media") or []) if m.get("url")][:4],
        "speakers": [{"id": s["id"], "sessionTitle": s.get("sessionTitle"),
                      "sessionDuration": s.get("sessionDuration")} for s in (e.get("speakers") or [])],
        "partners": [p.get("name") for p in (e.get("partners") or []) if p.get("name")],
        "club": ({"name": e["club"].get("name"), "university": e["club"].get("university"),
                  "city": e["club"].get("city")} if e.get("club") else None),
    } for e in events]
    slim_speakers = [{k: s.get(k) for k in ("id", "name", "slug", "title", "bio", "avatar", "social")}
                     for s in speakers]
    slim_programs = [{k: p.get(k) for k in ("id", "name", "description", "image", "order",
                                             "isCommunityProgram")} for p in programs]

    out = {
        "_meta": {
            "source": args.base,
            "exportedAt": dt.datetime.now(dt.timezone.utc).isoformat().replace("+00:00", "Z"),
            "note": "Offline snapshot of the official MMC API. Regenerate with tool/update_snapshot.py.",
        },
        "events": slim_events, "speakers": slim_speakers, "programs": slim_programs,
    }
    OUT.write_text(json.dumps(out, ensure_ascii=False, separators=(",", ":")), encoding="utf-8")
    print(f"Wrote {OUT.relative_to(ROOT)}: {len(slim_events)} events, "
          f"{len(slim_speakers)} speakers, {len(slim_programs)} programs "
          f"({OUT.stat().st_size // 1024} KB)")


if __name__ == "__main__":
    main()
