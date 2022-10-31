using System;
using UnityEngine;

namespace UnityStandardAssets.ImageEffects
{
    
    // 用于执行各种基于图像的渲染任务的实用工具类。
    /// A Utility class for performing various image based rendering tasks.
    [AddComponentMenu("")]
    public class ImageEffectsHelper
    {
        public static void RenderDistortion(Material material, RenderTexture source, RenderTexture destination, float angle, Vector2 center, Vector2 radius)
        {
            bool invertY = source.texelSize.y < 0.0f;
            if (invertY)
            {
                center.y = 1.0f - center.y;
                angle = -angle;
            }

            Matrix4x4 rotationMatrix = Matrix4x4.TRS(Vector3.zero, Quaternion.Euler(0, 0, angle), Vector3.one);

            material.SetMatrix("_RotationMatrix", rotationMatrix);
            material.SetVector("_CenterRadius", new Vector4(center.x, center.y, radius.x, radius.y));
            material.SetFloat("_Angle", angle*Mathf.Deg2Rad);

            Graphics.Blit(source, destination, material);
        }
    }
}
