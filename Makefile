build:
	@zig build
run:
	@make build && ./zig-out/bin/sqlts ./sql-examples/tricky.sql ./test.ts
