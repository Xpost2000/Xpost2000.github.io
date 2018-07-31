/*
 * Simple convenience class
 * to draw text to the console
 */

function Console( elementId ){
	this.ConsoleStrings = [];
	this.InternalDev = document.getElementById( elementId );
	this.Print = function( string ){
		this.ConsoleStrings.push(string);
		this.InternalDev.innerHTML = this.ConsoleStrings.join("\n");
	}
}
