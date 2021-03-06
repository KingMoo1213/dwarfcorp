
#define MAX_LIGHTS 16
#define LIGHT_COLOR float4(0, 0, 1, 0)

float3 xLightPositions[MAX_LIGHTS];


//------- Constants --------
float4x4 xView;
float4x4 xLightView;
float4x4 xLightProj;
float4x4 xReflectionView;

float xWaterOpacity;
float xWaterSloshOpacity;

float xWaterMinOpacity;

float4x4 xProjection;
float4x4 xWorld;
int xEnableLighting;

Texture xWaterBumpMap;

float xWaveLength;
float xWaveHeight;

float3 xCamPos;

float xTime;
float xWindForce;
float3 xWindDirection;
float xTimeOfDay;
int xEnableFog;

float xFogStart;
float xFogEnd;
float3 xFogColor;
float4 xRippleColor;
float4 xFlatColor;

//------- Technique: Clipping Plane Fix --------

int Clipping;
int GhostMode;
int SelfIllumination;
float4 ClipPlane0;

float4 GetNoise(float4 pos)
{
	float mag = dot(pos, pos);
	return float4(cos(mag * 1e-5) * 0.2, sin(mag * 1e-4) * 0.5, sin(-mag * 1e-5) * 0.2, 0);
}


//------- Technique: Clipping Plane Fix --------


//------- Texture Samplers --------
Texture xTexture;
Texture xIllumination;

sampler IllumSampler = sampler_state { texture = <xIllumination> ;  magfilter = LINEAR; minfilter = LINEAR; mipfilter=LINEAR; AddressU = clamp; AddressV = clamp;};

sampler TextureSampler = sampler_state { texture = <xTexture> ; magfilter = POINT; minfilter = ANISOTROPIC; mipfilter=POINT; AddressU = clamp; AddressV = clamp;};

sampler ColorscaleSampler = sampler_state { texture = <xTexture>; magfilter = POINT; minfilter = POINT; mipfilter = POINT; AddressU = clamp; AddressV = clamp; };
Texture xTexture0;

Texture xTexture1;
sampler TextureSampler1 = sampler_state { texture = <xTexture1> ; magfilter = POINT; minfilter = POINT; mipfilter=POINT; AddressU = clamp; AddressV = clamp;};

Texture xTexture2;
sampler TextureSampler2 = sampler_state { texture = <xTexture2> ; magfilter = POINT; minfilter = POINT; mipfilter=POINT; AddressU = clamp; AddressV = clamp;};

Texture xTexture3;
sampler TextureSampler3 = sampler_state { texture = <xTexture3> ; magfilter = POINT; minfilter = POINT; mipfilter=POINT; AddressU = clamp; AddressV = clamp;};

sampler WrappedTextureSampler = sampler_state { texture = <xTexture> ; magfilter = POINT; minfilter = POINT; mipfilter=POINT; AddressU = wrap; AddressV = wrap;};

sampler WrappedTextureSampler1 = sampler_state { texture = <xTexture1> ; magfilter = POINT; minfilter = POINT; mipfilter=POINT; AddressU = wrap; AddressV = wrap;};

Texture xReflectionMap;

Texture xSunGradient;
Texture xAmbientGradient;
Texture xTorchGradient;
Texture xRefractionMap;
float4 xTint;

sampler SunSampler = sampler_state { texture = <xSunGradient>; magfilter = POINT; minfilter = POINT; mipfilter = POINT; AddressU = clamp; AddressV = clamp; };

sampler AmbientSampler = sampler_state { texture = <xAmbientGradient>; magfilter = POINT; minfilter = POINT; mipfilter = POINT; AddressU = clamp; AddressV = clamp; };

sampler TorchSampler = sampler_state { texture = <xTorchGradient>; magfilter = POINT; minfilter = POINT; mipfilter = POINT; AddressU = clamp; AddressV = clamp; };

sampler ReflectionSampler = sampler_state { texture = <xReflectionMap> ; magfilter = LINEAR; minfilter = LINEAR; mipfilter=LINEAR; AddressU = clamp; AddressV = clamp;};

sampler RefractionSampler = sampler_state { texture = <xRefractionMap> ; magfilter = LINEAR; minfilter = LINEAR; mipfilter=LINEAR; AddressU = clamp; AddressV = clamp;};

sampler WaterBumpMapSampler = sampler_state { texture = <xWaterBumpMap> ; magfilter = LINEAR; minfilter = LINEAR; mipfilter=LINEAR; AddressU = wrap; AddressV = wrap;};

Texture xShadowMap;
sampler ShadowMapSampler = sampler_state { texture = <xShadowMap>; magfilter = POINT; minfilter = POINT; mipfilter = POINT; AddressU = clamp; AddressV = clamp; };

///////////// Technique untextured
	struct UTVertexToPixel
	{
	float4 Position     : POSITION;
	float4 Color        : COLOR0;
	float4 clipDistances     : TEXCOORD5;
	};

	struct UTPixelToFrame
	{
	float4 Color : COLOR0;
	};

	UTVertexToPixel UTexturedVS( float4 inPos_ : POSITION,  float4 inColor : COLOR0)
	{
		UTVertexToPixel Output = (UTVertexToPixel)0;
		float4 inPos = inPos_ + GetNoise(inPos_);
		float4x4 preViewProjection = mul (xView, xProjection);
		float4x4 preWorldViewProjection = mul (xWorld, preViewProjection);

		Output.Position = mul(inPos, preWorldViewProjection);
		Output.Color = inColor * xTint;


		if(Clipping)
		Output.clipDistances = dot(mul(xWorld,inPos), ClipPlane0); //MSS - Water Refactor added

		return Output;
	}

	UTPixelToFrame UTexturedPS(UTVertexToPixel PSIn)
	{
		UTPixelToFrame Output = (UTPixelToFrame)0;

		Output.Color = PSIn.Color;

	    clip(PSIn.clipDistances);  //MSS - Water Refactor added


		return Output;
	}

	technique Untextured_2_0
	{
		pass Pass0
		{
			VertexShader = compile vs_2_0 UTexturedVS();
			PixelShader = compile ps_2_0 UTexturedPS();
		}
	}

	technique Untextured
	{
		pass Pass0
		{   
			VertexShader = compile vs_2_0 UTexturedVS();
			PixelShader  = compile ps_2_0 UTexturedPS();
		}
	}




///////////////

// Shadowmaps
struct SMapVertexToPixel
{
	float4 Position     : POSITION;
	float4 Position2D    : TEXCOORD0;
	float2 TextureCoords : TEXCOORD1;
};

struct SMapPixelToFrame
{
	float4 Color : COLOR0;
};


SMapVertexToPixel ShadowMapVS(float4 inPos : POSITION, float2 inTexCoords : TEXCOORD0, float4x4 world : BLENDWEIGHT)
{
	float4 worldPosition = mul(inPos, world);
	float4 viewPosition = mul(worldPosition, xView);
	SMapVertexToPixel Output = (SMapVertexToPixel)0;
	Output.Position = mul(viewPosition, xProjection);
	Output.Position2D = Output.Position;
	Output.TextureCoords = inTexCoords;
	return Output;
}

SMapPixelToFrame ShadowMapPixelShader(SMapVertexToPixel PSIn)
{
	SMapPixelToFrame Output = (SMapPixelToFrame)0;
	float4 texColor = tex2D(TextureSampler, PSIn.TextureCoords);
	clip((texColor.a - 0.5));
	Output.Color = 1.0f - PSIn.Position2D.z / PSIn.Position2D.w;
	Output.Color.a = 1.0f;
	return Output;
}

SMapVertexToPixel ShadowMapVSNonInstance(float4 inPos : POSITION, float2 inTexCoords : TEXCOORD0)
{
	return ShadowMapVS(inPos, inTexCoords, xWorld);
}

SMapVertexToPixel ShadowMapVSInstance(float4 inPos : POSITION, float2 inTexCoords : TEXCOORD0, float4x4 transform : BLENDWEIGHT)
{
	return ShadowMapVS(inPos, inTexCoords, transpose(transform));
}

technique Shadow
{
	pass Pass0
	{
		VertexShader = compile vs_2_0 ShadowMapVSNonInstance();
		PixelShader = compile ps_2_0 ShadowMapPixelShader();
	}
};

technique ShadowInstanced
{
	pass Pass0
	{
		VertexShader = compile vs_2_0 ShadowMapVSInstance();
		PixelShader = compile ps_2_0 ShadowMapPixelShader();
	}
};


//------- Technique: Textured --------
struct TVertexToPixel
{
float4 Position     : POSITION;
float4 Color        : COLOR0;
float LightingFactor: TEXCOORD0;
float2 TextureCoords: TEXCOORD1;
float4 clipDistances     : TEXCOORD5;
float Fog : TEXCOORD7;	
float4 TextureBounds: TEXCOORD6;
float3 ColorTint : COLOR1;
};

struct TPixelToFrame
{
	float4 Color : COLOR0;
};


TVertexToPixel TexturedVS( float4 inPos : POSITION,  float2 inTexCoords: TEXCOORD0, float4 inColor : COLOR0, float4 inTexSource : TEXCOORD1, float4x4 world : BLENDWEIGHT, float4 lightTint : COLOR1, float3 tint)
{
    TVertexToPixel Output = (TVertexToPixel)0;
	float4 worldPosition = mul(inPos, world);
	worldPosition += GetNoise(worldPosition);
    float4 viewPosition = mul(worldPosition, xView);
    Output.Position = mul(viewPosition, xProjection);

    Output.TextureCoords = inTexCoords;
    Output.clipDistances = dot(worldPosition, ClipPlane0);
	Output.Color = inColor * lightTint;
	Output.Color.a = lightTint.a;
	Output.ColorTint = tint;
	if(xEnableLighting)
	{
		for (int i = 0; i < MAX_LIGHTS; i++)
		{
			float dx = worldPosition.x - xLightPositions[i].x;
			float dy = worldPosition.y - xLightPositions[i].y;
			float dz = worldPosition.z - xLightPositions[i].z;
			float dist = pow(dx, 2) + pow(dy, 2) + pow(dz, 2) + 0.001f;
			Output.Color = saturate(Output.Color + LIGHT_COLOR / dist);
		}
	}
	
	if(!xEnableLighting)
	{
		Output.Color = saturate(Output.Color + LIGHT_COLOR / 999.0f);
	}

	if (xEnableFog)
		Output.Fog = saturate((Output.Position.z - xFogStart) / (xFogEnd - xFogStart));
	
	Output.TextureBounds = inTexSource;
    return Output;
}

TVertexToPixel TexturedVSNonInstanced( float4 inPos : POSITION,  float2 inTexCoords: TEXCOORD0, float4 inColor : COLOR0, float4 inTexSource : TEXCOORD1, float3 vertColor : COLOR1)
{
	return TexturedVS(inPos, inTexCoords, inColor, inTexSource, xWorld, xTint, vertColor);
}

TVertexToPixel TexturedVSInstanced( float4 inPos : POSITION,  float2 inTexCoords: TEXCOORD0, float4 inColor : COLOR0, float4 inTexSource : TEXCOORD1, float4 tint : COLOR1, float4x4 transform : BLENDWEIGHT, float3 vertColor : COLOR2)
{
	return TexturedVS(inPos, inTexCoords, inColor, inTexSource, transpose(transform), tint, vertColor);
}


float2 ClampTexture(float2 uv, float4 bounds)
{	
	return float2(clamp(uv.x, bounds.x, bounds.z), clamp(uv.y, bounds.y, bounds.w));
}

TPixelToFrame TexturedPS_Colorscale(TVertexToPixel PSIn)
{
	TPixelToFrame Output = (TPixelToFrame)0;

	Output.Color = tex2D(ColorscaleSampler, ClampTexture(PSIn.TextureCoords, PSIn.TextureBounds));
	Output.Color.rgb *= tex2D(AmbientSampler, float2(PSIn.Color.g, 0.5f));

	if (Clipping)
	{
		if (GhostMode && PSIn.clipDistances.w < 0.0f)
		{
			Output.Color *= clamp(-1.0f / (PSIn.clipDistances.w * 0.75f) * 0.5f, 0, 1.0f);

			clip((Output.Color.a - 0.1f));
		}
		else
		{
			clip(PSIn.clipDistances.w);
		}
	}

	return Output;
}

TPixelToFrame TexturedPS_Alphatest(TVertexToPixel PSIn)
{
    TPixelToFrame Output = (TPixelToFrame)0;
    Output.Color =  tex2D(SunSampler, float2(PSIn.Color.r * (1.0f - xTimeOfDay), 0.5f));
	Output.Color.a *= PSIn.Color.a;
	Output.Color.rgb += tex2D(TorchSampler, float2(PSIn.Color.b,  0.5f));
	Output.Color.rgb *= tex2D(AmbientSampler, float2(PSIn.Color.g, 0.5f));
	saturate(Output.Color.rgb);
	float2 textureCoords = ClampTexture(PSIn.TextureCoords, PSIn.TextureBounds);
	float4 texColor = tex2D(TextureSampler, textureCoords);
	float4 illumColor = tex2D(IllumSampler, textureCoords);

	Output.Color.rgba *= texColor;
	Output.Color.rgb *= PSIn.ColorTint;
	if(SelfIllumination)
		Output.Color.rgba = lerp(Output.Color.rgba, texColor, illumColor.r); 
	
	Output.Color.rgba = float4(lerp(Output.Color.rgb, xFogColor, PSIn.Fog) * Output.Color.a, Output.Color.a);

	clip((texColor.a - 0.5));

	if (Clipping)
	{
		if (GhostMode && PSIn.clipDistances.w < 0.0f)
		{
			Output.Color *= clamp(-1.0f / (PSIn.clipDistances.w * 0.75f) * 0.25f, 0, 1.0f);

			clip((Output.Color.a - 0.1f));
		}
		else
		{
			clip(PSIn.clipDistances.w);
		}
	}
    return Output;
}


TPixelToFrame TexturedPS(TVertexToPixel PSIn)
{
    TPixelToFrame Output = (TPixelToFrame)0;
	if (Clipping)  clip(PSIn.clipDistances);  //MSS - Water Refactor added
    
	Output.Color =  tex2D(SunSampler, float2(PSIn.Color.r * (1.0f - xTimeOfDay), 0.5f));
	Output.Color.rgb += tex2D(TorchSampler, float2(PSIn.Color.b + (sin(xTime * 10.0f) + 1.0f) * 0.01f * PSIn.Color.b, 0.5f));
	saturate(Output.Color.rgb);

	Output.Color.rgb *=  tex2D(AmbientSampler, float2(PSIn.Color.g, 0.5f));
	Output.Color.rgb *= PSIn.ColorTint;
	float4 texColor = tex2D(TextureSampler, ClampTexture(PSIn.TextureCoords, PSIn.TextureBounds));
	float4 illumColor = tex2D(IllumSampler, ClampTexture(PSIn.TextureCoords, PSIn.TextureBounds));

	Output.Color.rgba *= texColor;
	if(SelfIllumination)
		Output.Color.rgba = lerp(Output.Color.rgba, texColor, illumColor.r); 
	
	Output.Color.rgba = float4(lerp(Output.Color.rgb, xFogColor, PSIn.Fog), Output.Color.a * PSIn.Color.a);

    return Output;
}

technique Textured
{
    pass Pass0
    {   
        VertexShader = compile vs_2_0 TexturedVSNonInstanced();
        PixelShader  = compile ps_2_0 TexturedPS_Alphatest();
    }
}

technique Textured_colorscale
{
	pass Pass0
	{
		VertexShader = compile vs_2_0 TexturedVSNonInstanced();
		PixelShader = compile ps_2_0 TexturedPS_Colorscale();
	}
}

technique Instanced
{
    pass Pass0
    {   
        VertexShader = compile vs_2_0 TexturedVSInstanced();
        PixelShader  = compile ps_2_0 TexturedPS_Alphatest();
    }
}

//------- Technique: Water --------
struct WVertexToPixel
{
     float4 Position                 : POSITION;
	 float2 TextureSamplingPos        : TEXCOORD5;
     float4 ReflectionMapSamplingPos    : TEXCOORD1;
     float2 BumpMapSamplingPos        : TEXCOORD2;
     float4 RefractionMapSamplingPos : TEXCOORD3;
     float4 Position3D                : TEXCOORD4;
	 float2 UnMovedTextureSamplingPos : TEXCOORD6;
	 float4 Color : COLOR0;
	 float Fog : TEXCOORD7;
	 float clipDistances : COLOR1;

};

struct WPixelToFrame
{
     float4 Color : COLOR0;
};

WVertexToPixel WaterVS(float4 inPos_ : POSITION, float2 inTex: TEXCOORD0, float4 inColor : COLOR0)
{    
	float4 inPos = inPos_ + GetNoise(inPos_);
     WVertexToPixel Output = (WVertexToPixel)0;

     float4x4 preViewProjection = mul (xView, xProjection);
     float4x4 preWorldViewProjection = mul (xWorld, preViewProjection);
     float4x4 preReflectionViewProjection = mul (xReflectionView, xProjection);
     float4x4 preWorldReflectionViewProjection = mul (xWorld, preReflectionViewProjection);

     Output.Position = mul(inPos, preWorldViewProjection);

     Output.ReflectionMapSamplingPos = mul(inPos, preWorldReflectionViewProjection);

     Output.RefractionMapSamplingPos = mul(inPos, preWorldViewProjection);
     Output.Position3D = mul(inPos, xWorld);
	 Output.BumpMapSamplingPos = inTex/xWaveLength;

     float3 windDir = normalize(xWindDirection);    
     float3 perpDir = cross(xWindDirection, float3(0,1,0));
     float ydot = dot(inTex, xWindDirection.xz);
     float xdot = dot(inTex, perpDir.xz);
     float2 moveVector = float2(xdot, ydot);
     moveVector.y += xTime*xWindForce;    
	 float2 moveVector2 = float2(xdot, ydot);
     moveVector2.y += xTime*xWindForce * 0.1f;    
     
	 Output.BumpMapSamplingPos = moveVector/xWaveLength;   
	 Output.TextureSamplingPos = moveVector2/xWaveLength * 90; 
	 Output.UnMovedTextureSamplingPos = inTex;
	 Output.Color = inColor;
	 Output.Fog = saturate((Output.Position.z - xFogStart) / (xFogEnd - xFogStart));
	 if(Clipping) Output.clipDistances = dot(mul(xWorld,inPos), ClipPlane0);

     return Output;
}

WVertexToPixel WaterVS_Flat(float4 inPos : POSITION, float2 inTex : TEXCOORD0, float4 inColor : COLOR0)
{
	WVertexToPixel Output = (WVertexToPixel)0;

	float4x4 preViewProjection = mul(xView, xProjection);
	float4x4 preWorldViewProjection = mul(xWorld, preViewProjection);
	Output.Position = mul(inPos, preWorldViewProjection);
	Output.Color = xFlatColor;

	if (Clipping) Output.clipDistances = dot(mul(xWorld, inPos), ClipPlane0);

	return Output;
}

WPixelToFrame WaterPS_Flat(WVertexToPixel PSIn)
{
	WPixelToFrame Output = (WPixelToFrame)0;
	Output.Color = PSIn.Color;
	return Output;
}

WPixelToFrame WaterPS(WVertexToPixel PSIn)
{
    WPixelToFrame Output = (WPixelToFrame)0;   
	if (Clipping)  clip(PSIn.clipDistances); 
	Output.Color = PSIn.Color;     

    float4 bumpColor = tex2D(WaterBumpMapSampler, PSIn.BumpMapSamplingPos);
    float2 perturbation = xWaveHeight*(bumpColor.rg - 0.5f)*2.0f;
    
    float2 ProjectedTexCoords;
    ProjectedTexCoords.x = PSIn.ReflectionMapSamplingPos.x/PSIn.ReflectionMapSamplingPos.w/2.0f + 0.5f;
    ProjectedTexCoords.y = -PSIn.ReflectionMapSamplingPos.y/PSIn.ReflectionMapSamplingPos.w/2.0f + 0.5f;        
    float2 perturbatedTexCoords = ProjectedTexCoords + perturbation;
    float4 reflectiveColor = tex2D(ReflectionSampler, perturbatedTexCoords);
    
    float2 ProjectedRefrTexCoords;
    ProjectedRefrTexCoords.x = PSIn.RefractionMapSamplingPos.x/PSIn.RefractionMapSamplingPos.w/2.0f + 0.5f;
    ProjectedRefrTexCoords.y = -PSIn.RefractionMapSamplingPos.y/PSIn.RefractionMapSamplingPos.w/2.0f + 0.5f;    
    float2 perturbatedRefrTexCoords = ProjectedRefrTexCoords + perturbation;    
    float4 refractiveColor = tex2D(RefractionSampler, perturbatedRefrTexCoords);

    float3 eyeVector = normalize(xCamPos - PSIn.Position3D);

    float3 normalVector = (bumpColor.rbg-0.5f);
    
    float fresnelTerm = dot(eyeVector, normalVector);   
    float4 combinedColor = lerp(reflectiveColor, refractiveColor, fresnelTerm);
    
    float4 dullColor = tex2D(WrappedTextureSampler, PSIn.TextureSamplingPos);
    float4 sloshColor = tex2D(WrappedTextureSampler1, PSIn.TextureSamplingPos + perturbation);

	float r = PSIn.Color.r;
    Output.Color = lerp(combinedColor, dullColor, max(xWaterOpacity  * PSIn.Color.b * (1.0f - xTimeOfDay), xWaterMinOpacity));    
    Output.Color = lerp(Output.Color, sloshColor, r * xWaterSloshOpacity * (1.0f - xTimeOfDay));

    Output.Color.rgba = float4(lerp(Output.Color.rgb, xFogColor, PSIn.Fog) * Output.Color.a, Output.Color.a);

	float st = (sin(xTime + r * 20) + 1.0) * 0.2;
	if(r > st + 0.4)
	{
		Output.Color.rgba += xRippleColor; 
	}
    return Output;
}




technique Water
{
     pass Pass0
     {
         VertexShader = compile vs_1_1 WaterVS();
         PixelShader = compile ps_2_0 WaterPS();

     }
}

technique WaterFlat
{
	pass Pass0
	{
		VertexShader = compile vs_1_1 WaterVS_Flat();
		PixelShader = compile ps_2_0 WaterPS_Flat();

	}
}