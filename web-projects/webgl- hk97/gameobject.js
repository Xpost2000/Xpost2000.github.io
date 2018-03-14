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
	this.update = function( limitX, limitY ){
		if(!this.dead){
		//peasantry
		if(this.lazyinit==0){
			if(this.type == 0){
				this.velX=4;
			}else{
			//god
				this.velX=10;
			}
			this.lazyinit=1;
		}
			if(this.x >= 0 && this.x+this.w <= limitX){
				this.x+=this.velX;	
			}else{
				this.velX = -this.velX;
				this.x -= this.velX > 0 ? -this.w : this.w; 
				this.y += this.h;
			}
			if(this.y >= limitY){
				this.y=0;
			}
		}
	}
}
