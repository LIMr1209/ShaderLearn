using UnityEngine;
using System.Collections;

// 边缘检测 
public class EdgeDetectNormalsAndDepth : PostEffectsBase
{
    public Shader edgeDetectShader;
    private Material edgeDetectMaterial = null;

    public Material material
    {
        get
        {
            edgeDetectMaterial = CheckShaderAndCreateMaterial(edgeDetectShader, edgeDetectMaterial);
            return edgeDetectMaterial;
        }
    }

    [Range(0.0f, 1.0f)] public float edgesOnly = 0.0f;

    public Color edgeColor = Color.black; // 边缘颜色

    public Color backgroundColor = Color.white; // 背景颜色

    public float sampleDistance = 1.0f; // 采样距离 

    public float sensitivityDepth = 1.0f; // 深度灵敏度

    public float sensitivityNormals = 1.0f; // 法线灵敏度

    void OnEnable()
    {
        GetComponent<Camera>().depthTextureMode |= DepthTextureMode.DepthNormals;
    }

    // 默认情况下 OnRenderImage 会在所有不透明和透明的Pass 执行完毕调用
    // ImageEffectOpaque 会在不透明的Pass 执行完毕 立即调用OnRenderImage
    [ImageEffectOpaque]
    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (material != null)
        {
            material.SetFloat("_EdgeOnly", edgesOnly);
            material.SetColor("_EdgeColor", edgeColor);
            material.SetColor("_BackgroundColor", backgroundColor);
            material.SetFloat("_SampleDistance", sampleDistance);
            material.SetVector("_Sensitivity", new Vector4(sensitivityNormals, sensitivityDepth, 0.0f, 0.0f));

            Graphics.Blit(src, dest, material);
        }
        else
        {
            Graphics.Blit(src, dest);
        }
    }
}