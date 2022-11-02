/*using System;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace DefaultNamespace
{
    [Serializable, VolumeComponentMenuForRenderPipeline("Custom/Cyberpunk", typeof(UniversalRenderPipeline))]
    public class CyberpunkComponent : VolumeComponent, IPostProcessComponent
    {
        
        // 从0到1的强度参数
        public ClampedFloatParameter pow = new ClampedFloatParameter(value: 0, min: 0, max: 1, overrideState: true);
        
        // 告诉我们的效果应该何时呈现
        public bool IsActive() => pow.value > 0;
        public bool IsTileCompatible() => true;
    }
}*/