using UnityEngine;
using System.Collections;

[ExecuteInEditMode] // 编辑器模式下也可以使用此脚本
[RequireComponent(typeof(Camera))] // 依赖相机组件
public class PostEffectsBase : MonoBehaviour
{
    // start 检查资源和条件是否满足
    protected void CheckResources()
    {
        bool isSupported = CheckSupport();

        if (isSupported == false)
        {
            NotSupported();
        }
    }

    // 检查资源和条件是否满足
    protected bool CheckSupport()
    {
        // // 检查 此平台是否支持支持图像效果或渲染纹理  过时
        // if (SystemInfo.supportsImageEffects == false || SystemInfo.supportsRenderTextures == false)
        // {
        //     Debug.LogWarning("This platform does not support image effects or render textures.");
        //     return false;
        // }

        return true;
    }

    // 不支持 禁用组件
    protected void NotSupported()
    {
        enabled = false;
    }

    protected void Start()
    {
        CheckResources();
    }

    // 检查shader 并 创建 material
    protected Material CheckShaderAndCreateMaterial(Shader shader, Material material)
    {
        if (shader == null)
        {
            return null;
        }

        if (shader.isSupported && material && material.shader == shader)
            return material;

        if (!shader.isSupported)
        {
            return null;
        }
        else
        {
            material = new Material(shader);
            material.hideFlags = HideFlags.DontSave;
            if (material)
                return material;
            else
                return null;
        }
    }
}