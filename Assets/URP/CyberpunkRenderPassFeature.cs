/*using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class CyberpunkRenderPassFeature : ScriptableRendererFeature
{
    // 创建可编写脚本的渲染通道
    class CyberpunkRenderPass : ScriptableRenderPass
    {
        Settings settings;
        RenderTargetHandle _TemporaryColorTexture; // 渲染目标句柄

        private RenderTargetIdentifier _source;
        private RenderTargetHandle _destination;

        public CyberpunkRenderPass(Settings customSettings)
        {
            settings = customSettings;
        }

        // RenderTargetIdentifier 标识CommandBuffer的RenderTexture。
        public void Setup(RenderTargetIdentifier source, RenderTargetHandle destination)
        {
            _source = source;
            _destination = destination;
        }
        

        // RenderTextureDescriptor 渲染纹理描述符
        public override void Configure(CommandBuffer cmd, RenderTextureDescriptor cameraTextureDescriptor)
        {
            _TemporaryColorTexture.Init("_TemporaryColorTexture");
        }

        
        // Unity Execute每帧运行该方法。在此方法中，您可以实现自定义渲染功能。
        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            // Skipping post processing rendering inside the scene View
            if(renderingData.cameraData.isSceneViewCamera)
                return;
            // 创建一个CommandBuffer类型对象。该对象包含要执行的渲染命令列表
            CommandBuffer cmd = CommandBufferPool.Get("My Pass");

            // 抓取相机目标描述符。我们将在创建临时渲染纹理时使用此选项。
            RenderTextureDescriptor descriptor = renderingData.cameraData.cameraTargetDescriptor;
            if (_destination == RenderTargetHandle.CameraTarget)
            {
                settings.material.SetFloat("_Power", settings.pow);
                // GetTemporaryRT 创建临时渲染纹理
                // renderingData.cameraData  从renderingData参数获取相机数据。
                cmd.GetTemporaryRT(_TemporaryColorTexture.id, descriptor, FilterMode.Point);
                // _TemporaryColorTexture.Identifier() 创建一个渲染目标标识符。
                cmd.Blit(_source, _TemporaryColorTexture.Identifier());
                cmd.Blit(_TemporaryColorTexture.Identifier(), _source, settings.material);
            }
            else
            {
                cmd.Blit(_source, _destination.Identifier(), settings.material, 0);
            }

            // 执行命令缓冲区的行
            context.ExecuteCommandBuffer(cmd);
            // 释放它的行。
            CommandBufferPool.Release(cmd);
            
        }

        public override void FrameCleanup(CommandBuffer cmd)
        {
            if (_destination == RenderTargetHandle.CameraTarget)
            {
                cmd.ReleaseTemporaryRT(_TemporaryColorTexture.id); 
            }
        }
    }

    [System.Serializable]
    public class Settings
    {
        [Range(0.0f, 1.0f)] public float pow = 1.0f;
        public RenderPassEvent renderPassEvent = RenderPassEvent.AfterRenderingPostProcessing;
        
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
    private CyberpunkRenderPass _scriptablePass;

    // Unity 在以下事件上调用此方法：
    //渲染器功能第一次加载时。
    //当您启用或禁用渲染器功能时。
    //当您在渲染器功能的检查器中更改属性时。
    public override void Create()
    {
        _scriptablePass = new CyberpunkRenderPass(settings);

        _scriptablePass.renderPassEvent = settings.renderPassEvent;  // 在渲染 Opaques 之后
    }

    
    // Unity每帧调用一次这个方法，每个Camera调用一次。此方法允许您将ScriptableRenderPass实例注入到可编写脚本的渲染器中。
    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        _scriptablePass.Setup(renderer.cameraColorTarget, RenderTargetHandle.CameraTarget);
        // 在渲染队列中入队
        renderer.EnqueuePass(_scriptablePass);
    }
}*/