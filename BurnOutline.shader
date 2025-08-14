Shader "MyShader/BurnOutline" {
    Properties {
        [Space]
        _MainTex("Texture", 2D) = "white" { }
        _OutlineColor ("OutlineColor", Color) = (1, 1, 1, 1) //??????
        _DeepOutLineColor2("DeepOutLineColor2", Color) = (1, 1, 1, 1)
        _OutlineAlpha ("OutlineAlpha", Range(0, 1)) = 1 //????????
        _OutlinePixelWidth ("OutlinePixelWidth", Int) = 1 //????????

        _OutlineDistortTex ("OutlineDistortionTex", 2D) = "white" { }//??????��??????
        _OutlineDistortAmount ("OutlineDistortionAmount", Range(0, 2)) = 0.5 //????????????��???
        _OutlineDistortTexXSpeed ("OutlineDistortTexXSpeed", Range(-50, 50)) = 5 //???????????X?????
        _OutlineDistortTexYSpeed ("OutlineDistortTexYSpeed", Range(-50, 50)) = 5 //???????????Y?????

        _OutLineColorTex ("OutlineColorTex", 2D) = "white" {}
        _OutLineLight ("OutLineLight",float) = 1
        _OutLineContrast ("OutLineContrast", float) = 1

    }
    SubShader {
        Tags { "Queue" = "Transparent" }
        Blend SrcAlpha OneMinusSrcAlpha

        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_TexelSize;//_MainTex????????????????

            fixed4 _OutlineColor;
            fixed4 _DeepOutLineColor2;

            float _OutlineAlpha;
            int _OutlinePixelWidth;

            sampler2D _OutlineDistortTex;
            float4 _OutlineDistortTex_ST;
            float _OutlineDistortTexXSpeed, _OutlineDistortTexYSpeed, _OutlineDistortAmount;

            sampler2D _OutLineColorTex;
            float4 _OutLineColorTex_ST;

            float _OutLineLight;
            float _OutLineContrast;


            struct appdata {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f {
                float2 uv : TEXCOORD0;
                float2 uvOutDistTex : TEXCOORD1;
                float4 vertex : SV_POSITION;
            };

            v2f vert(appdata v) {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uvOutDistTex = TRANSFORM_TEX(v.uv, _OutlineDistortTex);//
                o.uv = v.uv;
                return o;
            }



            fixed4 frag(v2f i) : SV_Target {
                //------Outline------
                fixed4 col = tex2D(_MainTex, i.uv);//???????????��???
                float originalAlpha = col.a;//????alpha?

                float2 destUv = float2(_OutlinePixelWidth * _MainTex_TexelSize.x, _OutlinePixelWidth * _MainTex_TexelSize.y);//??????????????��

                i.uvOutDistTex.x += (_Time * _OutlineDistortTexXSpeed) % 1;//???????????????????????????
                i.uvOutDistTex.y += (_Time * _OutlineDistortTexYSpeed) % 1;


                //??????????????r?????????��??��????
                float outDistortAmnt = (tex2D(_OutlineDistortTex, i.uvOutDistTex).r - 0.5) * 0.2 * _OutlineDistortAmount;
                float OutLineRandomProb = tex2D(_OutLineColorTex, i.uvOutDistTex).g;
                destUv.x += outDistortAmnt;//??????xy??????????��?????????????
                destUv.y += outDistortAmnt;

                float spriteLeft = tex2D(_MainTex, i.uv + float2(destUv.x, 0)).a;
                float spriteRight = tex2D(_MainTex, i.uv - float2(destUv.x, 0)).a;
                float spriteBottom = tex2D(_MainTex, i.uv + float2(0, destUv.y)).a;
                float spriteTop = tex2D(_MainTex, i.uv - float2(0, destUv.y)).a;
                float spriteTopLeft = tex2D(_MainTex, i.uv + float2(destUv.x, destUv.y)).a;
                float spriteTopRight = tex2D(_MainTex, i.uv + float2(-destUv.x, destUv.y)).a;
                float spriteBotLeft = tex2D(_MainTex, i.uv + float2(destUv.x, -destUv.y)).a;
                float spriteBotRight = tex2D(_MainTex, i.uv + float2(-destUv.x, -destUv.y)).a;
                float result = spriteLeft + spriteRight + spriteBottom + spriteTop + spriteTopLeft + spriteTopRight + spriteBotLeft + spriteBotRight;

                result = step(0.05, saturate(result));
                result *= (1 - originalAlpha) * _OutlineAlpha;
                OutLineRandomProb = (OutLineRandomProb-0.5)*_OutLineContrast+0.5;
                fixed4 outline = _DeepOutLineColor2*OutLineRandomProb + _OutlineColor* (1- OutLineRandomProb);
                outline *= _OutLineLight;
                //outline.a = 1;

                col = outline* result ;
                return col;
            }
            ENDCG
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma shader_feature _GRAYSWITCH_ON

            #include "UnityCG.cginc"
            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Color;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;

            };

            struct v2f
            {
                float2 uv1 : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv1 = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv1);
                //float pixel = i.uv1.y*255;
                //fixed4 finalColor = fixed4(pixel, pixel, pixel, 1);
                fixed4 finalColor = col;
                return finalColor;
            }
            ENDCG
        }
    }
}