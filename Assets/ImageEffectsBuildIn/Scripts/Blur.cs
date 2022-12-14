using System;
using UnityEngine;

// 模糊
namespace UnityStandardAssets.ImageEffects
{
    [ExecuteInEditMode]
    [AddComponentMenu("Image Effects/Blur/Blur")]
    public class Blur : ImageEffectBase
    {
        /// Blur iterations - larger number means more blur.
        [Range(0,10)]
        public int iterations = 3;

        /// Blur spread for each iteration. Lower values
        /// give better looking blur, but require more iterations to
        /// get large blurs. Value is usually between 0.5 and 1.0.
        [Range(0.0f,1.0f)]
        public float blurSpread = 0.6f;

        // Performs one blur iteration.
        public void FourTapCone (RenderTexture source, RenderTexture dest, int iteration)
        {
            float off = 0.5f + iteration*blurSpread;
            Graphics.BlitMultiTap (source, dest, material,
                                   new Vector2(-off, -off),
                                   new Vector2(-off,  off),
                                   new Vector2( off,  off),
                                   new Vector2( off, -off)
                );
        }

        // Downsamples the texture to a quarter resolution.
        private void DownSample4x (RenderTexture source, RenderTexture dest)
        {
            float off = 1.0f;
            Graphics.BlitMultiTap (source, dest, material,
                                   new Vector2(-off, -off),
                                   new Vector2(-off,  off),
                                   new Vector2( off,  off),
                                   new Vector2( off, -off)
                );
        }

        private void Awake()
        {
            SetShader("Hidden/BlurEffectConeTap");
        }

        // Called by the camera to apply the image effect
        void OnRenderImage (RenderTexture source, RenderTexture destination) {
            int rtW = source.width/4;
            int rtH = source.height/4;
            RenderTexture buffer = RenderTexture.GetTemporary(rtW, rtH, 0);

            // Copy source to the 4x4 smaller texture.
            DownSample4x (source, buffer);

            // Blur the small texture
            for(int i = 0; i < iterations; i++)
            {
                RenderTexture buffer2 = RenderTexture.GetTemporary(rtW, rtH, 0);
                FourTapCone (buffer, buffer2, i);
                RenderTexture.ReleaseTemporary(buffer);
                buffer = buffer2;
            }
            Graphics.Blit(buffer, destination);

            RenderTexture.ReleaseTemporary(buffer);
        }
    }
}
