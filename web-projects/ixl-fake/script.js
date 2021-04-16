/*
 * I'm going to relearn some DOM for this gag shit.
 */

/*
 * Perfect
 * now to create some basic stuff.
 */
function isEmpty( str ){
	return str.length ? 0 : 1;
}
var global_count_times=0;
function minor(){
	console.log("Function : MINOR");
	var usr_name=document.getElementById("name");
	var pswrd=document.getElementById("password");
	var minutes=document.getElementById("mins");
	console.log("Getting input values.");
	// do something later with that.
	
	console.log("Doing conditional checks...");
	var flag1=isEmpty(usr_name.value);
	var flag2=isEmpty(pswrd.value);
	if( !flag1 && !flag2 ){ 
		console.log("Passed string check");
	}
	else{ console.log("failed string check");
	      console.log("DUMPING VALUES");
	      if(flag1){ console.log("This is the responsible string?"); }	
	      if(flag2){ console.log("This is the responsible string?"); }	
	      if(flag2&&flag1){ console.log("Both are responsible?"); }
		return 0; }	
	console.log("Checking if minutes.value != NaN");
	if( minutes.value != NaN ){ 
		console.log("Minutes is not a number");
		return 1; }
}
function play_aud(){
	if(minor()==1){
		alert("Welcome to die!");
		var snd = new Audio("noise.wav");
		var txt = document.getElementById("header-banner");
		txt.innerHTML="BEAUTIFUL BIG BREASTED MAN";
		txt = document.getElementById("header-banner-little");
		txt.innerHTML="You really shouldn't have done that!";
		txt = document.getElementById("slightly-bigger-text");
		txt.innerHTML="Still virus free at least.";
		setTimeout(function(){
			window.open("http://lmgtfy.com/?q=The+cure+to+cancer.");
		}, 10000);
		snd.play();
	}else{
		if(global_count_times > 3){ alert("Your doing something seriously wrong"); }
		else if(global_count_times < 3){ alert("You may have entered incorrect information"); }
		global_count_times++;
	}
}


