using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;


namespace ImageEffects                     
{
    public class CyberpunkRenderVolumeFeatureV1 : ScriptableRendererFeature
    {
        // 创建可编写脚本的渲染通道
        class CyberpunkRenderVolumePass : ScriptableRenderPass
        {
            Settings settings;

            RenderTargetIdentifier source;
            // RenderTargetIdentifier destinationA;
            // RenderTargetIdentifier destinationB;
            // RenderTargetIdentifier latestDest;

            // readonly int temporaryRTIdA = Shader.PropertyToID("_TempRTA");
            // readonly int temporaryRTIdB = Shader.PropertyToID("_TempRTB");

            public CyberpunkRenderVolumePass(Settings customSettings)
            {
                settings = customSettings;
                renderPassEvent = RenderPassEvent.BeforeRenderingPostProcessing;
            }

            public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
            {
                RenderTextureDescriptor descriptor = renderingData.cameraData.cameraTargetDescriptor;
                descriptor.depthBufferBits = 0;

                var renderer = renderingData.cameraData.renderer;
                source = renderer.cameraColorTarget;

                // cmd.GetTemporaryRT(temporaryRTIdA, descriptor, FilterMode.Bilinear);
                // destinationA = new RenderTargetIdentifier(temporaryRTIdA);
                // cmd.GetTemporaryRT(temporaryRTIdB, descriptor, FilterMode.Bilinear);
                // destinationB = new RenderTargetIdentifier(temporaryRTIdB);
            }

            public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
            {
                if (renderingData.cameraData.isSceneViewCamera)
                    return;

                var material = settings.material;
                if (material == null)
                {
                    Debug.LogError("Custom Post Processing Materials instance is null");
                    return;
                }

                CommandBuffer cmd = CommandBufferPool.Get("Cyberpunk V1");
                cmd.Clear();

                var stack = VolumeManager.instance.stack;

                // #region Local Methods
                //
                // void BlitTo(Material mat, int pass = 0)
                // {
                //     var first = latestDest;
                //     var last = first == destinationA ? destinationB : destinationA;
                //     Blit(cmd, first, last, mat, pass);
                //
                //     latestDest = last;
                // }
                //
                // #endregion
                //
                // latestDest = source;

                var customEffect = stack.GetComponent<CyberpunkComponentV1>();
                // if (customEffect.IsActive())
                // {
                //     material.SetFloat(Shader.PropertyToID("_Power"), customEffect.power.value);
                //
                //     BlitTo(material);
                // }
                
                material.SetFloat(Shader.PropertyToID("_Power"), customEffect.power.value);
                Blit(cmd, source, source, material, 0);

                // Blit(cmd, latestDest, source);

                context.ExecuteCommandBuffer(cmd);
                CommandBufferPool.Release(cmd);
            }

            public override void OnCameraCleanup(CommandBuffer cmd)
            {
                // cmd.ReleaseTemporaryRT(temporaryRTIdA);
                // cmd.ReleaseTemporaryRT(temporaryRTIdB);
            }
        }

        [System.Serializable]
        public class Settings
        {
            private Shader m_shader;

            private Material m_Material;

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
                        m_shader = Shader.Find("Hidden/ImageEffects/CyberpunkV1");
                    }

                    return m_shader;
                }
            }
        }

        public Settings settings = new Settings();
        private CyberpunkRenderVolumePass _scriptablePass;

        // Unity 在以下事件上调用此方法：
        //渲染器功能第一次加载时。
        //当您启用或禁用渲染器功能时。
        //当您在渲染器功能的检查器中更改属性时。
        public override void Create()
        {
            _scriptablePass = new CyberpunkRenderVolumePass(settings);
        }


        // Unity每帧调用一次这个方法，每个Camera调用一次。此方法允许您将ScriptableRenderPass实例注入到可编写脚本的渲染器中。
        public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
        {
            var stack = VolumeManager.instance.stack;
            var customEffect = stack.GetComponent<CyberpunkComponentV1>();
            if (customEffect.IsActive()) renderer.EnqueuePass(_scriptablePass);  // 在渲染队列中入队
        }
    }
}