package game;

import engine.Vector;

class Entity {
	public var position: Vector;
	public var velocity: Vector;

	public var resting: Bool;

	public function new() {
		this.position = new Vector(0, 0);
		this.velocity = new Vector(0, 0);
		this.resting = false;
	}

	public function applyForce(f: Vector) {
		this.resting = false;
		this.velocity = this.velocity.add(f);
	}

}