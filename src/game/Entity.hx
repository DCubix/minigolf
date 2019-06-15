package game;

import engine.Vector;

class Entity {
	public var position: Vector;
	public var velocity: Vector;
	public var accel: Vector;

	public function new() {
		this.position = new Vector(0, 0);
		this.velocity = new Vector(0, 0);
		this.accel = new Vector(0, 0);
	}

}