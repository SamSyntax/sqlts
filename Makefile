build:
	@zig build
run:
	@make build && ./zig-out/bin/sqlts {a..e}
