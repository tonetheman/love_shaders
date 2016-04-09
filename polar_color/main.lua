

local shader = nil
local time

function love.load()
	time = 0
	print("before shader")

	shader = love.graphics.newShader[[
extern number time;
#define TWO_PI 6.28318530718

vec3 hsb2rgb( in vec3 c ){
    vec3 rgb = clamp(abs(mod(c.x*6.0+vec3(0.0,4.0,2.0),
                             6.0)-3.0)-1.0, 
                     0.0, 
                     1.0 );
    rgb = rgb*rgb*(3.0-2.0*rgb);
    return c.z * mix( vec3(1.0), rgb, c.y);
}

vec4 effect( vec4 color, Image texture, 
	vec2 texture_coords, vec2 screen_coords ){

	vec2 st = gl_FragCoord.xy/love_ScreenSize.xy;
    vec3 color2 = vec3(0.0);

    // Use polar coordinates instead of cartesian
    vec2 toCenter = vec2(0.5)-st;
    float angle = atan(toCenter.y,toCenter.x);
    float radius = length(toCenter)*2.0;
  
    // Map the angle (-PI to PI) to the Hue (from 0 to 1)
    // and the Saturation to the radius
    color2 = hsb2rgb(vec3(sin(time) * (angle/TWO_PI)+0.5,radius,1.0));

    return vec4(color2,1.0);

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

	love.graphics.rectangle("fill", 0, 0, 800, 600 )
	 
    love.graphics.setShader()

end
