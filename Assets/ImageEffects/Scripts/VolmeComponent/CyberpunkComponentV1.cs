using System;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace ImageEffects
{
    [Serializable, VolumeComponentMenuForRenderPipeline("Custom/Cyberpunk V1", typeof(UniversalRenderPipeline))]
    public class CyberpunkComponentV1 : VolumeComponent, IPostProcessComponent
    {
        public const float PowerDefault = 1;
        // 从0到1的强度参数
        public ClampedFloatParameter power = new ClampedFloatParameter(value: 0, min: 0, max: 1, overrideState: true);

        // 告诉我们的效果应该何时呈现
        public bool IsActive() => power.value > 0;
        public bool IsTileCompatible() => true;
    }
}