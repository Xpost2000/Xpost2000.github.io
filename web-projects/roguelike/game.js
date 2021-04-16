var con;
var maze;
var player = MakeCreature(1, 8, '@', "HeroNameHere", 0, 1);
var map = new Map(); 
map.addRoom(4, 5, 10, 10);
map.addRoom(14, 7, 10, 6);
map.removeWall(4, 10);
map.removeWall(14, 10);
map.addEntity(MakeCreature(21, 9, 'p', "Catholic Priest", 0, 1))
map.addEntity(MakeCreature(21, 11, 'p', "Catholic Priest", 0, 1))
map.addEntity(MakeCreature(22, 10, 'P', "The Pope", 0, 1))

function initGame(){
	con = new Console("cmd-text")

	maze = document.getElementById("game-area-draw");
	gameStep();
};

// testfunction
function drawMap(){
    var displayMap = [], x, y;
    for (y = 0; y < map.map.length; y += 1) {
        displayMap[y] = displayMap[y] || [];
        for (x = 0; x < map.map[y].length; x += 1) {
            displayMap[y][x] = map.map[y][x];
        }
    }

    displayMap[player.prototype.y][player.prototype.x] = player.prototype.drawSymbol;
    map.entities.forEach(function(element){
	    displayMap[element.prototype.y][element.prototype.x] = element.prototype.drawSymbol;
    });

    for (y = 0; y < displayMap.length; y += 1) {
        displayMap[y] = displayMap[y].join('');
    }
    maze.innerHTML = displayMap.join('\n');
}

function playerMove(x, y){
	var result = player.move(map, x, y);
	if(result != "GOOD"){
		con.Print("You bumped into a " + result);
	}
	gameStep();
}

function playerInventory(){
	con.Print("Checking player inventory: [TODO]");
}

function playerEquip(){
	con.Print("Equipping an item from inventory[PICK] [TODO]");
}

function playerPickup(){
	con.Print("Picking up item(s) that I stand on. [TODO]");
	gameStep();
}

function playerPray(){
	con.Print("Attempting prayer...[TODO]");
	gameStep();
}

function gameStep(){
	drawMap();
	map.updateEntities();
}
