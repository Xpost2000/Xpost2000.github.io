var renderer;
var background_change_timer=0;
var spawn_timer=0;
var killCount=15;
var bkgnd=1;
var pause=false;

var chin = new GameObject( 300, 600, 50, 100 );
var god  = new GameObject( 0, 0, 200, 200 );
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
		// it takes values from the upper case ascii value.
		if(Key.isDown(65)){
			chin.x -= 4;
		}
		if(Key.isDown(68)){
			chin.x += 4;
		}
		if(Key.isDown(87)){
			chin.y -= 4;
		}
		if(Key.isDown(83)){
			chin.y += 4;
		}
		if(pauseKeyDelay==0){
		if(Key.isDown(27)){
			pause=!pause;
			pauseKeyDelay=10;
		}
		}else{
			pauseKeyDelay--;
		}
	if(!pause){
		background_change_timer+=0.5;
		spawn_timer += 0.2;
		if(killCount>0 && killCount%15==0){
			if(god.dead){
				god.dead=false;
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
	
		for(var i = 0; i < enemies.length; ++i){
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
	}else{
	}
	txtDc.fillText("Kill Count : " + killCount, 0, 15);
	renderer.clear( 0.3, 0.4, 0.4, 1);
	renderer.renderRectangle(0, 0, gl.canvas.width*2, gl.canvas.height*2, 255, 255, 255, "bk"+String(bkgnd));
	chin.draw(renderer);
	for(var i = 0; i < enemies.length; ++i){
		enemies[i].draw(renderer);
	}
	god.draw(renderer);
//	renderer.renderRectangle( 200, 0, 170, 170, 155, 255, 0, "boss" );
	requestAnimationFrame(function(){main_draw(gl, txtDc);});
}

function main_unload(){
	renderer.finish();
}
