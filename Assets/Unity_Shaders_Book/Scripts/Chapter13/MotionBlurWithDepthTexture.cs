using UnityEngine;
using System.Collections;


// 运动模糊
public class MotionBlurWithDepthTexture : PostEffectsBase
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

    private Camera myCamera;

    public Camera thisCamera
    {
        get
        {
            if (myCamera == null)
            {
                myCamera = GetComponent<Camera>();
            }

            return myCamera;
        }
    }

    [Range(0.0f, 1.0f)] public float blurSize = 0.5f; // 定义运动模糊时模糊图像使用的大小

    private Matrix4x4 previousViewProjectionMatrix; // 保存上一帧摄像机的视角*投影矩阵

    void OnEnable()
    {
        thisCamera.depthTextureMode |= DepthTextureMode.Depth;

        // projectionMatrix 投影矩阵  worldToCameraMatrix 从世界转换到相机空间的矩阵,  视角矩阵
        previousViewProjectionMatrix = thisCamera.projectionMatrix * thisCamera.worldToCameraMatrix;
    }

    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (material != null)
        {
            material.SetFloat("_BlurSize", blurSize);

            material.SetMatrix("_PreviousViewProjectionMatrix", previousViewProjectionMatrix);
            // 当前帧的 视角*投影矩阵
            Matrix4x4 currentViewProjectionMatrix = thisCamera.projectionMatrix * thisCamera.worldToCameraMatrix;
            Matrix4x4 currentViewProjectionInverseMatrix = currentViewProjectionMatrix.inverse; // 逆矩阵
            material.SetMatrix("_CurrentViewProjectionInverseMatrix", currentViewProjectionInverseMatrix);
            previousViewProjectionMatrix = currentViewProjectionMatrix;

            Graphics.Blit(src, dest, material);
        }
        else
        {
            Graphics.Blit(src, dest);
        }
    }
}