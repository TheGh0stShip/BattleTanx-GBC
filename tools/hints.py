"""Manually identified entry points and tables for the tracer."""

# Screen/mode table in bank 1 at $47EC: 8-byte entries
#   db bank, 0 ; dw init, update ; dw 0
SCREEN_TABLE = (1, 0x47EC, 13)

# Bank 3 state dispatcher at $6878 indexes this 15-entry pointer table with
# the value at $CA06.
STATE_CHECK_TABLE = (3, 0x685A, 15)

# Bank 1 dispatcher at $44F4 uses an entity field at offset $1E as an index.
ENTITY_HANDLER_TABLE = (1, 0x44E0, 10)

# Bank 1 routines at $4E35/$4E60 select and identify the active callback.
RUNTIME_CALLBACK_TABLE = (1, 0x4E2F, 3)

# Confirmed non-code ranges, expressed as half-open ROM offsets. These prevent
# the conservative gap pass from interpreting pointer bytes as instructions.
DATA_RANGES = (
    (0x0000, 0x0040),  # unused restart vectors / fixed-bank metadata
    (0x0104, 0x0150),  # cartridge header
    (0x44E0, 0x44F4),  # entity handler pointers
    (0x47EC, 0x4854),  # banked screen mode records
    (0x4E2F, 0x4E35),  # runtime callback pointers
    (0xE85A, 0xE878),  # state check pointers
)


def screen_entries(rom):
    out = []
    bank, addr, n = SCREEN_TABLE
    base = bank * 0x4000 + addr - 0x4000
    for i in range(n):
        e = rom[base + i * 8: base + i * 8 + 8]
        for p in (e[2] | e[3] << 8, e[4] | e[5] << 8):
            out.append((e[0], p))
    return out


def pointer_table_entries(rom, table):
    bank, addr, count = table
    base = bank * 0x4000 + addr - 0x4000
    return [
        (bank, rom[base + i * 2] | rom[base + i * 2 + 1] << 8)
        for i in range(count)
    ]


def extra_entries(rom):
    # banks $2B-$2E share an init/update stub layout at $4000/$4058
    return (
        screen_entries(rom)
        + pointer_table_entries(rom, STATE_CHECK_TABLE)
        + pointer_table_entries(rom, ENTITY_HANDLER_TABLE)
        + pointer_table_entries(rom, RUNTIME_CALLBACK_TABLE)
        + [(0x2e, 0x4000), (0x2e, 0x4058)]
    )

CODE_BANKS = [0, 1, 2, 3, 4, 5, 6, 7, 8, 0x2a, 0x2b, 0x2c, 0x2d, 0x2e]

# Hand-assigned names: rom offset -> label
NAMES = {
    0x0040: "VBlankInterrupt",
    0x0048: "LCDInterrupt",
    0x0050: "TimerInterrupt",
    0x0058: "SerialInterrupt",
    0x0060: "JoypadInterrupt",
    0x0100: "Boot",
    0x0150: "Init",
    0x06AB: "EnableDoubleSpeed",
    0x0911: "LoadOAMDMARoutine",
    0x0925: "OAMDMARoutine",
    0x0A8F: "CopyBytes",
    0x0AA4: "CopyBytesShort",
    0x39A7: "ScreenTable_CallInit",
    0x39CD: "ScreenTable_CallUpdate",
    0x39FB: "ScreenTable_LoadEntry",
    0x47EC: "ScreenModeTable",
    0x44E0: "EntityHandlerTable",
    0x44F4: "DispatchEntityHandler",
    0x4E2F: "RuntimeCallbackTable",
    0xE85A: "StateCheckTable",
    0xE878: "DispatchStateCheck",
}
