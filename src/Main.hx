package;

import engine.GameCanvas;

class Main extends GameCanvas {
	static function main() {
		var canvas = new Main();
		canvas.start();
	}

	var sprites: Sprite;

	public override function onPreload() {
		this.loadImage("sprites.png");
	}

	public override function onInit() {
		this.sprites = this.getImage("sprites.png");
	}

	public override function onDraw() {
		this.clear();
		this.tile(this.sprites, 8, 7, 0, 2, 2);
	}
}
