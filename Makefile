all: lua/scpaste.lua

lua/%.lua: fnl/%.fnl
	fennel -c $< > $@

clean:
	rm lua/*.lua

.PHONY: clean all
