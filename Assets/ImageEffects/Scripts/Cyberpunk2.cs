using System;
using UnityEngine;


// 赛博朋克滤镜2
namespace UnityStandardAssets.ImageEffects
{
    [ExecuteInEditMode]
    [RequireComponent(typeof (Camera))]
    [AddComponentMenu("Image Effects/Other/Cyberpunk2")]
    public class Cyberpunk2 : ImageEffectBase
    {
        [Range(-1.0f, 0.5f)] public float red = 0;
        [Range(-0.5f, 0.5f)] public float orange = 0;
        [Range(-0.5f, 1.0f)] public float yellow = 0;
        [Range(-1.0f, 1.0f)] public float green = 0;
        [Range(-1.0f, 1.0f)] public float cyan = 0;
        [Range(-1.0f, 0.5f)] public float blue = 0;
        [Range(-0.5f, 0.5f)] public float purple = 0;
        [Range(-0.5f, 1.0f)] public float magenta = 0;
    
        [Range(1.0f, 10.0f)] public float pow = 0;
    
        [Range(0.0f, 2.0f)] public float value = 0;

        private void Awake()
        {
            SetShader("Hidden/Cyberpunk2");
        }

        void OnRenderImage(RenderTexture src, RenderTexture dest)
        {
            if (material != null)
            {
                material.SetFloat("_Red", red);
                material.SetFloat("_Orange", orange);
                material.SetFloat("_Yellow", yellow);
                material.SetFloat("_Green", green);
                material.SetFloat("_Cyan", cyan);
                material.SetFloat("_Blue", blue);
                material.SetFloat("_Purple", purple);
                material.SetFloat("_Magenta", magenta);
                
                
                material.SetFloat("_Power", pow);
                material.SetFloat("_Value", value);
    
                //  src 纹理会传递给shader 中名为 _MainTex 的纹理属性 参数 pass 默认 -1 表示一次调用 pass , 否则只会调用指定索引的pass
                Graphics.Blit(src, dest, material);
            }
            else
            {
                // 没有材质 会直接把源图像 显示到屏幕上
                Graphics.Blit(src, dest);
            }
        }
    }
}
