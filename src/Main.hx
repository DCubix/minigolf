package;

import engine.GameCanvas;
import engine.AssetManager;
import engine.SpriteBatch;

class Main extends GameCanvas {
	static function main() {
		var canvas = new Main();
		canvas.start();
	}

	var sprites: Sprite;
	var sx: Float = 2;

	var sb: SpriteBatch;

	public function new() {
		super();
		this.sb = new SpriteBatch();
	}

	public override function onPreload() {
		assets.loadSprite("sprites.png");
	}

	public override function onInit() {
		this.sprites = assets.getSprite("sprites.png");
	}

	public override function onDraw() {
		this.clear();
		for (i in 0...20) {
			sb.drawTile(sprites, 8, 7,  0,  i * 2 + Math.floor(sx / (i+1)), i * 2);
		}
		sb.flush(this);
	}

	public override function onUpdate(dt: Float) {
		if (input.isKeyHeld("d")) {
			sx += 40.0 * dt;
		}
	}
}
