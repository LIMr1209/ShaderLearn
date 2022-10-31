using System;
using UnityEngine;


// 赛博朋克滤镜1
namespace UnityStandardAssets.ImageEffects
{
    [ExecuteInEditMode]
    [RequireComponent(typeof (Camera))]
    [AddComponentMenu("Image Effects/Other/Cyberpunk1")]
    public class Cyberpunk1 : ImageEffectBase
    {
        [Range(0.0f, 1.0f)] public float pow = 1.0f;

        private void Awake()
        {
            SetShader("Hidden/Cyberpunk1");
        }

        void OnRenderImage(RenderTexture src, RenderTexture dest)
        {
            if (material != null)
            {
                material.SetFloat("_Power", pow);

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
