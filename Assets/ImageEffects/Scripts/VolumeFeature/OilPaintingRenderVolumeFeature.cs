using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
using UnityEngine.Rendering.Universal.Internal;


namespace ImageEffects
{
    public class OilPaintingRenderVolumeFeature : ScriptableRendererFeature
    {
        // 创建可编写脚本的渲染通道
        class OilPaintingRenderVolumePass : ScriptableRenderPass
        {
            private readonly Material structureTensorMaterial;
            private readonly Material kuwaharaFilterMaterial;
            private readonly Material lineIntegralConvolutionMaterial;
            private readonly Material compositorMaterial;

            RenderTargetIdentifier source;

            private RenderTexture structureTensorTex;
            private RenderTexture kuwaharaFilterTex;
            private RenderTexture edgeFlowTex;


            public OilPaintingRenderVolumePass(
                Material structureTensorMaterial,
                Material kuwaharaFilterMaterial,
                Material lineIntegralConvolutionMaterial,
                Material compositorMaterial)
            {
                this.structureTensorMaterial = structureTensorMaterial;
                this.kuwaharaFilterMaterial = kuwaharaFilterMaterial;
                this.lineIntegralConvolutionMaterial = lineIntegralConvolutionMaterial;
                this.compositorMaterial = compositorMaterial;
                renderPassEvent = RenderPassEvent.BeforeRenderingPostProcessing;
            }


            private void SetupKuwaharaFilter(OilPaintingComponent component)
            {
                kuwaharaFilterMaterial.SetInt("_FilterKernelSectors", component.filterKernelSectors.value);
                kuwaharaFilterMaterial.SetTexture("_FilterKernelTex", component.filterKernelTexture);
                kuwaharaFilterMaterial.SetFloat("_FilterRadius", component.filterRadius.value);
                kuwaharaFilterMaterial.SetFloat("_FilterSharpness", component.filterSharpness.value);
                kuwaharaFilterMaterial.SetFloat("_Eccentricity", component.eccentricity.value);
            }

            private void SetupLineIntegralConvolution(OilPaintingComponent component)
            {
                lineIntegralConvolutionMaterial.SetTexture("_NoiseTex", component.noiseTexture);
                lineIntegralConvolutionMaterial.SetInt("_StreamLineLength", component.streamLineLength.value);
                lineIntegralConvolutionMaterial.SetFloat("_StreamKernelStrength", component.streamKernelStrength.value);
            }

            private void SetupCompositor(OilPaintingComponent component)
            {
                compositorMaterial.SetFloat("_EdgeContribution", component.edgeContribution.value);
                compositorMaterial.SetFloat("_FlowContribution", component.flowContribution.value);
                compositorMaterial.SetFloat("_DepthContribution", component.depthContribution.value);
                compositorMaterial.SetFloat("_BumpPower", component.bumpPower.value);
                compositorMaterial.SetFloat("_BumpIntensity", component.bumpIntensity.value);
            }

            public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
            {
                // 抓取相机目标描述符。我们将在创建临时渲染纹理时使用此选项。
                RenderTextureDescriptor descriptor = renderingData.cameraData.cameraTargetDescriptor;
                descriptor.depthBufferBits = 0;

                var renderer = renderingData.cameraData.renderer;
                source = renderer.cameraColorTarget;

                structureTensorTex = RenderTexture.GetTemporary(descriptor.width, descriptor.height, 0,
                    RenderTextureFormat.ARGBFloat);
                kuwaharaFilterTex = RenderTexture.GetTemporary(descriptor);
                edgeFlowTex =
                    RenderTexture.GetTemporary(descriptor.width, descriptor.height, 0, RenderTextureFormat.RFloat);
            }

            // 过程的实际执行。这是进行自定义渲染的地方。
            public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
            {
                // 跳过场景视图中的后期处理渲染
                if (renderingData.cameraData.isSceneViewCamera)
                    return;

                CommandBuffer cmd = CommandBufferPool.Get("OilPainting");
                cmd.Clear();

                // 这将保存所有当前卷信息
                var stack = VolumeManager.instance.stack;


                var customEffect = stack.GetComponent<OilPaintingComponent>();

                var texture = new Texture2D(FilterKernelSize, FilterKernelSize, TextureFormat.RFloat, true);
                InitializeFilterKernelTexture(texture,
                    FilterKernelSize,
                    customEffect.filterKernelSectors.value,
                    customEffect.filterKernelSmoothness.value);

                customEffect.filterKernelTexture = texture;
                customEffect.noiseTexture = Resources.Load<Texture2D>("Textures/noisy-texture");

                SetupKuwaharaFilter(customEffect);
                SetupLineIntegralConvolution(customEffect);
                SetupCompositor(customEffect);

                Blit(cmd, source, structureTensorTex, structureTensorMaterial, -1);

                kuwaharaFilterMaterial.SetTexture("_StructureTensorTex", structureTensorTex);

                Blit(cmd, source, kuwaharaFilterTex, kuwaharaFilterMaterial, -1);
                for (int i = 0; i < customEffect.iterations.value - 1; i++)
                {
                    Blit(cmd, kuwaharaFilterTex, kuwaharaFilterTex, kuwaharaFilterMaterial, -1);
                }

                Blit(cmd, structureTensorTex, edgeFlowTex, lineIntegralConvolutionMaterial, -1);

                compositorMaterial.SetTexture("_EdgeFlowTex", edgeFlowTex);
                Blit(cmd, kuwaharaFilterTex, source, compositorMaterial, -1);

                Blit(cmd, source, source);

                context.ExecuteCommandBuffer(cmd);
                CommandBufferPool.Release(cmd);
            }

            // 当我们不再需要时，清理临时RT
            public override void OnCameraCleanup(CommandBuffer cmd)
            {
                RenderTexture.ReleaseTemporary(structureTensorTex);
                RenderTexture.ReleaseTemporary(kuwaharaFilterTex);
                RenderTexture.ReleaseTemporary(edgeFlowTex);
            }
        }

        private OilPaintingRenderVolumePass _scriptablePass;
        private const int FilterKernelSize = 32;
        private DepthOnlyPass depthOnlyPass;
        private RenderTargetHandle depthTexture;
        private static readonly LayerMask AllLayers = ~0;


        // Unity 在以下事件上调用此方法：
        //渲染器功能第一次加载时。
        //当您启用或禁用渲染器功能时。
        //当您在渲染器功能的检查器中更改属性时。
        public override void Create()
        {
            var structureTensorMaterial = CoreUtils.CreateEngineMaterial("Hidden/ImageEffects/Structure Tensor");
            var kuwaharaFilterMaterial =
                CoreUtils.CreateEngineMaterial("Hidden/ImageEffects/Anisotropic Kuwahara Filter");
            var lineIntegralConvolutionMaterial =
                CoreUtils.CreateEngineMaterial("Hidden/ImageEffects/Line Integral Convolution");
            var compositorMaterial = CoreUtils.CreateEngineMaterial("Hidden/ImageEffects/Compositor");
            _scriptablePass = new OilPaintingRenderVolumePass(structureTensorMaterial,
                kuwaharaFilterMaterial,
                lineIntegralConvolutionMaterial,
                compositorMaterial);
            depthOnlyPass = new DepthOnlyPass(RenderPassEvent.BeforeRenderingPostProcessing,
                RenderQueueRange.all,
                AllLayers);

            depthTexture.Init("_CameraDepthTexture");
        }


        // Unity每帧调用一次这个方法，每个Camera调用一次。此方法允许您将ScriptableRenderPass实例注入到可编写脚本的渲染器中。
        public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
        {
            var stack = VolumeManager.instance.stack;

            var customEffect = stack.GetComponent<OilPaintingComponent>();
            // 仅在效果处于活动状态时处理
            if (customEffect.IsActive())
            {
                depthOnlyPass.Setup(renderingData.cameraData.cameraTargetDescriptor, depthTexture);
                renderer.EnqueuePass(depthOnlyPass);
                renderer.EnqueuePass(_scriptablePass);
            }
        }

        private static void InitializeFilterKernelTexture(Texture2D texture, int kernelSize, int sectorCount,
            float smoothing)
        {
            for (int j = 0; j < texture.height; j++)
            {
                for (int i = 0; i < texture.width; i++)
                {
                    float x = i - 0.5f * texture.width + 0.5f;
                    float y = j - 0.5f * texture.height + 0.5f;
                    float r = Mathf.Sqrt(x * x + y * y);

                    float a = 0.5f * Mathf.Atan2(y, x) / Mathf.PI;

                    if (a > 0.5f)
                    {
                        a -= 1f;
                    }

                    if (a < -0.5f)
                    {
                        a += 1f;
                    }

                    if ((Mathf.Abs(a) <= 0.5f / sectorCount) && (r < 0.5f * kernelSize))
                    {
                        texture.SetPixel(i, j, Color.red);
                    }
                    else
                    {
                        texture.SetPixel(i, j, Color.black);
                    }
                }
            }

            float sigma = 0.25f * (kernelSize - 1);

            GaussianBlur(texture, sigma * smoothing);

            float maxValue = 0f;
            for (int j = 0; j < texture.height; j++)
            {
                for (int i = 0; i < texture.width; i++)
                {
                    var x = i - 0.5f * texture.width + 0.5f;
                    var y = j - 0.5f * texture.height + 0.5f;
                    var r = Mathf.Sqrt(x * x + y * y);

                    var color = texture.GetPixel(i, j);
                    color *= Mathf.Exp(-0.5f * r * r / sigma / sigma);
                    texture.SetPixel(i, j, color);

                    if (color.r > maxValue)
                    {
                        maxValue = color.r;
                    }
                }
            }

            for (int j = 0; j < texture.height; j++)
            {
                for (int i = 0; i < texture.width; i++)
                {
                    var color = texture.GetPixel(i, j);
                    color /= maxValue;
                    texture.SetPixel(i, j, color);
                }
            }

            texture.Apply(true, true);
        }

        private static void GaussianBlur(Texture2D texture, float sigma)
        {
            float twiceSigmaSq = 2.0f * sigma * sigma;
            int halfWidth = Mathf.CeilToInt(2 * sigma);

            var colors = new Color[texture.width * texture.height];

            for (int y = 0; y < texture.height; y++)
            {
                for (int x = 0; x < texture.width; x++)
                {
                    int index = y * texture.width + x;

                    float norm = 0;
                    for (int i = -halfWidth; i <= halfWidth; i++)
                    {
                        int xi = x + i;
                        if (xi < 0 || xi >= texture.width) continue;

                        for (int j = -halfWidth; j <= halfWidth; j++)
                        {
                            int yj = y + j;
                            if (yj < 0 || yj >= texture.height) continue;

                            float distance = Mathf.Sqrt(i * i + j * j);
                            float k = Mathf.Exp(-distance * distance / twiceSigmaSq);

                            colors[index] += texture.GetPixel(xi, yj) * k;
                            norm += k;
                        }
                    }

                    colors[index] /= norm;
                }
            }

            texture.SetPixels(colors);
        }
    }
}