/*
 * I'm going to hopefully have a working webgl renderer.
 *
 * draws rectangles
 * and textured rectangles.
 * Amazing.
 */

function WebGLRenderer(context){
	this.gl = context;

	// planning to only have one set of shaders
	// so leave it as is.
	this.shaderProgram;
	this.vertShader;
	this.fragShader;
	this.textures = {};
	this.vbo;

	this.loadTexture = function(url, name){
		this.textures[name] = new Texture(this.gl);
		this.textures[name].init(url);
	}

	this.renderRectangle = function( x, y, w, h, r=255, g=255, b=255, texture="default" ){
		/*
		 * blam me for now
		 * doing this math on the shaders.
		 * It works fine and is just as fast... I think
		 */
		x /= this.gl.canvas.width;
		x-=1;
		y /= this.gl.canvas.height;
		y=-y; // to imitate normal 2d orthographic projections
		      // where 0 = y top.
		y+=(1-(h/this.gl.canvas.height));
		w /= this.gl.canvas.width;
		h /= this.gl.canvas.height;

		r/=255;
		g/=255;
		b/=255;
		this.gl.useProgram(this.shaderProgram);
		this.gl.bindBuffer(this.gl.ARRAY_BUFFER, this.vbo);
		this.gl.bufferData(this.gl.ARRAY_BUFFER,
				   new Float32Array([
				   //       0   4       8  12 16   20 24
					    x,  y, 	r, g, b,   0, 1,
					    x,  y+h,	r, g, b,   0, 0,
					    x+w, y,	r, g, b,   1, 1,
					    x+w, y,	r, g, b,   1, 1,
					    x, y+h,	r, g, b,   0, 0,
					    x+w, y+h,	r, g, b,   1, 0
				   ]),
				   this.gl.DYNAMIC_DRAW);
		this.textures[texture].use();
		this.gl.drawArrays(this.gl.TRIANGLES, 0, 6);
		this.textures[texture].unuse();
	}

	this.init  = function( vertexId, fragmentId ){
		console.log("initing WebGLRenderer");
		this.textures["default"] = new Texture(this.gl);
		this.textures["default"].init();

		this.shaderProgram = this.gl.createProgram();
		this.vertShader = this.gl.createShader(this.gl.VERTEX_SHADER);
		this.fragShader = this.gl.createShader(this.gl.FRAGMENT_SHADER);

		this.gl.shaderSource( this.vertShader, document.getElementById(vertexId).text );
		this.gl.shaderSource( this.fragShader, document.getElementById(fragmentId).text );
		this.gl.compileShader(this.vertShader);
		console.log("Shader Vertex Log : ");
		console.log(this.gl.getShaderInfoLog(this.vertShader));
		this.gl.compileShader(this.fragShader);
		console.log("Shader Fragment Log : ");
		console.log(this.gl.getShaderInfoLog(this.fragShader));

		this.gl.enable(this.gl.BLEND);
		this.gl.blendFunc(this.gl.SRC_ALPHA, this.gl.ONE_MINUS_SRC_ALPHA);

		this.gl.attachShader(this.shaderProgram, this.vertShader);
		this.gl.attachShader(this.shaderProgram, this.fragShader);
		this.gl.linkProgram(this.shaderProgram);
		console.log("If the console didn't show any warnings. The shader is successfully compiled");

		this.vbo = this.gl.createBuffer();
		this.gl.bindBuffer(this.gl.ARRAY_BUFFER, this.vbo);
		this.gl.enableVertexAttribArray(this.gl.getAttribLocation(this.shaderProgram, "vAttribPos"));
		this.gl.enableVertexAttribArray(this.gl.getAttribLocation(this.shaderProgram, "vAttribColor"));
		this.gl.enableVertexAttribArray(this.gl.getAttribLocation(this.shaderProgram, "vAttribUvs"));
		this.gl.vertexAttribPointer(
			this.gl.getAttribLocation(this.shaderProgram, "vAttribPos"),
			2,
			this.gl.FLOAT,
			false,
			4*7,
			0
		);
		this.gl.vertexAttribPointer(
			this.gl.getAttribLocation(this.shaderProgram, "vAttribColor"),
			3,
			this.gl.FLOAT,
			false,
			4*7,
			4*2
		);
		this.gl.vertexAttribPointer(
			this.gl.getAttribLocation(this.shaderProgram, "vAttribUvs"),
			2,
			this.gl.FLOAT,
			false,
			4*7,
			4*5
		);
	}
	this.finish = function(){
		console.log("finishing WebGLRenderer");
		for(var key in this.textures){
			this.textures[key].finish();
		}
		this.gl.deleteShader(this.vertShader);
		this.gl.deleteShader(this.fragShader);
		this.gl.deleteProgram(this.shaderProgram);
		this.gl.deleteBuffer(this.vbo);
	}

	this.clear = function(r, g, b, a){
		this.gl.clearColor(r, g, b, a);
		this.gl.clear(this.gl.COLOR_BUFFER_BIT);
	}
}
