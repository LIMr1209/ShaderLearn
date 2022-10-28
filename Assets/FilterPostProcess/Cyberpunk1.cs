using UnityEngine;


// 赛博朋克滤镜1
public class Cyberpunk1 : PostEffectsBase
{
    public Shader CyberpunkShader;
    private Material CyberpunkMaterial;

    public Material material
    {
        get
        {
            CyberpunkMaterial = CheckShaderAndCreateMaterial(CyberpunkShader, CyberpunkMaterial);
            return CyberpunkMaterial;
        }
    }

    [Range(0.0f, 1.0f)] public float pow = 1.0f;


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