using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;


namespace ImageEffects
{
    public class FogWithNoiseRenderVolumeFeature : ScriptableRendererFeature
    {
        // 创建可编写脚本的渲染通道
        class FogWithNoiseRenderVolumePass : ScriptableRenderPass
        {
            Settings settings;

            RenderTargetIdentifier source;

            static class ShaderIDs
            {
                internal static readonly int noiseTex = Shader.PropertyToID("_NoiseTex");
                internal static readonly int fogColor = Shader.PropertyToID("_FogColor");
                internal static readonly int fogDensity = Shader.PropertyToID("_FogDensity");
                internal static readonly int frustumCornersRay = Shader.PropertyToID("_FrustumCornersRay");
                internal static readonly int fogStart = Shader.PropertyToID("_FogStart");
                internal static readonly int fogEnd = Shader.PropertyToID("_FogEnd");
                internal static readonly int fogXSpeed = Shader.PropertyToID("_FogXSpeed");
                internal static readonly int fogYSpeed = Shader.PropertyToID("_FogYSpeed");
                internal static readonly int noiseAmount = Shader.PropertyToID("_NoiseAmount");
            }

            public FogWithNoiseRenderVolumePass(Settings customSettings)
            {
                settings = customSettings;
                renderPassEvent = RenderPassEvent.BeforeRenderingPostProcessing;
            }

            public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
            {
                // 抓取相机目标描述符。我们将在创建临时渲染纹理时使用此选项。
                RenderTextureDescriptor descriptor = renderingData.cameraData.cameraTargetDescriptor;
                descriptor.depthBufferBits = 0;

                var renderer = renderingData.cameraData.renderer;
                source = renderer.cameraColorTarget;

            }

            // 过程的实际执行。这是进行自定义渲染的地方。
            public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
            {
                // 跳过场景视图中的后期处理渲染
                if (renderingData.cameraData.isSceneViewCamera)
                    return;


                var material = settings.material;
                if (material == null)
                {
                    Debug.LogError("FogWithNoise Materials instance is null");
                    return;
                }

                CommandBuffer cmd = CommandBufferPool.Get("FogWithNoise");
                cmd.Clear();

                // 这将保存所有当前卷信息
                var stack = VolumeManager.instance.stack;

                var customEffect = stack.GetComponent<FogWithNoiseComponent>();
                Camera camera = renderingData.cameraData.camera;
                Transform cameraTransform = camera.transform;
                Matrix4x4 frustumCorners = Matrix4x4.identity;

                float fov = camera.fieldOfView;
                float near = camera.nearClipPlane;
                float aspect = camera.aspect;

                float halfHeight = near * Mathf.Tan(fov * 0.5f * Mathf.Deg2Rad);
                Vector3 toRight = cameraTransform.right * halfHeight * aspect;
                Vector3 toTop = cameraTransform.up * halfHeight;

                Vector3 topLeft = cameraTransform.forward * near + toTop - toRight;
                float scale = topLeft.magnitude / near;

                topLeft.Normalize();
                topLeft *= scale;

                Vector3 topRight = cameraTransform.forward * near + toRight + toTop;
                topRight.Normalize();
                topRight *= scale;

                Vector3 bottomLeft = cameraTransform.forward * near - toTop - toRight;
                bottomLeft.Normalize();
                bottomLeft *= scale;

                Vector3 bottomRight = cameraTransform.forward * near + toRight - toTop;
                bottomRight.Normalize();
                bottomRight *= scale;

                frustumCorners.SetRow(0, bottomLeft);
                frustumCorners.SetRow(1, bottomRight);
                frustumCorners.SetRow(2, topRight);
                frustumCorners.SetRow(3, topLeft);

                material.SetMatrix(ShaderIDs.frustumCornersRay, frustumCorners);

                material.SetFloat(ShaderIDs.fogDensity, customEffect.fogDensity.value);
                material.SetColor(ShaderIDs.fogColor, customEffect.fogColor.value);
                material.SetFloat(ShaderIDs.fogStart, customEffect.fogStart.value);
                material.SetFloat(ShaderIDs.fogEnd, customEffect.fogEnd.value);

                if (settings.noiseTex != null)
                {
                    material.SetTexture(ShaderIDs.noiseTex, settings.noiseTex);
                }

                material.SetFloat(ShaderIDs.fogXSpeed, customEffect.fogXSpeed.value);
                material.SetFloat(ShaderIDs.fogYSpeed, customEffect.fogYSpeed.value);
                material.SetFloat(ShaderIDs.noiseAmount, customEffect.noiseAmount.value);

                // 完成！现在我们已经处理了所有自定义效果，将最终结果应用到相机
                Blit(cmd, source, source, material, 0);

                context.ExecuteCommandBuffer(cmd);
                CommandBufferPool.Release(cmd);
            }

            // 当我们不再需要时，清理临时RT
            public override void OnCameraCleanup(CommandBuffer cmd)
            {
            }
        }

        [System.Serializable]
        public class Settings
        {
            private Shader m_shader;

            private Material m_Material;

            private Texture2D m_noiseTex;

            public Material material
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

            public Shader shader
            {
                get
                {
                    if (m_shader == null)
                    {
                        m_shader = Shader.Find("Hidden/ImageEffects/FogWithNoise");
                    }

                    return m_shader;
                }
            }

            public Texture noiseTex
            {
                get
                {
                    if (m_noiseTex == null)
                    {
                        m_noiseTex = Resources.Load<Texture2D>("Textures/fog_noise");
                    }

                    return m_noiseTex;
                }
            }
        }

        public Settings settings = new Settings();
        private FogWithNoiseRenderVolumePass _scriptablePass;

        // Unity 在以下事件上调用此方法：
        //渲染器功能第一次加载时。
        //当您启用或禁用渲染器功能时。
        //当您在渲染器功能的检查器中更改属性时。
        public override void Create()
        {
            _scriptablePass = new FogWithNoiseRenderVolumePass(settings);
        }


        // Unity每帧调用一次这个方法，每个Camera调用一次。此方法允许您将ScriptableRenderPass实例注入到可编写脚本的渲染器中。
        public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
        {
            var stack = VolumeManager.instance.stack;
            var customEffect = stack.GetComponent<FogWithNoiseComponent>();
            if (customEffect.IsActive()) renderer.EnqueuePass(_scriptablePass); // 在渲染队列中入队
        }
    }
}