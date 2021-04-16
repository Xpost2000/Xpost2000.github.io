/*
 * Game Object Class
 */

function GameObject( x, y, w, h ){
	this.x = x;
	this.y = y;
	this.w = w;
	this.h = h;

	this.velX = 4;

	this.type=0;
	this.bossHp=100;
	this.dead=false;

	this.touch = function( other ){
		return ( this.x < other.x + other.w && this.x + this.w > other.x ) && 
		       ( this.y < other.y + other.h && this.y + this.h > other.y);
	}
	this.draw = function(renderer){
		if(!this.dead){
		if(this.type==1){
		renderer.renderRectangle(this.x, this.y, this.w, this.h, 255, 255, 255, "chin");
		}else if(this.type==0){
		renderer.renderRectangle(this.x, this.y, this.w, this.h, 255, 200, 200, "chin");
		console.log("drawing chin like");
		}
		else
		renderer.renderRectangle(this.x, this.y, this.w, this.h, 255, 255, 255, "boss");
		}
	}	
	this.lazyinit=0;
	this.fireDelay=0;
	this.fireDelayMax=30;
	this.velY=4;
	this.update = function( limitX, limitY ){
		if(!this.dead){
		//peasantry
		if(this.lazyinit==0){
			if(this.type == 0){
				this.velX=4;
				this.fireDelayMax = 40;
			}else{
			//god
				this.velX=10;
				this.fireDelayMax = 15;
			}
			this.lazyinit=1;
		}
			if(this.x >= 0 && this.x+this.w <= limitX){
				this.x+=this.velX;	
			}else{
				this.velX = -this.velX;
				this.x -= this.velX > 0 ? -this.w : this.w; 
				if(this.type==0)
				this.y += this.h;
			}
			if(this.type!=0){
				this.y+=this.velY;
			}
			if(this.y <= 0){
				if(this.type!=0)
				this.velY=-this.velY;
			}
			if(this.y >= limitY){
				if(this.type!=0)
				this.velY=-this.velY;
				else
				this.y=0;
			}
			if(this.fireDelay >= this.fireDelayMax){
				global_bullets.push(new Bullet(this.x, this.y+this.h, 15, 15, 0, 4, 300, "ENEMY"));
				console.log("FIRE");
				this.fireDelay = 0;
			}else{
				this.fireDelay++;
			}
		}
	}
}
