package engine;

import engine.AssetManager.Sprite;
import engine.Vector.Point;

import js.html.Node;
import js.html.CanvasElement;
import js.html.CanvasRenderingContext2D;
import js.html.ImageData;
import js.Browser;

class MathExtensions {
	public static function randomBetween(a: Float, b: Float) {
		var diff: Float = b - a;
		return a + Math.floor(Math.random() * diff);
	}

	public static function fromIso(x: Float, y: Float, z: Float) {
		return new Point(
			Math.floor(x - y),
			Math.floor(((x + y) / 2) - z)
		);
	}

	public static function toIso(x: Int, y: Int, ?z: Float = 0.0) {
		return new Vector(
			(2.0 * y + x) / 2.0,
			(2.0 * y - x) / 2.0,
			z
		);
	}
}

class Range {
	var end:Int;
	var step:Int;
	var index:Int;

	public inline function new(start:Int, end:Int, step:Int) {
		this.index = start;
		this.end = end;
		this.step = step;
	}

	public inline function hasNext() return index < end;
	public inline function next() return (index += step) - step;
}

class Vert {
	public var x: Int;
	public var y: Int;
	public var u: Float;
	public var v: Float;

	public function new(x: Int, y: Int, u: Float, v: Float) {
		this.x = x;
		this.y = y;
		this.u = u;
		this.v = v;
	}
}

class GameCanvas {
	private var canvas: CanvasElement;
	private var buffer: CanvasElement;
	private var ctx: CanvasRenderingContext2D;
	private var bctx: CanvasRenderingContext2D;

	private var pixels: ImageData;

	public var assets(default, null): AssetManager;
	public var input(default, null): InputManager;

	function get_width() { return this.buffer.width; }
	function get_height() { return this.buffer.height; }

	public var width(get_width, null): Int;
	public var height(get_height, null): Int;

	// LOGIC CODE
	public static inline var TIME_STEP: Float = 1.0 / 60.0;
	var lastTime: Float = haxe.Timer.stamp();
	var accum: Float = 0.0;

	public function onPreload() {}
	public function onInit() {}
	public function onDraw() {}
	public function onUpdate(dt: Float) {}

	public function start() {
		onPreload();
		assets.loadAll(function() {
			onInit();
			_mainloop_(0.0);
		});
	}

	// RENDERING CODE
	public function new(?target: Node) {
		this.assets = new AssetManager();

		this.canvas = cast(Browser.document.createElement("canvas"), CanvasElement);
		this.buffer = cast(Browser.document.createElement("canvas"), CanvasElement);

		this.input = new InputManager(this.canvas);

		if (target == null)
			Browser.document.body.appendChild(this.canvas);
		else
			target.appendChild(this.canvas);

		this.canvas.width = 800;
		this.canvas.height = 600;

		this.buffer.width = cast(this.canvas.width / 2, Int);
		this.buffer.height = cast(this.canvas.height / 2, Int);

		this.ctx = this.canvas.getContext2d();
		this.ctx.imageSmoothingEnabled = false;

		this.bctx = this.buffer.getContext2d();
		this.bctx.imageSmoothingEnabled = false;

		this.pixels = this.bctx.createImageData(this.buffer.width, this.buffer.height);
	}

	public function tri(spr: Sprite, v0: Vert, v1: Vert, v2: Vert, ?r: Int = 255, ?g: Int = 255, ?b: Int = 255) {
		var minX = Math.floor(Math.min(Math.min(v0.x, v1.x), v2.x));
		var maxX = Math.ceil(Math.max(Math.max(v0.x, v1.x), v2.x));
		var minY = Math.floor(Math.min(Math.min(v0.y, v1.y), v2.y));
		var maxY = Math.ceil(Math.max(Math.max(v0.y, v1.y), v2.y));
		for (y in minY...maxY) {
			for (x in minX...maxX) {
				var px = x + 0.5;
				var py = y + 0.5;

				var w0 = cross(v1, v2, px, py);
				var w1 = cross(v2, v0, px, py);
				var w2 = cross(v0, v1, px, py);
				var area = cross(v0, v1, v2.x, v2.y);

				if (w0 >= 1e-5 || w1 >= 1e-5 || w2 >= 1e-5) {
					continue;
				}

				if (spr != null) {
					var u = (w0 * v0.u + w1 * v1.u + w2 * v2.u) / area;
					var v = (w0 * v0.v + w1 * v1.v + w2 * v2.v) / area;
					var tx = Math.floor(fmod(u, 1.0) * (spr.width - 1));
					var ty = Math.floor(fmod(v, 1.0) * (spr.height - 1));
					var idx = (tx + ty * spr.width) * 4;
					var tr = spr.pixels[idx + 0];
					var tg = spr.pixels[idx + 1];
					var tb = spr.pixels[idx + 2];
					dot(x, y, tr, tg, tb);
				} else {
					dot(x, y, r, g, b);
				}
			}
		}
	}

	public function dot(x: Int, y: Int, r: Int, g: Int, b: Int) {
		if (x < 0 || x >= this.buffer.width || y < 0 || y >= this.buffer.height) return;
		var i = (x + y * this.buffer.width) * 4;
		this.pixels.data[i + 0] = r;
		this.pixels.data[i + 1] = g;
		this.pixels.data[i + 2] = b;
		this.pixels.data[i + 3] = 255;
	}

	public function sprite(spr: Sprite, x: Int, y: Int, ?sx: Int = 0, ?sy: Int = 0, ?sw: Int = 0, ?sh: Int = 0) {
		var w = sw > 0 ? sw : spr.width;
		var h = sh > 0 ? sh : spr.height;
		for (iy in 0...h) {
			for (ix in 0...w) {
				var px = ix + x;
				var py = iy + y;

				var si = ((ix + sx) + (iy + sy) * spr.width) * 4;

				if (spr.pixels[si + 3] < 200) continue;

				this.dot(px, py, spr.pixels[si + 0], spr.pixels[si + 1], spr.pixels[si + 2]);
			}
		}
	}

	public function tile(spr: Sprite, cols: Int, rows: Int, index: Int, x: Int, y: Int) {
		var sw: Int = Math.floor(spr.width / cols);
		var sh: Int = Math.floor(spr.height / rows);
		var sx: Int = (index % cols) * sw;
		var sy: Int = cast(Math.floor(index / cols) * sh, Int);
		sprite(spr, x, y, sx, sy, sw, sh);
	}

	public function text(font: Sprite, charMap: String, text: String, x: Int, y: Int) {
		var vertical = font.height > font.width;
		var tx = x;
		var ty = y;
		var ch = !vertical ? font.height : Math.floor(font.height / charMap.length);

		for (i in 0...text.length) {
			var c = text.charAt(i);
			if (c == '\n') {
				tx = x;
				ty += ch;
			} else {
				tx = char(font, charMap, c, tx, ty);
			}
		}
	}

	public function char(font: Sprite, charMap: String, c: String, x: Int, y: Int) : Int {
		var vertical = font.height > font.width;
		var cw = !vertical ? Math.floor(font.width / charMap.length) : font.width;
		//var ch = !vertical ? font.height : Math.floor(font.height / charMap.length);

		var index = charMap.indexOf(c);
		tile(font, vertical ? 1 : charMap.length, vertical ? charMap.length : 1, index, x, y);

		return x + cw;
	}

	public function clear(?r: Int = 0, ?g: Int = 0, ?b: Int = 0) {
		for (i in new Range(0, (this.buffer.width * this.buffer.height * 4), 4)) {
			this.pixels.data[i + 0] = r;
			this.pixels.data[i + 1] = g;
			this.pixels.data[i + 2] = b;
			this.pixels.data[i + 3] = 255;
		}
	}

	function flip() {
		this.bctx.putImageData(this.pixels, 0, 0);
		this.ctx.drawImage(this.buffer, 0, 0, this.canvas.width, this.canvas.height);
	}

	function _mainloop_(d: Float) {
		var currentTime = haxe.Timer.stamp();
		var delta = currentTime - lastTime;
		lastTime = currentTime;
		accum += delta;

		while (accum >= TIME_STEP) {
			accum -= TIME_STEP;
			if (this.input.active) onUpdate(TIME_STEP);
		}

		this.input.refresh();

		if (this.input.active) {
			onDraw();
			flip();
		}

		Browser.window.requestAnimationFrame(_mainloop_);
	}

	function cross(a: Vert,  b: Vert,  cx: Float, cy: Float) : Float {
		return (b.x - a.x) * -(cy - a.y) - -(b.y - a.y) * (cx - a.x);
	}

	function fmod(a: Float, b: Float) : Float {
		if (a < 0.0) {
			a += b;
		}
		return a % b;
	}

}