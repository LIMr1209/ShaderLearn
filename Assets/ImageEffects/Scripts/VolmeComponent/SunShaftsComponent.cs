using System;
using JetBrains.Annotations;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
using UnityEngine;

namespace ImageEffects
{
    [Serializable, VolumeComponentMenuForRenderPipeline("Custom/SunShafts", typeof(UniversalRenderPipeline))]
    public class SunShaftsComponent : VolumeComponent, IPostProcessComponent
    {
        public enum SunShaftsResolution
        {
            Low = 0,
            Normal = 1,
            High = 2,
        }

        public enum ShaftsScreenBlendMode
        {
            Screen = 0,
            Add = 1,
        }

        public IntParameter radialBlurIterations = new IntParameter(2);
        public ColorParameter sunColor = new ColorParameter(Color.white);
        public ColorParameter sunThreshold = new ColorParameter(new Color(0.87f, 0.74f, 0.65f));
        public FloatParameter sunShaftBlurRadius = new FloatParameter(2.5f);
        public FloatParameter sunShaftIntensity = new FloatParameter(1.15f);

        public FloatParameter maxRadius = new FloatParameter(0.75f);

        public BoolParameter useDepthTexture = new BoolParameter(true);
        
        // 告诉我们的效果应该何时呈现
        public bool IsActive() => sunShaftBlurRadius.value > 0 && sunShaftIntensity.value > 0 & maxRadius.value > 0;
        public bool IsTileCompatible() => true;
    }
}