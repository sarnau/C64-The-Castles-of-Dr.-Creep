#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Render every sprite the game uses into a single images/sprite.png sheet.

Sprite data comes from Creep Sourcecode/inc/CC_DataSprites.asm. Each sprite is a
3-byte header (cols-in-bytes, rows, "look") followed by cols*rows bitmap bytes.
The look byte: bit4=0 -> multicolor, bits3-0 -> the sprite's individual colour.
Multicolor sprites decode as bit-pairs 00=transparent, 01=SPMC0 ($D025=LT_RED),
10=individual colour, 11=SPMC1 ($D026=LT_GREEN); each MC pixel is 2 hi-res wide.
Hi-res sprites (bit4=1) are 1 bit/pixel in the individual colour.
"""
import os
import re
from PIL import Image, ImageDraw, ImageFont

REPO = os.path.dirname(os.path.abspath(__file__))
SPRITES = os.path.join(REPO, "Creep Sourcecode", "inc", "CC_DataSprites.asm")
OUT = os.path.join(REPO, "images", "sprite.png")

C64 = [(0, 0, 0), (255, 255, 255), (129, 51, 56), (117, 206, 200),
       (142, 60, 151), (86, 172, 77), (46, 44, 155), (237, 241, 113),
       (142, 80, 41), (85, 56, 0), (196, 108, 113), (74, 74, 74),
       (123, 123, 123), (169, 255, 159), (112, 109, 235), (178, 178, 178)]
NAME = {'BLACK': 0, 'WHITE': 1, 'RED': 2, 'CYAN': 3, 'PURPLE': 4, 'GREEN': 5,
        'BLUE': 6, 'YELLOW': 7, 'ORANGE': 8, 'BROWN': 9, 'LT_RED': 10,
        'DK_GREY': 11, 'GREY': 12, 'LT_GREEN': 13, 'LT_BLUE': 14, 'LT_GREY': 15}

SPMC0 = NAME['LT_RED']      # $D025 -> bit-pair 01 (CC_MultiColor1Players)
SPMC1 = NAME['LT_GREEN']    # $D026 -> bit-pair 11 (CC_MultiColor2Players)

# look symbol -> look byte (CC_DataSprites.asm header). multicolor if bit4 clear.
LOOKS = {
    'CC_PlayerLook': NAME['YELLOW'],
    'CC_BeamLook': NAME['RED'],
    'CC_FrankLook': NAME['GREY'],
    'CC_MummyLook': 0x10 | NAME['WHITE'],
    'CC_ArrowLook': 0x10 | 0x20 | NAME['BLACK'],
    'CC_SparkLook': 0x10 | 0x20 | 0x40 | NAME['WHITE'],
    'CC_ForceFieldLook0': 0x10 | 0x20 | NAME['WHITE'],
    'CC_ForceFieldLook1': 0x10 | 0x20 | 0x40 | NAME['WHITE'],
}


def value(tok):
    tok = tok.strip()
    if tok.startswith('$'):
        return int(tok[1:], 16) & 0xFF
    if tok.startswith('%'):
        return int(tok[1:], 2) & 0xFF
    if tok in LOOKS:
        return LOOKS[tok]
    if tok in NAME:
        return NAME[tok]
    if re.match(r'^-?\d+$', tok):
        return int(tok) & 0xFF
    return 0


def parse_sprites():
    dcb = re.compile(r'^\s*(\S+)?\s+dc\.b\s+(.*?)(?:;.*)?$')
    sprites, cur, vals = [], None, []
    for ln in open(SPRITES, encoding='latin-1'):
        m = dcb.match(ln)
        if not m:
            continue
        label, data = m.group(1), m.group(2)
        if label and label.startswith('Dat'):
            if cur and len(vals) >= 3:
                sprites.append((cur, vals))
            cur, vals = label, []
        if cur is None:
            continue
        for t in data.split(','):
            if t.strip():
                vals.append(value(t))
    if cur and len(vals) >= 3:
        sprites.append((cur, vals))
    return sprites


def decode(vals):
    """Return an RGBA image of the sprite at native hi-res pixel size."""
    cols, rows, look = vals[0], vals[1], vals[2]
    bmp = vals[3:3 + cols * rows]
    indiv = look & 0x0F
    multicolor = (look & 0x10) == 0
    W = cols * 8                       # hi-res px wide (8 px per byte)
    img = Image.new("RGBA", (W, rows), (0, 0, 0, 0))
    px = img.load()
    for r in range(rows):
        for c in range(cols):
            b = bmp[r * cols + c] if r * cols + c < len(bmp) else 0
            if multicolor:
                for p in range(4):                 # 4 MC pixels, each 2 hi-res wide
                    pair = (b >> (6 - 2 * p)) & 3
                    if pair == 0:
                        continue
                    col = (SPMC0, indiv, SPMC1)[pair - 1]
                    x = c * 8 + p * 2
                    px[x, r] = C64[col] + (255,)
                    px[x + 1, r] = C64[col] + (255,)
            else:
                for p in range(8):
                    if b & (0x80 >> p):
                        px[c * 8 + p, r] = C64[indiv] + (255,)
    return img


def main():
    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    sprites = parse_sprites()
    print("parsed %d sprites" % len(sprites))

    scale = 4
    cell_w, cell_h = 24 * scale + 14, 21 * scale + 20   # fit a 24x21 sprite + label
    cols = 9
    rows = (len(sprites) + cols - 1) // cols
    title_h = 28
    bg = (24, 24, 24)
    sheet = Image.new("RGB", (cols * cell_w, title_h + rows * cell_h), bg)
    draw = ImageDraw.Draw(sheet)
    try:
        tfont = ImageFont.truetype("/System/Library/Fonts/Supplemental/Arial.ttf", 16)
        nfont = ImageFont.truetype("/System/Library/Fonts/Supplemental/Arial.ttf", 9)
    except Exception:
        tfont = nfont = ImageFont.load_default()
    draw.text((6, 6), "The Castles of Dr. Creep - all %d sprites" % len(sprites),
              fill=(240, 240, 160), font=tfont)

    for i, (name, vals) in enumerate(sprites):
        img = decode(vals)
        big = img.resize((img.width * scale, img.height * scale), Image.NEAREST)
        cx = (i % cols) * cell_w
        cy = title_h + (i // cols) * cell_h
        # per-cell checkerboard so transparent areas (and black sprites) are visible
        for yy in range(cell_h - 14):
            for xx in range(cell_w):
                shade = 64 if ((xx // 8) + (yy // 8)) & 1 else 48
                sheet.putpixel((cx + xx, cy + yy), (shade, shade, shade))
        ox = cx + (cell_w - big.width) // 2
        oy = cy + (24 * scale - big.height) // 2 + 2
        sheet.paste(big, (ox, oy), big)
        label = name[3:]                    # strip "Dat"
        draw.text((cx + 3, cy + cell_h - 13), label, fill=(210, 210, 210), font=nfont)

    sheet.save(OUT)
    print("wrote %s (%dx%d)" % (os.path.relpath(OUT, REPO), sheet.width, sheet.height))


if __name__ == "__main__":
    main()
