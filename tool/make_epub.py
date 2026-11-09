"""Builds assets/books/the-salt-road.epub, a small valid EPUB 3 used by the reader.

Run from the repo root: python3 tool/make_epub.py
The text is original sample prose written for this demo.
"""
import zipfile, html

TITLE = "The Salt Road"
AUTHOR = "Imogen Hale"
CHAPTERS = [
    ("The Well", [
        "The well at the edge of Harrow Flats was older than the town, and the town was older than anyone could remember. Nadia had drawn water from it every morning since she was tall enough to lean over the stone lip.",
        "That spring the rope came up dry. Her father lowered a lantern on a cord and they watched the small light sink past the green moss, past the old iron rings, until it touched cracked mud and went still.",
        "\"The salt has moved,\" he said, as if the salt were a herd that wandered. In a way it was. Every few generations the flats breathed out, and the water went somewhere else.",
        "By evening the town council had decided what the town always decided. The caravan would cross to Oakhaven before the summer heat, trade salt for grain, and ask the river people for a share of their wells.",
        "Nobody said aloud that the river people had not spoken to Harrow in eleven years. Nobody had to.",
        "Nadia sat on the well's lip until the stars came out, counting the cracks in the mud the way other children counted sheep, and wondering how a whole town could be thirsty in a place made of water that had simply dried.",
    ]),
    ("Salt and Dust", [
        "The caravan left before dawn, when the salt still held the cold of the night. Nadia walked beside the third camel, counting the bells the way her father had taught her: seven brass, three tin, each ringing a half-beat behind the stride.",
        "Across the white basin of the flats nothing cast a shadow except their own slow march against the fading stars. The crust crunched beneath her boots, brittle as glazed sugar, ready to give way to the dark brine waiting underneath.",
        "Inside the heavy wool of her travelling coat, the sealed letter pressed against her collarbone. A salt trader's daughter was not supposed to carry letters between towns that no longer spoke, yet here she was, her pulse thumping against the paper.",
        "A dry wind rose off the eastern hills as the horizon turned from plum to pale apricot. It tasted of old seas and bitter rosemary. She pulled her linen veil over her mouth and watched the lead scout raise his arm to signal the morning descent.",
        "Three days remained before they would reach the terraced gates of Oakhaven. Three days to decide whether the letter stayed hidden, or burned to ash in the evening fires.",
        "At midday they rested in the shade of the salt stacks, and old Imre told the story of the year the flats flooded and the whole caravan floated home on rafts of reeds. Nobody believed him. Everybody asked him to tell it again.",
        "When the bells started again, Nadia found she had stopped counting them. The road had a rhythm of its own now, and she let it carry her.",
    ]),
    ("Night Market", [
        "Oakhaven's night market opened when the heat broke, lanterns strung between the terraces like a second set of stars. The caravan unloaded in the lower square, and within an hour the salt was stacked, weighed and argued over.",
        "Nadia slipped away while her father bargained. She followed the smell of bread up three flights of stone steps to a stall where a woman with flour on her sleeves was folding dough into knots.",
        "\"You're from the flats,\" the woman said, without looking up. \"You walk like the ground might break.\"",
        "\"It might,\" said Nadia. \"Where I'm from.\"",
        "The woman laughed and handed her a warm knot of bread. Her name was Wren, and her brother kept the river gate, and yes, she remembered Harrow, and no, she did not think the river people had forgotten anything at all.",
        "Nadia touched the letter through her coat and said nothing. Above them the lanterns swayed, and somewhere below a fiddler started a tune her mother used to hum.",
    ]),
    ("The River Gate", [
        "The river gate was smaller than the stories made it. Two posts of black oak, a chain, and a man asleep on a stool with a hat over his face.",
        "Wren kicked the stool. Her brother woke, saw the girl from the flats, and sat up very straight.",
        "Nadia took out the letter. The wax had softened in the heat of the road and the seal of Harrow had blurred into a thumbprint, but the words inside had not changed in eleven years. Her grandmother had written them and never sent them.",
        "The gatekeeper read it twice. Then he unhooked the chain, and the sound it made against the post was the first quiet thing Nadia had heard since the well ran dry.",
        "\"Bring your barrels in the morning,\" he said. \"And bring your grandmother's apology to the council yourself. It will mean more from someone who walked it here.\"",
    ]),
]

def xhtml(title, body):
    return f'''<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:epub="http://www.idpf.org/2007/ops" lang="en">
<head><title>{html.escape(title)}</title></head>
<body>{body}</body>
</html>'''

def build(path="assets/books/the-salt-road.epub"):
    with zipfile.ZipFile(path, "w") as z:
        z.writestr(zipfile.ZipInfo("mimetype"), "application/epub+zip", compress_type=zipfile.ZIP_STORED)
        z.writestr("META-INF/container.xml", '''<?xml version="1.0"?>
<container version="1.0" xmlns="urn:oasis:names:tc:opendocument:xmlns:container">
  <rootfiles><rootfile full-path="OEBPS/content.opf" media-type="application/oebps-package+xml"/></rootfiles>
</container>''', compress_type=zipfile.ZIP_DEFLATED)
        items, spine, nav = [], [], []
        for i, (name, paras) in enumerate(CHAPTERS, 1):
            body = f"<section epub:type=\"chapter\"><h2>Chapter {i} - {html.escape(name)}</h2>" + "".join(f"<p>{html.escape(p)}</p>" for p in paras) + "</section>"
            z.writestr(f"OEBPS/ch{i}.xhtml", xhtml(name, body), compress_type=zipfile.ZIP_DEFLATED)
            items.append(f'<item id="ch{i}" href="ch{i}.xhtml" media-type="application/xhtml+xml"/>')
            spine.append(f'<itemref idref="ch{i}"/>')
            nav.append(f'<li><a href="ch{i}.xhtml">{html.escape(name)}</a></li>')
        z.writestr("OEBPS/nav.xhtml", xhtml("Contents", '<nav epub:type="toc"><ol>' + "".join(nav) + "</ol></nav>"), compress_type=zipfile.ZIP_DEFLATED)
        z.writestr("OEBPS/content.opf", f'''<?xml version="1.0" encoding="utf-8"?>
<package xmlns="http://www.idpf.org/2007/opf" version="3.0" unique-identifier="bookid">
  <metadata xmlns:dc="http://purl.org/dc/elements/1.1/">
    <dc:identifier id="bookid">urn:uuid:7c1d2f0a-5a1e-4c8e-9b7d-salt-road-0001</dc:identifier>
    <dc:title>{TITLE}</dc:title>
    <dc:creator>{AUTHOR}</dc:creator>
    <dc:language>en</dc:language>
    <meta property="dcterms:modified">2026-11-01T00:00:00Z</meta>
  </metadata>
  <manifest>
    <item id="nav" href="nav.xhtml" media-type="application/xhtml+xml" properties="nav"/>
    {"".join(items)}
  </manifest>
  <spine>{"".join(spine)}</spine>
</package>''', compress_type=zipfile.ZIP_DEFLATED)

if __name__ == "__main__":
    build()
    print("wrote assets/books/the-salt-road.epub")
