using UnityEngine;
using System.Collections;

// 高斯模糊
public class GaussianBlur : PostEffectsBase
{
    public Shader gaussianBlurShader;
    private Material gaussianBlurMaterial = null;

    public Material material
    {
        get
        {
            gaussianBlurMaterial = CheckShaderAndCreateMaterial(gaussianBlurShader, gaussianBlurMaterial);
            return gaussianBlurMaterial;
        }
    }

    // 模糊迭代-较大的数字意味着更多的模糊。
    [Range(0, 4)] public int iterations = 3;

    // 每次迭代的模糊扩散-值越大表示模糊越大
    [Range(0.2f, 3.0f)] public float blurSpread = 0.6f;

    [Range(1, 8)] public int downSample = 2; // 降采样系数 减少需要处理的像素个数,提高性能
    // 适当的降采样 有时候能得到更好的效果, 过大的值可能导致图像像素化

    // 1st edition: just apply blur
    // void OnRenderImage(RenderTexture src, RenderTexture dest)
    // {
    //     if (material != null)
    //     {
    //         int rtW = src.width;
    //         int rtH = src.height;
    //         RenderTexture buffer = RenderTexture.GetTemporary(rtW, rtH, 0);
    //
    //         // Render the vertical pass
    //         Graphics.Blit(src, buffer, material, 0);
    //         // Render the horizontal pass
    //         Graphics.Blit(buffer, dest, material, 1);
    //
    //         RenderTexture.ReleaseTemporary(buffer);
    //     }
    //     else
    //     {
    //         Graphics.Blit(src, dest);
    //     }
    // }

    // 2nd edition: scale the render texture
	// void OnRenderImage (RenderTexture src, RenderTexture dest) {
	// 	if (material != null) {
	// 		int rtW = src.width/downSample;
	// 		int rtH = src.height/downSample;
	// 		RenderTexture buffer = RenderTexture.GetTemporary(rtW, rtH, 0);
	// 		buffer.filterMode = FilterMode.Bilinear;
	//
	// 		// Render the vertical pass
	// 		Graphics.Blit(src, buffer, material, 0);
	// 		// Render the horizontal pass
	// 		Graphics.Blit(buffer, dest, material, 1);
	//
	// 		RenderTexture.ReleaseTemporary(buffer);
	// 	} else {
	// 		Graphics.Blit(src, dest);
	// 	}
	// }

     // 3rd edition: use iterations for larger blur
     void OnRenderImage(RenderTexture src, RenderTexture dest)
     {
         if (material != null)
         {
             int rtW = src.width / downSample;
             int rtH = src.height / downSample;
    
             // 分配一块与屏幕图像大小相同的缓冲区
             RenderTexture buffer0 = RenderTexture.GetTemporary(rtW, rtH, 0);
             buffer0.filterMode = FilterMode.Bilinear; // 渲染纹理的滤波模式设置为双线性
    
             Graphics.Blit(src, buffer0);
    
             // 迭代交替临时缓存
             for (int i = 0; i < iterations; i++)
             {
                 material.SetFloat("_BlurSize", 1.0f + i * blurSpread);
    
                 RenderTexture buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);
    
                 // Render the vertical pass
                 Graphics.Blit(buffer0, buffer1, material, 0);
    
                 RenderTexture.ReleaseTemporary(buffer0);
                 buffer0 = buffer1;
                 buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);
    
                 // Render the horizontal pass
                 Graphics.Blit(buffer0, buffer1, material, 1);
    
                 RenderTexture.ReleaseTemporary(buffer0);
                 buffer0 = buffer1;
             }
    
             Graphics.Blit(buffer0, dest);
             RenderTexture.ReleaseTemporary(buffer0); // 释放缓冲区
         }
         else
         {
             Graphics.Blit(src, dest);
         }
     }
}