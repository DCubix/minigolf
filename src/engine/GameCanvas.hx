package engine;

import js.html.Node;
import js.html.CanvasElement;
import js.html.CanvasRenderingContext2D;
import js.html.ImageData;
import js.html.Image;
import js.html.Uint8ClampedArray;

import haxe.ds.StringMap;

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

class Sprite {
	public var width: Int;
	public var height: Int;
	public var pixels: Uint8ClampedArray;

	public function new() {}
}

class GameCanvas {
	var canvas: CanvasElement;
	var buffer: CanvasElement;
	var ctx: CanvasRenderingContext2D;
	var bctx: CanvasRenderingContext2D;

	var pixels: ImageData;

	// ASSETS CODE
	var imagePaths: Array<String>;
	var images: StringMap<Sprite>;

	public function loadImage(path: String) {
		this.imagePaths.push(path);
	}

	public function getImage(path: String) {
		return this.images.get(path);
	}

	function loadAll(onFinish: Void -> Void) {
		if (this.imagePaths.length == 0) onFinish();

		var loadedCount = 0, errCount = 0;
		for (path in this.imagePaths) {
			var img = new Image();
			img.onload = function() {
				var canvas = cast(js.Browser.document.createElement("canvas"), CanvasElement);
				canvas.width = img.width;
				canvas.height = img.height;
				var ctx = canvas.getContext2d();
				ctx.drawImage(img, 0, 0);

				var spr = new Sprite();
				spr.width = img.width;
				spr.height = img.height;
				spr.pixels = ctx.getImageData(0, 0, img.width, img.height).data;
				this.images.set(path, spr);

				loadedCount++;
				if (loadedCount + errCount >= this.imagePaths.length) {
					onFinish();
				}
			};
			img.onerror = function() {
				errCount++;
				if (loadedCount + errCount >= imagePaths.length) {
					onFinish();
				}
			};
			img.src = path;
		}
	}

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
		loadAll(function() {
			onInit();
			_mainloop_(0.0);
		});
	}

	// RENDERING CODE
	public function new(?target: Node) {
		this.imagePaths = new Array();
		this.images = new StringMap();

		this.canvas = cast(js.Browser.document.createElement("canvas"), CanvasElement);
		this.buffer = cast(js.Browser.document.createElement("canvas"), CanvasElement);

		if (target == null)
			js.Browser.document.body.appendChild(this.canvas);
		else
			target.appendChild(this.canvas);

		this.canvas.width = 800;
		this.canvas.height = 600;

		this.buffer.width = cast(this.canvas.width / 4, Int);
		this.buffer.height = cast(this.canvas.height / 4, Int);

		this.ctx = this.canvas.getContext2d();
		this.ctx.imageSmoothingEnabled = false;

		this.bctx = this.buffer.getContext2d();
		this.bctx.imageSmoothingEnabled = false;

		this.pixels = this.bctx.createImageData(this.buffer.width, this.buffer.height);
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
			onUpdate(TIME_STEP);
		}

		onDraw();
		flip();

		js.Browser.window.requestAnimationFrame(_mainloop_);
	}

}