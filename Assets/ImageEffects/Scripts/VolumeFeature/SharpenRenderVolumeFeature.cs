using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;


namespace ImageEffects
{
    public class SharpenRenderVolumeFeature : ScriptableRendererFeature
    {
        // 创建可编写脚本的渲染通道
        class SharpenRenderVolumePass : ScriptableRenderPass
        {
            Settings settings;

            RenderTargetIdentifier source;

            static class ShaderIDs
            {
                internal static readonly int centralFactor = Shader.PropertyToID("_CentralFactor");
                internal static readonly int sideFactor = Shader.PropertyToID("_SideFactor");
            }

            public SharpenRenderVolumePass(Settings customSettings)
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
                    Debug.LogError("Sharpen Materials instance is null");
                    return;
                }

                CommandBuffer cmd = CommandBufferPool.Get("Sharpen");
                cmd.Clear();

                // 这将保存所有当前卷信息
                var stack = VolumeManager.instance.stack;

                var customEffect = stack.GetComponent<SharpenComponent>();
                material.SetFloat(ShaderIDs.centralFactor, 1.0f + 3.2f * customEffect.sharpness.value);
                material.SetFloat(ShaderIDs.sideFactor, 0.8f * customEffect.sharpness.value);

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
                        m_shader = Shader.Find("Hidden/ImageEffects/Sharpen");
                    }

                    return m_shader;
                }
            }
        }

        public Settings settings = new Settings();
        private SharpenRenderVolumePass _scriptablePass;

        // Unity 在以下事件上调用此方法：
        //渲染器功能第一次加载时。
        //当您启用或禁用渲染器功能时。
        //当您在渲染器功能的检查器中更改属性时。
        public override void Create()
        {
            _scriptablePass = new SharpenRenderVolumePass(settings);
        }


        // Unity每帧调用一次这个方法，每个Camera调用一次。此方法允许您将ScriptableRenderPass实例注入到可编写脚本的渲染器中。
        public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
        {
            var stack = VolumeManager.instance.stack;
            var customEffect = stack.GetComponent<SharpenComponent>();
            if (customEffect.IsActive()) renderer.EnqueuePass(_scriptablePass); // 在渲染队列中入队
        }
    }
}