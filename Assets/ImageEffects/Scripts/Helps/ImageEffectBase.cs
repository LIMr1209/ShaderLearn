using System;
using UnityEngine;

namespace UnityStandardAssets.ImageEffects
{
    [RequireComponent(typeof (Camera))]
    [AddComponentMenu("")]
    public class ImageEffectBase : MonoBehaviour
    {
        public Shader shader;

        private Material m_Material;

        protected void SetShader(string shaderName)
        {
            if (!shader)
            {
                shader = Shader.Find(shaderName);
            }
        }


        protected virtual void Start()
        {
            // // Disable if we don't support image effects
            // if (!SystemInfo.supportsImageEffects)
            // {
            //     enabled = false;
            //     return;
            // }
            // 如果着色器无法在用户图形卡上运行，则禁用图像效果
            if (!shader || !shader.isSupported)
                enabled = false;
        }
        

        protected Material material
        {
            get
            {
                if (m_Material == null)
                {
                    m_Material = new Material(shader);
                    m_Material.hideFlags = HideFlags.HideAndDontSave;
                }
                return m_Material;
            }
        }


        protected virtual void OnDisable()
        {
            if (m_Material)
            {
                DestroyImmediate(m_Material);
            }
        }
    }
}
