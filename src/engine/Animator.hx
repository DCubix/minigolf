package engine;

import haxe.ds.StringMap;

class Animation {
	public var frames: Array<Int>;
	public var loop: Bool;
	public var speed: Float;
	public var time: Float;
	public var frame: Int;

	public function new() {}
}

class Animator {

	private var animations: StringMap<Animation>;
	private var currentAnimation: String;

	public var currentFrame(default, null): Int = 0;

	public function new() {
		this.animations = new StringMap();
		this.currentAnimation = "";
	}

	public function add(name: String, ?frames: Array<Int>) {
		var anim = new Animation();
		anim.frames = frames == null ? [] : frames;
		anim.loop = false;
		anim.speed = 0;
		anim.frame = 0;
		anim.time = 0;

		this.animations.set(name, anim);
		if (this.currentAnimation.length == 0) {
			this.currentAnimation = name;
		}
	}

	public function play(name: String, speed: Float, ?loop: Bool = true) {
		var anim = this.animations.get(name);
		anim.speed = speed;
		anim.loop = loop;
		anim.frame = 0;
		this.currentAnimation = name;
	}

	public function update(dt: Float) {
		if (this.currentAnimation.length == 0) return;

		var anim = this.animations.get(this.currentAnimation);
		var frameCount = anim.frames.length;

		anim.time += dt;
		if (anim.time >= anim.speed) {
			anim.time = 0;
			if (anim.frame++ >= frameCount - 1) {
				if (anim.loop) {
					anim.frame = 0;
				} else {
					anim.frame = frameCount - 1;
				}
			}
		}
		this.currentFrame = anim.frames[anim.frame];
	}

}