// using UnityEngine;
// using UnityEngine.Rendering;
// using UnityEngine.Rendering.Universal;
//
//
// // 有问题 导致内存爆炸
// namespace ImageEffects
// {
//     public class SunShaftsRenderVolumeFeature : ScriptableRendererFeature
//     {
//         // 创建可编写脚本的渲染通道
//         class SunShaftsRenderVolumePass : ScriptableRenderPass
//         {
//             Settings settings;
//
//             RenderTargetIdentifier source;
//             RenderTargetIdentifier destinationA;
//             RenderTargetIdentifier destinationB;
//             RenderTargetIdentifier latestDest;
//
//             static class ShaderIDs
//             {
//                 internal static readonly int blurRadius4 = Shader.PropertyToID("_BlurRadius4");
//                 internal static readonly int sunPosition = Shader.PropertyToID("_SunPosition");
//                 internal static readonly int sunThreshold = Shader.PropertyToID("_SunThreshold");
//                 internal static readonly int sunColor = Shader.PropertyToID("_SunColor");
//                 internal static readonly int colorBuffer = Shader.PropertyToID("_ColorBuffer");
//                 internal static readonly int skybox = Shader.PropertyToID("_Skybox");
//                 internal static readonly int bufferRT = Shader.PropertyToID("_BufferRT");
//                 internal static readonly int bufferRT2 = Shader.PropertyToID("_BufferRT2");
//             }
//
//             public SunShaftsRenderVolumePass(Settings customSettings)
//             {
//                 settings = customSettings;
//                 renderPassEvent = RenderPassEvent.BeforeRenderingPostProcessing;
//             }
//
//             public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
//             {
//                 // 抓取相机目标描述符。我们将在创建临时渲染纹理时使用此选项。
//                 RenderTextureDescriptor descriptor = renderingData.cameraData.cameraTargetDescriptor;
//                 descriptor.depthBufferBits = 0;
//
//                 var renderer = renderingData.cameraData.renderer;
//                 source = renderer.cameraColorTarget;
//             }
//
//             // 过程的实际执行。这是进行自定义渲染的地方。
//             public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
//             {
//                 // 跳过场景视图中的后期处理渲染
//                 if (renderingData.cameraData.isSceneViewCamera)
//                     return;
//
//                 var material = settings.material;
//                 if (material == null)
//                 {
//                     Debug.LogError("SunShafts instance is null");
//                     return;
//                 }
//
//                 CommandBuffer cmd = CommandBufferPool.Get("SunShafts");
//                 cmd.Clear();
//
//                 // 这将保存所有当前卷信息
//                 var stack = VolumeManager.instance.stack;
//
//                 //从相机源开始
//                 latestDest = source;
//
//                 var customEffect = stack.GetComponent<SunShaftsComponent>();
//                 // 仅在效果处于活动状态时处理
//                 if (customEffect.IsActive())
//                 {
//                     Camera camera = renderingData.cameraData.camera;
//                     // int divider = 4;
//                     // if (customEffect.resolution == SunShaftsComponent.SunShaftsResolution.Normal)
//                     //     divider = 2;
//                     // else if (customEffect.resolution == SunShaftsComponent.SunShaftsResolution.High)
//                     //     divider = 1;
//                     int divider = 2;
//
//
//                     Vector3 v = Vector3.one * 0.5f;
//                     // if (customEffect.sunTransform)
//                     //     v = camera.WorldToViewportPoint(customEffect.sunTransform.position);
//
//                     int rtH = camera.scaledPixelHeight / divider;
//                     int rtW = camera.scaledPixelWidth / divider;
//
//                     cmd.GetTemporaryRT(ShaderIDs.bufferRT, rtW, rtH, 0, FilterMode.Bilinear);
//                     RenderTexture lrDepthBuffer = RenderTexture.GetTemporary (rtW, rtH, 0);
//
//                     cmd.Blit(latestDest, ShaderIDs.bufferRT);
//
//                     material.SetVector(ShaderIDs.blurRadius4,
//                         new Vector4(1.0f, 1.0f, 0.0f, 0.0f) * customEffect.sunShaftBlurRadius.value);
//                     material.SetVector(ShaderIDs.sunPosition, new Vector4(v.x, v.y, v.z, customEffect.maxRadius.value));
//                     material.SetVector(ShaderIDs.sunThreshold, customEffect.sunThreshold.value);
//
//                     if (customEffect.useDepthTexture.value)
//                     {
//                         var format = camera.allowHDR ? RenderTextureFormat.DefaultHDR : RenderTextureFormat.Default;
//                         RenderTexture tmpBuffer = RenderTexture.GetTemporary(rtW, rtH, 0, format);
//                         RenderTexture.active = tmpBuffer;
//                         GL.ClearWithSkybox(false, camera);
//                         material.SetTexture(ShaderIDs.skybox, tmpBuffer);
//                         cmd.Blit(ShaderIDs.bufferRT, lrDepthBuffer, material, 3);
//                         RenderTexture.ReleaseTemporary(tmpBuffer);
//                     }
//                     else
//                     {
//                         cmd.Blit(ShaderIDs.bufferRT, lrDepthBuffer, material, 2);
//                     }
//
//                     int radialBlurIterations = Mathf.Clamp(customEffect.radialBlurIterations.value, 1, 4);
//
//                     float ofs = customEffect.sunShaftBlurRadius.value * (1.0f / 768.0f);
//
//                     material.SetVector(ShaderIDs.blurRadius4, new Vector4(ofs, ofs, 0.0f, 0.0f));
//                     material.SetVector(ShaderIDs.sunPosition, new Vector4(v.x, v.y, v.z, customEffect.maxRadius.value));
//                     
//                     
//                     for (int it2 = 0; it2 < radialBlurIterations; it2++ ) {
//
//                         cmd.GetTemporaryRT(ShaderIDs.bufferRT2, rtW, rtH, 0, FilterMode.Bilinear);
//                         cmd.Blit(lrDepthBuffer, ShaderIDs.bufferRT2, material, 1);
//                         RenderTexture.ReleaseTemporary (lrDepthBuffer);
//                         ofs = customEffect.sunShaftBlurRadius.value * (((it2 * 2.0f + 1.0f) * 6.0f)) / 768.0f;
//                         material.SetVector (ShaderIDs.blurRadius4, new Vector4 (ofs, ofs, 0.0f, 0.0f) );
//                         lrDepthBuffer = RenderTexture.GetTemporary (rtW, rtH, 0);
//                         cmd.Blit(ShaderIDs.bufferRT2, lrDepthBuffer, material, 1);
//                         ofs = customEffect.sunShaftBlurRadius.value * (((it2 * 2.0f + 2.0f) * 6.0f)) / 768.0f;
//                         material.SetVector (ShaderIDs.blurRadius4, new Vector4 (ofs, ofs, 0.0f, 0.0f) );
//                     }
//
//                     Color sunColor = customEffect.sunColor.value;
//                     if (v.z >= 0.0f)
//                         material.SetVector (ShaderIDs.sunColor, new Vector4 (sunColor.r, sunColor.g, sunColor.b, sunColor.a) * customEffect.sunShaftIntensity.value);
//                     else
//                         material.SetVector (ShaderIDs.sunColor, Vector4.zero); // no backprojection !
//                     material.SetTexture (ShaderIDs.colorBuffer, lrDepthBuffer);
//                     cmd.Blit(source, latestDest, material, 0);
//                 }
//
//                 // 完成！现在我们已经处理了所有自定义效果，将最终结果应用到相机
//                 Blit(cmd, latestDest, source);
//
//                 context.ExecuteCommandBuffer(cmd);
//                 CommandBufferPool.Release(cmd);
//             }
//
//             // 当我们不再需要时，清理临时RT
//             public override void OnCameraCleanup(CommandBuffer cmd)
//             {
//                 cmd.ReleaseTemporaryRT(ShaderIDs.bufferRT);
//                 cmd.ReleaseTemporaryRT(ShaderIDs.bufferRT2);
//             }
//         }
//
//         [System.Serializable]
//         public class Settings
//         {
//             private Shader m_shader;
//
//             private Material m_Material;
//
//             public Material material
//             {
//                 get
//                 {
//                     if (m_Material == null)
//                     {
//                         m_Material = new Material(shader);
//                         m_Material.hideFlags = HideFlags.HideAndDontSave;
//                     }
//
//                     return m_Material;
//                 }
//             }
//
//             public Shader shader
//             {
//                 get
//                 {
//                     if (m_shader == null)
//                     {
//                         m_shader = Shader.Find("Hidden/ImageEffects/SunShafts");
//                     }
//
//                     return m_shader;
//                 }
//             }
//         }
//
//         public Settings settings = new Settings();
//         private SunShaftsRenderVolumePass _scriptablePass;
//
//         // Unity 在以下事件上调用此方法：
//         //渲染器功能第一次加载时。
//         //当您启用或禁用渲染器功能时。
//         //当您在渲染器功能的检查器中更改属性时。
//         public override void Create()
//         {
//             _scriptablePass = new SunShaftsRenderVolumePass(settings);
//         }
//
//
//         // Unity每帧调用一次这个方法，每个Camera调用一次。此方法允许您将ScriptableRenderPass实例注入到可编写脚本的渲染器中。
//         public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
//         {
//             var stack = VolumeManager.instance.stack;
//             var customEffect = stack.GetComponent<SunShaftsComponent>();
//             if (customEffect.IsActive()) renderer.EnqueuePass(_scriptablePass);  // 在渲染队列中入队
//         }
//     }
// }