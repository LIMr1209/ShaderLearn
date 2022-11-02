/*using DefaultNamespace;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class CyberpunkRenderVolumeFeature : ScriptableRendererFeature
{
    // 创建可编写脚本的渲染通道
    class CyberpunkRenderVolumePass : ScriptableRenderPass
    {
        Settings settings;
        
        RenderTargetIdentifier source;
        RenderTargetIdentifier destinationA;
        RenderTargetIdentifier destinationB;
        RenderTargetIdentifier latestDest;

        readonly int temporaryRTIdA = Shader.PropertyToID("_TempRT");
        readonly int temporaryRTIdB = Shader.PropertyToID("_TempRTB");

        public CyberpunkRenderVolumePass(Settings customSettings)
        {
            settings = customSettings;
            renderPassEvent = RenderPassEvent.BeforeRenderingPostProcessing;
        }

        public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
        {
            // Grab the camera target descriptor. We will use this when creating a temporary render texture.
            RenderTextureDescriptor descriptor = renderingData.cameraData.cameraTargetDescriptor;
            descriptor.depthBufferBits = 0;

            var renderer = renderingData.cameraData.renderer;
            source = renderer.cameraColorTarget;

            // Create a temporary render texture using the descriptor from above.
            cmd.GetTemporaryRT(temporaryRTIdA , descriptor, FilterMode.Bilinear);
            destinationA = new RenderTargetIdentifier(temporaryRTIdA);
            cmd.GetTemporaryRT(temporaryRTIdB , descriptor, FilterMode.Bilinear);
            destinationB = new RenderTargetIdentifier(temporaryRTIdB);
        }

            // The actual execution of the pass. This is where custom rendering occurs.
    public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
    {
    	// Skipping post processing rendering inside the scene View
        if(renderingData.cameraData.isSceneViewCamera)
            return;
        
        // Here you get your materials from your custom class
        // (It's up to you! But here is how I did it)
        var material = settings.material;
        if (material == null)
        {
            Debug.LogError("Custom Post Processing Materials instance is null");
            return;
        }
        
        CommandBuffer cmd = CommandBufferPool.Get("Custom Post Processing");
        cmd.Clear();

		// This holds all the current Volumes information
		// which we will need later
        var stack = VolumeManager.instance.stack;

        #region Local Methods

		// Swaps render destinations back and forth, so that
		// we can have multiple passes and similar with only a few textures
        void BlitTo(Material mat, int pass = 0)
        {
            var first = latestDest;
            var last = first == destinationA ? destinationB : destinationA;
            Blit(cmd, first, last, mat, pass);

            latestDest = last;
        }

        #endregion

		// Starts with the camera source
        latestDest = source;

        //---Custom effect here---
        var customEffect = stack.GetComponent<CyberpunkComponent>();
        // Only process if the effect is active
        if (customEffect.IsActive())
        {
            // P.s. optimize by caching the property ID somewhere else
            material.SetFloat(Shader.PropertyToID("_Power"), customEffect.pow.value);
            
            BlitTo(material);
        }
        
        // Add any other custom effect/component you want, in your preferred order
        // Custom effect 2, 3 , ...

		
		// DONE! Now that we have processed all our custom effects, applies the final result to camera
        Blit(cmd, latestDest, source);
        
        context.ExecuteCommandBuffer(cmd);
        CommandBufferPool.Release(cmd);
    }

	//Cleans the temporary RTs when we don't need them anymore
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
                    m_shader = Shader.Find("Hidden/Cyberpunk1");
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
        // 在渲染队列中入队
        renderer.EnqueuePass(_scriptablePass);
    }
}*/