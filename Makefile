# BattleTanx (USA) - Game Boy Color disassembly
ROM     := battletanx.gbc
BASEROM := baserom.gbc
PYTHON  ?= python3
SRCS    := $(wildcard src/*.asm) $(wildcard include/*.inc)

.PHONY: all check compare check-project check-baserom extract-assets graphics maps levels screens disasm clean tidy

all: compare

check: compare check-project graphics maps levels screens

check-project:
	$(PYTHON) tools/check_project.py

check-baserom:
	@$(PYTHON) tools/verify_rom.py $(BASEROM)

# Maintenance target for deliberately refreshing the committed source assets.
extract-assets: assets.txt check-baserom
	$(PYTHON) tools/extract_assets.py $(BASEROM) assets.txt

graphics: graphics.txt check-baserom
	$(PYTHON) tools/extract_graphics.py $(BASEROM) graphics.txt build/graphics

maps: check-baserom
	$(PYTHON) tools/extract_scene_maps.py $(BASEROM) build/maps

levels: check-baserom
	$(PYTHON) tools/extract_level_data.py $(BASEROM) build/levels

screens: check-baserom
	$(PYTHON) tools/extract_screen_data.py $(BASEROM) build/screens

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
