using System;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace ImageEffects
{
    [Serializable, VolumeComponentMenuForRenderPipeline("Custom/OilPainting", typeof(UniversalRenderPipeline))]
    public class OilPaintingComponent : VolumeComponent, IPostProcessComponent
    {

        public const float FilterRadiusDefault = 4f;

        public ClampedIntParameter filterKernelSectors = new ClampedIntParameter(value: 8, min: 3, max: 8, overrideState: true);

        public Texture2D filterKernelTexture;
        
        public ClampedFloatParameter filterRadius = new ClampedFloatParameter(value: 0, min: 0, max: 12, overrideState: true);

        public ClampedFloatParameter filterSharpness = new ClampedFloatParameter(value: 8, min: 2, max: 16, overrideState: true);

        public ClampedFloatParameter eccentricity = new ClampedFloatParameter(value: 1, min: 0.125f, max: 8, overrideState: true);

        public ClampedFloatParameter filterKernelSmoothness = new ClampedFloatParameter(value: 0.33f, min: 0, max: 1, overrideState: true);
        
        public ClampedIntParameter iterations = new ClampedIntParameter(value: 1, min: 1, max: 4, overrideState: true);

        
        public Texture2D noiseTexture;

        public ClampedIntParameter streamLineLength = new ClampedIntParameter(value: 10, min: 1, max: 64, overrideState: true);

        public ClampedFloatParameter streamKernelStrength = new ClampedFloatParameter(value: 0.5f, min: 0, max: 2, overrideState: true);

        public ClampedFloatParameter edgeContribution = new ClampedFloatParameter(value: 1f, min: 0, max: 4, overrideState: true);

        public ClampedFloatParameter flowContribution = new ClampedFloatParameter(value: 1f, min: 0, max: 4, overrideState: true);

        public ClampedFloatParameter depthContribution = new ClampedFloatParameter(value: 1f, min: 0, max: 4, overrideState: true);

        public ClampedFloatParameter bumpPower = new ClampedFloatParameter(value: 0.8f, min: 0.25f, max: 1, overrideState: true);
        public ClampedFloatParameter bumpIntensity = new ClampedFloatParameter(value: 0.4f, min: 0, max: 1, overrideState: true);

        // 告诉我们的效果应该何时呈现
        public bool IsActive() => filterRadius.value > 0;
        public bool IsTileCompatible() => true;
    }
}