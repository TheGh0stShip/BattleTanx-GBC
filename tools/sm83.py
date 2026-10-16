"""SM83 (Game Boy CPU) instruction decoder producing RGBDS syntax."""
R8 = ["b", "c", "d", "e", "h", "l", "[hl]", "a"]
R16 = ["bc", "de", "hl", "sp"]
R16S = ["bc", "de", "hl", "af"]
CC = ["nz", "z", "nc", "c"]
ALU = ["add a,", "adc a,", "sub", "sbc a,", "and", "xor", "or", "cp"]
CB = ["rlc", "rrc", "rl", "rr", "sla", "sra", "swap", "srl"]
INVALID = {0xD3, 0xDB, 0xDD, 0xE3, 0xE4, 0xEB, 0xEC, 0xED, 0xF4, 0xFC, 0xFD}

# kind: 'jp','jr','call','ret','reti','rst','jphl', None
def decode(buf, i):
    """Return (length, fmt, operand, kind, cond) or None if invalid.
    fmt contains {} where the 16-bit/8-bit/target operand is formatted."""
    if i >= len(buf):
        return None
    op = buf[i]
    def n8():
        return buf[i + 1] if i + 1 < len(buf) else None
    def n16():
        return buf[i + 1] | (buf[i + 2] << 8) if i + 2 < len(buf) else None
    if op in INVALID:
        return None
    if op == 0x00: return (1, "nop", None, None, False)
    if op == 0x10:
        if n8() != 0x00: return None
        return (2, "stop", None, None, False)
    if op == 0x76: return (1, "halt", None, None, False)
    if op == 0xCB:
        b = n8()
        if b is None: return None
        x, y, z = b >> 6, (b >> 3) & 7, b & 7
        if x == 0: return (2, f"{CB[y]} {R8[z]}", None, None, False)
        return (2, f"{['', 'bit', 'res', 'set'][x]} {y}, {R8[z]}", None, None, False)
    x, y, z = op >> 6, (op >> 3) & 7, op & 7
    p, q = y >> 1, y & 1
    if x == 1:
        return (1, f"ld {R8[y]}, {R8[z]}", None, None, False)
    if x == 2:
        return (1, f"{ALU[y]} {R8[z]}", None, None, False)
    if x == 0:
        if z == 0:
            if y == 1:
                v = n16();
                if v is None: return None
                return (3, "ld [{}], sp", ("a16", v), None, False)
            if y == 3 or y >= 4:
                d = n8()
                if d is None: return None
                t = (i + 2 + (d - 256 if d >= 128 else d))
                if y == 3: return (2, "jr {}", ("rel", t), "jr", False)
                return (2, f"jr {CC[y-4]}, {{}}", ("rel", t), "jr", True)
        if z == 1:
            if q == 0:
                v = n16()
                if v is None: return None
                return (3, f"ld {R16[p]}, {{}}", ("n16", v), None, False)
            return (1, f"add hl, {R16[p]}", None, None, False)
        if z == 2:
            m = ["[bc]", "[de]", "[hli]", "[hld]"][p]
            return (1, f"ld {m}, a" if q == 0 else f"ld a, {m}", None, None, False)
        if z == 3: return (1, f"{'inc' if q == 0 else 'dec'} {R16[p]}", None, None, False)
        if z == 4: return (1, f"inc {R8[y]}", None, None, False)
        if z == 5: return (1, f"dec {R8[y]}", None, None, False)
        if z == 6:
            d = n8()
            if d is None: return None
            return (2, f"ld {R8[y]}, {{}}", ("n8", d), None, False)
        if z == 7:
            return (1, ["rlca", "rrca", "rla", "rra", "daa", "cpl", "scf", "ccf"][y], None, None, False)
    # x == 3
    if z == 0:
        if y < 4: return (1, f"ret {CC[y]}", None, "ret", True)
        d = n8()
        if d is None: return None
        if y == 4: return (2, "ldh [{}], a", ("h8", d), None, False)
        if y == 6: return (2, "ldh a, [{}]", ("h8", d), None, False)
        if y == 5: return (2, "add sp, {}", ("s8", d), None, False)
        return (2, "ld hl, sp+{}", ("s8u", d), None, False)
    if z == 1:
        if q == 0: return (1, f"pop {R16S[p]}", None, None, False)
        return [(1, "ret", None, "ret", False), (1, "reti", None, "reti", False),
                (1, "jp hl", None, "jphl", False), (1, "ld sp, hl", None, None, False)][p]
    if z == 2:
        if y < 4:
            v = n16()
            if v is None: return None
            return (3, f"jp {CC[y]}, {{}}", ("a16", v), "jp", True)
        if y == 4: return (1, "ldh [c], a", None, None, False)
        if y == 6: return (1, "ldh a, [c]", None, None, False)
        v = n16()
        if v is None: return None
        return (3, "ld [{}], a" if y == 5 else "ld a, [{}]", ("a16", v), None, False)
    if z == 3:
        if y == 0:
            v = n16()
            if v is None: return None
            return (3, "jp {}", ("a16", v), "jp", False)
        if y == 6: return (1, "di", None, None, False)
        if y == 7: return (1, "ei", None, None, False)
        return None
    if z == 4:
        v = n16()
        if v is None: return None
        return (3, f"call {CC[y]}, {{}}", ("a16", v), "call", True)
    if z == 5:
        if q == 0: return (1, f"push {R16S[p]}", None, None, False)
        v = n16()
        if v is None: return None
        return (3, "call {}", ("a16", v), "call", False)
    if z == 6:
        d = n8()
        if d is None: return None
        return (2, f"{ALU[y]} {{}}", ("n8", d), None, False)
    if z == 7:
        return (1, "rst {}", ("rst", y * 8), "rst", False)
