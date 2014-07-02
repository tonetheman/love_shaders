
local time

function love.load()
	time = 0
    myShader = love.graphics.newShader[[

mat3 rotm;

mat3 rot(vec3 v, float angle)
{
	float c = cos(angle);
	float s = sin(angle);
	
	return mat3(c + (1.0 - c) * v.x * v.x, (1.0 - c) * v.x * v.y - s * v.z, (1.0 - c) * v.x * v.z + s * v.y,
		(1.0 - c) * v.x * v.y + s * v.z, c + (1.0 - c) * v.y * v.y, (1.0 - c) * v.y * v.z - s * v.x,
		(1.0 - c) * v.x * v.z - s * v.y, (1.0 - c) * v.y * v.z + s * v.x, c + (1.0 - c) * v.z * v.z
		);
}


vec2 dragonkifs(vec3 p) {
	float otrap=1000.;
	float l=0.;
	for (int i=0; i<20; i++) {
		p.y*=-sign(p.x);
		p.x=abs(p.x);
		p=p*rotm*1.18-vec3(1.2);
		l=length(p);
		if (l>100.) otrap=0.;
		otrap=min(otrap,l);		
	}
	return vec2(l*pow(1.18,float(-20))*.15,clamp(otrap*.3,0.,1.));
}

extern number itime;

vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){
	float time = itime*.5;
	vec2 coord = screen_coords.xy / love_ScreenSize.xy *2. - vec2(1.);
	coord.y *= love_ScreenSize.y / love_ScreenSize.x;
	vec3 from = 16.*normalize(vec3(sin(time),cos(time),.5+sin(time)));
	vec3 up=vec3(1,sin(time*2.)*.5,1);
    vec3 edir = normalize(-from);
    vec3 udir = normalize(up-dot(edir,up)*edir);
    vec3 rdir = normalize(cross(edir,udir));
	vec3 dir=normalize((coord.x*rdir+coord.y*udir)*.9+edir);
	vec3 col=vec3(0.);
	float dist=0.;
	rotm=rot(normalize(vec3(1.)),time*3.);
	for (int r=0; r<120; r++) {
		vec3 p=from+dist*dir;
		vec2 d=dragonkifs(p);
		dist+=max(0.02,abs(d.x));
		if (dist>20.) break;
		col+=vec3(1.+d.y*1.8,.5+d.y,d.y*.5)*.125*sign(d.y);
	}
	col=col*length(col)*0.001;
	return  vec4(col,1.0);	
	
}

    ]]
end
 
 function love.update(dt)
	time = time + dt;
	-- local factor = math.abs(math.cos(time)); --so it keeps going/repeating
	myShader:send("itime",time)
end

function love.draw()
    love.graphics.setShader(myShader)

	love.graphics.rectangle("fill", 0, 0, 800, 600 )
	 
    love.graphics.setShader()
end