// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Ch7/BlinnPhongWithTextures"
{
    Properties
    {
        _DiffuseColor ("Diffuse", Color) = (1, 1, 1, 1)
        _SpecularColor ("Specular", Color) = (1, 1, 1, 1)
        _Gloss ("Gloss", Range(1.0, 500)) = 20
        _AlbedoTex ("BaseColor", 2D) = "white"{}
        _SpecMaskTex("SpecularMask", 2D) = "white"{}
        _NormalTex("Normal", 2D) = "white"{}
    }
    SubShader
    {
        Pass
        {
            Tags
            {
                "LightMode"="ForwardBase"
            }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"
            #include "UnityCG.cginc"
            fixed4 _DiffuseColor;
            fixed4 _SpecularColor;
            float _Gloss;
            sampler2D _AlbedoTex;
            sampler2D _SpecMaskTex;
            sampler2D _NormalTex;
            float4 _AlbedoTex_ST;
            float4 _SpecMaskTex_ST;
            float4 _NormalTex_ST;

            struct a2v
            {
                float4 position : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float4 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 albedoUV : TEXCOORD0;
                float2 specUV : TEXCOORD1;
                float2 normalUV : TEXCOORD2;

                float4 tbn0 : TEXCOORD3;
                float4 tbn1 : TEXCOORD4;
                float4 tbn2 : TEXCOORD5;
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.position);
                // Use the build-in funtion to compute the normal in world space
                // o.worldNormal = UnityObjectToWorldNormal(v.normal);

                float3 worldPos = mul(unity_ObjectToWorld, v.position);
                float3 worldNormal = UnityObjectToWorldNormal(v.normal);
                float3 worldTangent =  UnityObjectToWorldDir(v.tangent.xyz);
                float3 worldBitangent = cross(normalize(v.normal), normalize(v.tangent.xyz)) * v.tangent.w;
                
                // o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.albedoUV = TRANSFORM_TEX(v.texcoord, _AlbedoTex);
                o.specUV = TRANSFORM_TEX(v.texcoord, _SpecMaskTex);
                o.normalUV = TRANSFORM_TEX(v.texcoord, _NormalTex);
                
                // TANGENT_SPACE_ROTATION;
                o.tbn0 = float4(worldTangent.x, worldBitangent.x, worldNormal.x, worldPos.x);
                o.tbn1 = float4(worldTangent.y, worldBitangent.y, worldNormal.y, worldPos.y);
                o.tbn2 = float4(worldTangent.z, worldBitangent.z, worldNormal.z, worldPos.z);
                
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // recover data
                float3 worldPos = float3(i.tbn0.w, i.tbn1.w, i.tbn2.w);
                float3x3 worldTBN = float3x3(i.tbn0.xyz, i.tbn1.xyz, i.tbn2.xyz);

                float3 tangentNormal = UnpackNormal(tex2D(_NormalTex, i.normalUV));
                float3 worldNormal = mul(worldTBN, tangentNormal);  
//				worldNormal = normalize(half3(dot(i.tbn0.xyz, tangentNormal), dot(i.tbn1.xyz, tangentNormal), dot(i.tbn2.xyz, tangentNormal)));

                fixed3 albedo = tex2D(_AlbedoTex, i.albedoUV).rgb * _DiffuseColor.rgb;
                // Get the mask value
                fixed3 specularTexture = tex2D(_SpecMaskTex, i.specUV).r * 1.0f;
//                _SpecMaskTexular.rgb;

			 	// fixed specularMask = tex2D(_SpecMaskTexularMask, i.uv).r * _SpecMaskTexularScale;
			 	// Compute specular term with the specular mask
//			 	fixed3 specular = _LightColor0.rgb * _SpecMaskTexular.rgb * pow(max(0, dot(tangentNormal, halfDir)), _Gloss) * specularMask;

                
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                // fixed3 worldNormal = normalize(i.worldNormal);
                //  Use the build-in funtion to compute the light direction in world space
                //  // Remember to normalize the result
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(worldPos));
                fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(worldNormal, worldLightDir));
                // Use the build-in funtion to compute the view direction in world space
                // // Remember to normalize the result
                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));
                fixed3 halfDir = normalize(worldLightDir + viewDir);
                fixed3 specular = _LightColor0.rgb * _SpecularColor.rgb * pow(max(0, dot(worldNormal, halfDir)), _Gloss) * specularTexture;
				return fixed4(ambient + diffuse + specular, 1.0);
            }
            ENDCG
        }
    }
    FallBack "Specular"
}