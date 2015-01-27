int FRAME_SIZE = 2;
boolean take_picture = false;
float DRAG = 0.95;

interface kdrawer {
	public void draw(PGraphics r);
	public int xsize();
	public int ysize();
}

class krender {
	public boolean use_mouse = false;
	public boolean with_mask = true;

	krender(PApplet parent, int size, kdrawer drawer) {
		this.parent = parent;

		this.t_height = (int)sqrt(.75*size*size);
		this.x_grid_step = size * 3;
		this.y_grid_step = t_height;
		this.x_grid = this.parent.width / x_grid_step + 2;
		this.y_grid = this.parent.height / (t_height / 2) + 2;

		this.drawer = drawer;
		this.x_offset = -size;
		this.y_offset = -t_height;
		this.size = size;
		this.pg = createGraphics(size, t_height);
		createMask();
	}

	private void createMask() {
		this.mask = createGraphics(size,t_height);
		this.mask.beginDraw();
		this.mask.background(0,0,0);
		this.mask.triangle(-2, -2, size/2.0, t_height+2, size+2, -2);
		this.mask.endDraw();
	}

	private PImage draw_triangle() {
		this.pg.beginDraw();
		this.pg.pushMatrix();
		this.pg.rotate(this.parent.radians(count));
		this.pg.translate(this.x_offset, this.y_offset);

		drawer.draw(this.pg);
		this.pg.popMatrix();
		this.pg.endDraw();	

		PImage img = new PImage(this.pg.image);	
		if (with_mask)
			img.mask(this.mask);

		return img;
	}

	private PImage flip(PImage img) {
		this.pg.beginDraw();
		this.pg.pushMatrix();
		this.pg.scale(-1, 1);
		this.pg.translate(-size, 0);
		this.pg.image(img, 0, 0);
		this.pg.popMatrix();
		this.pg.endDraw();

		img = new PImage(this.pg.image);
		if (with_mask)
			img.mask(this.mask);

		return img;
	}

	void draw() {
		PImage normal_image = draw_triangle();
		PImage flipped_image = flip(normal_image);

		this.parent.pushMatrix();

		translate(0, -t_height); // First hex starts offset
		for(int y=0; y< y_grid; y++) {
			this.parent.pushMatrix();
			translate(0, y*y_grid_step);
			if ((y+1)%2 == 0) {
				translate(size*1.5, 0);
			}
			for(int x=0; x < x_grid; x++) {
				this.parent.pushMatrix();

				translate(x*x_grid_step, 0);
				this.parent.scale(1.01, 1.01);
				draw_hex(normal_image, flipped_image);
				this.parent.popMatrix();
			}
			this.parent.popMatrix();
		}

		this.parent.popMatrix();
	}

	private void draw_hex(PImage img, PImage flipped_img) {
		this.parent.pushMatrix();
		for(int i=0; i< 6; i++) {
			this.parent.image((i+1)%2==0 ? img : flipped_img, 0, 0);
			rotate(60);
		}
		this.parent.popMatrix();
	}

	private void rotate(int degrees) {
		// translate(size, 0);
		this.parent.translate(size/2.0, t_height);
		this.parent.rotate(this.parent.radians(degrees));
		this.parent.translate(-size/2.0, -t_height);
	}

	void update() {

		if (use_mouse) {
			x_offset = lerp(-drawer.xsize(), drawer.xsize(), (float)this.parent.mouseX / (float)this.parent.width);
			y_offset = lerp(-drawer.ysize(), drawer.ysize(), (float)this.parent.mouseY / (float)this.parent.height);
		} else {
			x_offset = lerp(-drawer.xsize(), drawer.xsize(), (float)sin(radians(count)));
			y_offset = lerp(-drawer.ysize(), drawer.ysize(), (float)sin(radians(count)));
		}
	}

	private PApplet parent;
	private PGraphics pg, mask;
	private kdrawer drawer;
	private float x_offset, y_offset;
	private int size;
	private int t_height;
	private int x_grid, y_grid;
	private int x_grid_step, y_grid_step;
	public int count = 0;
};

class BezierDrawer implements kdrawer {
	public BezierDrawer(PApplet parent, int size) {
		this.parent = parent;
		this.size = size;

		this.p1 = randomVector(size);
		this.p2 = randomVector(size);
		this.p3 = randomVector(size);
		this.p4 = randomVector(size);

		this.v1 = zeroVector();
		this.v2 = zeroVector();
		this.v3 = zeroVector();
		this.v4 = zeroVector();
	}

	public void draw(PGraphics r) {
		update();

		r.fill(96, 45, 24);
		r.stroke(0);
		r.strokeWeight(5);
		r.background(23,45, 18);

		drawBezier(r, p1, p2, p3, p4);
		drawBezier(r, p2, p4, p1, p3);
	}

	private void update() {
		p2.add(randomVector(10));
		p2.sub(randomVector(5));
		p3.add(randomVector(10));
		p3.sub(randomVector(5));


	}

	private void applyForce(int angle, int mag, PVector v, PVector p) {
		PVector a = PVector.fromAngle(radians(angle));
		a.setMag(mag);

		v.add(a);
		v.mult(DRAG);
		p.add(v);
	}

	private void drawBezier(PGraphics r, PVector pt1, PVector pt2, PVector pt3, PVector pt4)
   {
		r.bezier(
			pt1.x, pt1.y,
			pt2.x, pt2.y,
			pt3.x, pt3.y,
			pt4.x, pt4.y
		);
	}

	public int xsize() {
		return size;
	}

	public int ysize() {
		return size;
	}

	private PVector randomVector(int step) {
		return new PVector(
			parent.random(step),
			parent.random(step)
		);
	}

	private PVector zeroVector() {
		return new PVector(0,0);
	}

	private PApplet parent;
	private PVector p1, p2, p3, p4;
	private PVector v1, v2, v3, v4;
	private int size;
};

krender renderer;
BezierDrawer drawer;
int count;

void setup() {
	size(1024, 768);

	frameRate(30);
	smooth();
	noStroke();
	drawer = new BezierDrawer(this, 600);
	renderer = new krender(this, 300, drawer);
}

void mouseMoved() {
	renderer.update();
}

void keyReleased() {
	switch(keyCode) {
		case 'm':
			renderer.use_mouse = !renderer.use_mouse;
			break;

		case 'k':
			renderer.with_mask = !renderer.with_mask;
			break;

		case ' ':
			take_picture = true;
			break;

		case LEFT:
			renderer.count += 1;
			break;

		case RIGHT:
			renderer.count -= 1;
			break;

	}
}

void draw() {
	renderer.draw();

	if (take_picture) {
		saveFrame("frame-####.jpg");
		take_picture = false;
	}

	renderer.count += FRAME_SIZE;
	renderer.count %= 360;
	saveFrame("build-tmp/frame-####.tif");
	if (count > 1500) {
		noLoop();
	}
}