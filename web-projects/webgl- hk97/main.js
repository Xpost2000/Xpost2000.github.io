var renderer;
var background_change_timer=0;
var spawn_timer=0;
var killCount=0;
var bkgnd=1;
var pause=false;
var chinFireDelay=40;

var chin = new GameObject( 300, 600, 45, 100 );
var god  = new GameObject( 0, 0, 200, 200 );

var themesong = new Sound();
var bullet = new Sound();

god.type=-1;
god.dead=true;
chin.type=1;
var enemies = [];

var Key = {
	keyDown:[],
	Left: 37,
	Up: 38,
	Right: 39,
	Down: 40,

	isDown: function(keycode){
		return this.keyDown[keycode];
	},

	onDownEvent: function(keycode){
		console.log("Pressed : " + keycode);
		this.keyDown[keycode] = true;
	},
	
	onReleaseEvent: function(keycode){
		console.log("Released : " + keycode);
		this.keyDown[keycode] = false;
	}
};

function main(){
	bullet.load("snd/gun.wav");
	themesong.load("snd/themesong.wav");
	var lastMessage = "Nothing";
	var shouldRun = false;
	var textCanvas = document.getElementById("dc2").getContext("2d");
	var gl = document.getElementById("dc").getContext("experimental-webgl") || 
		 document.getElementById("dc").getContext("webgl");
	if(gl){
		shouldRun = true;
		console.log("OpenGL is successful");
	}else{
		document.getElementById("error-message").innerHTML = "WebGL context failed to capture... Update your browser or reload the page.";
	}
	renderer = new WebGLRenderer(gl);
	renderer.init( "glsl3_vertexShader", "glsl3_fragmentShader" );

	renderer.loadTexture("textures/chin.png", "chin");
	renderer.loadTexture("textures/boss.png", "boss");
	renderer.loadTexture("textures/tsar bomba.png", "bullet");
	renderer.loadTexture("textures/bk1.png", "bk1");
	renderer.loadTexture("textures/bk2.png", "bk2");

	textCanvas.fillStyle = "white";
	textCanvas.font = "18px Arial";
	if(shouldRun){
		requestAnimationFrame(function(){main_draw(gl, textCanvas);});
		setInterval(main_update, 1000/60);
	}

	window.addEventListener('keyup', function(event){ Key.onReleaseEvent(event.keyCode) });
	window.addEventListener('keydown', function(event){ Key.onDownEvent(event.keyCode) });

	enemies.push(new GameObject(0, 0, 50, 100));
	enemies.push(new GameObject(150, 0, 50, 100));
}

var pauseKeyDelay=0;
function main_update(){
	if(document.hasFocus()){
		themesong.play();
		// it takes values from the upper case ascii value.
		if(Key.isDown(65)){
			if(chin.x > 0)
			chin.x -= 5.3;
		}
		if(Key.isDown(68)){
			if(chin.x+chin.w < 1280)
			chin.x += 5.3;
		}
		if(Key.isDown(87)){
			if(chin.y > 0)
			chin.y -= 5.3;
		}
		if(Key.isDown(83)){
			if(chin.y+chin.h < 960)
			chin.y += 5.3;
		}
		if(chinFireDelay >= 40){
		if(Key.isDown(32)){
			global_bullets.push(new Bullet(chin.x, chin.y, 15, 15, 0, -7, 300));
			chinFireDelay=0;
			bullet.play();
		}}else{
			chinFireDelay++;
		}
		if(pauseKeyDelay==0){
		if(Key.isDown(27)){
			pause=!pause;
			pauseKeyDelay=10;
		}
		}else{
			pauseKeyDelay--;
		}
	if(!pause && !chin.dead){
		background_change_timer+=0.5;
		spawn_timer += 0.8;
		if(killCount>0 && killCount%15==0){
			if(god.dead){
				god.dead=false;
				god.x = 0;
				god.y = 0;
				god.bossHp=150;
				enemies.splice(0, enemies.length);
			}
		}
		if(spawn_timer >= 70 && (killCount>0 && (killCount % 15 != 0))){
			enemies.push(new GameObject(0, 0, 50, 100));
			spawn_timer = 0;
		}
		if(background_change_timer >= 50){
			if(bkgnd!=1)
			bkgnd=1;
			else
			bkgnd=2;

			background_change_timer = 0;
		}
	
		if(chin.touch(god)){
			chin.dead=true;
		}
		for(var i = 0; i < global_bullets.length; ++i){
			if(global_bullets[i].lifeTime <= 0){
				global_bullets.splice(i, 1);
			}else{
			if(chin.touch(global_bullets[i]) && global_bullets[i].owner != "CHIN"){
				chin.dead=true;
			}
			if(god.touch(global_bullets[i]) && global_bullets[i].owner == "CHIN"){
				if(god.bossHp > 0){
					god.bossHp -= 20;
					global_bullets.splice(i, 1);
				}
				if(god.bossHp <= 0){
					god.dead=true;
					killCount++;
				}
			}
			global_bullets[i].update();
			}
		}
		for(var i = 0; i < enemies.length; ++i){
			for(var j = 0; j < global_bullets.length; ++j){
				if(enemies[i].touch(global_bullets[j]) && global_bullets[j].owner =="CHIN"){
					enemies[i].dead = 1;
					global_bullets[j].lifeTime = 0;
					killCount++;
				}
			}

			enemies[i].update(renderer.gl.canvas.width*2, renderer.gl.canvas.height*2);
		}
		god.update(renderer.gl.canvas.width*2, renderer.gl.canvas.height*2);
	}
	}
}
function main_draw(gl, txtDc){
	txtDc.fillStyle = "rgba(0, 0, 0, 0)";
	txtDc.clearRect(0, 0, 1000, 1000);
	txtDc.fillStyle = "yellow";
	if(pause){
		txtDc.fillText("PAUSED GAME", 0, 30);
	}
	txtDc.fillText("Kill Count : " + killCount, 0, 15);
	if(chin.dead){
		txtDc.fillText("CHIN is DEAD", 0, 60);
	}
	renderer.clear( 0.3, 0.4, 0.4, 1);
	renderer.renderRectangle(0, 0, gl.canvas.width*2, gl.canvas.height*2, 255, 255, 255, "bk"+String(bkgnd));
	chin.draw(renderer);
	for(var i = 0; i < enemies.length; ++i){
		enemies[i].draw(renderer);
	}
	for(var i = 0; i < global_bullets.length; ++i){
		global_bullets[i].draw(renderer);
	}
	god.draw(renderer);
	requestAnimationFrame(function(){main_draw(gl, txtDc);});
}

function main_unload(){
	renderer.finish();
}
