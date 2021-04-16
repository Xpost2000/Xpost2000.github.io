/*
 * This is an Entity
 * all game object types
 * inherit from this.
 *
 * also all game object types are defined here
 */

function Entity(x, y, drawSymbol){
	this.x = x;
	this.y = y;
	this.type = 0; // 0 creature/living thing : other numbers reserved for other objects.
	this.drawSymbol = drawSymbol;
}

function Creature(){
	this.name="NAME";

	this.activityLvl=0;// used by NPCs to determine movements.
	this.aggression=0; // same thing...

	// these two only apply to player
	this.hungerLevel = 0;
	this.thirstLevel = 0;

	// but all other creatures will indeed use these items
	// to some extent.
	
	this.update = function(map){
		// this is for npcs 
	} // TODO FUNCTION
	this.move = function(map, x, y){
		var predX = this.prototype.x + x;
		var predY = this.prototype.y + y;
		var returnValue="GOOD";
		var canMove=true;
		for(var i = 0; i < map.entities.length; ++i){
			if(predX != map.entities[i].prototype.x || predY != map.entities[i].prototype.y){
			}else{
				canMove=false;
				returnValue = map.entities[i].name;
			}
		}
		if(map.map[predY][predX] != '#'){
		}else{
			canMove=false;
			returnValue = "wall";
		}
		if(canMove){
			this.prototype.x = predX;
			this.prototype.y = predY;
		}

		return returnValue;
	}

	this.inventory = [];
	this.spells = [];

	this.className= 0;
	this.race = 0;

	this.level = 1;

	this.hp = 10;

	this.strength=5;
	this.dexterity=5;
	this.wisdom=5;
	this.intelligence=5;
	this.charisma=5;
	this.luck=5;
}

function MakeCreature(x, y, drawSymbol, name, className, race){
	var objToConvert = new Creature();
	objToConvert.prototype = Object.create(Entity.prototype);
	objToConvert.prototype.x = x;
	objToConvert.prototype.y = y;
	objToConvert.prototype.drawSymbol = drawSymbol;
	objToConvert.name = name;
	objToConvert.className = className;
	objToConvert.race = race;
	return objToConvert;
}
