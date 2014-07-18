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

extern number iGlobalTime;

float noise( vec2 p )
{
	return texture2D(iChannel0,p).x; 
}

float fnoise(vec2 uv, vec4 sc) {
	float f  = sc.x*noise( uv ); uv = 2.*uv+.11532185;
		  f += sc.y*noise( uv ); uv = 2.*uv+.23548563;
		  f += sc.z*noise( uv ); uv = 2.*uv+.12589452;
		  f += sc.w*noise( uv ); uv = 2.*uv+.26489542;
	return f;
}


float terrain(float x) {
	float w=0.;
	float a=1.;
	x*=20.;
	w+=sin(x*.3521)*4.;
	for (int i=0; i<5; i++) {
		x*=1.53562;
		x+=7.56248;
		w+=sin(x)*a;		
		a*=.5;
	}
	return .2+w*.015;	
}

float bird(vec2 p) {
	p.x+=iGlobalTime*.05;
	float t=iGlobalTime*.05+noise(vec2(floor(p.x/.4-.2)*.7213548))*.7;
	p.x=mod(p.x,.4)-.2;
	p*=2.-mod(t,1.)*2.;
	p.y+=.6-mod(t,1.);
	p.y+=pow(abs(p.x),2.)*20.*(.2+sin(iGlobalTime*20.));
	float s=step(0.003-abs(p.x)*.1,abs(p.y));	
	return min(s,step(0.005,length(p+vec2(0.,.0015))));
}

float tree(vec2 p, float tx) {
	float noisev=noise(p.xx*.1+.552121)*.25;
	p.x=mod(p.x,.2)-.1;
	p*=15.+noise(vec2(tx*1.72561))*10.;
	float ot=1000.;
	float a=radians(-60.+noise(vec2(tx))*30.);
	for (int i=0; i<7; i++) {
		ot=min(ot,length(max(vec2(0.),abs(p)-vec2(-a*.15,.9))));
		float s=(sign(p.x)+1.)*.25;
		p.x=abs(p.x);
		p=p*1.3-vec2(0.,1.+noisev);		
		a*=.8;
		a-=(noise(vec2(float(i+2)*.55170275+tx,s))-.5)*.2;
		mat2 rot=mat2(cos(a),sin(a),-sin(a),cos(a));
		p*=rot;
	}
	return step(0.05,ot);
}


float scene(vec2 p) {
	float t=terrain(p.x);
	float s=step(0.,p.y+t);
	float tx=floor(p.x/.2)*.2+.1;
	if (noise(vec2(tx*3.75489))>.55) s=min(s,tree(p+vec2(0.,terrain(tx)),.42+tx*4.5798523));
	s=min(s,bird(p));
	return s;
}

float aascene(vec2 p) {
	vec2 pix=vec2(0.,max(.25,6.-iGlobalTime)/love_ScreenSize.x);
	float aa=scene(p);
	aa+=scene(p+pix.xy);
	aa+=scene(p+pix.yy);
	aa+=scene(p+pix.yx);
	return aa*.25;	
}

vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords )
{
	vec2 uv = screen_coords.xy / love_ScreenSize.xy-.5;
	uv.x*=love_ScreenSize.x/love_ScreenSize.y;
	float v=0., l;
	float t=iGlobalTime*.05;
	vec2 c=vec2(-t,0.);
	vec2 p;
	float sc=clamp(t*t*.5,.05,.15);
	uv.y-=.25;
	uv.x-=.2;
	for (int i=0; i<50; i++) {
		p=uv*sc;
		l=pow(max(0.,1.-length(p)*2.),15.);
		l=.02+l*.8;
		v+=scene(p+c)*pow(float(i+1)/30.,2.)*l;			
		sc+=.006;
	}
	float clo=fnoise((uv-vec2(t,0.))*vec2(.03,.15),vec4(.8,.6,.3,.1))*max(0.,1.-uv.y*3.);
	float tx=uv.x-t*.5;
	float ter=.5+step(0.,uv.y-fnoise(vec2(tx)*.015,
			  vec4(1.,.5,.3,.1))*(.23*(1.+sin(tx*3.2342)*.25))+.5);
	float s=aascene(p+c)*(ter+clo*.4);
	v*=.025;
	float col=min(1.,.05+v+s*l);
	col=sqrt(col)*2.-.5;
	//gl_FragColor = vec4(col*min(1.,iGlobalTime*.2));
	return vec4(col*min(1.,iGlobalTime*.2));
}



	]])
end