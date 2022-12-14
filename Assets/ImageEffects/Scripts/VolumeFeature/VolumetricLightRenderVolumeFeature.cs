using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace ImageEffects
{
    public class VolumetricLightRenderVolumeFeature : ScriptableRendererFeature
    {
        // 创建可编写脚本的渲染通道
        class VolumetricLightRenderVolumePass : ScriptableRenderPass
        {
            Settings settings;

            RenderTargetIdentifier source;
            RenderTargetIdentifier destinationA;
            RenderTargetIdentifier latestDest;
            

            private FilteringSettings filteringSettings = new FilteringSettings(RenderQueueRange.opaque);
            private readonly List<ShaderTagId> shaderTagIdList = new List<ShaderTagId>();
            
            readonly int temporaryRTIdA = Shader.PropertyToID("_TempRT");

            static class ShaderIDs
            {
                internal static readonly int center = Shader.PropertyToID("_Center");
                internal static readonly int intensity = Shader.PropertyToID("_Intensity");
                internal static readonly int blurWidth = Shader.PropertyToID("_BlurWidth");
            }
            

            public VolumetricLightRenderVolumePass(Settings customSettings)
            {
                settings = customSettings;
                renderPassEvent = RenderPassEvent.BeforeRenderingPostProcessing;
                shaderTagIdList.Add(new ShaderTagId("UniversalForward"));
                shaderTagIdList.Add(new ShaderTagId("UniversalForwardOnly"));
                shaderTagIdList.Add(new ShaderTagId("LightweightForward"));
                shaderTagIdList.Add(new ShaderTagId("SRPDefaultUnlit"));
            }


            public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
            {
                // 抓取相机目标描述符。我们将在创建临时渲染纹理时使用此选项。
                RenderTextureDescriptor descriptor = renderingData.cameraData.cameraTargetDescriptor;
                descriptor.depthBufferBits = 0;
                descriptor.width = Mathf.RoundToInt(descriptor.width * settings.resolutionScale);
                descriptor.height = Mathf.RoundToInt(descriptor.height * settings.resolutionScale);
                
                var renderer = renderingData.cameraData.renderer;
                source = renderer.cameraColorTarget;
                
                // 使用上面的描述符创建临时渲染纹理。
                cmd.GetTemporaryRT(temporaryRTIdA, descriptor, FilterMode.Bilinear);
                destinationA = new RenderTargetIdentifier(temporaryRTIdA);
                ConfigureTarget(destinationA);
               
            }

            // 过程的实际执行。这是进行自定义渲染的地方。
            public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
            {
                // 跳过场景视图中的后期处理渲染
                // if (renderingData.cameraData.isSceneViewCamera)
                //     return;

                CommandBuffer cmd = CommandBufferPool.Get("VolumetricLight");
                cmd.Clear();

                // 这将保存所有当前卷信息
                var stack = VolumeManager.instance.stack;

                //从相机源开始
                latestDest = source;

                var customEffect = stack.GetComponent<VolumetricLightComponent>();
                // 仅在效果处于活动状态时处理
                if (customEffect.IsActive())
                {
                    Camera camera = renderingData.cameraData.camera;
                    context.DrawSkybox(camera);

                    DrawingSettings drawSettings = CreateDrawingSettings(shaderTagIdList, ref renderingData, SortingCriteria.CommonOpaque);
                    drawSettings.overrideMaterial = settings.occludersMaterial;

                    context.DrawRenderers(renderingData.cullResults, ref drawSettings, ref filteringSettings);

                    Vector3 sunDirectionWorldSpace = RenderSettings.sun.transform.forward;
                    Vector3 cameraPositionWorldSpace = camera.transform.position;
                    Vector3 sunPositionWorldSpace = cameraPositionWorldSpace + sunDirectionWorldSpace;
                    Vector3 sunPositionViewportSpace = camera.WorldToViewportPoint(sunPositionWorldSpace);

                    settings.radialBlurMaterial.SetVector(ShaderIDs.center, new Vector4(sunPositionViewportSpace.x, sunPositionViewportSpace.y, 0, 0));
                    settings.radialBlurMaterial.SetFloat(ShaderIDs.intensity, customEffect.intensity.value);
                    settings.radialBlurMaterial.SetFloat(ShaderIDs.blurWidth, customEffect.blurWidth.value);

                    Blit(cmd, destinationA, latestDest, settings.radialBlurMaterial);
                }

                // 完成！现在我们已经处理了所有自定义效果，将最终结果应用到相机
                Blit(cmd, latestDest, source);

                context.ExecuteCommandBuffer(cmd);
                CommandBufferPool.Release(cmd);
            }

            // 当我们不再需要时，清理临时RT
            public override void OnCameraCleanup(CommandBuffer cmd)
            {
                cmd.ReleaseTemporaryRT(temporaryRTIdA);
            }
        }

        [System.Serializable]
        public class Settings
        {
            [Range(0.1f, 1f)] public float resolutionScale = 0.5f;
            private Shader m_occludersShader;

            private Shader m_radialBlurShader;

            private Material m_occludersMaterial;

            private Material m_radialBlurMaterial;

            public Material occludersMaterial
            {
                get
                {
                    if (m_occludersMaterial == null)
                    {
                        m_occludersMaterial = new Material(occludersShader);
                        m_occludersMaterial.hideFlags = HideFlags.HideAndDontSave;
                    }

                    return m_occludersMaterial;
                }
            }

            public Material radialBlurMaterial
            {
                get
                {
                    if (m_radialBlurMaterial == null)
                    {
                        m_radialBlurMaterial = new Material(radialBlurShader);
                        m_radialBlurMaterial.hideFlags = HideFlags.HideAndDontSave;
                    }

                    return m_radialBlurMaterial;
                }
            }

            public Shader occludersShader
            {
                get
                {
                    if (m_occludersShader == null)
                    {
                        m_occludersShader = Shader.Find("Hidden/ImageEffects/UnlitColor");
                    }

                    return m_occludersShader;
                }
            }

            public Shader radialBlurShader
            {
                get
                {
                    if (m_radialBlurShader == null)
                    {
                        m_radialBlurShader = Shader.Find("Hidden/ImageEffects/RadialBlur");
                    }

                    return m_radialBlurShader;
                }
            }
        }

        public Settings settings = new Settings();

        private VolumetricLightRenderVolumePass _scriptablePass;


        // Unity 在以下事件上调用此方法：
        //渲染器功能第一次加载时。
        //当您启用或禁用渲染器功能时。
        //当您在渲染器功能的检查器中更改属性时。
        public override void Create()
        {
            _scriptablePass = new VolumetricLightRenderVolumePass(settings);
        }


        // Unity每帧调用一次这个方法，每个Camera调用一次。此方法允许您将ScriptableRenderPass实例注入到可编写脚本的渲染器中。
        public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
        {
            var stack = VolumeManager.instance.stack;
            var customEffect = stack.GetComponent<VolumetricLightComponent>();
            if (customEffect.IsActive()) renderer.EnqueuePass(_scriptablePass);  // 在渲染队列中入队
        }
    }
}