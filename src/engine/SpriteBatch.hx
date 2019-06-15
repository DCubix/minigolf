package engine;

import engine.AssetManager.Sprite;

enum DrawType {
	SPRITE;
	TILE;
}

enum Sorting {
	Y_SORT;
	NO_SORTING;
}

class DrawCommand {
	public var x: Int;
	public var y: Int;
	public var ox: Int;
	public var oy: Int;
	public var drawType: DrawType;

	public var sprite: Sprite;

	public var sx: Int;
	public var sy: Int;
	public var sw: Int;
	public var sh: Int;

	public var tileIndex: Int;
	public var rows: Int;
	public var cols: Int;

	public function new() {}
}

class SpriteBatch {
	private var commands: Array<DrawCommand>;

	public function new() {
		this.commands = new Array();
	}

	public function drawSprite(spr: Sprite, x: Int, y: Int, ?sx: Int = 0, ?sy: Int = 0, ?sw: Int = 0, ?sh: Int = 0) {
		var cmd = new DrawCommand();
		cmd.drawType = DrawType.SPRITE;
		cmd.x = x;
		cmd.y = y;
		cmd.sprite = spr;
		cmd.sx = sx;
		cmd.sy = sy;
		cmd.sw = sw;
		cmd.sh = sh;
		this.commands.push(cmd);
	}

	public function drawTile(spr: Sprite, cols: Int, rows: Int, index: Int, x: Int, y: Int, ?ox: Int = 0, ?oy: Int = 0) {
		var cmd = new DrawCommand();
		cmd.drawType = DrawType.TILE;
		cmd.x = x;
		cmd.y = y;
		cmd.ox = ox;
		cmd.oy = oy;
		cmd.sprite = spr;
		cmd.tileIndex = index;
		cmd.cols = cols;
		cmd.rows = rows;
		this.commands.push(cmd);
	}

	public function flush(canvas: GameCanvas, ?sorting: Sorting, ?reverse: Bool = false) {
		switch (sorting) {
			default:
			case Y_SORT:
				this.commands.sort(function(a: DrawCommand, b: DrawCommand) {
					if (a.y + a.oy == b.y + b.oy) return 0;
					return a.y + a.oy > b.y + b.oy ? 1 : -1;
				});
		}
		if (reverse) {
			this.commands.reverse();
		}

		for (cmd in this.commands) {
			switch (cmd.drawType) {
				case SPRITE: canvas.sprite(cmd.sprite, cmd.x, cmd.y, cmd.sx, cmd.sy, cmd.sw, cmd.sh);
				case TILE: canvas.tile(cmd.sprite, cmd.cols, cmd.rows, cmd.tileIndex, cmd.x - cmd.ox, cmd.y - cmd.oy);
			}
		}
		while (this.commands.length > 0)
			this.commands.pop();
	}
}