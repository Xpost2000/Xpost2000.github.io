// It was either this or populate the html file itself.
// Might as well generate it after it's loaded.

// I'm sure there's a better way, but I can always fix this later.
function paste_lots_of_tildes(event) {
    let gutter = document.getElementById("ugly-ass-gutter");

    // I'm not expecting anyone with less than like a 4K monitor to hit the limit.
    // I'd like to seriously know how to approach this since this was the fastest thing I can think of.
    // I guess I can check against the actual screen height and add for the maximum size?
    for (let tilde_index = 0; tilde_index < 3250; ++tilde_index) {
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
mini_buffer_autocompletion.addEventListener("click", function(event) { mini_buffer_autocompletion.style.display = "none"; });
mini_buffer_autocompletion.addEventListener("mouseout", function(event) { mini_buffer_autocompletion.style.display = "none"; });
