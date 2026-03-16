Shader "XGame/SemiToon_Pastel"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Color ("Base Color", Color) = (1,1,1,1)

        // Pastel / color grading
        _PastelTint ("Pastel Tint", Color) = (0.9,0.8,1,1)
        _PastelAmount ("Pastel Amount", Range(0,1)) = 0.5
        _Saturation ("Saturation", Range(0,2)) = 1.0
        _Contrast ("Contrast", Range(0,2)) = 1.0

        // Toon / semi-toon control
        _ToonRamp ("Toon Ramp (grayscale)", 2D) = "gray" {}
        _ToonStrength ("Toon Strength (0=smooth,1=toon)", Range(0,1)) = 0.6
        _ToonLevels ("Toon Levels", Range(1,8)) = 3
        _Smoothness ("Smoothness (phong)", Range(0,1)) = 0.4
        _SpecularColor ("Specular Color", Color) = (1,1,1,1)
        _SpecPower ("Spec Power", Range(1,128)) = 16

        // Fresnel + rim
        _FresnelColor ("Fresnel Color", Color) = (1,0.9,0.8,1)
        _FresnelPower ("Fresnel Power", Range(0.1,8)) = 2.0
        _FresnelIntensity ("Fresnel Intensity", Range(0,4)) = 0.8
        _RimIntensity ("Rim Intensity", Range(0,4)) = 0.6
        _RimPower ("Rim Power", Range(0.1,8)) = 1.8

        // Stylized shadow control
        _ShadowContrast ("Shadow Contrast", Range(0,2)) = 1.2
        _ShadowBias ("Shadow Bias (for ramp)", Range(0,1)) = 0.15

        // Misc
        _EmissionColor ("Emission", Color) = (0,0,0,1)
        _Cutoff ("Alpha Cutoff", Range(0,1)) = 0.0

        [Header(STENCIL)]
        [Enum(Equal,3, NotEqual,6, Always,8)] _StencilComp ("Stencil Compare", Float) = 8
        _StencilRef ("Stencil Ref", Range(0,255)) = 2
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200
        Stencil
        {
            Ref [_StencilRef]
            Comp [_StencilComp]
            Pass keep
        }
        CGPROGRAM
        #pragma surface surf SemiToon fullforwardshadows
        #pragma target 3.0


      

        sampler2D _MainTex;
        fixed4 _Color;

        fixed4 _PastelTint;
        float _PastelAmount;
        float _Saturation;
        float _Contrast;

        sampler2D _ToonRamp;
        float _ToonStrength;
        int _ToonLevels;
        float _Smoothness;
        fixed4 _SpecularColor;
        float _SpecPower;

        fixed4 _FresnelColor;
        float _FresnelPower;
        float _FresnelIntensity;
        float _RimIntensity;
        float _RimPower;

        float _ShadowContrast;
        float _ShadowBias;

        fixed4 _EmissionColor;
        float _Cutoff;

        struct Input {
            float2 uv_MainTex;
            float3 viewDir;
        };

        // utility: simple saturation
        fixed3 AdjustSaturation(fixed3 col, float sat)
        {
            float l = dot(col, fixed3(0.2126,0.7152,0.0722));
            return lerp(fixed3(l,l,l), col, sat);
        }

        // simple contrast
        fixed3 AdjustContrast(fixed3 col, float contrast)
        {
            return ((col - 0.5) * contrast) + 0.5;
        }

        // pastel grading: blend towards a soft tint and desaturate a bit
        fixed3 PastelGrade(fixed3 col)
        {
            fixed3 tinted = lerp(col, _PastelTint.rgb, _PastelAmount);
            tinted = AdjustSaturation(tinted, saturate(_Saturation * (1 - _PastelAmount*0.5)));
            tinted = AdjustContrast(tinted, _Contrast);
            return tinted;
        }

        // fetch ramp-based toon shade (assume ramp is horizontal gradient)
        float SampleToonRamp(float NdotL)
        {
            // sample ramp texture at x = NdotL; y = 0.5
            float2 uv = float2(saturate(NdotL), 0.5);
            fixed4 rampCol = tex2D(_ToonRamp, uv);
            // Convert ramp to luminance
            float lum = dot(rampCol.rgb, float3(0.299,0.587,0.114));
            return lum;
        }

        // custom lighting function
        half4 LightingSemiToon(SurfaceOutput s, half3 lightDir, half3 viewDir, half atten)
        {
            // N · L (clamped)
            half NdotL = saturate(dot(s.Normal, lightDir));

            // Phong-style smooth diffuse
            half diffuseSmooth = NdotL;

            // Toon ramp sample
            float toonShade = SampleToonRamp(NdotL);

            // Combine smooth and toon via _ToonStrength
            float diffuseCombined = lerp(diffuseSmooth, toonShade, _ToonStrength);

            // Apply toon levels: quantize when strength is high
            if (_ToonStrength > 0.01)
            {
                float levels = max(1.0, (float)_ToonLevels);
                diffuseCombined = floor(diffuseCombined * levels + 0.0001) / levels;
                // soften edges a little by blending back small amount
                diffuseCombined = lerp(diffuseCombined, toonShade, saturate(_ToonStrength*0.5));
            }

            // specular (phong) using viewDir
            half3 R = reflect(-lightDir, s.Normal);
            half spec = pow(saturate(dot(R, viewDir)), _SpecPower) * _Smoothness;

            // rim based on fresnel
            float fres = pow(saturate(1.0 - saturate(dot(viewDir, s.Normal))), _FresnelPower);
            float rim = pow(saturate(1.0 - dot(viewDir, s.Normal)), _RimPower);

            // combine lighting
            fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * s.Albedo;
            fixed3 diffuse = s.Albedo * diffuseCombined * _LightColor0.rgb;
            fixed3 specular = _SpecularColor.rgb * spec * _LightColor0.rgb;

            // stylized shadow contrast: push darker areas darker
            diffuse = lerp(diffuse * _ShadowContrast, diffuse, saturate(diffuseCombined + _ShadowBias));

            // fresnel glow + rim highlight
            fixed3 fresnelCol = _FresnelColor.rgb * fres * _FresnelIntensity;
            fixed3 rimCol = _FresnelColor.rgb * rim * _RimIntensity;

            fixed3 col = ambient + diffuse + specular + fresnelCol + rimCol;
            return half4(col * atten, 1);
        }

        void surf (Input IN, inout SurfaceOutput o)
        {
            fixed4 tex = tex2D(_MainTex, IN.uv_MainTex) * _Color;

            // alpha cutoff
            clip(tex.a - _Cutoff);

            // base albedo
            o.Albedo = tex.rgb;

            // apply pastel grading to final albedo BEFORE lighting multipliers
            o.Albedo = PastelGrade(o.Albedo);

            // roughness / smoothness mapping
            o.Gloss = _Smoothness;

            // emission
            o.Emission = _EmissionColor.rgb;

            // normal will be default (could be expanded to accept _BumpMap)
            o.Alpha = tex.a;
        }
        ENDCG
    }

    FallBack "Diffuse"
}
