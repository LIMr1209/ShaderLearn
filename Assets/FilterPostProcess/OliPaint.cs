using UnityEngine;


// 赛博朋克滤镜1
public class OliPaint : PostEffectsBase
{
    public Shader OliPaintShader;
    private Material OliPaintMaterial;

    public Material material
    {
        get
        {
            OliPaintMaterial = CheckShaderAndCreateMaterial(OliPaintShader, OliPaintMaterial);
            return OliPaintMaterial;
        }
    }

    [Range(0, 10)] public int Radius = 3;


    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (material != null)
        {
            material.SetInt("_Radius", Radius);
            material.SetVector("_PSize", new Vector2(1f / (float) src.width, 1f / (float) src.height));

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