extends Node2D
# 격자 배경 — 에셋 없이도 보이는 필드 느낌
const TILE := 64
const COLS := 32
const ROWS := 24
const COLOR_A := Color(0.08, 0.08, 0.12, 1.0)
const COLOR_B := Color(0.10, 0.10, 0.16, 1.0)
const LINE_COLOR := Color(0.18, 0.18, 0.25, 1.0)

func _draw() -> void:
	for row in ROWS:
		for col in COLS:
			var c := COLOR_A if (row + col) % 2 == 0 else COLOR_B
			draw_rect(Rect2(col * TILE, row * TILE, TILE, TILE), c)
	# 격자 선
	for col in COLS + 1:
		draw_line(Vector2(col * TILE, 0), Vector2(col * TILE, ROWS * TILE), LINE_COLOR, 1.0)
	for row in ROWS + 1:
		draw_line(Vector2(0, row * TILE), Vector2(COLS * TILE, row * TILE), LINE_COLOR, 1.0)
