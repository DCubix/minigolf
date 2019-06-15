package;

import engine.GameCanvas;
import engine.GameCanvas.MathExtensions;
import engine.AssetManager;
import engine.SpriteBatch;
import engine.Animator;
import engine.Vector;
import game.Entity;

import js.Browser;

typedef Tile = { index : Int, z : Int };

class Main extends GameCanvas {
	private static inline var MAP_SIZE: Int = 12;
	private static inline var BALL_SPRITE: Int = 57;
	private static inline var CHAR_MAP: String = " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ";

	static function main() {
		var canvas = new Main();
		canvas.start();
	}

	var camera: Vector;

	var tileSet: Sprite;
	var font: Sprite;

	var map: Array<Int>;
	var entities: Array<Entity>;

	var ball: Entity;

	var sb: SpriteBatch;

	public function mapGet(x: Int, y: Int) : Int {
		if (x < 0 || x >= MAP_SIZE || y < 0 || y >= MAP_SIZE) return -1;
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
		this.camera = new Vector(0, 0, 0);
		this.entities = new Array();

		this.map = [
			16, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 21,
			14, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 17,
			14, 0, 16, 15, 15, 21, 0, 0, 0, 0, 0, 17,
			14, 0, 14, 47, 0, 17, 0, 0, 0, 0, 0, 17,
			14, 0, 14, 0, 0, 17, 0, 0, 0, 0, 0, 17,
			14, 0, 20, 18, 18, 19, 0, 0, 0, 0, 0, 17,
			14, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 17,
			14, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 17,
			14, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 17,
			14, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 17,
			14, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 17,
			20, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 19
		];

		mapPrint(this.map, MAP_SIZE);
	}

	public override function onPreload() {
		assets.loadSprite("tiles.png");
		assets.loadSprite("font.png");
	}

	public override function onInit() {
		tileSet = assets.getSprite("tiles.png");
		font = assets.getSprite("font.png");

		ball = new Entity();
		entities.push(ball);

		ball.position.z = 64;
	}

	public override function onDraw() {
		this.clear();

		var camX = camera.x - width / 2 + 16;
		var camY = camera.y - height / 2 + 16;

		for (i in 0...(MAP_SIZE * MAP_SIZE)) {
			var tile = this.map[i];
			var ix = (i % MAP_SIZE);
			var iy = Math.floor(i / MAP_SIZE);
			var x = ix * 16;
			var y = iy * 16;
			var pos = MathExtensions.fromIso(x, y, 0);

			if (tile != -1)
				sb.drawTile(tileSet, 7, 10,  tile,  Math.floor(pos.x - camX), Math.floor(pos.y - camY));
		}

		// Draw ball
		var ballPos = MathExtensions.fromIso(ball.position.x, ball.position.y, ball.position.z);
		var ballSPos = MathExtensions.fromIso(ball.position.x, ball.position.y, 0);
		sb.drawTile(tileSet, 7, 10, BALL_SPRITE, Math.floor(ballPos.x - camX), Math.floor(ballPos.y - camY), 16, 18);
		sb.drawTile(tileSet, 7, 10, BALL_SPRITE + 1, Math.floor(ballSPos.x - camX), Math.floor(ballSPos.y - camY), 16, 14);

		sb.flush(this, Sorting.Y_SORT);

		text(font, CHAR_MAP, "Z: " + ball.position.z, 2, 2);
		text(font, CHAR_MAP, "VX: " + (ball.velocity.x), 2, 10);
		text(font, CHAR_MAP, "AX: " + (ball.accel.x), 2, 18);
	}

	public override function onUpdate(dt: Float) {
		if (input.isKeyHeld("a")) {
			ball.accel.x += 200.0 * dt;
		}

		// Verlet integrate entities
		for (ent in entities) {
			ent.velocity = ent.velocity.add(ent.accel.mul(dt)).mul(0.99);
			ent.velocity.z -= 100.0 * dt;

			ent.position = ent.position.add(ent.velocity.mul(dt));

			ent.accel = ent.accel.mul(0.99);
			if (ent.accel.length <= 1e-5) {
				ent.accel.x = ent.accel.y = ent.accel.z = 0.0;
			}

			// MAP COLLISION
			var mx = Math.floor(ent.position.x / 16);
			var my = Math.floor(ent.position.y / 16);
			var tile = mapGet(mx, my);

			var minZ = 0;
			if (tile != -1 && ent.position.z <= minZ) {
				ent.velocity.z *= -1;
			}

		}

	}
}
