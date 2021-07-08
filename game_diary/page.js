/*
   https://steamwebapi.azurewebsites.net/
   
   thanks I guess.
   
   God damn it SteamDB, I know this information is publically avaliable but why is it so hard
   to figure out how to get the description for a fucking game?
   
   Maybe I just can't google very well...
*/
class steam_game_information {
  constructor(game_id) {
    this.game_id = game_id;
    this.name = "#game_name";
    this.description = "#game_description";
    this.developer = "#game_developer";
    this.release_date = "#release_date";
    this.thumbnail_source = "#thumbnail_source";
  }
}

async function steam_get_game_information(game_id) {
}


/* steam_get_game_information(220); */

const https = require('https');
const options = {
  hostname: 'store.steampowered.com',
  port: 80,
  path: '/api/appdetails?appids=220',
  method: 'GET'
}

const req = https.request(options, res => {
  console.log(`statusCode: ${res.statusCode}`)

  res.on('data', d => {
    process.stdout.write(d)
  })
})

req.on('error', error => console.error(error));
req.end();
/* 
 * fetch("https://store.steampowered.com/api/appdetails?appids=220").then(
 *   response => response.json()
 * ).then(
 *   function (json) {
 *     console.log(json);
 *   }
 * ); */
