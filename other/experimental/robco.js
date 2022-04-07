/*
   TODO(jerry): 
   More animation elements!
*/

/*
   Welcome to ROBCO Term!
   
   This is mostly javascript powered, and looks cool as hell.
   
   There are a lot of assumptions in the website format that are rigid so I can't
   modify it too much off of my original design, but whatever.
   
   NOTE(jerry):
   Animation is actually one of the hardest f**king things about graphics.
   So much f**king state to keep track of.
   
   TODO(jerry):
   Image hack. Since my case is niche (intentionally making a website load an image
   slowly). It seems by conventional means this is impossible (or really hard to look up that
   I'm not even going to bother, and just do it myself with this hack...)
   
   Create a canvas the size of the image element (I'll shadow DOM substitute the image with a canvas,
   that slowly increases it's size). Just draw the full image, and increase the size of the canvas slowly.
   
   Of course that does mean images *MUST* delay the rest of the page from presenting otherwise it
   would look stupid.
*/
function hack_to_refresh_all_youtube_video_embeds() {
  /*
     Since I know for now the only iframes I have are just videos... We'll just do this...
     
     This might actually straight up just be the right decisions anyways.
   */

  const embeds = Array.from(document.querySelectorAll("iframe"));
  for (const embed of embeds) {
    const s = embed.src;
    embed.src = s;
  }
}

/* stupid web hacks */
function hash_history_push(hash) {
  if (history.pushState) {
    history.pushState(null, null, hash);
    _enter_page(unhash_location());
  } else {
    location.hash = hash;
  }
}


/* This is probably generating way too much garbage or something? */
var audio_objects = {};
function load_sound(name) {
  return new Promise(
    function (resolve, reject) {
      let new_snd = new Audio(name);
      new_snd.addEventListener(
        'loadeddata', function () {
          audio_objects[name] = new_snd;
          resolve(new_snd);
      });
    }
  );
}

async function play_sound(name) {
  let snd = audio_objects[name];
  if (!snd) snd = await load_sound(name);

  snd.play();
}

var current_page = undefined;

/*
   This list stores a separate state model for the text in order to animate it.
   
   There is one limitation in that we cannot actually store marked up text, unless I convert
   the text into a weird markdown form... It would be a pain is what I mean. So I'm not doing that.
*/
var animating_text_list = [];

function random_elt(list) {
  let idx = Math.floor(Math.random() * list.length);
  return list[idx];
}

/* hahahaha, the word waitlist gives me conniptions */
function get_animated_element_by_name(name) {
  for (const element of animating_text_list) {
    if (element.element.getAttribute("id") === name) {
      return element;
    }
  }

  return null;
}

function animated_element_done_animating(element) {
    if (element.presented < element.text.length) {
      return false;
    }

  return true;
}

function element_waitlist_completed(element) {
  for (const item of element.dependencies) {
    const dependency = get_animated_element_by_name(item);
    if (!animated_element_done_animating(dependency)) {
      return false;
    }
  }

  return true;
}

function extract_dependency_list_from_string(string) {
  if (string)
    return string.split(" ");
  return [];
}

/*Okay... This wasn't so well thought out... Whatever*/
function animated_element_fire_onend(element) {
  if (element.id && element.events.finish !== 1) {
    let old = element.events.finish;
    element.events.finish += 1;
    if (element.events.finish != old) {
      handle_onend_animated_event(element.id);
    }
  }
}
function animated_element_fire_onstart(element) {
  if (element.id && element.events.start !== 1) {
    let old = element.events.start;
    element.events.start += 1;
    if (element.events.start != old) {
      handle_onstart_animated_event(element.id);
    }
  }
}

function animated_text_state_from_element(element) {
  return {
    /* mutate this */
    element,
    id: element.getAttribute("id"),
    text: element.innerText,
    original_html: element.innerHTML,

    /* 
       this is a map of events along with their counter. 

       Technically these two events are booleans only, and I literally see
       no scenario where I would actually check these numbers nor do I see any scenario
       where these anything other than 1 or 0, but whatever. (in it's short lifespan of a day.)
    */
    events: {
      finish: 0,
      start:  0,
    },
    /* 
       This is stored we can restore HTML-ness after text shows. 
       This is the best compromise between complexity of the website, and complexity of this
       code. I'm NOT writing another markup language for this, and I think most people don't care
       about the thing I'm talking about here.
     */
    presented: 0,
    timer: 0,
    initial_delay_timer: element.getAttribute("initial-delay"),
    dependencies: extract_dependency_list_from_string(element.getAttribute("waitfor")),
    speed: (element.getAttribute("type-speed")),
  };
}

function has_animation_attributes(element) {
  return element.getAttribute("type-speed");
}

function ready_animation_list_for_animation() {
  for (const state_object of animating_text_list) {
    state_object.element.innerText = "";
  }
}

function animation_list_complete() {
  for (const element of animating_text_list) {
    if (!animated_element_done_animating(element)) {
      return false;
    }
  }

  return true;
}

function animated_element_fire_onfinish(element) {

}

var _animation_last_time = 0;
var _last_request_animation_frame_id;

function force_finish_all_animations_on_page() {
  /* no skipping the intro though :) */
  if (current_page === "intro-login" ||
      current_page === "intro-boot-up")
    return false;

  if (_last_request_animation_frame_id) {
    cancelAnimationFrame(_last_request_animation_frame_id);
  }

  for (const element of animating_text_list) {
    element.element.innerHTML = element.original_html;
  }

  return true;
}

function animation_frame(current_timestamp) {
  let delta_time = current_timestamp - _animation_last_time;
  _animation_last_time = current_timestamp;
  delta_time /= 1000;
  
  /* 
     run through one frame of animation 
     keeping in mind of dependencies and what not...
     
     We figure out the advancements...
   */
  for (const element of animating_text_list) {
    if (!element_waitlist_completed(element)) {
      continue;
    }

    if (element.initial_delay_timer > 0) {
      element.initial_delay_timer -= delta_time;
      continue;
    }

    if (!animated_element_done_animating(element)) {
      if (element.timer <= 0) {
        animated_element_fire_onstart(element);

        element.presented += 1;

        if (element.element.getAttribute("hack-override-human") != null) {
          play_sound(random_elt(
            [
              "./sfx/hacking/char/single/ui_hacking_charsingle_01.wav",
              "./sfx/hacking/char/single/ui_hacking_charsingle_02.wav",
              "./sfx/hacking/char/single/ui_hacking_charsingle_03.wav",
              "./sfx/hacking/char/single/ui_hacking_charsingle_04.wav",
              "./sfx/hacking/char/single/ui_hacking_charsingle_05.wav",
              "./sfx/hacking/char/single/ui_hacking_charsingle_06.wav",
            ]
          ));
        } else {
          play_sound("./sfx/hacking/char/ui_hacking_charscroll.wav");
        }
        
        element.timer = element.speed;
      } else {
        element.timer -= delta_time;
      }
    } else {
      /* 
         this is a hack-ish thing that wasn't given much thought. I just needed a quick way to handle
         "events".
         
         Actually this is still not the worst way to do this though lol. It's actually still a relatively
         sane way of doing so compared to the hardcoding.
      */
      animated_element_fire_onend(element);
    }
  }

  /*
     Update the web page...
  */
  for (const element of animating_text_list) {
    if (!element_waitlist_completed(element)) {
      continue;
    }

    if (element.presented == element.text.length) {
      /* If the text is complete, restore the html */
      element.element.innerHTML = element.original_html;

      /* 
         NOTE(jerry): Too lazy to add another flag. I'm just going to use 
         implicit logic, which makes absolutely no sense to avoid writing more code. 
       */
      element.presented += 1;
    } else if (!animated_element_done_animating(element)) {
      element.element.innerText = element.text.slice(0, element.presented);
    }
  }

  if (!animation_list_complete()) {
    _last_request_animation_frame_id = requestAnimationFrame(animation_frame);
  } else {
    special_case_handle_transitions_for_current_page();
  }
}

function begin_animation() {
  _last_request_animation_frame_id = requestAnimationFrame(animation_frame);
}

/*
   Sets up the entire page for animation
*/
function _enter_page(page_id) {
  console.log("_enter page: ", page_id);
  hack_to_refresh_all_youtube_video_embeds();
  /* eliminate any previous remaining state... */
  {
    force_finish_all_animations_on_page();
    const pages = Array.from(document.querySelectorAll(".page"));
    for (const page of pages) {
      page.classList.add("hidden");
    }
  }

  current_page = page_id;
  special_case_handle_entering_page_transitions_for_current_page();
  /* 
     collect all animatable elements and produce an animation list to run through.

     For now only text is animated. TODO(jerry): add images
  */

  {
    /* explicitly, I'm only expecting page_id to actually be ids. To elements */
    let target_page_element = document.getElementById(current_page);

    if (!target_page_element) {
      target_page_element = document.getElementById("404errorpageohnononononononononono");
    }

    target_page_element.classList.remove("hidden");
    let all_animatable_elements =
      Array.from(target_page_element.children).filter(has_animation_attributes);

    animating_text_list =
      all_animatable_elements.map(animated_text_state_from_element);

    ready_animation_list_for_animation();
    begin_animation();
  }
}

function enter_page(page_id) {
  hash_history_push("#"+page_id);
  console.log("enter page: ", page_id);
}

/* 
   NOTE(jerry): 
   Very few pages need to "automatically" change or otherwise do things on animation
   finish. so I could add a special attribute or just special case it here.
   
   So these are hardcoded. I do not want to spend that much time coming up with an elaborate
   system, for what is arguably the worst UI creation method ever conceived.
*/
const quotes = [
  /* Does anyone know where these quotes come from without googling them? :) */
  "The human being created civilization not because of willingness but of a need to be assimilated into higher orders of structure and meaning.",
  "Every war is the result of a difference of opinion. Maybe the biggest questions can only be answered by the greatest of conflicts.",
  "The Individual desires judgment. Without that desire, the cohesion of groups is impossible, and so is civilization.",
  "What good's an honest soldier if he can be ordered to behave like a terrorist?",
  "All free societies have started with one premise: human nature is cruel, unjust -- a force to be controlled.",
  "Technology offers us strength. Strength enables dominance, and dominance paves the way for abuse.",
  "Freedom. To those that don't have it, it's more valuable than gold. But where should it start and end? We humans often think we have the right to expand, absorb, convert, or possess anything we need to reach our dreams. But time and time again, hasn't this lead to conflicts with others who essentially believe the same thing?",
];

function special_case_handle_entering_page_transitions_for_current_page() {
  switch (current_page) {
    case "main-menu": {
      const random_quote_element = document.getElementById("menu-random-quote");
      random_quote_element.innerHTML = `"<b>${random_elt(quotes)}</b>"`;
    } break;
  }
}

function special_case_handle_transitions_for_current_page() {
  switch (current_page) {
    case "intro-boot-up": {
      console.log("hmm");
      enter_page("intro-login");
    } break;
    case "intro-login": {
      enter_page("main-menu");
    } break;
  }
}

/*
   Key events
*/

function keydown_listener(event) {
  if (force_finish_all_animations_on_page()) {
    special_case_handle_transitions_for_current_page();
  }
}

function keyup_listener(event) {
}

document.addEventListener("keydown", keydown_listener);
document.addEventListener("keyup",   keyup_listener);

/* fancy nice things for that authentic feel. */
function random_float_between(a, b) {
  return Math.random() * (b - a) + a;
}

function setup_driver_page() {
  function driver(name, should_fail) {
    return {name, should_fail};
  }

  const drivers_list = [
    driver("NETLNK", false),
    driver("INTRPLY96", false),
    driver("OBSIDIAN", false),
    driver("VLTTKTRK1V2", false),
    driver("SHUB81", false),
    driver("ATH9K", true),
    driver("AUTHOCT10.97", true),
    driver("NTKRNL", true),
    driver("GEIGER", false),
    driver("VTKEXP", true),
  ];
  const page = document.getElementById("intro-boot-up");

  let i = 0;
  let driver_statuses = [];
  for (const driver of drivers_list) {
    let driver_text_element = document.createElement("P");
    let driver_status_element = document.createElement("P");
    {
      driver_text_element.innerHTML = "Loading driver: " + driver.name;
      if (driver.should_fail) {
        driver_status_element.innerHTML = `[FAIL] Failed to load driver "${driver.name}"!`;
      } else {
        driver_status_element.innerHTML = `[OK] Loaded driver "${driver.name}" successfully!`;
      }

      let driver_element_id = `intro-driver${i}`;

      if (i === drivers_list.length-1) driver_element_id = "last-intro-driver-id";

      driver_text_element.setAttribute("id", driver_element_id);
      driver_text_element.setAttribute("waitfor", "1intro1a");
      driver_text_element.setAttribute("type-speed", "0.1");
      driver_text_element.setAttribute("initial-delay", `${random_float_between(0.1, 0.3)}`);
      driver_status_element.setAttribute("waitfor", driver_element_id);
      driver_status_element.setAttribute("id", `${driver_element_id}-status`);
      driver_status_element.setAttribute("type-speed", "0.08");

      i += 1;
    }
    page.appendChild(driver_text_element);
    /* defer this for the look */
    driver_statuses.push(driver_status_element);
  }

  for (const driver_status_element of driver_statuses) {
    page.appendChild(driver_status_element);
  }


  /* last elements to push */
  {
    page.appendChild(document.createElement("BR"));
    const flavor = document.createElement("P");
    flavor.setAttribute("waitfor", "last-intro-driver-id-status");
    flavor.setAttribute("initial-delay", "1.2");
    flavor.setAttribute("type-speed", "0.13");
    flavor.innerHTML = "<b>SYSTEM BOOT OKAY...</b>";
    page.appendChild(flavor);
  }

}

function preload_assets() {
}

const TYPE_EVENT_START = 1;
const TYPE_EVENT_END   = 2;
function handle_onend_animated_event(id) {
  handle_animated_event(id, TYPE_EVENT_END);
}
function handle_onstart_animated_event(id) {
  handle_animated_event(id, TYPE_EVENT_START);
}


function handle_animated_event(id, event_type) {
  switch (id) {
    case 'vtclogo': {
      if (event_type === TYPE_EVENT_START) {
        play_sound("./sfx/pipboy/ui_pipboy_holotape_start.wav");
      } else {
        play_sound("./sfx/pipboy/ui_pipboy_holotape_stop.wav");
      }
    } break;
    case 'headbar': {
      if (event_type === TYPE_EVENT_START) {
        play_sound("./sfx/vats/ui_vats_ready.wav");
      }
    } break;
    case "intro4": {
      if (event_type === TYPE_EVENT_END) {
        play_sound("./sfx/hacking/char/enter/ui_hacking_charenter_01.wav");
      }
    } break;
    case "intro9": {
      if (event_type === TYPE_EVENT_END) {
        play_sound("./sfx/hacking/ui_hacking_passgood.wav");
      }
    } break;
  }
}

/*
   This was kind of lazy but whatever.
*/
function set_color_preference(color) {
  const elt = document.getElementById("color-tinter");
  // lazy lol
  elt.classList.remove("nva");
  elt.classList.remove("pb");
  elt.classList.remove("aw");
  elt.classList.remove("cwl-g");

  const color_map = {
    "fo3green": "cwl-g",
    "fonvamber": "nva",
    "fo3blue": "pb",
    "fo3white": "aw",
  };

  /* update in local storage */
  {
    localStorage.setItem("colorpref", color);
  }
  elt.classList.add(color_map[color] || "cwl-g");
}

