Shader "Custom/UnlitWithShadows"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color Tint", Color) = (1,1,1,1)
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry" }
        LOD 100

        CGPROGRAM
        #pragma surface surf UnlitWithShadow fullforwardshadows addshadow

        sampler2D _MainTex;
        fixed4 _Color;
        struct Input
        {
            float2 uv_MainTex;
        };

        half4 LightingUnlitWithShadow(SurfaceOutput s, half3 lightDir, half atten)
        {
            // Attenuation = shadow darkness
            return half4(s.Albedo * atten, 1.0);
        }

        void surf(Input IN, inout SurfaceOutput o)
        {
            fixed4 tex = tex2D(_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = tex.rgb;
            o.Alpha = tex.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
