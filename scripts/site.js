// I'm sure there's a better way, but I can always fix this later.
function paste_lots_of_tildes(event) {
    let gutter = document.getElementById("ugly-ass-gutter");

    // The gutter no longer scrolls, so this is unnecessary.
    for (let tilde_index = 0; tilde_index < 200; ++tilde_index) {
        let new_tilde = document.createElement("p");
        new_tilde.innerHTML = "~";
        gutter.appendChild(new_tilde);
    }
}

paste_lots_of_tildes();

function handle_resize(event) {
    let gutter = document.getElementById("ugly-ass-gutter");
    gutter.style.height = window.innerHeight * 1.1;
}

window.addEventListener("resize", handle_resize);
handle_resize();

const mini_buffer = document.querySelector("#mini-buffer-main");
const mini_buffer_autocompletion = document.querySelector("#mini-buffer-autocompletion");

mini_buffer.addEventListener("mouseover", function(event) { mini_buffer_autocompletion.style.display = "block"; });
mini_buffer_autocompletion.addEventListener("mouseover", function(event) { mini_buffer_autocompletion.style.display = "block"; });
// This is for mobile access
mini_buffer.addEventListener("click", function(event) {
    if (mini_buffer_autocompletion.style.display != "none") {
        mini_buffer_autocompletion.style.display = "none";
    } else {
        mini_buffer_autocompletion.style.display = "block";
    }
});
mini_buffer_autocompletion.addEventListener("mouseout", function(event) { mini_buffer_autocompletion.style.display = "none"; });
mini_buffer_autocompletion.addEventListener("click", function(event) { mini_buffer_autocompletion.style.display = "none"; });

let theme_selector_visible = false;
let theme_selector = function() {
    let holder_div = document.createElement("div");
    holder_div.id = "theme-selector";

    let box_holder_div = document.createElement("div");
    box_holder_div.id = "theme-selector-box";

    holder_div.appendChild(box_holder_div);

    {
        let header = document.createElement("h1");
        header.appendChild(document.createTextNode("Theme Selection"));
        let paragraph = document.createElement("p");
        paragraph.appendChild(document.createTextNode(`
          Use this little selector widget to change the current theme for the site. It doesn't really
          serve any practical usage, but it's cool to see things change. I may add more themes whenever
          I feel like it. Enjoy the selection.
        `));
        box_holder_div.appendChild(header);
        box_holder_div.appendChild(paragraph);
        box_holder_div.appendChild(document.createElement("br"));

        let selector = document.createElement("select");
        selector.id="theme-selection-selector";

        for (const theme of avaliable_themes) {
            let option = document.createElement("option");
            option.setAttribute("value", theme);
            if (theme === current_theme) {
                option.setAttribute("selected", "true");
            }
            option.appendChild(document.createTextNode(theme));
            selector.appendChild(option);
        }

        selector.addEventListener('change',
                                  function(event) {
                                      switch_to_theme(event.target.value);
                                  });

        box_holder_div.appendChild(selector);

        let button = document.createElement("button");
        button.appendChild(document.createTextNode("Close Selector"));
        button.id = "theme-selection-close-button";
        button.addEventListener("click",
                                function() {
                                    close_theme_selector();
                                });
        box_holder_div.appendChild(button);
    }

    return holder_div;
}();
function open_theme_selector() {
    document.body.appendChild(theme_selector);
    theme_selector_visible = true;
}
function close_theme_selector() {
    document.body.removeChild(theme_selector);
    theme_selector_visible = false;
}

document.addEventListener("keydown",
                          function(event) {
                              if (event.key == 'o' && event.ctrlKey) {
                                  if (theme_selector_visible) {
                                      close_theme_selector();
                                  } else {
                                      open_theme_selector();
                                  }
                                  event.preventDefault();
                              }
                          }
                         );

var _link_to_themeselector_open = document.createElement("a");
_link_to_themeselector_open.setAttribute("href", "#");
_link_to_themeselector_open.appendChild(document.createTextNode("*theme-selector*"));
_link_to_themeselector_open.addEventListener('click',
                                             function (event) {
                                                 open_theme_selector();
                                             });
document.getElementById("mini-buffer-links").appendChild(_link_to_themeselector_open);
