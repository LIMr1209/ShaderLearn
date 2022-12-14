using System;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace ImageEffects
{
    [Serializable, VolumeComponentMenuForRenderPipeline("Custom/WhiteBalance", typeof(UniversalRenderPipeline))]
    public class WhiteBalanceComponent : VolumeComponent, IPostProcessComponent
    {
        public ClampedFloatParameter temperature =
            new ClampedFloatParameter(value: 0.0f, min: -1.0f, max: 1.0f, overrideState: true);
        
        public ClampedFloatParameter tint =
            new ClampedFloatParameter(value: 0.0f, min: -1.0f, max: 1.0f, overrideState: true);


        // 告诉我们的效果应该何时呈现
        public bool IsActive() => temperature != 0 || tint !=0 ;
        public bool IsTileCompatible() => true;
    }
}