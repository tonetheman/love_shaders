

-- sites to look at
-- https://www.shadertoy.com/view/4dfGDM
-- https://github.com/shiffman/The-Nature-of-Code-Cosmos-Edition/blob/master/stars/StarNestShaderDome/data/stars.glsl
-- http://glsl.heroku.com/

local myShader = nil
local time

function love.load()
	time = 0
    myShader = love.graphics.newShader[[

extern number time;

	vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){
		

// Star Nest by Pablo Román Andrioli
// Modified a lot.

// This content is under the MIT License.

#define iterations 15
#define formuparam 0.530

#define volsteps 10
#define stepsize 0.120

#define zoom   1.900
#define tile   0.850
#define speed  0.0

#define brightness 0.0015
#define darkmatter 0.400
#define distfading 0.760
#define saturation 0.0010		
		
			// changed these two lines for lua
			vec2 uv=screen_coords.xy/love_ScreenSize.xy-.5;
			uv.y*=love_ScreenSize.y/love_ScreenSize.x;
			
			
			vec3 dir=vec3(uv*zoom,1.);
	
			float a2=time*speed+.5;
			float a1=0.0;
			mat2 rot1=mat2(cos(a1),sin(a1),-sin(a1),cos(a1));
			mat2 rot2=rot1;//mat2(cos(a2),sin(a2),-sin(a2),cos(a2));
			dir.xz*=rot1;
			dir.xy*=rot2;
			
			//from.x-=time;
			//mouse movement
			vec3 from=vec3(0.,0.,0.);
			from+=vec3(.05*time,.05*time,-2.);			
	from.xz*=rot1;
	from.xy*=rot2;
	
	//volumetric rendering
	float s=.1,fade=.2;
	vec3 v=vec3(0.4);
	for (int r=0; r<volsteps; r++) {
		vec3 p=from+s*dir*.5;
		p = abs(vec3(tile)-mod(p,vec3(tile*2.))); // tiling fold
		float pa,a=pa=0.;
		for (int i=0; i<iterations; i++) { 
			p=abs(p)/dot(p,p)-formuparam; // the magic formula
			a+=abs(length(p)-pa); // absolute sum of average change
			pa=length(p);
		}
		float dm=max(0.,darkmatter-a*a*.001); //dark matter
		a*=a*a*2.; // add contrast
		if (r>3) fade*=1.-dm; // dark matter, don't render near
		//v+=vec3(dm,dm*.5,0.);
		v+=fade;
		v+=vec3(s,s*s,s*s*s*s)*a*brightness*fade; // coloring based on distance
		fade*=distfading; // distance fading
		s+=stepsize;
	}
	v=mix(vec3(length(v)),v,saturation); //color adjust
	return vec4(v*.01,1.);



			}
    ]]
end
 
 function love.update(dt)
	time = time + dt;
	myShader:send("time",time)
end

function love.draw()
    love.graphics.setShader(myShader)

	love.graphics.rectangle("fill", 0, 0, 800, 600 )
	 
    love.graphics.setShader()
end