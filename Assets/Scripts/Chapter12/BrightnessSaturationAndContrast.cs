using UnityEngine;
using System.Collections;


// 调整屏幕 亮度 饱和度 和对比度
public class BrightnessSaturationAndContrast : PostEffectsBase
{
    public Shader briSatConShader;
    private Material briSatConMaterial;

    public Material material
    {
        get
        {
            briSatConMaterial = CheckShaderAndCreateMaterial(briSatConShader, briSatConMaterial);
            return briSatConMaterial;
        }
    }

    [Range(0.0f, 3.0f)] public float brightness = 1.0f;

    [Range(0.0f, 3.0f)] public float saturation = 1.0f;

    [Range(0.0f, 3.0f)] public float contrast = 1.0f;

    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (material != null)
        {
            material.SetFloat("_Brightness", brightness);
            material.SetFloat("_Saturation", saturation);
            material.SetFloat("_Contrast", contrast);

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