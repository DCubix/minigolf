package engine;

import js.html.CanvasElement;
import js.Browser;
import js.html.KeyboardEvent;
import js.html.MouseEvent;

import haxe.ds.StringMap;
import haxe.ds.IntMap;

private class InputState {
	public var pressed: Bool;
	public var released: Bool;
	public var held: Bool;

	public function new() {}
}

class InputManager {

	private var keyboard: StringMap<InputState>;
	private var mouse: IntMap<InputState>;

	public var mouseX(default, null): Int = 0;
	public var mouseY(default, null): Int = 0;

	public function new(canvas: CanvasElement) {
		this.keyboard = new StringMap();
		this.mouse = new IntMap();

		Browser.document.body.onkeydown = function(e: KeyboardEvent) {
			e.preventDefault();
			if (!this.keyboard.exists(e.key)) {
				this.keyboard.set(e.key, new InputState());
			}
			this.keyboard.get(e.key).pressed = true;
			this.keyboard.get(e.key).held = true;
		};

		Browser.document.body.onkeyup = function(e: KeyboardEvent) {
			e.preventDefault();
			if (!this.keyboard.exists(e.key)) {
				this.keyboard.set(e.key, new InputState());
			}
			this.keyboard.get(e.key).released = true;
			this.keyboard.get(e.key).held = false;
		};

		Browser.document.body.onmousedown = function(e: MouseEvent) {
			e.preventDefault();
			if (!this.mouse.exists(e.button)) {
				this.mouse.set(e.button, new InputState());
			}
			this.mouse.get(e.button).pressed = true;
			this.mouse.get(e.button).held = true;
		};

		Browser.document.body.onmouseup = function(e: MouseEvent) {
			e.preventDefault();
			if (!this.mouse.exists(e.button)) {
				this.mouse.set(e.button, new InputState());
			}
			this.mouse.get(e.button).released = true;
			this.mouse.get(e.button).held = false;
		};

		Browser.document.body.onmousemove = function(e: MouseEvent) {
			e.preventDefault();
			var rect = canvas.getBoundingClientRect();
			this.mouseX = Math.floor((e.clientX - rect.left) / 2);
			this.mouseY = Math.floor((e.clientY - rect.top) / 2);
		};

		canvas.oncontextmenu = function() return false;

	}

	public function isKeyPressed(key: String) {
		return this.keyboard.exists(key) && this.keyboard.get(key).pressed;
	}

	public function isKeyReleased(key: String) {
		return this.keyboard.exists(key) && this.keyboard.get(key).released;
	}

	public function isKeyHeld(key: String) {
		return this.keyboard.exists(key) && this.keyboard.get(key).held;
	}

	public function isMousePressed(btn: Int) {
		return this.mouse.exists(btn) && this.mouse.get(btn).pressed;
	}

	public function isMouseReleased(btn: Int) {
		return this.mouse.exists(btn) && this.mouse.get(btn).released;
	}

	public function isMouseHeld(btn: Int) {
		return this.mouse.exists(btn) && this.mouse.get(btn).held;
	}

	public function refresh() {
		for (e in this.keyboard) {
			e.pressed = false;
			e.released = false;
		}
		for (e in this.mouse) {
			e.pressed = false;
			e.released = false;
		}
	}

}