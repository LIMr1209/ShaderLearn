using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;


namespace ImageEffects                     
{
    public class CyberpunkRenderVolumeFeatureV2 : ScriptableRendererFeature
    {
        // 创建可编写脚本的渲染通道
        class CyberpunkRenderVolumePass : ScriptableRenderPass
        {
            Settings settings;

            RenderTargetIdentifier source;

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

                CommandBuffer cmd = CommandBufferPool.Get("Cyberpunk V2");
                cmd.Clear();

                var stack = VolumeManager.instance.stack;

                var customEffect = stack.GetComponent<CyberpunkComponentV2>();
                
                
                material.SetFloat(Shader.PropertyToID("_Power"), customEffect.power.value);
                material.SetFloat(Shader.PropertyToID("_Value"), customEffect.value.value);
                material.SetFloat(Shader.PropertyToID("_Red"), customEffect.red.value);
                material.SetFloat(Shader.PropertyToID("_Orange"), customEffect.orange.value);
                material.SetFloat(Shader.PropertyToID("_Yellow"), customEffect.yellow.value);
                material.SetFloat(Shader.PropertyToID("_Green"), customEffect.green.value);
                material.SetFloat(Shader.PropertyToID("_Cyan"), customEffect.cyan.value);
                material.SetFloat(Shader.PropertyToID("_Blue"), customEffect.blue.value);
                material.SetFloat(Shader.PropertyToID("_Purple"), customEffect.purple.value);
                material.SetFloat(Shader.PropertyToID("_Magenta"), customEffect.magenta.value);

                Blit(cmd, source, source, material, 0);

                context.ExecuteCommandBuffer(cmd);
                CommandBufferPool.Release(cmd);
            }

            public override void OnCameraCleanup(CommandBuffer cmd)
            {
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
                        m_shader = Shader.Find("Hidden/ImageEffects/CyberpunkV2");
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
            var customEffect = stack.GetComponent<CyberpunkComponentV2>();
            if (customEffect.IsActive()) renderer.EnqueuePass(_scriptablePass);  // 在渲染队列中入队
        }
    }
}