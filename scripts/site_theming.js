// It was either this or populate the html file itself.
// Might as well generate it after it's loaded.
const avaliable_themes = ['default', 'light', 'plan9', 'borlandblue'];

let current_theme = function() {
    let theme = localStorage.getItem('theme');
    // I wish I was joking
    if (theme === null || theme === undefined || theme === "" || theme === "null") {
        return "plan9";
    }

  // local storage appears to persist forever,
  // and plan9 appears to be the most readable version to me.
  return "plan9";
  /* return theme; */
}();

function stylesheet_link(path) {
    let stylesheet_link = document.createElement('link');
    stylesheet_link.type = "text/css";
    stylesheet_link.rel = "stylesheet";
    stylesheet_link.href = path;
    return stylesheet_link;
}
for (const prefix of ["styles/", "../styles/", "../../styles/", "../../../styles/"]) {
    document.head.appendChild(stylesheet_link(`${prefix}base.css`));
}

function update_theme() {
    // to avoid so much work, I'm literally going to link as many paths as I can
    // find for all the themes...
    // TODO(jerry): does this work with a more direct URL?
    console.log("updating theme");
    let relative_path_prefixes = ["styles/", "../styles/", "../../styles/", "../../../styles/"];
    for (const prefix of relative_path_prefixes) {
        document.head.appendChild(stylesheet_link(`${prefix}${current_theme}.css`));
    }
}
function switch_to_theme(new_theme) {
    current_theme = new_theme;
    localStorage.setItem('theme', new_theme);

    update_theme();
}

update_theme();
