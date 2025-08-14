sampler2D imgTexture;
sampler2D bkdTexture : register(s1) = sampler_state{
  MinFilter = Point;
  MagFilter = Point;
};

// Global variables
float intensity;
float amplitude;
float periods;
float frequency;

float4 colorA;
float4 colorB;

float blur=0.01;

float4 ps_main(float2 In : TEXCOORD0) : COLOR0
{
  // Background
    // float4 back = tex2D(bkd,textureCoordinate);
  // Foreground
    // fore = tex2D(img,textureCoordinate);

  // SinX
        textureCoordinate.y = textureCoordinate.y + (sin((textureCoordinate.y+frequency)*periods)*amplitude);

  // Warp
    float4 TexTL; float4 TexBL; float4 TexBR; float4 TexTR;
    float4 TexBTL; float4 TexBBL; float4 TexBBR; float4 TexBTR;
    TexTL.rgba = tex2D(imgTexture, float2(textureCoordinate.x-blur,textureCoordinate.y-blur));
    TexBL.rgba = tex2D(imgTexture, float2(textureCoordinate.x-blur,textureCoordinate.y+blur));
    TexBR.rgba = tex2D(imgTexture, float2(textureCoordinate.x+blur,textureCoordinate.y+blur));
    TexTR.rgba = tex2D(imgTexture, float2(textureCoordinate.x+blur,textureCoordinate.y-blur));
    float4 fore = tex2D(imgTexture, textureCoordinate.xy);
    fore.rgba = (fore.rgba+TexTL.rgba+TexBL.rgba+TexBR.rgba+TexTR.rgba)/5.0;

  // Apply Color
    float md = (frequency*10.0)+(textureCoordinate.y*3.0);
    float tick = cos(md);
    float3 melt = lerp(fore.rgb+(colorB.rgb*0.5),fore.rgb*(colorA.rgb*2.0),textureCoordinate.y);
    float3 anim = lerp(melt,fore.rgb,tick);
    fore.rgb = lerp(fore.rgb,anim,intensity);

  return fore;
}

// Effect technique
technique HeatRay { pass P0 { PixelShader = compile ps_2_0 ps_main(); } }
