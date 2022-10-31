using System;
using UnityEngine;


// 油画
namespace UnityStandardAssets.ImageEffects
{
    [ExecuteInEditMode]
    [RequireComponent(typeof (Camera))]
    [AddComponentMenu("Image Effects/Other/OliPaint")]
    public class OliPaint : ImageEffectBase
    {
        
        [Range(0, 10)] public int Radius = 3;

        private void Awake()
        {
            SetShader("Hidden/OilPaint");
        }

        void OnRenderImage(RenderTexture source, RenderTexture destination)
        {
            if (material != null)
            {
                material.SetInt("_Radius", Radius);
                material.SetVector("_PSize", new Vector2(1f / (float) source.width, 1f / (float) source.height));

                //  src 纹理会传递给shader 中名为 _MainTex 的纹理属性 参数 pass 默认 -1 表示一次调用 pass , 否则只会调用指定索引的pass
                Graphics.Blit(source, destination, material);
            }
            else
            {
                Graphics.Blit(source, destination);
            }
        }
    }
}