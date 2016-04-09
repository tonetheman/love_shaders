

local shader = nil
local time

function love.load()
	time = 0
	print("before shader")

	shader = love.graphics.newShader[[
extern number time;
#define PI 3.14159265359

mat2 rotate2d(float _angle){
    return mat2(cos(_angle),-sin(_angle),
                sin(_angle),cos(_angle));
}

float box(in vec2 _st, in vec2 _size){
    _size = vec2(0.5) - _size*0.5;
    vec2 uv = smoothstep(_size,
                        _size+vec2(0.001),
                        _st);
    uv *= smoothstep(_size,
                    _size+vec2(0.001),
                    vec2(1.0)-_st);
    return uv.x*uv.y;
}

float cross(in vec2 _st, float _size){
    return  box(_st, vec2(_size,_size/4.)) + 
            box(_st, vec2(_size/4.,_size));
}

vec4 effect( vec4 color, Image texture, 
	vec2 texture_coords, vec2 screen_coords ){
 
    vec2 st = gl_FragCoord.xy/love_ScreenSize.xy;
    vec3 color2 = vec3(0.0);
    
    // move space from the center to the vec2(0.0)
    st -= vec2(0.5);
    // rotate the space
    st = rotate2d( sin(time)*PI ) * st;
    // move it back to the original place
    st += vec2(0.5);

    // Show the coordinates of the space on the background
    color2 = vec3(st.x,st.y,0.0);

    // Add the shape on the foreground
    color2 += vec3(cross(st,0.4));

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
