#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Faithful PNG renderer for "The Castles of Dr. Creep" (C64) tutorial castle.

This is a port of the actual room-drawing logic from the reconstructed
assembly source (Creep Sourcecode/asm/object.asm and inc/CC_Data*.asm).

The C64 game renders rooms in multicolor bitmap mode (160x200 multicolor
pixels = 320x200 hi-res pixels).  Each room is composed by painting a set of
graphic "objects" (DatObj* tables) into a bitmap + screen-RAM + color-RAM,
exactly as PaintObject / PaintRoom / Room* do on the C64.  We reproduce those
buffers in Python and then compose them to RGB.

Key asm routines ported here:
  PaintObject       -> Renderer.paint_object        (object.asm:10113)
  PaintRoom         -> Renderer.render_room          (object.asm:9608)
  PaintRoomItems    -> Renderer.render_room          (object.asm:2162)
  RoomDoor          -> room_door                     (object.asm:2192)
  RoomFloor         -> room_floor                    (object.asm:2303)
  RoomPole          -> room_pole                     (object.asm:2435)
  RoomLadder        -> room_ladder                   (object.asm:2535)
  RoomDoorBell      -> room_doorbell                 (object.asm:2676)
  RoomLightMachine  -> room_lightmachine             (object.asm:2754)
  RoomForceField    -> room_forcefield               (object.asm:2895)
  RoomMummy         -> room_mummy                     (object.asm:2987)
  RoomKey           -> room_key                       (object.asm:3149)
  RoomLock          -> room_lock                      (object.asm:3215)
  RoomRayGun        -> room_raygun                    (object.asm:3331)
  RoomMatterXmit    -> room_matterxmit                (object.asm:3479)
  RoomTrapDoor      -> room_trapdoor                  (object.asm:3618)
  RoomSideWalk      -> room_sidewalk                  (object.asm:3753)
  RoomFrankenStein  -> room_frankenstein              (object.asm:3898)
  RoomTextLine/PaintText -> room_textline             (object.asm:4042 / 9712)
  RoomGraphic       -> room_graphic                   (object.asm:4081)
"""

import os
import struct
import re
import sys

try:
    from PIL import Image, ImageDraw, ImageFont
except ImportError:
    sys.exit("Pillow (PIL) is required: pip install pillow")

# --------------------------------------------------------------------------- #
# Paths
# --------------------------------------------------------------------------- #
REPO = os.path.dirname(os.path.abspath(__file__))
SRC = os.path.join(REPO, "Creep Sourcecode")
DATA_OBJECTS = os.path.join(SRC, "inc", "CC_DataObjects.asm")
TUTORIAL = os.path.join(REPO, "The Castles of Dr. Creep", "ztutorial.prg")
CHAR_ROM = os.path.join(REPO, "Game.vc64", "char.rom")
IMAGES = os.path.join(REPO, "images")

BASE_ADDR = 0x7800
GRID_W = 0x04          # CC_GridWidth
GRID_H = 0x08          # CC_GridHeight

# --------------------------------------------------------------------------- #
# C64 palette (RGB)
# --------------------------------------------------------------------------- #
C64_RGB = [
    (0x00, 0x00, 0x00),  # 0  BLACK
    (0xFF, 0xFF, 0xFF),  # 1  WHITE
    (0x81, 0x33, 0x38),  # 2  RED
    (0x75, 0xCE, 0xC8),  # 3  CYAN
    (0x8E, 0x3C, 0x97),  # 4  PURPLE
    (0x56, 0xAC, 0x4D),  # 5  GREEN
    (0x2E, 0x2C, 0x9B),  # 6  BLUE
    (0xED, 0xF1, 0x71),  # 7  YELLOW
    (0x8E, 0x50, 0x29),  # 8  ORANGE
    (0x55, 0x38, 0x00),  # 9  BROWN
    (0xC4, 0x6C, 0x71),  # 10 LIGHT_RED
    (0x4A, 0x4A, 0x4A),  # 11 DARK_GREY
    (0x7B, 0x7B, 0x7B),  # 12 GREY
    (0xA9, 0xFF, 0x9F),  # 13 LIGHT_GREEN
    (0x70, 0x6D, 0xEB),  # 14 LIGHT_BLUE
    (0xB2, 0xB2, 0xB2),  # 15 LIGHT_GREY
]
C64_NAMES = [
    "BLACK", "WHITE", "RED", "CYAN", "PURPLE", "GREEN", "BLUE", "YELLOW",
    "ORANGE", "BROWN", "LIGHT_RED", "DARK_GREY", "GREY", "LIGHT_GREEN",
    "LIGHT_BLUE", "LIGHT_GREY",
]

# Map HR_* color-name fragments -> palette index.  The HR_<Color1><Color2>
# constants are defined in an absent system include; we synthesize them from
# the C64 color names (high nibble = Color1, low nibble = Color2).
HR_FRAGMENT = {
    "Black": 0, "White": 1, "Red": 2, "Cyan": 3, "Purple": 4, "Green": 5,
    "Blue": 6, "Yellow": 7, "Orange": 8, "Brown": 9,
    "LtRed": 10, "DkGrey": 11, "Grey": 12, "LtGreen": 13, "LtBlue": 14,
    "LtGrey": 15,
}
# Ordered longest-first so "LtGrey" is matched before "Grey", etc.
_HR_KEYS = sorted(HR_FRAGMENT.keys(), key=len, reverse=True)


def resolve_hr(name):
    """Resolve an HR_<C1><C2> constant string to a packed color byte."""
    body = name[3:]  # strip "HR_"
    parts = []
    while body:
        for k in _HR_KEYS:
            if body.startswith(k):
                parts.append(HR_FRAGMENT[k])
                body = body[len(k):]
                break
        else:
            raise ValueError("cannot parse HR constant %r (rest %r)" % (name, body))
    if len(parts) != 2:
        raise ValueError("HR constant %r did not resolve to 2 colors: %r" % (name, parts))
    return (parts[0] << 4) | parts[1]


# --------------------------------------------------------------------------- #
# Parse CC_DataObjects.asm
# --------------------------------------------------------------------------- #
class GfxObject:
    """A parsed DatObj* graphic: header + bitmap + (optional) two color blocks."""

    __slots__ = ("name", "cols", "rows", "bitmap", "screen", "color", "has_color")

    def __init__(self, name, cols, rows, bitmap, screen, color):
        self.name = name
        self.cols = cols
        self.rows = rows
        self.bitmap = bitmap        # list[cols*rows]
        self.screen = screen        # list[ColorCount] nibble bytes -> screen RAM
        self.color = color          # list[ColorCount] nibble bytes -> color RAM
        self.has_color = screen is not None


def color_count(cols, rows):
    """ColorCount = ceil(rows/8) * cols  (one byte per 8x8 cell)."""
    return (((rows - 1) >> 3) + 1) * cols


def parse_data_objects():
    """
    Parse the object data file into:
      - order:   list of object-data label names in TabObjectDataPtr order
                 (index == NoObj* number used by the engine)
      - objects: name -> GfxObject  (keyed by the Dat* label)
      - ptrmap:  Obj* label -> Dat* label
    Returns (objects_by_index, label_to_obj)
    """
    text = open(DATA_OBJECTS, "r", encoding="latin-1").read()
    lines = text.splitlines()

    # --- pass 1: collect raw byte streams per Dat* label -------------------- #
    # A data block starts at a line whose first token is a label that we treat
    # as a data label (begins with "Dat" or "Col") and continues collecting
    # dc.b values until the next data label.  We keep ALL dc.b values (the
    # ColObj* labels that sit *inside* a block are just sub-labels, their bytes
    # belong to the preceding Dat* block's color area).
    blocks = {}          # Dat* label -> list[int]
    current = None
    dcb_re = re.compile(r'^\s*(\S+)?\s+dc\.b\s+(.*?)(?:;.*)?$')

    def parse_values(s):
        out = []
        for tok in s.split(","):
            tok = tok.strip()
            if not tok:
                continue
            if tok.startswith("$"):
                out.append(int(tok[1:], 16) & 0xFF)
            elif tok.startswith("%"):
                out.append(int(tok[1:], 2) & 0xFF)
            elif tok.startswith("HR_"):
                out.append(resolve_hr(tok))
            elif tok == "ColBaseLine":
                out.append(resolve_hr("HR_BlackBrown"))
            elif re.match(r'^-?\d+$', tok):
                out.append(int(tok) & 0xFF)
            else:
                # Unknown symbol inside data (e.g. another equ). Treat as 0
                # placeholder; this never happens for the bitmap objects we use.
                out.append(0)
        return out

    for ln in lines:
        m = dcb_re.match(ln)
        if not m:
            continue
        label, vals = m.group(1), m.group(2)
        if label and label.startswith("Dat"):
            # A few objects label their individual rows/colours with numeric
            # sub-labels (e.g. DatObjFoFiTime01..08, DatObjLiMaPole01..02). Those
            # start with "Dat" too, but belong to the current block -- only start
            # a NEW block when the label isn't "<current><digits>".
            if not (current and label.startswith(current)
                    and label[len(current):].isdigit()):
                current = label
                blocks[current] = []
        if current is None:
            continue
        blocks[current].extend(parse_values(vals))

    # --- pass 2: turn raw streams into GfxObject ---------------------------- #
    label_to_obj = {}
    for label, raw in blocks.items():
        if len(raw) < 3:
            continue
        cols, rows = raw[0], raw[1]
        if cols == 0 or rows == 0:
            continue
        body = raw[3:]
        bm_len = cols * rows
        cc = color_count(cols, rows)
        bitmap = body[:bm_len]
        if len(bitmap) < bm_len:
            bitmap = bitmap + [0] * (bm_len - len(bitmap))
        # Color blocks after the bitmap: many objects carry two blocks
        # (screen-RAM nibbles + color-RAM nibbles), but several carry only ONE
        # (screen-RAM only — e.g. doors all $40, the grate, the pole, ladder
        # rungs). A single block still colours the object; without it the
        # object draws with screen-RAM 0 = black = invisible. Detect both.
        rest = body[bm_len:]
        if cc > 0 and len(rest) >= 2 * cc:
            screen = rest[:cc]
            color = rest[cc:2 * cc]
        elif cc > 0 and len(rest) >= cc:
            screen = rest[:cc]        # single screen-RAM block
            color = [0] * cc          # no color-RAM block (bit-pair 11 -> black)
        else:
            screen = None
            color = None
        label_to_obj[label] = GfxObject(label, cols, rows, bitmap, screen, color)

    # --- pass 3: TabObjectDataPtr ordering (index -> Dat* label) ------------ #
    order = []
    in_tab = False
    ptr_re = re.compile(r'^\s*(\S+)\s+dc\.w\s+(\S+)')
    for ln in lines:
        if ln.strip().startswith("TabObjectDataPtr"):
            in_tab = True
            continue
        if not in_tab:
            continue
        if ln.strip().startswith(";") and order:
            # The "----" separator after the table ends it.
            if "---" in ln:
                break
            continue
        m = ptr_re.match(ln)
        if m:
            datlabel = m.group(2)
            order.append(datlabel)
        elif order and ln.strip() and not ln.strip().startswith(";"):
            # first non dc.w, non comment line after entries -> table ended
            if "equ" in ln or "=" in ln:
                break
    # Build index -> GfxObject (ObjRoomDyn is $0000 placeholder at index 0)
    objects_by_index = []
    for datlabel in order:
        objects_by_index.append(label_to_obj.get(datlabel))
    return objects_by_index, label_to_obj


# --------------------------------------------------------------------------- #
# C64 character ROM (for text)
# --------------------------------------------------------------------------- #
def load_charrom():
    if not os.path.exists(CHAR_ROM):
        return None
    return open(CHAR_ROM, "rb").read()


# Lowercase bank holds PETSCII-uppercase glyphs at their PETSCII index
# (CHR_LO == file offset $0800 for the extracted 4K chargen).
CHR_LO = 0x0800
CHR_UP = 0x0000

# nibble (4 hi-res px) -> multicolor byte where each set hi-res bit becomes a
# bit-pair "01" (TabTransChr2BitMap, CC_DataTables.asm:452).
TAB_CHR2BITMAP = [0x00, 0x01, 0x04, 0x05, 0x10, 0x11, 0x14, 0x15,
                  0x40, 0x41, 0x44, 0x45, 0x50, 0x51, 0x54, 0x55]


# --------------------------------------------------------------------------- #
# Renderer
# --------------------------------------------------------------------------- #
class Renderer:
    def __init__(self, objects_by_index, label_to_obj, charrom):
        self.objs = objects_by_index
        self.labels = label_to_obj
        self.charrom = charrom
        self.warnings = []

    # ---- per-room buffers -------------------------------------------------- #
    def new_room(self):
        # bmp[200][40] bitmap bytes (0 = background bit-pairs 00)
        self.bmp = [[0] * 40 for _ in range(200)]
        # screen RAM and color RAM, one byte per 8x8 cell (25 rows x 40 cols)
        self.scr = [[0] * 40 for _ in range(25)]
        self.col = [[0] * 40 for _ in range(25)]
        # control screen: tracks which cells already carry a floor tile,
        # used by RoomPole / RoomLadder to decide cover graphics.
        # We only need the "is there a floor here" bit.
        self.floor_ctrl = [[0] * 40 for _ in range(25)]

    # ---- core paint primitive (port of PaintObject) ----------------------- #
    def paint_object(self, gfx, grid_col, grid_row, prm_type, gfx1=None,
                     col_override=None, screen_cells=None):
        """
        Paint object `gfx` (a GfxObject) at (grid_col, grid_row).

        prm_type:
          0  type-0 : OR bitmap into bmp, write screen+color RAM nibbles
          1  type-1 : EOR/erase bitmap (drawn without color info)
          2  type-2 : paint gfx1 as type1 erase AND gfx as type0 with color

        Placement (PaintObject):
          left hi-res pixel = (grid_col - 0x10) * 2
          top  pixel row    = grid_row  (but the engine computes it via the
                              hires row table = identity for the room screen)
          cell column start = (grid_col - 0x10) // 4
        col_override: optional (screen_byte, color_byte) tuple applied to every
                      covered cell instead of the object's stored color data.
        screen_cells: optional list of per-cell screen-RAM bytes (indexed
                      cr*cols+c). Matches PaintRoom recolouring objects that have
                      their own colour block per cell (e.g. DatLadderPaFl: the two
                      floor cells vs the middle ladder-rung cell get different
                      colours). The colour-RAM nibble is kept from the graphic's
                      own data. Takes precedence over col_override.
        """
        # Type 2 = a type-1 eraser (gfx1) plus a type-0 colored object (gfx).
        if prm_type == 2 and gfx1 is not None:
            self.paint_object(gfx1, grid_col, grid_row, 1)
            self.paint_object(gfx, grid_col, grid_row, 0,
                              col_override=col_override, screen_cells=screen_cells)
            return

        cols, rows = gfx.cols, gfx.rows
        left_px = (grid_col - 0x10) * 2      # hi-res pixel x of leftmost column
        start_cell_col = (grid_col - 0x10) // 4
        # byte column in the 40-wide bitmap row (each object column = 8 hi-res px)
        start_byte_col = left_px // 8

        # ---- bitmap ---- #
        for r in range(rows):
            py = grid_row + r
            if py < 0 or py >= 200:
                continue
            for c in range(cols):
                bc = start_byte_col + c
                if bc < 0 or bc >= 40:
                    continue
                val = gfx.bitmap[r * cols + c]
                if prm_type == 0:
                    self.bmp[py][bc] |= val
                else:  # type 1: erase (the C64 inverts: EOR/AND on $ff screen)
                    self.bmp[py][bc] &= (~val) & 0xFF

        # ---- color (type 0 only) ---- #
        # Objects like DatObjPole / DatObjLadderMid carry no color block
        # (has_color == False); on the C64 their lit bit-pairs take the colour
        # already present in the cell. We model that with an explicit
        # col_override, which must apply even when the object has no colours.
        if prm_type == 0 and (gfx.has_color or col_override is not None
                              or screen_cells is not None):
            cc_rows = ((rows - 1) >> 3) + 1   # number of cell-rows of color data
            start_cell_row = grid_row // 8
            for cr in range(cc_rows):
                cell_row = start_cell_row + cr
                if cell_row < 0 or cell_row >= 25:
                    continue
                for c in range(cols):
                    cell_col = start_cell_col + c
                    if cell_col < 0 or cell_col >= 40:
                        continue
                    idx = cr * cols + c
                    if screen_cells is not None:
                        # per-cell screen byte; keep the graphic's own colour-RAM
                        sval = screen_cells[idx]
                        cval = gfx.color[idx] if gfx.has_color else 0
                    elif col_override is not None:
                        sval, cval = col_override
                    else:
                        sval = gfx.screen[idx]
                        cval = gfx.color[idx]
                    self.scr[cell_row][cell_col] = sval
                    self.col[cell_row][cell_col] = cval

    # ---- compose to RGB image (final compose) ------------------------------ #
    def compose(self):
        img = Image.new("RGB", (320, 200), C64_RGB[0])
        px = img.load()
        for py in range(200):
            cell_row = py // 8
            row = self.bmp[py]
            for bc in range(40):
                val = row[bc]
                if val == 0:
                    continue
                cell_col = bc
                s = self.scr[cell_row][cell_col]
                cram = self.col[cell_row][cell_col]
                colors = [0, (s >> 4) & 0x0F, s & 0x0F, cram & 0x0F]
                base_x = bc * 8
                for p in range(4):
                    pair = (val >> (6 - 2 * p)) & 3
                    if pair == 0:
                        continue
                    rgb = C64_RGB[colors[pair]]
                    x0 = base_x + p * 2
                    px[x0, py] = rgb
                    px[x0 + 1, py] = rgb
        return img

    # ---- text (PaintText port) -------------------------------------------- #
    def paint_char(self, ch, grid_col, grid_row, color, height):
        """Render one character using the C64 char ROM (lowercase bank)."""
        if self.charrom is None:
            return
        code = ch & 0x7F
        glyph = self.charrom[CHR_LO + code * 8: CHR_LO + code * 8 + 8]
        # Build a 2-byte-wide (cols=2) multicolor object, rows = 8*height.
        cols = 2
        rows = 8 * height
        # Each source row -> one multicolor row of 2 bytes; for multi-height
        # the source row is repeated `height` times (matches PaintText doubling).
        bm = []
        for r in range(8):
            b = glyph[r]
            hi = TAB_CHR2BITMAP[(b >> 4) & 0x0F]
            lo = TAB_CHR2BITMAP[b & 0x0F]
            for _ in range(height):
                bm.append(hi)
                bm.append(lo)
        # color: foreground (bit-pair 01) = screen high nibble = text color.
        gfx = GfxObject("char", cols, rows, bm, None, None)
        # We override colors so the bit-pair 01 picks the text color.
        cc = color_count(cols, rows)
        gfx.has_color = True
        gfx.screen = [(color << 4) & 0xF0] * cc
        gfx.color = [0] * cc
        self.paint_object(gfx, grid_col, grid_row, 0)

    def paint_text(self, s, grid_col, grid_row, color, fmt):
        height = fmt & 0x03
        if height == 0:
            height = 1
        gc = grid_col
        for ch in s:
            self.paint_char(ord(ch), gc, grid_row, color, height)
            gc += GRID_W * 2   # PaintText advances GridCol by CC_GridWidth*2 (2 cells)


# --------------------------------------------------------------------------- #
# Object-list parser + Room* routines
# --------------------------------------------------------------------------- #
class Castle:
    def __init__(self, path):
        raw = open(path, "rb").read()
        self.load_addr = struct.unpack("<H", raw[0:2])[0]
        self.data = raw[2:]

    def w(self, off):
        return struct.unpack("<H", self.data[off:off + 2])[0]

    def rooms(self):
        """Each room: (idx, color, objp, mapX, mapY, mapW, mapH).

        mapX/mapY are the room's position on the castle map; mapW/mapH its size
        in map cells. One map cell = CC_GridWidth(4) X-units wide and
        CC_GridHeight(8) Y-units tall, so a room occupies the map rectangle
        [mapX, mapX + mapW*4] x [mapY, mapY + mapH*8]; these tessellate into the
        castle floor plan (room records +1 X, +2 Y, +3 w/h).
        """
        out = []
        off = 0x100
        idx = 0
        d = self.data
        while not (d[off] & 0x40):
            color = d[off] & 0x0F
            x = d[off + 1]
            y = d[off + 2]
            wh = d[off + 3]
            w = (wh >> 3) & 7
            h = wh & 7
            objp = self.w(off + 6) - BASE_ADDR
            out.append((idx, color, objp, x, y, w, h))
            off += 8
            idx += 1
        return out


def render_room(rend, castle, color, objp):
    """Port of PaintRoom + PaintRoomItems for a single room."""
    d = castle.data
    rend.new_room()
    L = rend.labels

    # --- room-color recolor bytes (PaintRoom) ------------------------------ #
    floor_col = (color << 4) | color                  # ColObjFloor*
    pole_cover_col = (color & 0x0F) | 0x10             # ColObjPoleCover
    ladder_fl_col = (floor_col & 0xF0) | 0x01          # ColObjLadderFl / pass

    # destination-room colour per door (by door index), filled when the door
    # list is drawn; a doorbell looks this up via its target-door number.
    door_target_color = []

    off = objp

    def floor_present(cell_row, cell_col):
        if 0 <= cell_row < 25 and 0 <= cell_col < 40:
            return rend.floor_ctrl[cell_row][cell_col]
        return 0

    def mark_floor(cell_row, cell_col):
        if 0 <= cell_row < 25 and 0 <= cell_col < 40:
            rend.floor_ctrl[cell_row][cell_col] = 1

    while True:
        oid = struct.unpack("<H", d[off:off + 2])[0]
        off += 2
        if oid == 0x0000:
            break

        # ---- Door (RoomDoor) --------------------------------------------- #
        if oid == 0x0803:
            count = d[off]; off += 1
            for _ in range(count):
                x, y, inwall, toroom = d[off], d[off + 1], d[off + 2], d[off + 3]
                typ = d[off + 7]
                # destination room colour (RoomDoor: CC_WaO_TypDoorTargColor)
                troom_color = (d[0x100 + toroom * 8] & 0x0F
                               if 0x100 + toroom * 8 < len(d) else color)
                door_target_color.append(troom_color)
                # door frame graphic by type
                frame = L["DatObjDoorNormal"] if typ == 0 else L["DatObjDoorExit"]
                rend.paint_object(frame, x, y, 0)
                # grating (closed) or open ground, lower part (X, Y + 16)
                if not (inwall & 0x80):
                    rend.paint_object(L["DatObjDoorGrate"], x + GRID_W, y + GRID_H * 2, 0)
                else:
                    # open door: the passage ("ground") is painted in the
                    # destination room's colour (RoomDoor .OpenColor fills
                    # ColObjDoorGround with CC_WaO_TypDoorTargColor).
                    gc = (troom_color << 4) | troom_color
                    rend.paint_object(L["DatObjDoorGround"], x + GRID_W, y + GRID_H * 2, 0,
                                      col_override=(gc, gc))
                off += 8
            continue

        # ---- Floor / Walkway (RoomFloor) --------------------------------- #
        if oid == 0x0806:
            while d[off] != 0:
                length, x, y = d[off], d[off + 1], d[off + 2]
                gc = x
                for i in range(1, length + 1):
                    if i == 1:
                        lab = "DatObjFloorStart"
                    elif i == length:
                        lab = "DatObjFloorEnd"
                    else:
                        lab = "DatObjFloorMid"
                    g = L[lab]
                    rend.paint_object(g, gc, y, 0,
                                      col_override=(floor_col, resolve_hr("HR_BlackBrown")))
                    # mark floor control cell
                    mark_floor(y // 8, (gc - 0x10) // 4)
                    gc += g.cols * 4
                off += 3
            off += 1
            continue

        # ---- Pole (RoomPole) --------------------------------------------- #
        if oid == 0x0809:
            while d[off] != 0:
                length, x, y = d[off], d[off + 1], d[off + 2]
                gc, gr = x, y
                for _ in range(length):
                    cell_row, cell_col = gr // 8, (gc - 0x10) // 4
                    if floor_present(cell_row, cell_col):
                        # pole passes a floor: erase floor with pass + cover front
                        passfl = L["DatObjPolePaFl"]
                        cover = L["DatObjPoleCover"]
                        # type2: erase pass-floor (gfx1) at gc-GRID_W, cover (type0) at gc
                        rend.paint_object(passfl, gc - GRID_W, gr, 1)
                        rend.paint_object(cover, gc, gr, 0,
                                          col_override=(pole_cover_col,
                                                        resolve_hr("HR_BlackBrown")))
                    else:
                        # plain pole, drawn type-0 (RoomPole .SetObjPole).
                        # DatObjPole carries its own 1-cell colour block: the
                        # screen byte is $10, so the lit bit-pair 01 takes high
                        # nibble 1 = WHITE (CC_DataObjects.asm:280). The pole is
                        # white regardless of room colour.
                        rend.paint_object(L["DatObjPole"], gc, gr, 0,
                                          col_override=(0x10, 0x00))
                    gr += GRID_H
                off += 3
            off += 1
            continue

        # ---- Ladder (RoomLadder) ----------------------------------------- #
        if oid == 0x080c:
            while d[off] != 0:
                length, x, y = d[off], d[off + 1], d[off + 2]
                gc, gr = x, y
                rem = length
                while rem > 0:
                    cell_row, cell_col = gr // 8, (gc - 0x10) // 4
                    if not floor_present(cell_row, cell_col):
                        lab = "DatObjLadderTop" if rem == 1 else "DatObjLadderMid"
                        rend.paint_object(L[lab], gc, gr, 0,
                                          col_override=(ladder_fl_col,
                                                        resolve_hr("HR_BlackBrown")))
                    else:
                        if rem == 1:
                            # ladder on floor (junction): 1-cell, ColObjLadderFl
                            rend.paint_object(L["DatObjLadderXOn"], gc, gr, 1)
                            rend.paint_object(L["DatObjLadderFl"], gc, gr, 0,
                                              screen_cells=[ladder_fl_col])
                        else:
                            # ladder passes floor: 3-cell graphic. PaintRoom gives
                            # the two floor cells the floor colour and the middle
                            # (rung) cell ColLadderPaFl02 = (color<<4)|0x01.
                            rend.paint_object(L["DatObjLadderXPa"], gc - GRID_W, gr, 1)
                            rend.paint_object(L["DatLadderPaFl"], gc - GRID_W, gr, 0,
                                              screen_cells=[floor_col, ladder_fl_col,
                                                            floor_col])
                    gr += GRID_H
                    rem -= 1
                off += 3
            off += 1
            continue

        # ---- DoorBell (RoomDoorBell) ------------------------------------- #
        if oid == 0x080f:
            count = d[off]; off += 1
            bell = L["DatObjDoorBell"]            # 3x19, 9 colour cells (3x3)
            ncells = color_count(bell.cols, bell.rows)
            for _ in range(count):
                x, y, target_door = d[off], d[off + 1], d[off + 2]
                # RoomDoorBell colours the whole bell with the colour of the
                # room the target door leads to; the centre "knob" cell (index 4)
                # gets a white high-nibble (white | dest-colour).
                tcol = (door_target_color[target_door]
                        if target_door < len(door_target_color) else color)
                tc = (tcol << 4) | tcol
                screen_cells = [tc] * ncells
                if ncells > 4:
                    screen_cells[4] = 0x10 | tcol     # ColObjDoorBell02 knob
                rend.paint_object(bell, x, y, 0, screen_cells=screen_cells)
                off += 3
            continue

        # ---- LightMachine (RoomLightMachine) ----------------------------- #
        if oid == 0x0812:
            while not (d[off] & 0x20):
                mode = d[off]
                gc, gr = d[off + 1], d[off + 2]
                pole_len = d[off + 3]
                if mode & 0x80:
                    # switch (frame + up/down)
                    rend.paint_object(L["DatObjLiMaSwFrm"], gc, gr, 0)
                    sw = "DatObjLiMaSwUp" if (mode & 0x40) else "DatObjLiMaSwDo"
                    rend.paint_object(L[sw], gc + GRID_W, gr + GRID_H, 0)
                else:
                    # pole of balls down + ball
                    yy = gr
                    pl = pole_len
                    while pl > 0:
                        rend.paint_object(L["DatObjLiMaPoleOn"], gc, yy, 0)
                        yy += GRID_H
                        pl -= 1
                    rend.paint_object(L["DatObjLiMaBall"], gc - GRID_W, yy, 0)
                off += 8
            off += 1
            continue

        # ---- ForceField (RoomForceField) --------------------------------- #
        if oid == 0x0815:
            while d[off] != 0:
                swc, swr, fic, fir = d[off], d[off + 1], d[off + 2], d[off + 3]
                rend.paint_object(L["DatObjFoFiSwitch"], swc, swr, 0)
                # RoomForceField fills the timer square's 8 bitmap rows with $55
                # (a full "filler-line" bar = timer reset) before painting it; the
                # static data bytes are just placeholders, so draw the filled bar.
                t = L["DatObjFoFiTime"]
                timer_full = GfxObject("FoFiTimeFull", t.cols, t.rows,
                                       [0x55] * (t.cols * t.rows), t.screen, t.color)
                rend.paint_object(timer_full, swc + GRID_W, swr + GRID_H, 0)
                rend.paint_object(L["DatObjFoFiHead"], fic, fir, 0)
                off += 4
            off += 1
            continue

        # ---- Mummy (RoomMummy) ------------------------------------------- #
        if oid == 0x0818:
            while d[off] != 0:
                status = d[off]
                ankh_c, ankh_r = d[off + 1], d[off + 2]
                wall_c, wall_r = d[off + 3], d[off + 4]
                # Ankh
                rend.paint_object(L["DatObjMummyAnkh"], ankh_c, ankh_r, 0)
                # 3 brick rows, each: (cols-1) wall bricks + 1 end brick
                gr = wall_r
                for _ in range(3):
                    gc = wall_c
                    # MummyWall is wider than 1 cell; advance by GRID_W per brick
                    rend.paint_object(L["DatObjMummyWall"], gc, gr, 0)
                    gr += GRID_H
                off += 7
            off += 1
            continue

        # ---- Key (RoomKey) ----------------------------------------------- #
        if oid == 0x081b:
            keymap = ["DatObjKeyWhite", "DatObjKeyRed", "DatObjKeyCyan",
                      "DatObjKeyPurple", "DatObjKeyGreen", "DatObjKeyBlue",
                      "DatObjKeyYellow"]
            while d[off] != 0:
                kcolor = d[off]
                status = d[off + 1]
                x, y = d[off + 2], d[off + 3]
                if status:  # not picked up
                    cidx = (status & 0x0F) - 1
                    if 0 <= cidx < len(keymap):
                        rend.paint_object(L[keymap[cidx]], x, y, 0)
                off += 4
            off += 1
            continue

        # ---- Lock (RoomLock) --------------------------------------------- #
        if oid == 0x081e:
            while d[off] != 0:
                lcolor = d[off]
                target = d[off + 2]
                x, y = d[off + 3], d[off + 4]
                cval = ((lcolor & 0x0F) << 4) | (lcolor & 0x0F)
                rend.paint_object(L["DatObjLock"], x, y, 0,
                                  col_override=(cval, cval))
                off += 5
            off += 1
            continue

        # ---- RayGun (RoomRayGun) ----------------------------------------- #
        if oid == 0x0824:
            while not (d[off] & 0x80):
                direction = d[off]
                pole_c, pole_r = d[off + 1], d[off + 2]
                pole_len = d[off + 3]
                sw_c, sw_r = d[off + 5], d[off + 6]
                pole_lab = "DatObjGunPoleLe" if (direction & 0x01) else "DatObjGunPoleRi"
                yy = pole_r
                pl = pole_len
                while pl > 0:
                    rend.paint_object(L[pole_lab], pole_c, yy, 0)
                    yy += GRID_H
                    pl -= 1
                rend.paint_object(L["DatObjGunSwitch"], sw_c, sw_r, 0)
                off += 7
            off += 1
            continue

        # ---- MatterTransmitter (RoomMatterXmit) -------------------------- #
        if oid == 0x0827:
            booth_c, booth_r, bcolor = d[off], d[off + 1], d[off + 2]
            # floor strip under booth (3 mid tiles), booth, far floor, xmit oval
            floor_strip = L["DatObjFloorMid"]
            gc = booth_c
            for _ in range(3):                      # CCW_XmitBoothFloorMax
                rend.paint_object(floor_strip, gc, booth_r + 0x18, 1)
                gc += GRID_W
            rend.paint_object(L["DatObjXmitBooth"], booth_c, booth_r, 0)
            rend.paint_object(floor_strip, booth_c + 0x0C, booth_r + 0x18, 0,
                              col_override=(floor_col, resolve_hr("HR_BlackBrown")))
            rend.paint_object(L["DatObjXmit"], booth_c + GRID_W, booth_r + 0x18, 0)
            off += 3
            rc = resolve_hr("HR_RedBlack")
            while d[off] != 0:
                tx, ty = d[off], d[off + 1]
                rend.paint_object(L["DatObjXmitRcOv"], tx, ty, 0,
                                  col_override=(rc, rc))
                off += 2
                rc = (rc + 0x10) & 0xFF
            off += 1
            continue

        # ---- TrapDoor (RoomTrapDoor) ------------------------------------- #
        if oid == 0x082a:
            while not (d[off] & 0x80):
                status = d[off]
                door_c, door_r = d[off + 1], d[off + 2]
                sw_c, sw_r = d[off + 3], d[off + 4]
                if status & 0x01:    # open
                    rend.paint_object(L["DatObjTrapOpen"], door_c, door_r, 1)
                    rend.paint_object(L["DatObjTrapMovBas"], door_c + GRID_W, door_r, 0)
                rend.paint_object(L["DatObjTrapSw"], sw_c, sw_r, 0)
                off += 5
            off += 1
            continue

        # ---- SideWalk / Conveyor (RoomSideWalk) -------------------------- #
        if oid == 0x082d:
            while not (d[off] & 0x80):
                status = d[off]
                walk_c, walk_r = d[off + 1], d[off + 2]
                sw_c, sw_r = d[off + 3], d[off + 4]
                rend.paint_object(L["DatObjWalkBlank"], walk_c, walk_r, 1)
                rend.paint_object(L["DatObjWalkMov01"], walk_c, walk_r, 0)
                rend.paint_object(L["DatObjWalkSw"], sw_c, sw_r, 0)
                rend.paint_object(L["DatObjWalkSpot"], sw_c + GRID_W, sw_r + GRID_H, 0)
                off += 5
            off += 1
            continue

        # ---- Frankenstein (RoomFrankenStein) ----------------------------- #
        if oid == 0x0830:
            while not (d[off] & 0x80):
                cdir = d[off]
                cof_c, cof_r = d[off + 1], d[off + 2]
                # blank out start of floor below the coffin
                rend.paint_object(L["DatObjFrankCover"], cof_c, cof_r + 0x18, 1)
                coffin = "DatObjFrankCofLe" if (cdir & 0x01) else "DatObjFrankCofRi"
                rend.paint_object(L[coffin], cof_c, cof_r, 0)
                if not (cdir & 0x01):
                    rend.paint_object(L["DatObjFloorMid"], cof_c + GRID_W, cof_r + 0x18, 0,
                                      col_override=(floor_col, resolve_hr("HR_BlackBrown")))
                off += 7
            off += 1
            continue

        # ---- Text (RoomTextLine) ----------------------------------------- #
        if oid == 0x0833:
            while d[off] != 0:
                x, y, tcol, fmt = d[off], d[off + 1], d[off + 2], d[off + 3]
                off += 4
                s = ""
                while not (d[off] & 0x80):
                    s += chr(d[off]); off += 1
                s += chr(d[off] & 0x7F); off += 1
                rend.paint_text(s, x, y, tcol, fmt)
            off += 1
            continue

        # ---- Graphic (RoomGraphic, inline 0x836 image) ------------------- #
        if oid == 0x0836:
            w, h = d[off], d[off + 1]
            hdr = off
            cc = (((h - 1) >> 3) + 1) * w
            data_len = 3 + w * h + 2 * cc
            body = d[hdr:hdr + data_len]
            bitmap = list(body[3:3 + w * h])
            screen = list(body[3 + w * h:3 + w * h + cc])
            colram = list(body[3 + w * h + cc:3 + w * h + 2 * cc])
            gfx = GfxObject("inline", w, h, bitmap, screen, colram)
            off += data_len
            while d[off] != 0:
                gx, gy = d[off], d[off + 1]
                rend.paint_object(gfx, gx, gy, 0)
                off += 2
            off += 1
            continue

        # ---- unknown -> skip safely -------------------------------------- #
        rend.warnings.append("room@%#x: unknown object id %#06x, stopping" % (objp, oid))
        break

    return rend.compose()


# --------------------------------------------------------------------------- #
# Output / scaling / overview
# --------------------------------------------------------------------------- #
def scale(img, factor=3):
    return img.resize((img.width * factor, img.height * factor), Image.NEAREST)


def with_caption(img, text):
    bar_h = 22
    out = Image.new("RGB", (img.width, img.height + bar_h), (20, 20, 20))
    out.paste(img, (0, 0))
    draw = ImageDraw.Draw(out)
    try:
        font = ImageFont.truetype("/System/Library/Fonts/Supplemental/Arial.ttf", 14)
    except Exception:
        font = ImageFont.load_default()
    draw.text((6, img.height + 3), text, fill=(220, 220, 220), font=font)
    return out


def draw_castle_map(castle, title, out_path, factor=3):
    """Draw the castle map the way the game does (port of _mapRoomDraw / MapHandler).

    Each room is a solid rectangle in the room's colour at its map position
    ((x-16)*2, y), sized w*8 x h*8 px (w=(wh>>3)&7 cells of 8px, h=wh&7 cells of
    8px), with a dotted wall border and a small arrow per door pointing in the
    door's direction (DoorInWallId & 3: 0=N 1=E 2=S 3=W). The whole map fills the
    320x200-style screen space; we render at native scale then enlarge.
    """
    d = castle.data

    rooms = []
    off = 0x100
    while off + 8 <= len(d) and not (d[off] & 0x40):
        color = d[off] & 0x0F
        x, y, wh = d[off + 1], d[off + 2], d[off + 3]
        w = (wh >> 3) & 7        # cells across (each 8 px)
        h = wh & 7               # cells down   (each 8 px)
        door_ptr = struct.unpack("<H", d[off + 4:off + 6])[0] - BASE_ADDR
        rooms.append((color, x, y, w, h, door_ptr))
        off += 8

    def PX(gx):                  # map grid X -> screen pixel (screenDraw convention)
        return (gx - 16) * 2

    pad = 6
    min_x = min(PX(r[1]) for r in rooms)
    min_y = min(r[2] for r in rooms)
    max_x = max(PX(r[1]) + r[3] * 8 for r in rooms)
    max_y = max(r[2] + r[4] * 8 for r in rooms)
    Wp = (max_x - min_x) + 2 * pad
    Hp = (max_y - min_y) + 2 * pad

    img = Image.new("RGB", (Wp, Hp), (0, 0, 0))
    px = img.load()

    def put(X, Y, rgb):
        if 0 <= X < Wp and 0 <= Y < Hp:
            px[X, Y] = rgb

    WALL = (40, 40, 40)
    ARROW = (255, 255, 255)

    def arrow(cx, cy, direction):
        # small 4px triangle pointing outward (0=N up,1=E right,2=S down,3=W left)
        for k in range(4):
            if direction == 0:      # up
                for j in range(-k, k + 1):
                    put(cx + j, cy - 3 + k, ARROW)
            elif direction == 2:    # down
                for j in range(-k, k + 1):
                    put(cx + j, cy + 3 - k, ARROW)
            elif direction == 1:    # right
                for j in range(-k, k + 1):
                    put(cx + 3 - k, cy + j, ARROW)
            else:                   # left
                for j in range(-k, k + 1):
                    put(cx - 3 + k, cy + j, ARROW)

    for color, x, y, w, h, door_ptr in rooms:
        rx = PX(x) - min_x + pad
        ry = y - min_y + pad
        rw, rh = w * 8, h * 8
        rgb = C64_RGB[color]
        for yy in range(ry, ry + rh):
            for xx in range(rx, rx + rw):
                put(xx, yy, rgb)
        # dotted wall border
        for xx in range(rx, rx + rw):
            if (xx - rx) & 1 == 0:
                put(xx, ry, WALL); put(xx, ry + rh - 1, WALL)
        for yy in range(ry, ry + rh):
            if (yy - ry) & 1 == 0:
                put(rx, yy, WALL); put(rx + rw - 1, yy, WALL)
        # door arrows
        if 0 <= door_ptr < len(d):
            count = d[door_ptr]
            if count <= 32:
                for i in range(count):
                    rec = door_ptr + 1 + i * 8
                    if rec + 7 >= len(d):
                        break
                    direction = d[rec + 2] & 3
                    off_col, off_row = d[rec + 5], d[rec + 6]
                    if direction in (0, 2):     # N / S: x = room_x + off_col
                        ax = PX(x + off_col) - min_x + pad + 1
                        ay = ry if direction == 0 else ry + rh - 1
                    else:                        # E / W: y = room_y + off_row
                        ay = (y + off_row) - min_y + pad
                        ax = rx if direction == 3 else rx + rw - 1
                    arrow(ax, ay, direction)

    big = img.resize((Wp * factor, Hp * factor), Image.NEAREST)
    title_h = 24
    out = Image.new("RGB", (big.width, big.height + title_h), (16, 16, 16))
    out.paste(big, (0, title_h))
    draw = ImageDraw.Draw(out)
    try:
        tfont = ImageFont.truetype("/System/Library/Fonts/Supplemental/Arial.ttf", 16)
    except Exception:
        tfont = ImageFont.load_default()
    draw.text((6, 4), title, fill=(240, 240, 160), font=tfont)
    out.save(out_path)


def render_castle(rend, path, out_dir):
    """Render every room of one castle .prg into out_dir/."""
    os.makedirs(out_dir, exist_ok=True)
    name = os.path.splitext(os.path.basename(path))[0][1:]  # strip leading 'z'
    castle = Castle(path)
    rooms = castle.rooms()
    print("%-13s %2d rooms -> %s/" % (name.upper(), len(rooms),
                                      os.path.relpath(out_dir, REPO)))
    for idx, color, objp, mx, my, mw, mh in rooms:
        try:
            img = render_room(rend, castle, color, objp)
        except Exception as e:               # never let one room kill the batch
            rend.warnings.append("%s room %02d: %s" % (name, idx, e))
            img = Image.new("RGB", (320, 200), C64_RGB[0])
        cap = "%s  Room %02d  (%s)" % (name.upper(), idx, C64_NAMES[color])
        with_caption(scale(img, 3), cap).save(
            os.path.join(out_dir, "room_%02d.png" % idx))
    # overview = the in-game castle map (coloured room blocks + door arrows)
    draw_castle_map(castle, "%s  (%d rooms)" % (name.upper(), len(rooms)),
                    os.path.join(out_dir, "overview.png"))
    return len(rooms) + 1


def main():
    import glob
    os.makedirs(IMAGES, exist_ok=True)
    print("Parsing object graphics from %s ..." % os.path.relpath(DATA_OBJECTS, REPO))
    objs, labels = parse_data_objects()
    print("  parsed %d object data blocks, %d table entries"
          % (len(labels), len(objs)))
    charrom = load_charrom()
    print("  char ROM: %s\n" % ("loaded" if charrom else "MISSING (text disabled)"))

    rend = Renderer(objs, labels, charrom)
    castle_dir = os.path.join(REPO, "The Castles of Dr. Creep")
    paths = sorted(glob.glob(os.path.join(castle_dir, "z*.prg")))

    total = 0
    for p in paths:
        name = os.path.splitext(os.path.basename(p))[0][1:]
        total += render_castle(rend, p, os.path.join(IMAGES, name))

    if rend.warnings:
        print("\nWarnings (%d):" % len(rend.warnings))
        for w in rend.warnings:
            print("  " + w)
    print("\nDone. Rendered %d castles, %d PNGs into %s/<castle>/"
          % (len(paths), total, os.path.relpath(IMAGES, REPO)))


if __name__ == "__main__":
    main()
