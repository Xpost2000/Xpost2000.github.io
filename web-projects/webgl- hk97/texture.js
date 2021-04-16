/*
 * Texture object
 */

function Texture( gl ){
	this.gl = gl;
	this.texId = 0;
	this.htmlImage;	
	this.finish = function(){
		this.gl.deleteTexture(this.texId);
	}
	this.use = function(){
		this.gl.bindTexture(this.gl.TEXTURE_2D, this.texId);
	}
	this.unuse = function(){
		this.gl.bindTexture(this.gl.TEXTURE_2D, null);
	}
	this.init = function( url="OPT" ){
		this.texId = this.gl.createTexture();
		this.gl.bindTexture(this.gl.TEXTURE_2D, this.texId);
		this.gl.texImage2D(
			this.gl.TEXTURE_2D,
			0,
			this.gl.RGBA,
			1, 1,
			0,
			this.gl.RGBA,
			this.gl.UNSIGNED_BYTE,
			new Uint8Array([ 255, 255, 255, 255 ])
		);
		this.gl.texParameteri(
			this.gl.TEXTURE_2D,
			this.gl.TEXTURE_MAG_FILTER,
			this.gl.NEAREST
		);
		this.gl.texParameteri(
			this.gl.TEXTURE_2D,
			this.gl.TEXTURE_MIN_FILTER,
			this.gl.NEAREST
		);
		this.gl.texParameteri(
			this.gl.TEXTURE_2D,
			this.gl.TEXTURE_WRAP_S,
			this.gl.CLAMP_TO_EDGE
		);
		this.gl.texParameteri(
			this.gl.TEXTURE_2D,
			this.gl.TEXTURE_WRAP_T,
			this.gl.CLAMP_TO_EDGE
		);
		if(url == "OPT"){
			this.gl.generateMipmap(this.gl.TEXTURE_2D);
		}else{
			this.htmlImage = new Image();
			this.htmlImage.src = url;
			this.htmlImage.onload= this._onload_callback();
		}
		this.gl.bindTexture(this.gl.TEXTURE_2D, null);
	}
	this._onload_callback = function(){
			this.gl.bindTexture(this.gl.TEXTURE_2D, this.texId);
			this.gl.texImage2D(
				this.gl.TEXTURE_2D,
				0,
				this.gl.RGBA,
				this.gl.RGBA,
				this.gl.UNSIGNED_BYTE,
				this.htmlImage
			);
			this.gl.generateMipmap(this.gl.TEXTURE_2D);
			console.log("HTML Image loaded");
	}
}
