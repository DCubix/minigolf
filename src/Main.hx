package;

import engine.GameCanvas;
import engine.GameCanvas.MathExtensions;
import engine.AssetManager;
import engine.SpriteBatch;

class Main extends GameCanvas {
	static function main() {
		var canvas = new Main();
		canvas.start();
	}

	var tileSet: Sprite;
	var map: Array<Int>;

	var sb: SpriteBatch;

	public function new() {
		super();
		this.sb = new SpriteBatch();
		this.map = new Array();
		for (i in 0...(8 * 8)) {
			this.map.push(Math.floor(MathExtensions.randomBetween(1, 3)));
		}
	}

	public override function onPreload() {
		assets.loadSprite("tiles.png");
	}

	public override function onInit() {
		tileSet = assets.getSprite("tiles.png");
	}

	public override function onDraw() {
		this.clear();

		var diag = Math.floor(Math.sqrt(8*8 + 8*8)) * 15;
		for (i in 0...(8 * 8)) {
			if (map[i] == 0) continue;

			var x = (i % 8) * 16;
			var y = Math.floor(i / 8) * 16;
			var pos = MathExtensions.fromIso(x, y, map[i] * 8);
			sb.drawTile(tileSet, 7, 10,  5,  pos.x - 15 + diag, pos.y + Math.floor(diag / 2));
		}
		sb.flush(this);
	}

	public override function onUpdate(dt: Float) {

	}
}
