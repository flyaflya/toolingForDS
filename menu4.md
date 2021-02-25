@def title = "Pluto Prototype"
@def hascode = true
@def rss = "A short description of the page which would serve as **blurb** in a `RSS` feed; you can use basic markdown here but the whole description string must be a single line (not a multiline string). Like this one for instance. Keep in mind that styling is minimal in RSS so for instance don't expect maths or fancy styling to work; images should be ok though: ![](https://upload.wikimedia.org/wikipedia/en/b/b0/Rick_and_Morty_characters.jpg)"
@def rss_title = "Pluto Prototype"
@def rss_pubdate = Date(2019, 5, 1)
@def tags = ["syntax", "code", "image"]

# Pluto Prototype

\toc

The above is an h1.

The below is h2.

## Code from the HTML file

~~~
<!DOCTYPE html>
            <html lang="en">
            <head>
                <meta name="viewport" content="width=device-width" />
                <title>⚡ Pluto.jl ⚡</title>
                <meta charset="utf-8" />

                <link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/fonsp/Pluto.jl@0.12.21/frontend/treeview.css" type="text/css" />
                <link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/fonsp/Pluto.jl@0.12.21/frontend/hide-ui.css" type="text/css" />
                <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/codemirror@5.58.1/lib/codemirror.min.css" type="text/css" />
                <link rel="stylesheet" href="/libs/highlight/github.min.css"\>
                <style id="MJX-SVG-styles">
mjx-container[jax="SVG"] {
  direction: ltr;
}

mjx-container[jax="SVG"] > svg {
  overflow: visible;
}

mjx-container[jax="SVG"] > svg a {
  fill: blue;
  stroke: blue;
}

mjx-assistive-mml {
  position: absolute !important;
  top: 0px;
  left: 0px;
  clip: rect(1px, 1px, 1px, 1px);
  padding: 1px 0px 0px 0px !important;
  border: 0px !important;
  display: block !important;
  width: auto !important;
  overflow: hidden !important;
  -webkit-touch-callout: none;
  -webkit-user-select: none;
  -khtml-user-select: none;
  -moz-user-select: none;
  -ms-user-select: none;
  user-select: none;
}

mjx-assistive-mml[display="block"] {
  width: 100% !important;
}

mjx-container[jax="SVG"][display="true"] {
  display: block;
  text-align: center;
  margin: 1em 0;
}

mjx-container[jax="SVG"][display="true"][width="full"] {
  display: flex;
}

mjx-container[jax="SVG"][justify="left"] {
  text-align: left;
}

mjx-container[jax="SVG"][justify="right"] {
  text-align: right;
}

g[data-mml-node="merror"] > g {
  fill: red;
  stroke: red;
}

g[data-mml-node="merror"] > rect[data-background] {
  fill: yellow;
  stroke: none;
}

g[data-mml-node="mtable"] > line[data-line] {
  stroke-width: 70px;
  fill: none;
}

g[data-mml-node="mtable"] > rect[data-frame] {
  stroke-width: 70px;
  fill: none;
}

g[data-mml-node="mtable"] > .mjx-dashed {
  stroke-dasharray: 140;
}

g[data-mml-node="mtable"] > .mjx-dotted {
  stroke-linecap: round;
  stroke-dasharray: 0,140;
}

g[data-mml-node="mtable"] > g > svg {
  overflow: visible;
}

[jax="SVG"] mjx-tool {
  display: inline-block;
  position: relative;
  width: 0;
  height: 0;
}

[jax="SVG"] mjx-tool > mjx-tip {
  position: absolute;
  top: 0;
  left: 0;
}

mjx-tool > mjx-tip {
  display: inline-block;
  padding: .2em;
  border: 1px solid #888;
  font-size: 70%;
  background-color: #F8F8F8;
  color: black;
  box-shadow: 2px 2px 5px #AAAAAA;
}

g[data-mml-node="maction"][data-toggle] {
  cursor: pointer;
}

mjx-status {
  display: block;
  position: fixed;
  left: 1em;
  bottom: 1em;
  min-width: 25%;
  padding: .2em .4em;
  border: 1px solid #888;
  font-size: 90%;
  background-color: #F8F8F8;
  color: black;
}

foreignObject[data-mjx-xml] {
  font-family: initial;
  line-height: normal;
  overflow: visible;
}

.MathJax path {
  stroke-width: 3;
}
</style>
            </head>
            <body>
                <main><preamble><button class="runallchanged" title="Save and run all changed cells"><span></span></button></preamble><pluto-notebook id="7c5ff370-76c5-11eb-2d51-0bc559b43e4e"><pluto-cell class="code_folded " id="b673ef20-7540-11eb-20c8-2bca83428010"><pluto-shoulder draggable="true" title="Drag to move cell"><button class="foldcode" title="Show/hide code"><span></span></button></pluto-shoulder><pluto-trafficlight></pluto-trafficlight><button class="add_cell before" title="Add cell"><span></span></button><pluto-output class="rich_output " mime="text/html"><assignee></assignee><div><div class="markdown"><h2>This is a heading for testing deploying Pluto</h2>
<p>Can I then write text and continue.  I wodner</p>
</div></div></pluto-output><pluto-runarea><button class="runcell" title="Run"><span></span></button><span class="runtime">24.8&nbsp;μs</span></pluto-runarea><button class="add_cell after" title="Add cell"><span></span></button></pluto-cell></pluto-notebook><dropruler></dropruler></main>
                <svg id="MJX-SVG-global-cache" style="display: none;"><defs></defs></svg>
            </body>
            </html>
        
~~~
