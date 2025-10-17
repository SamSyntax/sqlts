build:
	@zig build
run:
	@make build && ./zig-out/bin/sqlts ./sql-examples/ ./test.ts
test:
	zig test src/tests.zig
