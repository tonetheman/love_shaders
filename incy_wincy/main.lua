

-- sites to look at
-- https://www.shadertoy.com/view/4dfGDM
-- https://github.com/shiffman/The-Nature-of-Code-Cosmos-Edition/blob/master/stars/StarNestShaderDome/data/stars.glsl
-- http://glsl.heroku.com/

local myShader = nil
local time

function love.load()
	time = 0
    myShader = love.graphics.newShader[[

extern number iTime;

const float rootTwo = 1.4142135623;

// Create a grid.
const float gridSize = 20.;

// To draw a line we basically figure out how far away we are from the projection of our current
// point to the line, and then depending on our desired line thickness we can draw.
float L(vec2 p, vec2 a,vec2 b) {               
    vec2 pa = p-a;
    vec2 ba = b-a;
    // Normalised projection clamped between zero and one.
    float proj = clamp(dot(pa,ba)/dot(ba,ba), 0., 1. );
    // Distance from point and line.
    return length(pa - ba*proj);
}

vec3 spider(vec2 C, vec2 grid, vec2 gv) {
    vec3 col = vec3(0.);
    
    // Grid points near the spider.
    if (distance(grid, C*gridSize) <= 1.9*rootTwo) {
        // TC changed for lua
        //col += smoothstep(3.*gridSize/iResolution.y, 0., length(gv));
        col += smoothstep(3.*gridSize/love_ScreenSize.y, 0., length(gv));
    }
    // Spider legs.
    // Totally redundant but I wanted to see how to smoothstep between arbitrary different colours.
    vec3 legCol = vec3(1.);
    vec2 anchor = floor(C*gridSize), offset;
    float d, line;
    for (int y=-2; y<=2; y++) {
        for (int x=-2; x<=2; x++) {
            offset = vec2(x, y);
            d = distance(anchor+offset, C*gridSize);
            if (d >= 1. && d <= 2.) {
                line = L(grid, anchor+offset, C*gridSize);
                // TC changed for lua
                //col += mix(vec3(0.), legCol, smoothstep(1.4*gridSize/iResolution.y, 0., line));
                col += mix(vec3(0.), legCol, smoothstep(1.4*gridSize/love_ScreenSize.y, 0., line));
            }
        }
    }
    return col;
}


vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){

    // Centre of the screen is (0,0).
    //vec2 uv = (fragCoord - .5*iResolution.xy) / iResolution.y;
    // TC: added for lua
    vec2 uv = screen_coords.xy/love_ScreenSize.xy-.5;
    vec3 col = vec3(0.);
    
    vec2 grid = uv*gridSize;
    // Coordinates inside each grid square.
    vec2 gv = fract(grid);
    
    // Centre of moving spider.
    vec2 C = .3*cos(.5*iTime+vec2(3,2)) + .15*sin(1.4*iTime+vec2(1,0));
    col += spider(C, grid, gv);
    // His friend (or maybe his enemy). 
    C = .3*sin(.5*iTime+vec2(3,2)) + .15*cos(1.4*iTime+vec2(1,0));
    col += spider(C, grid, gv);

    // TC changed for lua
    // fragColor = vec4(col,1.0);
    return vec4(col,1.0);
}
    ]]
end
 
 function love.update(dt)
	time = time + dt;
	myShader:send("iTime",time)
end

function love.draw()
    love.graphics.setShader(myShader)

	love.graphics.rectangle("fill", 0, 0, 800, 600 )
	 
    love.graphics.setShader()
end