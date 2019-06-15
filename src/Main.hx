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

	private static var RAMP_TO_LEFT: Int = 5;
	private static var RAMP_TO_TOP: Int = 6;
	private static var RAMP_TO_RIGHT: Int = 7;
	private static var RAMP_TO_BOTTOM: Int = 8;

	private static var RAMPS: Array<Int> = [5, 6, 7, 8];

	private static var CORNER_TOP_LEFT: Array<Int> = [16, 37];
	private static var CORNER_TOP_RIGHT: Array<Int> = [21, 42];
	private static var CORNER_BOTTOM_LEFT: Array<Int> = [20, 41];
	private static var CORNER_BOTTOM_RIGHT: Array<Int> = [19, 40];
	private static var TOP: Array<Int> = [15, 36];
	private static var BOTTOM: Array<Int> = [18, 39];
	private static var LEFT: Array<Int> = [14, 35];
	private static var RIGHT: Array<Int> = [17, 38];

	private static var TOP_LEFT: Array<Int> = [0, 1, 2, 3];
	private static var TOP_RIGHT: Array<Int> = [0, 4, 8, 12];
	private static var BOTTOM_RIGHT: Array<Int> = [0, 16, 32, 48];
	private static var BOTTOM_LEFT: Array<Int> = [0, 64, 128, 192];

	static function main() {
		var canvas = new Main();
		canvas.start();
	}

	var camera: Vector;

	var tileSet: Sprite;
	var font: Sprite;

	var map: Array<Int>;
	var dmap: Array<Int>;
	var entities: Array<Entity>;

	var sb: SpriteBatch;

	var time: Float = 0.0;
	var im: Vector;

	public function mapGet(x: Int, y: Int) : Int {
		if (x < 0 || x >= MAP_SIZE || y < 0 || y >= MAP_SIZE) return 0;
		return map[x + y * MAP_SIZE];
	}

	public function mapSet(x: Int, y: Int, v: Int) {
		if (x < 0 || x >= MAP_SIZE || y < 0 || y >= MAP_SIZE) return;
		map[x + y * MAP_SIZE] = v;
	}

	public function mapSmooth() {
		for (y in 0...MAP_SIZE) {
			for (x in 0...MAP_SIZE) {
				var mat = [

				];

				// 3x3
				for (oy in -1...2) {
					for (ox in -1...2) {
						mat.push(mapGet(x + ox, y + oy));
					}
				}

				var sum = 0.0;
				for (v in mat) sum += v;
				sum /= 9;

				map[x + y * MAP_SIZE] = Math.floor(sum);
			}
		}
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
		this.camera = new Vector(0, 64);
		this.im = new Vector(0, 0);
		this.entities = new Array();

		this.map = [
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		];

		this.dmap = [
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		];

		for (i in 0...map.length) {
			map[i] = Math.floor(MathExtensions.randomBetween(0, 5));
		}

		mapSmooth();
		mapPrint(this.map, MAP_SIZE);

		for (y in 0...MAP_SIZE) {
			for (x in 0...MAP_SIZE) {
				var a = mapGet(x, y);
				var b = mapGet(x + 1, y);
				var c = mapGet(x + 1, y + 1);
				var d = mapGet(x, y + 1);

				var minH = a;
				var maxH = a;

				minH = (b < minH) ? b : minH;
				minH = (c < minH) ? c : minH;
				minH = (d < minH) ? d : minH;
				maxH = (b > maxH) ? b : maxH;
				maxH = (c > maxH) ? c : maxH;
				maxH = (d > maxH) ? d : maxH;
				a -= minH;
				b -= minH;
				c -= minH;
				d -= minH;

				var t = (d << 6) + (c << 4) + (b << 2) + a;
				dmap[x+y*MAP_SIZE]=t;
			}
		}
		mapPrint(this.dmap, MAP_SIZE);
	}

	public override function onPreload() {
		assets.loadSprite("tiles.png");
		assets.loadSprite("font.png");
	}

	public override function onInit() {
		tileSet = assets.getSprite("tiles.png");
		font = assets.getSprite("font.png");
	}

	public override function onDraw() {
		this.clear();

		var camX = Math.floor(camera.x - width / 2);
		var camY = Math.floor(camera.y - height / 2);

		/**
		* Draws the world.
		*
		* Values for corners based on elevation:
		*              0, 1, 2, 3
		*                  /\
		* 0, 64, 128, 192 /  \ 0, 4, 8, 12
		*                 \  /
		*                  \/
		*             0, 16, 32, 48
		*/

		for (y in 0...MAP_SIZE) {
			for (x in 0...MAP_SIZE) {
				var a = mapGet(x, y);
				var b = mapGet(x + 1, y);
				var c = mapGet(x + 1, y + 1);
				var d = mapGet(x, y + 1);

				var minH = a;
				var maxH = a;

				minH = (b < minH) ? b : minH;
				minH = (c < minH) ? c : minH;
				minH = (d < minH) ? d : minH;
				maxH = (b > maxH) ? b : maxH;
				maxH = (c > maxH) ? c : maxH;
				maxH = (d > maxH) ? d : maxH;
				a -= minH;
				b -= minH;
				c -= minH;
				d -= minH;

				var elevation = maxH * 8;
				var t = (d << 6) + (c << 4) + (b << 2) + a;

				var tile = 0;
				switch (t) {
					case 1: tile = 1;
					case 4: tile = 4;
					case 5: tile = 6;
					case 16: tile = 3;
					case 17: tile = 19; elevation -= 8;
					case 20: tile = 7;
					case 21: tile = 11;
					case 25: tile = 17; elevation -= 8;
					case 64: tile = 2;
					case 65: tile = 5;
					case 68: tile = 18;
					case 69: tile = 12;
					case 70: tile = 14; elevation -= 8;
					case 80: tile = 8;
					case 81: tile = 13;
					case 84: tile = 10;
					case 100: tile = 16; elevation -= 8;
					case 145: tile = 15; elevation -= 8;
					case 148: tile = 20; elevation -= 8;
					default: tile = 0;
				}

				var tx = x * 16 - 8;
				var ty = y * 16 - 8;
				var pos = MathExtensions.fromIso(tx, ty, elevation);
				sb.drawTile(tileSet, 10, 10,  tile,  pos.x - camX, pos.y - camY, 16, 16);
			}
		}

		sb.flush(this, Sorting.Y_SORT);

		tri(tileSet, new Vert(0, 0, 0, 0), new Vert(120, 0, 1, 0), new Vert(120, 120, 1, 1), 255, 0, 0);
		tri(tileSet, new Vert(120, 120, 1, 1), new Vert(0, 120, 0, 1), new Vert(0, 0, 0, 0), 255, 255, 0);
	}

	public override function onUpdate(dt: Float) {
		time += dt;
	}
}
