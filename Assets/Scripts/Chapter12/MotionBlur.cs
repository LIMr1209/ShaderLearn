using UnityEngine;
using System.Collections;

// 运动模糊
public class MotionBlur : PostEffectsBase
{
    public Shader motionBlurShader;
    private Material motionBlurMaterial = null;

    public Material material
    {
        get
        {
            motionBlurMaterial = CheckShaderAndCreateMaterial(motionBlurShader, motionBlurMaterial);
            return motionBlurMaterial;
        }
    }

    // 在混合图像时使用的模糊参数 越大 运动拖尾效果越明显
    [Range(0.0f, 0.9f)] public float blurAmount = 0.5f;

    // 保存之前图像叠加的结果
    private RenderTexture accumulationTexture;

    void OnDisable()
    {
        DestroyImmediate(accumulationTexture);
    }

    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (material != null)
        {
            // 创建纹理
            if (accumulationTexture == null || accumulationTexture.width != src.width ||
                accumulationTexture.height != src.height)
            {
                DestroyImmediate(accumulationTexture);
                accumulationTexture = new RenderTexture(src.width, src.height, 0);
                accumulationTexture.hideFlags = HideFlags.HideAndDontSave; // 由于我们自己控制变量的效果，所以设置 HideAndDontSave
                Graphics.Blit(src, accumulationTexture); // 初始化纹理
            }

            // We are accumulating motion over frames without clear/discard
            // by design, so silence any performance warnings from Unity
            // accumulationTexture.MarkRestoreExpected();

            material.SetFloat("_BlurAmount", 1.0f - blurAmount);

            // 每次调用把当前的帧图像和 accumulationTexture 中的图像混合
            Graphics.Blit(src, accumulationTexture, material);
            Graphics.Blit(accumulationTexture, dest);
        }
        else
        {
            Graphics.Blit(src, dest);
        }
    }
}