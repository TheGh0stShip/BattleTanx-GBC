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

# Five menu/flow-state headers in bank 1. Each header is
#   db state id, screen-init index, screen-update index ; dw input callback
# and is followed by 16-byte choice records terminated by $FF. State $05's
# callback runs from the image copied from $01:$51CC to WRAM $D70A.
MENU_STATE_HEADERS = (0x4855, 0x48AB, 0x48F1, 0x4927, 0x495D)

# Confirmed non-code ranges, expressed as half-open ROM offsets. These prevent
# the conservative gap pass from interpreting pointer bytes as instructions.
DATA_RANGES = (
    (0x0000, 0x0040),  # unused restart vectors / fixed-bank metadata
    (0x0104, 0x0150),  # cartridge header
    (0x44E0, 0x44F4),  # entity handler pointers
    (0x47EC, 0x4854),  # banked screen mode records
    (0x4854, 0x49CB),  # menu/flow states, choice records, and option strings
    (0x4E2F, 0x4E35),  # runtime callback pointers
    (0xE85A, 0xE878),  # state check pointers
    (0x22DF0, 0x24000),  # bank 8 zero padding and bank marker
)

# Reviewed standalone routine entries that are not reached by the static bank
# and pointer propagation above. Each range was checked for coherent SM83
# decoding, internal branch targets, and a valid terminating control transfer.
MANUAL_ENTRIES = (
    (0x00, 0x004E), (0x00, 0x047C), (0x00, 0x04F4), (0x00, 0x06D6),
    (0x00, 0x0D05), (0x00, 0x164F), (0x00, 0x2080), (0x00, 0x2B58),
    (0x00, 0x2B75), (0x00, 0x2B7F), (0x00, 0x3004), (0x00, 0x35C6),
    (0x00, 0x362D),
    (0x00, 0x389A), (0x00, 0x3BD5), (0x00, 0x3BF7), (0x00, 0x3CC2),
    (0x01, 0x4102), (0x01, 0x42EF), (0x01, 0x4CAA), (0x01, 0x4EEC),
    (0x01, 0x5013), (0x01, 0x507F), (0x01, 0x543E), (0x01, 0x5619),
    (0x01, 0x57E1),
    (0x01, 0x6243), (0x01, 0x6762), (0x01, 0x6940), (0x01, 0x6A72),
    (0x01, 0x6B72), (0x01, 0x6C24), (0x01, 0x6D99), (0x01, 0x7981),
    (0x01, 0x7AA3),
    (0x02, 0x4D6A), (0x02, 0x4E0E), (0x02, 0x4E84), (0x02, 0x4E9F),
    (0x02, 0x5D33),
    (0x02, 0x635F),
    (0x02, 0x63F4),
    (0x03, 0x5FBF), (0x03, 0x61FC), (0x03, 0x6575),
    (0x04, 0x62F7),
)

# Literal options-menu strings. Other visible game text is stored as graphics
# or encoded data rather than plain ASCII.
TEXT_STRINGS = {
    0x48C6: b"MUSIC",
    0x48D6: b"CONTROL",
    0x48E6: b"SKILL",
    0x4993: b"ON ",
    0x4997: b"OFF",
    0x499B: b"1",
    0x49A3: b"2",
    0x49AB: b"3",
    0x49B3: b"EASY",
    0x49BB: b"MED ",
    0x49C3: b"HARD",
}


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
        + [
            (0 if (ptr := rom[a + 3] | rom[a + 4] << 8) >= 0x8000 else 1, ptr)
            for a in MENU_STATE_HEADERS
        ]
        + list(MANUAL_ENTRIES)
        + [(0x2e, 0x4000), (0x2e, 0x4058)]
    )

CODE_BANKS = [0, 1, 2, 3, 4, 5, 6, 7, 8, 0x2a, 0x2b, 0x2c, 0x2d, 0x2e]

# Hand-assigned names: rom offset -> label
NAMES = {
    0x0040: "VBlankInterrupt",
    0x0048: "LCDInterrupt",
    0x0050: "TimerInterrupt",
    0x0051: "EnableLCD",
    0x0058: "SerialInterrupt",
    0x0059: "ClearBytes",
    0x0060: "JoypadInterrupt",
    0x0100: "Boot",
    0x0150: "Init",
    0x00F9: "EnableBackground",
    0x0388: "BeginLevelCompleteCountdown",
    0x0396: "BeginPlayerDestroyedCountdown",
    0x03CB: "ResetLevelEndState",
    0x03DB: "UpdateLevelEndCountdown",
    0x0413: "SeedRandomNumberGenerator",
    0x0421: "RandomByte",
    0x043C: "RandomBelowB",
    0x047C: "CopyTilemapRows20",
    0x049E: "WriteBgMapTileAndAttribute",
    0x04B6: "DisableLCDSafely",
    0x04CD: "ClearCgbPalettes",
    0x04F4: "ClearHardwareOAM",
    0x050B: "ClearMemory",
    0x0514: "SetBackgroundPaletteColor",
    0x052F: "LoadBackgroundPaletteRange",
    0x0553: "LoadSingleObjectPalette",
    0x057D: "LoadObjectPaletteRange",
    0x05AB: "FillBytes",
    0x05B7: "CopyBytesBC",
    0x0622: "CopyTilesToVRAM",
    0x06AB: "EnableDoubleSpeed",
    0x0651: "RequireCgbHardware",
    0x072C: "ClearGameMemory",
    0x0764: "ResetDisplayState",
    0x0781: "ResetOamState",
    0x08C6: "InitializeHardware",
    0x0903: "LoadCurrentLevel",
    0x0911: "LoadOAMDMARoutine",
    0x0925: "OAMDMARoutine",
    0x0A59: "ReadJoypad",
    0x0AD5: "CreateObjectAtOrigin",
    0x0C3D: "ObjectMaxHealthByType",
    0x0C41: "GetObjectMaxHealth",
    0x0D05: "GetObjectType",
    0x0D0F: "InitializeObjectType",
    0x1927: "PositionPlayerAtSpawn",
    0x194B: "CenterLevelViewOnObject",
    0x1FF5: "AllocateObjectRecord",
    0x2028: "ClearObjectPool",
    0x2044: "FreeObjectRecord",
    0x2058: "ResetSpriteAllocators",
    0x2080: "ClassifyShadowOamCapacity",
    0x2090: "AllocateShadowOamFront",
    0x20B1: "AllocateShadowOamBack",
    0x20D2: "AllocateDynamicSpriteTiles",
    0x20FE: "ClearUnusedShadowOamEntries",
    0x2115: "SetObjectDirection",
    0x2125: "SetObjectPosition",
    0x214D: "UpdateObjectScreenPosition",
    0x21F7: "SaveObjectPreviousPosition",
    0x221F: "CommitObjectNextPosition",
    0x0A8F: "CopyBytes",
    0x0AA4: "CopyBytesShort",
    0x39A7: "ScreenTable_CallInit",
    0x3971: "WaitForButtonOrTimeout",
    0x39CD: "ScreenTable_CallUpdate",
    0x39FB: "ScreenTable_LoadEntry",
    0x2EB8: "Audio_InitFar",
    0x2ED5: "Music_Update",
    0x2F21: "Audio_Update",
    0x2F73: "Audio_QueueSound",
    0x2F93: "SetObjectHealthToMax",
    0x2FA3: "AddObjectHealth",
    0x2FBB: "SubtractObjectHealth",
    0x2FCE: "UpdatePlayerHealthRecovery",
    0x2FED: "GainPlayerLife",
    0x2FF9: "LosePlayerLife",
    0x3004: "ResetPlayerLives",
    0x300A: "ResetScore",
    0x302D: "CheckNextScoreThreshold",
    0x3104: "RenderObjectSprite",
    0x315F: "BuildObjectOamEntries",
    0x3190: "LoadObjectAnimationTiles",
    0x31E3: "AdvanceTimedObjectEffect",
    0x3CFB: "StartScreenEffect",
    0x3D70: "PreserveScreenEffectObjects",
    0x3D81: "ProcessNextScreenEffectObject",
    0x3DD8: "LoadScreenEffectPart",
    0x3E05: "RenderScreenEffect",
    0x3E3C: "CopyScreenEffectPartTiles",
    0x3E81: "BuildScreenEffectPartOam",
    0x3EB9: "RandomlyBlankDisplay",
    0x3ED1: "UpdateScreenEffect",
    0x0402: "LoadLevelLookupPointersFar",
    0x05C5: "CopyScreenMaps",
    0x06F8: "FadePalettesToBlackWithSound",
    0x071F: "FadeBackgroundPalettesToWhiteWithSound",
    0x09AB: "InitializeLevelRuntime",
    0x0AB3: "InstallGameplayInterruptHandlersFar",
    0x0AC4: "InstallBasicInterruptHandlersFar",
    0x0B65: "RedrawLevelCells2x3AroundPixel",
    0x0AF5: "RemoveObject",
    0x3C19: "ResetBgMapWriteQueue",
    0x3C28: "QueueBgMapWrite",
    0x3C56: "FlushBgMapWriteQueue",
    0x3C7A: "ApplyBgMapWrite",
    0x035C: "PrepareDisplayForScreenTransition",
    0x033A: "RunPauseLoopFar",
    0x3608: "ProcessGameplayInput",
    0x364E: "HandleControlScheme0",
    0x367F: "HandleControlScheme1",
    0x36AF: "HandleControlScheme2",
    0x0C51: "AccelerateVehicleReverse",
    0x0C74: "AccelerateVehicleForward",
    0x0C97: "DecelerateVehicle",
    0x0CA8: "StopVehicle",
    0x0CB5: "TurnVehicleCounterclockwise",
    0x0CDD: "TurnVehicleClockwise",
    0x0BA1: "CalculateVehicleNextPosition",
    0x2241: "LoadVehicleForwardVelocity",
    0x2295: "LoadVehicleReverseVelocity",
    0x104B: "UpdateVehicleTimersAndRemoveDestroyed",
    0x22ED: "UpdateAllObjects",
    0x0F98: "UsePlayerWeaponOrPowerup",
    0x1023: "QueueVehicleActionSound",
    0x2B86: "SpawnVehicleProjectile",
    0x2C24: "GetVehicleMuzzlePositionFar",
    0x307F: "SpawnVehicleMuzzleEffectFar",
    0x3090: "SpawnTimedObjectEffect",
    0x37CE: "InitializeLevelObjectsFar",
    0x3834: "DispatchLevelStateCheckFar",
    0x3775: "UpdateStatus4ObjectLifetime",
    0x3793: "RenderStatus4Object",
    0x37BD: "RenderStatus4ObjectSpriteFar",
    0x372E: "SpawnStatus4Object",
    0x06C5: "ConvertU8ToPackedBcdFar",
    0x06D6: "ConvertU16ToPackedBcdFar",
    0x06E7: "ConvertU32ToPackedBcdFar",
    0x034B: "HandlePlayerLifeLossFar",
    0x35F7: "AnimatePlayerHealthBarFillFar",
    0x3202: "CopyMapRows20Wide",
    0x32A3: "LoadHudBaseMapsFar",
    0x32B4: "DrawEmptyHudHealthBar",
    0x32DE: "LoadPauseHudMapsFar",
    0x3F28: "RunNoLivesScreenFar",
    0x28C5: "ResolveProjectileHit",
    0x2977: "TestObjectScreenProximity12",
    0x29B8: "GetHalfObjectManhattanDistance",
    0x2A15: "GetDirectionTowardObject",
    0x2DCB: "FindNearestVisibleObjectFacingSource",
    0x2EA7: "GetDirectionDifferenceFar",
    0x2C35: "ReleaseProjectileOwnerShotSlot",
    0x2C58: "CalculateProjectileNextPosition",
    0x2CC3: "UpdateProjectileLifetimeAndHoming",
    0x2CF1: "SteerHomingProjectile",
    0x2E67: "InitializeHomingProjectileTarget",
    0x30D1: "InitializeTimedEffectSubtype1Far",
    0x30E2: "InitializeTimedEffectSubtype0Far",
    0x30F3: "InitializeTimedEffectSubtype2Far",
    0x0192: "RunLevel",
    0x3B9F: "RunBootScreenSequenceFar",
    0x3F1F: "RunScreenMode8ActivityFar",
    0x3CD9: "ClearShadowOamAndTransferFar",
    0x322D: "InitializeHudWindow",
    0x3252: "MoveHudWindow",
    0x325B: "RefreshHud",
    0x32EF: "DisableHudWindow",
    0x3302: "DrawHudStatus",
    0x330F: "MultiplyU8ByU16",
    0x3344: "HudHealthScaleByType",
    0x334A: "DrawPlayerHealthBar",
    0x3439: "DrawHudPowerupAndAlert",
    0x34D3: "HudPowerupFirstTiles",
    0x34D7: "HudPowerupPalettes",
    0x34DF: "DrawPlayerPowerupIcon",
    0x3546: "DrawHudScoreDigit",
    0x356B: "DrawHudScore",
    0x3533: "DrawPlayerLivesDigit",
    0x35D7: "SpawnPlayerObject",
    0x37AC: "SelectObjectSpritePaletteFar",
    0x37DF: "QueuePendingLevelObjectFar",
    0x37F0: "UpdatePendingLevelObjectsFar",
    0x3856: "DarkenRgb555",
    0x3867: "BrightenRgb555",
    0x3878: "DarkenBackgroundPalettes",
    0x3889: "FadeBackgroundPalettesToWhite",
    0x3960: "ClearBackgroundPalettes",
    0x3A1E: "DarkenObjectPalettes",
    0x3A2F: "BuildBackgroundPaletteFadeFrames",
    0x3A40: "GetBackgroundPaletteFrameAddress",
    0x3A52: "LoadBackgroundPaletteFrame",
    0x3A68: "CopyBackgroundPaletteFromFrame",
    0x3A88: "PrepareBackgroundPaletteFade",
    0x1BCAE: "Audio_Init",
    0x1BD11: "Music_HandleEvent",
    0x1BE41: "Audio_PlaySound",
    0x1BEFD: "SfxSequence_Update",
    0x22DD5: "SelectObjectSpritePalette",
    0x47EC: "ScreenModeTable",
    0x44E0: "EntityHandlerTable",
    0x44F4: "DispatchEntityHandler",
    0x4E2F: "RuntimeCallbackTable",
    0x4D33: "HandleMenuState00Input",
    0x4D94: "HandleMenuState04Input",
    0x507F: "HandleMenuState03Input",
    0x51CC: "HandleMenuState05Input",
    0x5287: "HandleMenuState06Input",
    0xE85A: "StateCheckTable",
    0xE878: "DispatchStateCheck",
    0xE7FA: "QuantizeSignedVectorDirection",
    0xE887: "Level00StateCheck",
    0xE88F: "Level01StateCheck",
    0xE89D: "Level02StateCheck",
    0xE8A5: "Level03StateCheck",
    0xE8AD: "Level04StateCheck",
    0xE8B5: "Level05StateCheck",
    0xE8BD: "Level06StateCheck",
    0xE8C5: "Level07StateCheck",
    0xE8CD: "Level08StateCheck",
    0xE8DB: "Level09StateCheck",
    0xE8E9: "Level10StateCheck",
    0xE8F1: "Level11StateCheck",
    0xE8F9: "Level12StateCheck",
    0xE901: "Level13StateCheck",
    0xE909: "Level14StateCheck",
    0x12343: "QueuePendingLevelObject",
    0x12392: "UpdatePendingLevelObjects",
    0x123D0: "TrySpawnPendingLevelObject",
    0x1255C: "AbsoluteDifferenceBCDE",
}
