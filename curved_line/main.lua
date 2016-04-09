local shader = nil
local time

function love.load()
	time = 0
	print("before shader")

	shader = love.graphics.newShader[[

float plot(vec2 st, float pct){
  return  smoothstep( pct-0.02, pct, st.y) - 
          smoothstep( pct, pct+0.02, st.y);
}

vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){

	vec2 st = gl_FragCoord.xy/love_ScreenSize.xy;

    float y = pow(st.x,5.0);

    vec3 color2 = vec3(y);

    float pct = plot(st,y);
    color2 = (1.0-pct)*color2+pct*vec3(0.0,1.0,0.0);
    
    return vec4(color2,1.0);
}
	]]

	print("finished setting shader")
end

function love.draw()

    love.graphics.setShader(shader)

	love.graphics.rectangle("fill", 0, 0, 800, 600 )
	 
    love.graphics.setShader()

end

