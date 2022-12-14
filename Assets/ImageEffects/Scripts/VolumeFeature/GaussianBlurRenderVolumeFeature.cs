using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;


namespace ImageEffects
{
    public class GaussianBlurRenderVolumeFeature : ScriptableRendererFeature
    {
        // 创建可编写脚本的渲染通道
        class GaussianBlurRenderVolumePass : ScriptableRenderPass
        {
            Settings settings;

            RenderTargetIdentifier source;
            RenderTargetIdentifier destinationA;
            RenderTargetIdentifier destinationB;
            
            readonly int temporaryRTIdA = Shader.PropertyToID("GaussianBlur_TempRTA");
            readonly int temporaryRTIdB = Shader.PropertyToID("GaussianBlur_TempRTB");


            static class ShaderIDs
            {
                internal static readonly int blurRadius = Shader.PropertyToID("_BlurOffset");
               
            }

            public GaussianBlurRenderVolumePass(Settings customSettings)
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
                    Debug.LogError("GaussianBlur instance is null");
                    return;
                }

                CommandBuffer cmd = CommandBufferPool.Get("GaussianBlur");
                cmd.Clear();

                // 这将保存所有当前卷信息
                var stack = VolumeManager.instance.stack;

                var customEffect = stack.GetComponent<GaussianBlurComponent>();
                int RTHeight = (int) (renderingData.cameraData.camera.scaledPixelHeight /
                                     customEffect.rTDownScaling.value);
                int RTWidth = (int) (renderingData.cameraData.camera.scaledPixelWidth /
                                             customEffect.rTDownScaling.value);
                cmd.GetTemporaryRT(temporaryRTIdA, RTWidth, RTHeight, 0, FilterMode.Bilinear);
                destinationA = new RenderTargetIdentifier(temporaryRTIdA);
                cmd.GetTemporaryRT(temporaryRTIdB, RTWidth, RTHeight, 0, FilterMode.Bilinear);
                destinationB = new RenderTargetIdentifier(temporaryRTIdB);
                cmd.Blit(source, destinationA);
                for (int i = 0; i < customEffect.iteration.value; i++)
                {
                    material.SetVector(ShaderIDs.blurRadius,
                        new Vector4(
                            customEffect.blurRadius.value / renderingData.cameraData.camera.scaledPixelWidth, 0, 0,
                            0));
                    cmd.Blit(destinationA, destinationB, material, 0);

                    material.SetVector(ShaderIDs.blurRadius,
                        new Vector4(0,
                            customEffect.blurRadius.value / renderingData.cameraData.camera.scaledPixelHeight, 0,
                            0));
                    cmd.Blit(destinationB, destinationA, material, 0);
                }
                cmd.Blit(destinationA, source);

                context.ExecuteCommandBuffer(cmd);
                CommandBufferPool.Release(cmd);
            }

            // 当我们不再需要时，清理临时RT
            public override void OnCameraCleanup(CommandBuffer cmd)
            {
                cmd.ReleaseTemporaryRT(temporaryRTIdA);
                cmd.ReleaseTemporaryRT(temporaryRTIdB);
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
                        m_shader = Shader.Find("Hidden/ImageEffects/GaussianBlur");
                    }

                    return m_shader;
                }
            }
        }

        public Settings settings = new Settings();
        private GaussianBlurRenderVolumePass _scriptablePass;

        // Unity 在以下事件上调用此方法：
        //渲染器功能第一次加载时。
        //当您启用或禁用渲染器功能时。
        //当您在渲染器功能的检查器中更改属性时。
        public override void Create()
        {
            _scriptablePass = new GaussianBlurRenderVolumePass(settings);
        }


        // Unity每帧调用一次这个方法，每个Camera调用一次。此方法允许您将ScriptableRenderPass实例注入到可编写脚本的渲染器中。
        public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
        {
            var stack = VolumeManager.instance.stack;
            var customEffect = stack.GetComponent<GaussianBlurComponent>();
            if (customEffect.IsActive()) renderer.EnqueuePass(_scriptablePass);  // 在渲染队列中入队
        }
    }
}