

local shader = nil
local time

function love.load()
	time = 0
	print("before shader")

	shader = love.graphics.newShader[[
extern number time;
vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){
	return vec4(abs(sin(time)),abs(cos(time)),abs(tan(time)),1.0);
}
	]]

	print("finished setting shader")
end

function love.update(dt)
	time = time + dt
	shader:send("time",time)
end

function love.draw()

    love.graphics.setShader(shader)

	love.graphics.rectangle("fill", 0, 0, 400, 400 )
	 
    love.graphics.setShader()

end
