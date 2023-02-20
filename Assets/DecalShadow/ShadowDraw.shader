Shader "Unlit/ShadowDraw"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue" = "Transparent"}
        LOD 100

        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
            Stencil 
            {
                ref 2
                comp notEqual
            }
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 screenPos : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            sampler2D _CameraDepthTexture;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.screenPos = ComputeScreenPos(o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float4 divW = i.screenPos / i.screenPos.w;
                float4 ndcPos = divW * 2 - 1;
                //将屏幕像素对应在摄像机远平面的点转换到剪裁空间，也是相机(0,0,0)指向该点的向量
                float far = _ProjectionParams.z;
                float3 farClipVec = float3(ndcPos.xy, 1) * far;
                //通过逆投影矩阵将向量转换到观察空间
                float3 viewVec = mul(unity_CameraInvProjection, farClipVec.xyzz).xyz;
                //将向量乘以线性深度值，得到在深度缓冲中储存的值在观察空间的位置
                float2 screenUV = divW.xy;
                float depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, screenUV);
                float3 viewPos = viewVec * Linear01Depth(depth);
                //观察空间变换到世界空间

                const float4x4 RotateX90 = float4x4( 1,0,0,0,
                                                     0,1,0,0,
                                                     0,0,1,0,
                                                     0,0,0,1);
                
                float4 worldPos = mul(mul(RotateX90, UNITY_MATRIX_I_V), float4(viewPos, 1.0));

                float4 objectPos = mul(unity_WorldToObject, worldPos);
                clip(float3(0.5, 0.5, 0.5) - abs(objectPos));
                float2 uv = objectPos.xy + 0.5;
                // return float4(uv, 0, 1);
                
                float r = tex2D(_MainTex, uv).r;
                return fixed4(UNITY_LIGHTMODEL_AMBIENT.xyz, r*0.7);
            }
            ENDCG
        }
    }
}
