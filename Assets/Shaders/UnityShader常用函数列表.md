# Unity Shader常用函数列表

## Unity内置矩阵（float4x4）

UNITY_MATRIX_MVP 当前模型 * 视图 * 投影矩阵。  
UNITY_MATRIX_MV 当前模型 * 视图矩阵  
UNITY_MATRIX_V 当前视图矩阵。  
UNITY_MATRIX_P 当前投影矩阵。  
UNITY_MATRIX_VP 当前视图 * 投影矩阵。  
UNITY_MATRIX_T_MV  模型 * 视图 * 转矩阵  
UNITY_MATRIX_IT_MV 模型 * 视图 * 逆 转矩阵  
unity_ObjectToWorld  当前模型矩阵。
unity_WorldToObject  当前世界矩阵的逆矩阵。
UNITY_MATRIX_TEXTURE0 UNITY_MATRIX_TEXTURE3 纹理变换矩阵

## 内置着色器变量

unity_WorldToLight  float4x4 世界空间到光源空间矩阵。用于对 cookie 和衰减纹理进行采样。
_WorldSpaceCameraPos  float4 相机的世界空间位置。

## 时间

_Time float4  t是自该场景加载开始所经过的时间，4个分量的值分别是 （t/20, t, 2t, 3t）
_SinTime float4 t是时间的正弦值 4个分量的值分别是 （t/8, t/4, t/2, t）
_CosTime float4 t是时间的余弦值 4个分量的值分别是 （t/8, t/4, t/2, t）
unity_DeltaTime float4 dt是时间增量 4个分量的值分别是 （dt, 1/dt, smoothDt, 1/smoothDt）

## CG标准函数库

Cg 标准函数库主要分为五个部分:  
数学函数（Mathematical Functions）  
几何函数(Geometric Functions)  
纹理映射函数(Texture Map Functions)  
偏导数函数(Derivative Functions)  
调试函数(Debugging Function)  

### 数学函数（Mathematical Functions）

数学函数用于执行数学上常用计算，包括：三角函数、幂函数、园函数、向量和矩阵的操作函数。这些函数都被重载，以支持标量数据和不同长度的向量作为输入参数。

```
abs(x) 返回输入参数的绝对值
acos(x) 反余切函数，输入参数范围为[-1,1]，返回[0,π]区间的角度值
all(x) 如果输入参数均不为0，则返回 ture；否则返回 flase。&&运算
any(x) 输入参数只要有其中一个不为0，则返回 true。||运算
asin(x) 反正弦函数,输入参数取值区间为[−1,1]，返回角度值范围为[−π/2 ,π/2 ] atan(x) 反正切函数，返回角度值范围为⎡−π/2 ,π/2⎤
atan2(y,x) 计算y/x 的反正切值。实际上和atan(x)函数功能完全一样，至少输入参数不同。atan(x) = atan2(x, float(1))
ceil(x) 对输入参数向上取整。例如：ceil(float(1.3))，其返回值为 2.0
clamp(x,a,b) 如果x 值小于 a，则返回a；如果 x 值大于 b，返回b；否则，返回 x
cos(x) 返回弧度 x 的余弦值。返回值范围为[−1,1] osh(x) 双曲余弦（hyperbolic cosine）函数，计算x 的双曲余弦值
cross(A,B) 返回两个三元向量的叉积(cross product)。注意，输入参数必须是三元向量
degrees(x) 输入参数为弧度值(radians)，函数将其转换为角度值(degrees)
determinant(m)  计算矩阵的行列式因子
dot(A,B) 返回A 和 B的点积(dot product)。参数A 和 B 可以是标量，也可以是向量（输入参数方面，点积和叉积函数有很大不同）
exp(x) 计算ex的值，e= 2.71828182845904523536
exp2(x) 计算2x的值
floor(x) 对输入参数向下取整。例如floor(float(1.3)) 返回的值为1.0；但是 floor(float(-1.3))返回的值为-2.0。
fmod(x,y) 返回x/y 的余数。如果 y 为 0，结果不可预料
frexp(x, out exp)  将浮点数 x 分解为尾数和指数，即x = m* 2^exp，返回m，并将指数存入 exp 中；如果 x 为 0，则尾数和指数都返回0
frac(x) 返回标量或每个矢量分量的小数部分
isfinite(x) 判断标量或者向量中的每个数据是否是有限数，如果是返回true；否则返回false;无限的或者非数据(not-a-number NaN)
isinf(x) 判断标量或者向量中的每个数据是否是无限，如果是返回 true；否则返回 false;
isnan(x) 判断标量或者向量中的每个数据是否是非数据(not-a-number NaN)，如果是返回true；否则返回false;
ldexp(x, n) 计算x∗2n的值
lerp(a, b, f)  计算(1−f )∗ + ∗a b   f或者a+f ∗ −(b a)的值。即在下限a 和上限 b 之间进行插值，f表示权值。注意，如果 a和 b 是向
量，则权值 f必须是标量或者等长的向量。
lit(NdotL,NdotH, m)  N表示法向量；L 表示入射光向量；H表示半角向量；m 表示高光系数。
函数计算环境光、散射光、镜面光的贡献，返回的 4元向量：
1.位表示环境光的贡献，总是 1.0；
2.位代表镜面光的贡献，如果 N •L<0，则为0；否则为 N •L;
3.位代表镜面光的贡献，如果N •L<0或者 N •H <0 ，则为 0；否则为(N •H)m；
4.W位始终位 1.0
log(x)  计算ln(x)的值，x必须大于 0
log2(x) 计算log(2x)的值，x 必须大于 0
log10(x)  计算log10(x)的值，x必须大于 0
max(a, b)  比较两个标量或等长向量元素，返回 大值
min(a,b) 比较两个标量或等长向量元素，返回 小值
```

常用

```
modf(x, out ip)	 返回 x 的小数部分和整数部分
mul(M, N)	计算两个矩阵相乘，如果 M 为 AxB 阶矩阵，N为 BxC阶矩阵，则返回 AxC 阶矩阵。下面两个函数为其重载函数。
mul(M, v)	计算矩阵和向量相乘
mul(v, M)	计算向量和矩阵相乘
noise(x)	噪声函数，返回值始终在 0，1之间；对于同样的输入，始终返回相同的值（也就是说，并不是真正意义上的随机噪声）。
pow(x, y)	接受两个参数（基值和幂值），并返回基数的幂
radians(x)	函数将角度值转换为弧度值
round(x)	四舍五入
rsqrt(x)	X 的反平方根，x必须大于 0
saturate(x)	如果 x 小于0，返回 0；如果 x大于 1，返回1；否则，返回x
sign(x)	    如果 x 大于0，返回 1；如果 x小于 0，返回01；否则返回0。
sin(x)	    输入参数为弧度，计算正弦值，返回值范围为[−1,1]
sincos(float x, out s, out c)	      该函数是同时计算 x的 sin值和 cos值，其中 s=sin(x)，c=cos(x)。该函数用于“同时需要计算sin 值和cos 值的情况”，比分别运算要快很多!
sinh(x)	   计算双曲正弦（hyperbolic sine）值。
smoothstep(min, max, x)	在两个值之间执行 Hermite 插值。https://www.jianshu.com/p/53fe928a0fb6 
```

### 几何函数（Geometric Functions）

Cg语言标准函数库中有
3 个几何函数会经常被使用到，分别是：

normalize函数，对向量进行归一化；reflect函数，计算反射光方向向量；refract函数，计算折射光方向向量。

注：

1. 着色程序中的向量 最好进行归一化之后再使用，否则会出现难以预料的错误；
2. reflect函数和refract函数都存在以“入射光方向向量”作为输入参数，注意这两个函数中使用的入射光方向向量，是从外指向几何顶点的；平时我们在着色程序中或者在课本上都是将入射光方向向量作为从顶点出发。

| 函数                  |                    功能                    |
| :------------------ | :--------------------------------------: |
| distance( pt1, pt2) |     两点之间的欧几里德距离（Euclidean distance）      |
| faceforward(N,I,Ng) |        如果*Ng I*• <0 ，返回N；否则返回-N。         |
| length(v)           |        返回一个向量的模，即 sqrt(dot(v,v))         |
| normalize( v)       |                  归一化向量                   |
| reflect(I, N)       | 根据入射光方向向量 I，和顶点法向量N，计算反射光方向向量。其中I 和N 必须被归一化，需要非常注意的是，这个I 是指向顶点的；函数只对三元向量有效 |
| refract(I,N,eta)    | 计算折射向量，I为入射光线，N为法向量，eta为折射系数；其中 I 和N 必须被归一化，如果I 和N 之间的夹角太大，则返回（0，0，0），也就是没有折射光线；I是指向顶点的；函数只对三元向量有效 |

### 纹理映射函数（Texture Map Functions）

```
tex1D(sampler1D tex, float s)                        一维纹理查询
tex1D(sampler1D tex, float s, float dsdx, float dsdy)      使用导数值（derivatives）查询一维纹理
Tex1D(sampler1D tex, float2 sz)                     一维纹理查询，并进行深度值比较
Tex1D(sampler1D tex, float2 sz, float dsdx,float dsdy)      使用导数值（derivatives）查询一维纹理，并进行深度值比较
Tex1Dproj(sampler1D tex, float2 sq)                 一维投影纹理查询
Tex1Dproj(sampler1D tex, float3 szq)                一维投影纹理查询，并比较深度值
Tex2D(sampler2D tex, float2 s)                      二维纹理查询
Tex2D(sampler2D tex, float2 s, float2 dsdx, float2 dsdy)    使用导数值（derivatives）查询二维纹理
Tex2D(sampler2D tex, float3 sz)                     二维纹理查询，并进行深度值比较
Tex2D(sampler2D tex, float3 sz, float2 dsdx,float2 dsdy)  使用导数值（derivatives）查询二维纹理，并进行深度值比较
Tex2Dproj(sampler2D tex, float3 sq)                 二维投影纹理查询
Tex2Dproj(sampler2D tex, float4 szq)                二维投影纹理查询，并进行深度值比较
texRECT(samplerRECT tex, float2 s)
texRECT(samplerRECT tex, float2 s, float2 dsdx, float2 dsdy)
texRECT(samplerRECT tex, float3 sz)
texRECT(samplerRECT tex, float3 sz, float2 dsdx,float2 dsdy)
texRECT proj(samplerRECT tex, float3 sq)
texRECT proj(samplerRECT tex, float3 szq)
Tex3D(sampler3D tex, float s)                          三维纹理查询
Tex3D(sampler3D tex, float3 s, float3 dsdx, float3 dsdy)      结合导数值（derivatives）查询三维纹理
Tex3Dproj(sampler3D tex, float4 szq)                   查询三维投影纹理，并进行深度值比较
texCUBE(samplerCUBE tex, float3 s)                    查询立方体纹理
texCUBE (samplerCUBE tex, float3 s, float3 dsdx, float3 dsdy)    结合导数值（derivatives）查询立方体纹理
texCUBEproj (samplerCUBE tex, float4 sq) 查询投影立方体纹理
```

s象征一元、二元、三元纹理坐标；z代表使用“深度比较（depth comparison）”的值；q表示一个透视值（perspective value,其实就是透视投影后所得到的齐次坐标的 后一位），这个值被用来除以纹理坐标（S），得到新的纹理坐标（已归一化到0 和1 之间）然后用于纹理查询。
纹理函数非常多，总的来说，按照纹理维数进行分类，即：1D纹理函数， 2D 纹理函数，3D纹理函数，已经立方体纹理。需要注意，TexREC函数查询的纹理实际上也是二维纹理。3D 纹理，另一个比较学术化的名称是“体纹理（Volume Texture）”，体纹理通常用于体绘制，体纹理用于记录空间中的体细节数据。
还有一类较为特殊的纹理查询函数以 proj 结尾，主要是针对投影纹理进行查询。所谓投影纹理是指：将纹理当做一张幻灯片投影到场景中，使用投影纹理技术需要计算投影纹理坐标，然后使用投影纹理坐标进行查询。使用投影纹理坐标进行查询的函数就是投影纹理查询函数。  本质来说，投影纹理查询函数和普通的纹理查询函数没有什么不同，唯一的区别在于“投影纹理查询函数使用计算得到的投影纹理坐标，并在使用之前会将该投影纹理坐标除以透视值”。举例而言，计算得到的投影纹理坐标为float4 uvproj，使用二维投影纹理查询函数：
tex2Dproj(texture,uvproj);等价于按如下方法使用普通二维纹理查询函数：
float4 uvproj = uvproj/uvproj.q; tex2D(texture,uvproj);

### 偏导函数（Derivative Functions）

|   函数   | 功能                           |
| :----: | ---------------------------- |
| ddx(a) | 参数 a对应一个像素位置，返回该像素值在X 轴上的偏导数 |
| ddy(a) | 参数 a对应一个像素位置，返回该像素值在Y 轴上的偏导数 |

1. 函数 ddx和 ddy 用于求取相邻像素间某属性的差值；
2. 函数 ddx和 ddy 的输入参数通常是纹理坐标；
3. 函数 ddx和 ddy 返回相邻像素键的属性差值；


UnityCG.cginc 中的顶点变换函数
```
float4 UnityObjectToClipPos(float3 pos)  将点从对象空间转换为相机的齐次坐标中的剪辑空间。这等效于mul(UNITY_MATRIX_MVP, float4(pos, 1.0))，应该在其位置使用。
float3 UnityObjectToViewPos(float3 pos)  将点从对象空间转换到视图空间。这相当于mul(UNITY_MATRIX_MV, float4(pos, 1.0)).xyz，应该在它的位置使用。

```

UnityCG.cginc 中的通用辅助函数
```
float3 WorldSpaceViewDir (float4 v)：返回从给定对象空间顶点位置朝向相机的世界空间方向（未标准化）。  
float3 ObjSpaceViewDir (float4 v)：返回从给定对象空间顶点位置朝向相机的对象空间方向（未标准化）。  
float2 ParallaxOffset (half h, half height, half3 viewDir)：计算视差法线贴图的 UV 偏移。  
fixed Luminance (fixed3 c)：将颜色转换为亮度（灰度）。  
fixed3 DecodeLightmap (fixed4 color)：从Unity光照贴图解码颜色（基于平台为RGBM 或dLDR）。  
float4 EncodeFloatRGBA (float v)：为储存低精度的渲染目标，编码[0..1)范围的浮点数到RGBA颜色。  
float DecodeFloatRGBA (float4 enc)：解码RGBA颜色到float。  
float2 EncodeFloatRG (float v) 和float DecodeFloatRG (float2 enc) 使用的是两个颜色通道。  
float2 EncodeViewNormalStereo (float3 n)：将视图空间正常编码为 0..1 范围内的两个数字。  
float3 DecodeViewNormalStereo (float4 enc4)：从enc4.xy解码视图空间法线。  
```

UnityCG.cginc 中的前向渲染辅助函数
```
float3 WorldSpaceLightDir (float4 v) 输入一个模型空间中的顶点位置，返回世界空间中从该点到光源的光照方向（未标准化）。  
float3 ObjSpaceLightDir (float4 v)  输入一个模型空间中的顶点位置，返回模型空间中从该点到光源的光照方向（未标准化）。  
float3 Shade4PointLights (...)  计算来自四个点光源的照明，将光数据紧密打包到向量中。前向渲染使用它来计算逐顶点光照。  
```

UnityCG.cginc 中的屏幕空间辅助函数
```
float4 ComputeScreenPos (float4 clipPos) 计算纹理坐标以进行屏幕空间映射纹理样本。输入是裁剪空间位置。  
float4 ComputeGrabScreenPos (float4 clipPos) 计算用于采样GrabPass纹理的纹理坐标。输入是裁剪空间位置。  
```
UnityCG.cginc 中的顶点光照辅助函数
```
float3 ShadeVertexLights (float4 vertex, float3 normal)  在给定对象空间位置和法线的情况下，计算来自四个每个顶点灯​​光和环境的照明。  
```