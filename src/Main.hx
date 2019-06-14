package;

import engine.GameCanvas;
import engine.GameCanvas.MathExtensions;
import engine.AssetManager;
import engine.SpriteBatch;
import engine.Animator;

import js.Browser;

typedef Tile = { index : Int, z : Int };

class Main extends GameCanvas {
	private static inline var MAP_SIZE: Int = 12;

	static function main() {
		var canvas = new Main();
		canvas.start();
	}

	var flagAnim: Animator;

	var tileSet: Sprite;
	var map: Array<Int>;

	var sb: SpriteBatch;

	public function mapGet(x: Int, y: Int) : Int {
		if (x < 0 || x >= MAP_SIZE || y < 0 || y >= MAP_SIZE) return 0;
		return map[x + y * MAP_SIZE];
	}

	public function mapPrint(map: Array<Int>, sz: Int) {
		var dmap = [];
		for (y in 0...sz) {
			var row = [];
			for (x in 0...sz) {
				row.push(map[x + y * sz]);
			}
			dmap.push(row);
		}
		Browser.console.table(dmap);
	}

	public function new() {
		super();
		this.sb = new SpriteBatch();
		this.flagAnim = new Animator();

		flagAnim.add("loop", [ 49, 50, 51, 52 ]);
		flagAnim.play("loop", 0.1, true);

		this.map = [
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
			0, 0, 16, 15, 15, 21, 0, 0, 0, 0, 0, 0,
			0, 0, 14, 47, 0, 17, 0, 0, 0, 0, 0, 0,
			0, 0, 14, 0, 0, 17, 0, 0, 0, 0, 0, 0,
			0, 0, 20, 18, 18, 19, 0, 0, 0, 0, 0, 0,
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		];

		mapPrint(this.map, MAP_SIZE);
	}

	public override function onPreload() {
		assets.loadSprite("tiles.png");
	}

	public override function onInit() {
		tileSet = assets.getSprite("tiles.png");
	}

	public override function onDraw() {
		this.clear();

		var diag = Math.floor(Math.sqrt(MAP_SIZE * MAP_SIZE + MAP_SIZE * MAP_SIZE)) * 11;

		for (i in 0...(MAP_SIZE * MAP_SIZE)) {
			var tile = this.map[i];
			var ix = (i % MAP_SIZE);
			var iy = Math.floor(i / MAP_SIZE);
			var x = ix * 16;
			var y = iy * 16;
			var pos = MathExtensions.fromIso(x, y, 0);

			if (tile != -1)
				sb.drawTile(tileSet, 7, 10,  tile,  pos.x + diag, pos.y + Math.floor(diag / 2) - 16);
		}

		sb.drawTile(tileSet, 7, 10,  flagAnim.currentFrame,  20, 20);
		sb.drawTile(tileSet, 7, 10,  flagAnim.currentFrame + 4,  20, 20 + 32);

		sb.flush(this, Sorting.Y_SORT);
	}

	public override function onUpdate(dt: Float) {
		flagAnim.update(dt);
	}
}
