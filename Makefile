# BattleTanx (USA) - Game Boy Color disassembly
ROM     := battletanx.gbc
BASEROM := baserom.gbc
PYTHON  ?= python3
SRCS    := $(wildcard src/*.asm) $(wildcard include/*.inc)

.PHONY: all check compare check-project check-baserom assets graphics disasm clean tidy

all: compare

check: compare check-project graphics

check-project: assets
	$(PYTHON) tools/check_project.py

check-baserom:
	@$(PYTHON) tools/verify_rom.py $(BASEROM)

assets: assets.txt check-baserom
	$(PYTHON) tools/extract_assets.py $(BASEROM) assets.txt

graphics: graphics.txt check-baserom
	$(PYTHON) tools/extract_graphics.py $(BASEROM) graphics.txt build/graphics

# Regenerate src/ from the base ROM (overwrites src/!)
disasm: check-baserom
	$(PYTHON) tools/disasm.py $(BASEROM) .

build/main.o: $(SRCS) | assets
	@mkdir -p build
	rgbasm -Werror -o $@ src/main.asm

$(ROM): build/main.o
	rgblink -p 0xFF -n $(ROM:.gbc=.sym) -m $(ROM:.gbc=.map) -o $@ $<

compare: $(ROM)
	$(PYTHON) tools/verify_rom.py $(ROM) $(BASEROM)

tidy:
	rm -rf build $(ROM) $(ROM:.gbc=.sym) $(ROM:.gbc=.map)

clean: tidy
	rm -rf assets
