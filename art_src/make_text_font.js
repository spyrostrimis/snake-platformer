// Bakes the chat and notes font: an atlas of outlined glyphs (spr_text_font) and the GML table
// that says where each glyph is (scripts/scr_text_font/scr_text_font.gml).
// GameMaker only bakes font resources inside its IDE, and a running game can't read Windows'
// fonts, so the glyphs are drawn here like the rest of the art.
// It covers English, Turkish, Greek and the rest of Western Europe's letters.
// Run: node art_src/make_text_font.js <sharp module dir> <opentype.js module dir> <font .ttf> <output png> <output gml>
const fs = require("fs");
const sharp = require(process.argv[2] || "sharp");
const opentype = require(process.argv[3] || "opentype.js");
const font = opentype.loadSync(process.argv[4] || "C:/Windows/Fonts/arialbd.ttf");
const OUT_PNG = process.argv[5] || "text_font.png";
const OUT_GML = process.argv[6] || "scr_text_font.gml";

const SIZE = 19;            // pixels per em
const LINE = 3;             // outline width
const ATLAS_W = 1024;
const scale = SIZE / font.unitsPerEm;
const asc = Math.ceil(font.ascender * scale);
const desc = Math.ceil(-font.descender * scale);
const cellH = asc + desc + LINE * 2;

// The characters: printable ASCII, Latin-1, Latin Extended-A (Turkish ğ ı ş ...), Greek, and
// everyday punctuation (dashes, curly quotes, bullet, ellipsis, euro).
const codes = [];
const add = (a, b) => { for (let c = a; c <= b; c++) codes.push(c); };
add(32, 126); add(160, 383); add(0x370, 0x3ff);
[0x2013, 0x2014, 0x2018, 0x2019, 0x201c, 0x201d, 0x2022, 0x2026, 0x20ac].forEach((c) => codes.push(c));

const glyphs = [];
let x = 0, y = 0, svg = "";
for (const code of codes) {
  const g = font.charToGlyph(String.fromCodePoint(code));
  if (!g || g.index === 0) continue;                  // the font hasn't got it
  const adv = g.advanceWidth * scale;
  const path = g.getPath(0, asc + LINE, SIZE);
  const bb = path.getBoundingBox();
  const empty = !(bb.x2 > bb.x1);
  const left = empty ? 0 : Math.floor(bb.x1) - LINE;
  const w = empty ? 0 : Math.ceil(bb.x2) + LINE - left;
  if (x + w > ATLAS_W) { x = 0; y += cellH; }
  if (!empty) {
    const d = g.getPath(x - left, y + asc + LINE, SIZE).toPathData(2);
    svg += `<path d="${d}" fill="none" stroke="#101a40" stroke-width="${LINE * 2}" stroke-linejoin="round"/><path d="${d}" fill="#fff"/>`;
  }
  glyphs.push([code, x, y, w, left, Math.round(adv * 100) / 100]);
  x += w + 1;
}
const atlasH = y + cellH;

sharp(Buffer.from(`<svg xmlns="http://www.w3.org/2000/svg" width="${ATLAS_W}" height="${atlasH}">${svg}</svg>`))
  .png({ palette: true, colours: 96, compressionLevel: 9 }).toFile(OUT_PNG).then(() => console.log(`made ${glyphs.length} glyphs, atlas ${ATLAS_W} x ${atlasH}`));

const rows = [];
for (let i = 0; i < glyphs.length; i += 8) rows.push("        " + glyphs.slice(i, i + 8).map((g) => g.join(", ")).join(", ") + ",");
fs.writeFileSync(OUT_GML, `/// The chat and notes font (spr_text_font): made by art_src/make_text_font.js, don't edit by hand.

#macro TEXT_FONT_H ${cellH}         // a glyph cell's height in pixels (the outline included)

/// Glyph data by character code (as a string): [x, y, width, x offset, advance] in spr_text_font.
function text_font_glyphs()
{
    static _map = undefined;
    if (is_undefined(_map))
    {
        // code, x, y, width, x offset, advance
        var _d = [
${rows.join("\n")}
        ];
        _map = {};
        for (var _i = 0; _i < array_length(_d); _i += 6) _map[$ string(_d[_i])] = [_d[_i + 1], _d[_i + 2], _d[_i + 3], _d[_i + 4], _d[_i + 5]];
    }
    return _map;
}
`);
