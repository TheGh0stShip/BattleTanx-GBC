import sys; sys.path.insert(0,__import__('os').path.dirname(__file__)); from sm83 import decode
d=open(sys.argv[1],'rb').read()
a=int(sys.argv[2],16); n=int(sys.argv[3]); base=int(sys.argv[4],16) if len(sys.argv)>4 else (a if a<0x4000 else 0x4000+(a&0x3fff))
for _ in range(n):
    r=decode(d,a)
    if not r: print(f"{a:05x} {base:04x}: db ${d[a]:02x}"); a+=1; base+=1; continue
    l,f,o,k,c=r
    v=o[1] if o else 0
    if o and o[0]=='rel': v=base+(v-a)
    print(f"{a:05x} {base:04x}: {d[a:a+l].hex():8} {f.format(hex(v) if o else '')}"); a+=l; base+=l
