# BattleTanx (USA) - Game Boy Color disassembly
ROM     := battletanx.gbc
BASEROM := baserom.gbc
PYTHON  ?= python3
SRCS    := $(wildcard src/*.asm) $(wildcard include/*.inc)

.PHONY: all check verify-source check-repository compare check-project check-baserom check-assets extract-assets graphics maps levels screens objects bank08 relocation banks0105 completion passwords progress report diag disasm clean tidy

all: compare

check: compare check-project check-assets graphics maps levels screens objects bank08 relocation banks0105 completion passwords progress check-repository

# ROM-independent gate used by pull requests and ordinary source review.
verify-source: $(ROM) progress report check-repository

check-repository:
	$(PYTHON) tools/check_repository.py

check-project:
	$(PYTHON) tools/check_project.py

check-baserom:
	@$(PYTHON) tools/verify_rom.py $(BASEROM)

check-assets: check-baserom
	$(PYTHON) tools/prepare_assets.py $(BASEROM) --check

# Maintenance target for deliberately refreshing the committed source assets.
extract-assets: assets.txt check-baserom
	$(PYTHON) tools/prepare_assets.py $(BASEROM)

graphics: graphics.txt check-baserom
	$(PYTHON) tools/extract_graphics.py $(BASEROM) graphics.txt build/graphics

maps: check-baserom
	$(PYTHON) tools/extract_scene_maps.py $(BASEROM) build/maps

levels: check-baserom
	$(PYTHON) tools/extract_level_data.py $(BASEROM) build/levels

screens: check-baserom
	$(PYTHON) tools/extract_screen_data.py $(BASEROM) build/screens

objects: check-baserom
	$(PYTHON) tools/extract_object_banks.py $(BASEROM) build/objects

bank08: check-baserom
	$(PYTHON) tools/extract_bank08.py $(BASEROM) build/bank08

# Relocation audit (needs the linked symbols) and source shift tests.
relocation: compare
	$(PYTHON) tools/relocation_audit.py
	$(PYTHON) tools/level_comparison.py --check
	$(PYTHON) tools/shift_test.py .

# Banks $01-$05 structure, reports and shift tests (needs the linked symbols).
banks0105: compare
	$(PYTHON) tools/banks_01_05.py
	$(PYTHON) tools/object_sequence_fields.py
	$(PYTHON) tools/shift_test_01_05.py .

# Whole-ROM range map, operand/indirect audit and completion invariants.
completion: compare
	$(PYTHON) tools/rom_range_map.py
	$(PYTHON) tools/operand_audit.py
	$(PYTHON) tools/completion_invariants.py
	$(PYTHON) tools/semantic_invariants.py

# ROM-derived password list and encoder/decoder round trips.
passwords:
	$(PYTHON) tools/passwords.py --check

# Diagnostic (non-shipping) ROM that traps scene-handler calls into bank-$01 ROM
# while another bank is mapped; written to build/diag/, never touches src/.
diag: compare
	$(PYTHON) tools/diag_bank_trap.py

# Semantic naming progress, kept separate from traced-byte coverage.
progress: $(ROM)
	$(PYTHON) tools/source_progress.py $(ROM:.gbc=.sym)

# objdiff v2 reconstruction report consumed by byte-match trackers.
report: $(ROM)
	$(PYTHON) tools/bytematch_report.py --out report.json

# Regenerate src/ from the base ROM (overwrites src/!)
disasm: check-baserom
	$(PYTHON) tools/disasm.py $(BASEROM) .

build/main.o: $(SRCS) assets.txt
	@mkdir -p build
	rgbasm -Werror -o $@ src/main.asm

$(ROM): build/main.o
	rgblink -p 0xFF -n $(ROM:.gbc=.sym) -m $(ROM:.gbc=.map) -o $@ $<

compare: $(ROM)
	$(PYTHON) tools/verify_rom.py $(ROM) $(BASEROM)

tidy:
	rm -rf build $(ROM) $(ROM:.gbc=.sym) $(ROM:.gbc=.map)

clean: tidy
