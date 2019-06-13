package engine;

import js.html.CanvasElement;
import js.html.Image;
import haxe.ds.StringMap;
import js.html.Uint8ClampedArray;
import js.Browser;

enum AssetType {
	ASSET_SPRITE;
}

class Asset {
	public var type: AssetType;
	public var path: String;

	public function new(path: String, type: AssetType) {
		this.type = type;
		this.path = path;
	}
}

class Sprite {
	public var width: Int;
	public var height: Int;
	public var pixels: Uint8ClampedArray;

	public function new() {}
}

class AssetManager {
	private var assets: Array<Asset>;

	private var sprites: StringMap<Sprite>;

	public function new() {
		this.assets = new Array();
		this.sprites = new StringMap();
	}

	public function loadSprite(path: String) {
		this.assets.push(new Asset(path, AssetType.ASSET_SPRITE));
	}

	public function getSprite(path: String) {
		return this.sprites.get(path);
	}

	public function loadAll(onFinish: Void -> Void) {
		if (this.assets.length == 0) onFinish();

		var loadedCount = 0, errCount = 0;
		for (ast in this.assets) {
			switch (ast.type) {
				case ASSET_SPRITE: {
					var img = new Image();
					img.onload = function() {
						var canvas = cast(Browser.document.createElement("canvas"), CanvasElement);
						canvas.width = img.width;
						canvas.height = img.height;
						var ctx = canvas.getContext2d();
						ctx.drawImage(img, 0, 0);

						var spr = new Sprite();
						spr.width = img.width;
						spr.height = img.height;
						spr.pixels = ctx.getImageData(0, 0, img.width, img.height).data;
						this.sprites.set(ast.path, spr);

						loadedCount++;
						if (loadedCount + errCount >= this.assets.length) {
							onFinish();
						}

						trace("LOADED: " + ast.path);
					};
					img.onerror = function() {
						errCount++;
						if (loadedCount + errCount >= this.assets.length) {
							onFinish();
						}

						trace("ERR: " + ast.path);
					};
					img.src = ast.path;
				};
			}
		}
	}
}