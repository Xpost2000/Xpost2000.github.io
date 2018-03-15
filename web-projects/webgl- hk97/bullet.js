/*
 * bullet class.
 * kind of like the gameobject
 */

function Bullet( x, y, w, h, sx, sy, lifeTime, parent="CHIN" ){
	this.x = x;
	this.y = y;
	this.w = w;
	this.h = h;
	this.velX = sx;
	this.velY = sy;
	this.lifeTime = lifeTime;
	this.owner=parent;
	this.draw = function(renderer){
		if(this.lifeTime>0){
			if(this.owner=="CHIN")
			renderer.renderRectangle(this.x, this.y, this.w, this.h, 255, 255, 255, "bullet");	
			else
			renderer.renderRectangle(this.x, this.y, this.w, this.h, 255, 200, 200, "bullet");	
		}
	}
	this.update = function(){
		if(this.lifeTime > 0){
			this.x += this.velX;
			this.y += this.velY;
			this.lifeTime--;
		}else{
		}
	}
}

var global_bullets= [];
