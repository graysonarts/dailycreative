int FRAME_SIZE = 1;
boolean take_picture = false;

interface kdrawer {
	public void draw(PGraphics r);
	public int xsize();
	public int ysize();
}

class krender {
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
		x_offset = lerp(-drawer.xsize(), drawer.xsize(), (float)this.parent.mouseX / (float)this.parent.width);
		y_offset = lerp(-drawer.ysize(), drawer.ysize(), (float)this.parent.mouseY / (float)this.parent.height);

		// x_offset = min(size, min(x_offset, 0));
		// y_offset = min(size, min(y_offset, 0));
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

class ImageDrawer implements kdrawer {
	public ImageDrawer(PApplet parent, PImage img) {
		this.img = img;
	}

	public void draw(PGraphics r) {
		r.image(this.img, 0, 0);
	}

	public int xsize() {
		return this.img.width;
	}

	public int ysize() {
		return this.img.height;
	}

	private PImage img;
};

krender renderer;
ImageDrawer drawer;
int count;

void setup() {
	size(1024, 768);

	frameRate(30);
	smooth();
	noStroke();
	PImage kimage = loadImage("test.jpg");
	kimage.resize(600, 0);
	drawer = new ImageDrawer(this, kimage);
	renderer = new krender(this, 300, drawer);
}

void mouseMoved() {
	renderer.update();
}

void keyReleased() {
	switch(keyCode) {
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
	// saveFrame("frame-####.tif");
	// if (count > 1500) {
	// 	noLoop();
	// }
}