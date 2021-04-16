// JS FILE

var gameOver=0;
var killCount=1;
var spawnTimer=150;
var canvas;
var ctx;

var bomb;
var chin;
var deng;

var fireTest = -1;

var gunFire = new Audio("gun.wav")
var music = new Audio("themesong.wav");


function Bullet(x, y, w, h, speed, lifeTime, owner){
	this.speed = speed;
	this.owner = owner;
	this.x = x;
	this.y = y;
	this.w = w;
	this.h = h;
	this.lifeTime = lifeTime;
	this.update = function(){
		if(this.lifeTime > 0){
			this.y += this.speed;
			this.lifeTime--;
		}
	}
	this.draw = function(color){
		ctx.drawImage(bomb, this.x, this.y, this.w, this.h);
	}
	this.touching = function( other ){
		return (this.x + this.w > other.x
		       && this.x < other.x + other.w)&&
			(this.y + this.h > other.y
			&& this.y < other.y + other.h);
	}
}

var bullets = [];
var enemies = [];


function GameObject(x, y, w, h, dead){
	this.xSpeed = 4;
	this.x = x;
	this.y = y;
	this.w = w;
	this.h = h;
	this.fireCoolDown=95;
	this.dead = dead;
	this.health = 150; // for our god
	this.god=0;
	this.draw = function(color){
		if(this.god){
		ctx.drawImage(deng, this.x, this.y, this.w, this.h);
		}else{
		ctx.drawImage(chin, this.x, this.y, this.w, this.h);
		}
	};
	this.update = function(screenw, screenh){
		if(this.x+this.w > screenw || this.x < 0){
			this.xSpeed = -this.xSpeed;
			this.y += this.h;
		}
		if(this.y > screenh){ this.y = 0; }
		if(this.fireCoolDown >= 40){
			if(!this.god)
			this.fireCoolDown=0;
			else if(this.god==1)
			this.fireCoolDown=15;

			bullets.push(new Bullet(this.x, this.y+this.h+3, 10, 10, 5, 150, "e"));
			if(this.god==1)
				{
					bullets.push(new Bullet(this.x-15, this.y+this.h+5, 10, 10, 5, 150, "e"));
					bullets.push(new Bullet(this.x+15, this.y+this.h+5, 10, 10, 5, 150, "e"));
					bullets.push(new Bullet(this.x+30, this.y+this.h+5, 10, 10, 5, 150, "e"));
				}
		}else{
			this.fireCoolDown++;
		}
		this.x += this.xSpeed;
	}
}
var Chin = new GameObject(0, 0, 30, 60, 0);
var GOD = new GameObject(0, 0, 90, 90, 1);
var backgroundSwap = 150;
var backgrounds = [];
var bkgrndIndex = 1;
function gameDraw(){
	ctx.fillStyle = 'rgb(0, 0, 0)';
	//ctx.fillRect(0, 0, canvas.width, canvas.height);	
	
	if(backgroundSwap-- <= 0){
		backgroundSwap = 150;
		bkgrndIndex = Math.floor(Math.random()*3);
	}
	ctx.drawImage(backgrounds[bkgrndIndex], 0, 0, canvas.width, canvas.height);
	Chin.draw("rgb(255, 255, 255)");
	for(var i = 0; i < enemies.length; ++i){
		enemies[i].draw("rgb(255, 0, 0)");
	}
	for(var i = 0; i < bullets.length; ++i){
		bullets[i].draw("yellow");
	}
	if(!GOD.dead){
		GOD.draw("yellow");
	}
}

var frameLength = 150;
var introLength = frameLength*4;

var cutSceneImages = [];
var index=-1;
function gameUpdate(){
	// I think it's called every frame anyways.
	var killCountText = document.getElementById("killcount");	
	killCountText.innerHTML = String(killCount);
	music.play();
	if(gameOver == 0){
		if(introLength > 0){
			if(introLength > frameLength){
			if(introLength % frameLength == 0){
				index++;
			}
			ctx.drawImage(cutSceneImages[index], 0, 0, canvas.width, canvas.height);
			}else{
				ctx.fillStyle = "black";
				ctx.fillRect(0, 0, canvas.width, canvas.height);
				ctx.fillStyle = "yellow";
				ctx.font = "40px Arial";
				ctx.fillText("Welcome...", 0, 60);
				ctx.fillText("to Hong Kong...", 0, 100);
			}
			introLength--;
		}else{
		gameDraw();
		for(var i = 0; i < bullets.length; ++i){
			if(bullets[i].touching(Chin) && bullets[i].owner == "e"){
				gameOver = 1;
			}
			if(bullets[i].touching(GOD) && bullets[i].owner == "c"){
				if(GOD.health <= 0){
					GOD.dead = 1;
					killCount++;
				}else{
					bullets[i].lifeTime = -1;
					GOD.health -= 30;
				}
			}
			if(bullets[i].lifeTime > 0){
				bullets[i].update();
			}else{
				bullets.splice(i, 1);
			}
		}	
		if((killCount % 15) == 0 && GOD.dead){
			GOD = new GameObject(0, 0, 90, 90, 1);
			GOD.god = 1;
			GOD.dead = 0;
			enemies.splice(0, enemies.length);
			bullets.splice(0, bullets.length);
		}
		if(!GOD.dead){
			GOD.update(canvas.width, canvas.height);
		}
		for(var i = 0; i < enemies.length; ++i){
				if(enemies[i].dead != 1){
				enemies[i].update(canvas.width, canvas.height);
			}else{
				enemies.splice(i, 1);
			}
		}
		
		for(var i = 0; i < enemies.length; ++i){
			for(var j = 0; j < bullets.length; ++j){
			if(bullets[j].touching(enemies[i]) && bullets[j].owner == "c"){
					bullets[j].lifeTime = -1;
					enemies[i].dead = 1;
					killCount++;
				}
			}
		}
		if(spawnTimer >= 160 && GOD.dead){
			spawnTimer = 0;
			enemies.push(new GameObject(35, 0, 30, 60, 0));
			enemies.push(new GameObject(35*5, 0, 30, 60, 0));
			enemies.push(new GameObject(35*8, 0, 30, 60, 0));
		}else{
			if(GOD.dead)
			spawnTimer++;
		}
		if(fireTest > -1){
			fireTest--;
		}
		}
	}else{
		ctx.fillStyle = "yellow";
		ctx.font = "22px Arial";
		ctx.fillText("Game Over Refresh to play again" ,0, canvas.height*0.2);
		ctx.font = "40px Arial";
		ctx.fillText("CHIN IS DEAD" ,0, canvas.height/2);
	}
}

function init(){
	for(var i = 0; i < 4; ++i){
		cutSceneImages.push(new Image());
		cutSceneImages[i].src = String(i) + ".png";
	}

	for(var i = 0; i < 2; ++i){
		backgrounds.push(new Image());
		backgrounds[i].src = "bk"+String(i+1) + ".png";
	}

	chin = new Image();
	bomb = new Image();
	deng = new Image();
	chin.src = "chin.png";
	deng.src = "boss.png";
	bomb.src = "tsar bomba.png";

	console.log("Testing if the javascript is working.");
	console.log("Retrieving context of canvas...");

	canvas = document.getElementById("drawing-canvas");
	ctx = canvas.getContext("2d");
	Chin.x = (canvas.width/2)-Chin.w;
	Chin.y = (canvas.height)-Chin.h;
	document.addEventListener('keydown', 
	function(event){
		switch(event.key){
			case "ArrowLeft":
				Chin.x -= 19;
				break;
			case "ArrowRight":
				Chin.x += 19;
				break;
			case " ":
				if(fireTest < 0){
				gunFire.play();
				bullets.push(new Bullet(Chin.x, Chin.y - 20, 10, 10, -6, 150, "c"));
				fireTest = 30;
				}
				break;
		}
	}
	);
	setInterval(gameUpdate, 20)
	enemies.push(new GameObject(0, 0, 30, 60, 0));
	enemies.push(new GameObject(35*6, 0, 30, 60, 0));
	enemies.push(new GameObject(35*9, 0, 30, 60, 0));
	enemies.push(new GameObject(35*10, 0, 30, 60, 0));
}

function skipCutscene(){
	introLength = -1;
}
