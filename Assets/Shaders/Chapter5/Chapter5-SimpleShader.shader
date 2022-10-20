// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unity Shaders Book/Chapter 5/Simple Shader"
{
    Properties
    {
        _Color ("Color Tine", Color) = (1.0,1.0,1.0,1.0)
    }
    SubShader
    {
        Pass
        {
            // CG 代码片段
            CGPROGRAM
            #pragma vertex vert // 哪个函数 包含 顶点着色器代码
            #pragma fragment frag // 哪个函数 包含 片元着色器代码

            // 在CG代羁中， 我们需要定义一个与属性名称和类型都匹配的变量

            fixed4 _Color;

            // 定义一个结构体 存储 顶点着色器的输入
            struct a2v
            {
                // Type Name : Semantic;
                //  POSITION语义告诉Unity, 用模型空间的顶点坐标填充vertex变量
                float4 vertex: POSITION;
                // NORMAL语义告诉Unity, 用模型空间的法线方向填充normal变量
                float3 normal: NORMAL;
                // TEXCOORD0 语义告诉Unity, 用模型的第一套纹理坐标填充 texcord0 变量
                float4 texcoord : TEXCOORD0;
            };

            // 使用一个结构体来定义顶点着色器的输出  v2f用于在顶点着色器和片元着色器之间传递信息。
            struct v2f
            {
                // 。顶点着色器的输出结构中 必须包含一个变量，它的语义是 SV_POSITION。
                //  SV_POSITION语义告诉Unity, pos里包含了顶点在裁剪空间中的位置信息
                float4 pos: SV_POSITION;
                // COLORO 语义可以用于存储颜色信息
                fixed3 color: COLOR0;
            };

            //  POSITION 含义是 把模型的顶点坐标 输入到 输入参数 v 中， SV_POSITION 含义是 顶点着色器输出是 裁剪空间的顶点坐标
            // float4 vert(float4 v: POSITION) : SV_POSITION  // POSITION 和 SV_POSITION 都是 CG/HLSL中的语义
            // {
            //     return UnityObjectToClipPos(v); // 返回在裁剪空间中的位置
            // }

            // float4 vert(a2v v) : SV_POSITION  // POSITION 和 SV_POSITION 都是 CG/HLSL中的语义
            // {
            //     return UnityObjectToClipPos(v.vertex); // 返回在裁剪空间中的位置
            // }

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                // v.normal包含了顶点的法线方向 ，其分量范围在(-1.0, 1.0]
                //下面的代码把分量范围映射到了(0.0, 1.0]
                //存储到a.color中传递给片元着色器
                o.color = v.normal * 0.5 + fixed3(0.5, 0.5, 0.5);
                return o;
            }

            //  SV_Target 语义 把用户的输出颜色存储到渲染目标中 默认帧缓存   
            // fixed4 frag() : SV_Target
            // {
            //     return fixed4(1.0, 1.0, 1.0, 1.0); // 表示白色  
            // }


            // 顶点着色器是逐顶点调用的， 而片元着色器是逐片元调用的。 片元着色器中的输入实际上是把顶点着色器的输出进行插值后得到的结果
            // fixed4 frag(v2f i) : SV_Target
            // {
            //     return fixed4(i.color, 1.0); 
            // }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed3 c = i.color;
                c *= _Color.rgb;
                return fixed4(c, 1.0);
            }
            ENDCG
        }
    }
}