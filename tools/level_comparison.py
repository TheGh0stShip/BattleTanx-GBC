#!/usr/bin/env python3
"""Generate or validate the deterministic per-level comparison report.

Usage: level_comparison.py OUT.json
       level_comparison.py --check
"""
import sys,json,collections,hashlib
import pathlib; ROOT = pathlib.Path(__file__).resolve().parent.parent; sys.path.insert(0, str(ROOT / 'tools'))
if len(sys.argv) != 2:
    raise SystemExit("usage: level_comparison.py OUT.json | --check")
CHECK = sys.argv[1] == "--check"
OUTPUT = ROOT / "reports" / "level_comparison.json" if CHECK else pathlib.Path(sys.argv[1])
import level_data as L
rom=open(ROOT / 'baserom.gbc','rb').read()
lvs=L.parse_levels(rom)
out={"levels":[],"duplication":{}}
blobs={}
for lv in lvs:
    o,e=lv.cell_bank,lv.map_bank
    cells=L.read(rom,o,0x4000,lv.cells); tm=L.read(rom,e,0x4000,lv.cells); am=L.read(rom,e,lv.attrmap_addr,lv.cells)
    tiles=L.read(rom,o,lv.tiles_addr,16*lv.tile_count); lut=L.read(rom,o,lv.attr_table_addr,0xA0)
    pals=L.read(rom,o,lv.palettes_addr,8*lv.palette_count)
    theme=L.word(rom,5,0x5120+2*lv.number)
    used={L.tile_number(t,a) for t,a in zip(tm,am)}
    blobs[lv.number]=dict(cells=cells,tm=tm,am=am,tiles=tiles,lut=lut,pals=pals,w=lv.width)
    C=collections.Counter
    out["levels"].append(dict(level=lv.number,width=lv.width,height=lv.height,cells=lv.cells,tile_count=lv.tile_count,
     palette_count=lv.palette_count,record_hex=lv.record.hex(),lut_ptr=f"{lv.attr_table_bank:02X}:{lv.attr_table_addr:04X}",
     theme_ptr=f"05:{theme:04X}",cell_hist={f"{k:02X}":v for k,v in sorted(C(cells).items())},
     cell_low6_hist={f"{k:02X}":v for k,v in sorted(C(c&63 for c in cells).items())},
     attr_palette=dict(sorted(C(a&7 for a in am).items())),attr_vram1=sum(a>>3&1 for a in am),
     attr_xflip=sum(a>>5&1 for a in am),attr_yflip=sum(a>>6&1 for a in am),attr_priority=sum(a>>7&1 for a in am),
     distinct_tiles_used=len(used),unused_tiles=lv.tile_count-len(used),
     distinct_tilemap_entries=len(set(zip(tm,am))),
     lut_sha1=hashlib.sha1(lut).hexdigest()[:12],pal_sha1=hashlib.sha1(pals).hexdigest()[:12],tiles_sha1=hashlib.sha1(tiles).hexdigest()[:12]))
N=range(15)
def tl(b): return [b[i:i+16] for i in range(0,len(b),16)]
blank={bytes(16),b'\xff'*16}
tsets={n:set(tl(blobs[n]['tiles'])) for n in N}
# pairwise
pair={}
for a in N:
  for b in N:
    if a<b:
      sh=tsets[a]&tsets[b]
      ta,tb=tl(blobs[a]['tiles']),tl(blobs[b]['tiles'])
      # longest same-position run & longest common contiguous run (tiles)
      idx=collections.defaultdict(list)
      for i,t in enumerate(tb): idx[t].append(i)
      best=0;bi=None
      for i,t in enumerate(ta):
        for j in idx.get(t,()):
          if i and j and ta[i-1]==tb[j-1]: continue
          k=0
          while i+k<len(ta) and j+k<len(tb) and ta[i+k]==tb[j+k]: k+=1
          if k>best: best,bi=k,(i,j)
      ra=set(blobs[a]['tm'][r*blobs[a]['w']:(r+1)*blobs[a]['w']]+blobs[a]['am'][r*blobs[a]['w']:(r+1)*blobs[a]['w']] for r in range(len(blobs[a]['tm'])//blobs[a]['w']))
      rb=set(blobs[b]['tm'][r*blobs[b]['w']:(r+1)*blobs[b]['w']]+blobs[b]['am'][r*blobs[b]['w']:(r+1)*blobs[b]['w']] for r in range(len(blobs[b]['tm'])//blobs[b]['w']))
      pa=set(tl(blobs[a]['pals'][:]) )
      pals_a={blobs[a]['pals'][i:i+8] for i in range(0,len(blobs[a]['pals']),8)}
      pals_b={blobs[b]['pals'][i:i+8] for i in range(0,len(blobs[b]['pals']),8)}
      pair[f"{a}-{b}"]=dict(shared_tiles=len(sh),shared_nonblank=len(sh-blank),longest_tile_run=best,run_at=bi,
        lut_equal=blobs[a]['lut']==blobs[b]['lut'],lut_bytes_equal=sum(x==y for x,y in zip(blobs[a]['lut'],blobs[b]['lut'])),
        shared_palettes=len(pals_a&pals_b),palset_equal=blobs[a]['pals']==blobs[b]['pals'],
        shared_map_rows=len(ra&rb) if blobs[a]['w']==blobs[b]['w'] else None)
out["duplication"]["pairs"]=pair
out["duplication"]["intra_level_dup_tiles"]={n:len(tl(blobs[n]['tiles']))-len(tsets[n]) for n in N}
out["duplication"]["blank_tile_present"]={n:sorted(t.hex() for t in blank if t in tsets[n]) for n in N}
g=collections.defaultdict(list)
for l in out["levels"]: g[l["theme_ptr"]].append(l["level"])
out["theme_groups"]=g
rendered = json.dumps(out, indent=1)
if CHECK:
  if not OUTPUT.exists() or OUTPUT.read_text() != rendered:
    raise SystemExit("level comparison: report is stale; regenerate with tools/level_comparison.py reports/level_comparison.json")
  print("level comparison: report matches all 15 levels")
else:
  OUTPUT.write_text(rendered)
for l in out["levels"]:
  pass  # print(l["level"],l["width"],l["height"],l["tile_count"],l["palette_count"],l["record_hex"],l["lut_ptr"],l["theme_ptr"],l["distinct_tiles_used"],l["attr_palette"],l["attr_vram1"],l["attr_xflip"],l["attr_yflip"],l["attr_priority"],l["cell_hist"],l["lut_sha1"])
pass  # print(dict(g))
for k,v in pair.items():
  if v["shared_nonblank"] or v["lut_bytes_equal"]>100 or v["shared_palettes"] or v["shared_map_rows"]: None and print(k,v)
pass  # print(out["duplication"]["intra_level_dup_tiles"],out["duplication"]["blank_tile_present"])
