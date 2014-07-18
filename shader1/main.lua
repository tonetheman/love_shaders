 -- shader1
 
local myShader = nil
local myTime = 0

function love.update(dt)
	myTime = myTime + dt;
	myShader:send("time",myTime)
	myShader:send("mouse", { love.mouse.getX() , love.mouse.getY() } )
end

 function love.load()
	myShader = love.graphics.newShader([[ 
	extern number time;
	extern vec2 mouse;
	
	vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){
		vec2 pos = ( screen_coords.xy / love_ScreenSize.xy ) * 26.0 - 13.0;
		float x = sin(time + length(pos.xy)) + cos((mouse.x * 10.0) + pos.x);
		float y = cos(time + length(pos.xy)) + sin((mouse.y * 10.0)+ pos.y);
		return vec4( x * 0.5, y * 0.5, x * y, 1.0 );
	}
	
	]])
 end
 
 function love.draw()
    love.graphics.setShader(myShader)

	love.graphics.rectangle("fill", 0, 0, 800, 600 )
	 
    love.graphics.setShader()
end