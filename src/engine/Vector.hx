package engine;

class Point {
	public var x: Int;
	public var y: Int;

	public function new(x: Int, y: Int) {
		this.x = x;
		this.y = y;
	}
}

class Vector {
	public var x: Float;
	public var y: Float;
	public var z: Float;

	public var length(get_length, null): Float;
	public var lengthSqr(get_lengthSqr, null): Float;

	public function new(x: Float, y: Float, ?z: Float = 0.0) {
		this.x = x;
		this.y = y;
		this.z = z;
	}

	public function dot(rhs: Vector) : Float {
		return this.x * rhs.x + this.y * rhs.y + this.z + rhs.z;
	}

	public function cross(rhs: Vector) : Vector {
		return new Vector(
			this.y * rhs.z - this.z * rhs.y,
			this.z * rhs.x - this.x * rhs.z,
			this.x * rhs.y - this.y * rhs.x
		);
	}

	public function normalized() : Vector {
		var len = this.length;
		return new Vector(this.x / len, this.y / len, this.z / len);
	}

	function get_length() { return Math.sqrt(this.lengthSqr); }
	function get_lengthSqr() { return (this.dot(this)); }

	@:op(A + B)
	public function add(rhs: Vector) : Vector {
		return new Vector(
			this.x + rhs.x,
			this.y + rhs.y,
			this.z + rhs.z
		);
	}

	@:op(A - B)
	public function sub(rhs: Vector) : Vector {
		return new Vector(
			this.x - rhs.x,
			this.y - rhs.y,
			this.z - rhs.z
		);
	}

	@:op(A * B)
	public function mul(rhs: Float) : Vector {
		return new Vector(
			this.x * rhs,
			this.y * rhs,
			this.z * rhs
		);
	}

	public function clone() : Vector {
		return new Vector(x, y, z);
	}

}