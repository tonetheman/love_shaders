

local myShader = nil
local myTime = 0

function love.update(dt)
	myTime = myTime + dt;
	myShader:send("t",myTime)
	-- myShader:send("mouse", { love.mouse.getX() , love.mouse.getY() } )
end

function love.draw()
	love.graphics.setShader(myShader)
	love.graphics.rectangle("fill", 0, 0, 800, 600 )
	love.graphics.setShader()
end

function love.load()
	myShader = love.graphics.newShader([[

extern number t;
extern vec2 mouse;
	
#define MAX_RAY_STEPS 75
#define PI 3.14159265

// #define t iGlobalTime*2.0

float ball_angle = t/3.0;

vec3 forward = vec3(0.0,-cos(ball_angle),sin(ball_angle));
vec3 side    = normalize(cross(forward, vec3(1.0, 0.0, 0.0)));
vec3 up      = normalize(cross(forward, side));

mat3 rot = mat3(forward,side,up);

vec2 polarRepeat(vec2 p, float r) {
    float a = mod( atan(p.y,p.x), r) - r*0.5;
    return vec2(cos(a),sin(a)) * length(p.xy);
}

float ball(vec3 p, vec2 sides, float size, out vec3 c) {
	
	mat3 r = rot;
	
	p = r * p;
	
	p.xz = polarRepeat(p.xz, PI/sides.x);
	p.xy = polarRepeat(p.xy, PI/sides.y);

	float checkers = max(0.0,step(p.y*p.z, 0.0));
	
	c = vec3(1.0, vec2(checkers)) * 2.0;
	
	return dot(p,vec3(1.0,0.0,0.0))-size;
}

float fourth_wall = 0.0;

vec4 scene(vec3 p) {
	
	vec3 c;
	
	float width =12.0;
	
	float x = width*abs(fract(t/10.0)-0.5) - width*0.25;
	float z = width*abs(fract((-t+2.)/10.0)-0.5) - width*0.25 + 0.2;
		
	float t2 = max(t*4.0 - 15.0,0.0);
	
	float bounce = 1.0 + max(15.0-t*4.0,0.0) + 0.35*log(1.0+abs(10.0*sin(t2*0.33)));
	
	vec3 pos = p - vec3(x, bounce, z);
	
	float b = ball(pos, vec2(8.0,8.0), 2.0, c);

	float g = dot(p,vec3(0.0,1.0,0.0)) + 1.0;

	if(fourth_wall > 0.0) p.z = abs(p.z);
	
	float w1 = dot(p,vec3(0.0,0.0,-1.0)) + 5.0;
	float w2 = dot(vec3(abs(p.x),p.yz),vec3(-1.0,0.0,0.0)) + 5.0;	
	
	vec3 wallc = vec3(0.67) + normalize(p)*0.05;

	vec4 d = g<b ? vec4(g,wallc) : vec4(b,c);
	
	d = w1<d.x ? vec4(w1,wallc) : d;
	d = w2<d.x ? vec4(w2,wallc) : d;
	
	return d;
}

vec3 normal(vec3 p) {

    vec2 o = vec2(0.00001,0.0);

	float d = scene(p).x;
	
    float d1 = d-scene(p+o.xyy).x;
    float d2 = d-scene(p+o.yxy).x;
    float d3 = d-scene(p+o.yyx).x;

    return normalize(vec3(d1,d2,d3));
}

float AO(vec3 p, vec3 normal) {

    float a = 1.1;

	float c = 0.0;
    float s = 0.25;

    for(int i=0; i<4; i++) {
	    c += s;
        a *= 1.0-max(0.0, (c -scene(p + normal*c).x) * s / c);
    }
	
    return clamp(a,0.0,1.0);
}

vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){

    vec2 uv = (screen_coords.xy / love_ScreenSize.xy) * 2.0 - 1.0;
	
    vec3 dir = normalize(vec3(uv.x, uv.y * (love_ScreenSize.y/love_ScreenSize.x), 1.0));	
	
    vec3 cam = vec3(0.0,1.8,-10.0);

	vec3 p = cam;

	vec4 d;
	
	fourth_wall  = 0.0;
	
    for(int i=0; i<MAX_RAY_STEPS; i++) {
		d = scene(p);
        p += d.x * dir;
    }
	
	fourth_wall = 1.0;
	
    vec3 n = -normal(p-dir*0.00001);

    vec3 l = vec3(0.0,7,-4.0);

	vec3 diffuse = d.yzw;
		
	float ao = AO(p, 0.5*(n+normalize(n+l)));
	
	vec3 c = diffuse * ao;
	
	c += max(0.0, pow(dot(n, normalize(l-p)),1.5));
	
	c -= c * length(cam-p)*0.055;
		
    //gl_FragColor = vec4(c,1.0);
	return vec4(c,1.0);
}
	]])
end