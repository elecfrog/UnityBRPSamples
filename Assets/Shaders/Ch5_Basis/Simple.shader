// shader lab introduction 
Shader "Ch5/Simple"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
    }
    SubShader
    {
        Pass
        {
            Name "SIMPLE"
            CGPROGRAM
            #pragma vertex VertShader
            #pragma fragment FragShader
            #include "UnityCG.cginc"

            struct InputVertex
            {
                float4 position : POSITION;
                float3 normal : NORMAL;
                float4 uv: TEXCOORD;
            };

            struct VertexToFragment
            {
                float4 fragPos : SV_POSITION;

                fixed4 fragColor : COLOR0;
            };

            fixed4 _Color;

            VertexToFragment VertShader(InputVertex vertex)
            {
                VertexToFragment ret;
                ret.fragPos = mul(unity_MatrixMVP, vertex.position);
                ret.fragColor = fixed4(vertex.normal * 0.5f, 1.f) + fixed4(0.5f, 0.5f, 0.5f, 1.f);

                return ret;
            }

            fixed4 FragShader(VertexToFragment v2f) : SV_Target
            {
                return v2f.fragColor * _Color;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}