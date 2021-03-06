// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

Shader "Azure[Sky]/BuiltIn/Legacy Shaders/Transparent/Diffuse"
{
	Properties
	{
		_Color("Main Color", Color) = (1,1,1,1)
		_MainTex("Base (RGB) Trans (A)", 2D) = "white" {}
	}

	SubShader
	{
		Tags{ "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" }
		LOD 200


		// ------------------------------------------------------------
		// Surface shader code generated out of a CGPROGRAM block:
		ZWrite Off ColorMask RGB


		// ---- forward rendering base pass:
		Pass
		{
			Name "FORWARD"
			Tags{ "LightMode" = "ForwardBase" }
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			// compile directives
			#pragma vertex vert_surf
			#pragma fragment frag_surf
			#pragma multi_compile_instancing
			#pragma multi_compile_fog
			#pragma multi_compile_fwdbasealpha noshadow
			#include "HLSLSupport.cginc"
			#include "UnityShaderVariables.cginc"
			#include "UnityShaderUtilities.cginc"
			// -------- variant for: <when no other keywords are defined>
			#if !defined(INSTANCING_ON)
				// Surface shader code generated based on:
				// writes to per-pixel normal: no
				// writes to emission: no
				// writes to occlusion: no
				// needs world space reflection vector: no
				// needs world space normal vector: no
				// needs screen space position: no
				// needs world space position: no
				// needs view direction: no
				// needs world space view direction: no
				// needs world space position for lighting: YES
				// needs world space view direction for lighting: no
				// needs world space view direction for lightmaps: no
				// needs vertex color: no
				// needs VFACE: no
				// passes tangent-to-world matrix to pixel shader: no
				// reads from normal: no
				// 1 texcoords actually used
				//   float2 _MainTex
				#define UNITY_PASS_FORWARDBASE
				#include "UnityCG.cginc"
				#include "Lighting.cginc"
				#include "AutoLight.cginc"
				#include "AzureFogCore.cginc"

				#define INTERNAL_DATA
				#define WorldReflectionVector(data,normal) data.worldRefl
				#define WorldNormalVector(data,normal) normal

				// Original surface shader snippet:
				#line 11 ""
				#ifdef DUMMY_PREPROCESSOR_TO_WORK_AROUND_HLSL_COMPILER_LINE_HANDLING
				#endif
				/* UNITY: Original start of shader */
				//#pragma surface surf Lambert alpha:fade

				sampler2D _MainTex;
				fixed4 _Color;

				struct Input
				{
					float2 uv_MainTex;
				};

				void surf(Input IN, inout SurfaceOutput o)
				{
					fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
					o.Albedo = c.rgb;
					o.Alpha = c.a;
				}


				// vertex-to-fragment interpolation data
				// no lightmaps:
				#ifndef LIGHTMAP_ON
				struct v2f_surf
				{
					float4 pos : SV_POSITION;
					float2 pack0 : TEXCOORD0; // _MainTex
					half3 worldNormal : TEXCOORD1;
					float3 worldPos : TEXCOORD2;
					#if UNITY_SHOULD_SAMPLE_SH
					half3 sh : TEXCOORD3; // SH
					#endif
					UNITY_FOG_COORDS(4)
					#if SHADER_TARGET >= 30
					float4 lmap : TEXCOORD5;
					#endif

					// Azure fog texture coord.
					float4 projPos : TEXCOORD7;

					UNITY_VERTEX_INPUT_INSTANCE_ID
					UNITY_VERTEX_OUTPUT_STEREO
				};
				#endif

				// with lightmaps:
				#ifdef LIGHTMAP_ON
				struct v2f_surf
				{
					float4 pos : SV_POSITION;
					float2 pack0 : TEXCOORD0; // _MainTex
					half3 worldNormal : TEXCOORD1;
					float3 worldPos : TEXCOORD2;
					float4 lmap : TEXCOORD3;
					UNITY_FOG_COORDS(4)
					#ifdef DIRLIGHTMAP_COMBINED
					fixed3 tSpace0 : TEXCOORD5;
					fixed3 tSpace1 : TEXCOORD6;
					fixed3 tSpace2 : TEXCOORD7;
					#endif

					// Azure fog texture coord.
					float4 projPos : TEXCOORD8;

					UNITY_VERTEX_INPUT_INSTANCE_ID
					UNITY_VERTEX_OUTPUT_STEREO
				};
				#endif
				float4 _MainTex_ST;

				// vertex shader
				v2f_surf vert_surf(appdata_full v)
				{
					UNITY_SETUP_INSTANCE_ID(v);
					v2f_surf o;
					UNITY_INITIALIZE_OUTPUT(v2f_surf,o);
					UNITY_TRANSFER_INSTANCE_ID(v,o);
					UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
					o.pos = UnityObjectToClipPos(v.vertex);
					o.pack0.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
					float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
					fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
					#if defined(LIGHTMAP_ON) && defined(DIRLIGHTMAP_COMBINED)
					fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
					fixed tangentSign = v.tangent.w * unity_WorldTransformParams.w;
					fixed3 worldBinormal = cross(worldNormal, worldTangent) * tangentSign;
					#endif
					#if defined(LIGHTMAP_ON) && defined(DIRLIGHTMAP_COMBINED)
					o.tSpace0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
					o.tSpace1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
					o.tSpace2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);
					#endif
					o.worldPos = worldPos;
					o.worldNormal = worldNormal;
					#ifdef DYNAMICLIGHTMAP_ON
					o.lmap.zw = v.texcoord2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
					#endif
					#ifdef LIGHTMAP_ON
					o.lmap.xy = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
					#endif

					// SH/ambient and vertex lights
					#ifndef LIGHTMAP_ON
					#if UNITY_SHOULD_SAMPLE_SH
					o.sh = 0;
					// Approximated illumination from non-important point lights
					#ifdef VERTEXLIGHT_ON
					o.sh += Shade4PointLights(
					unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
					unity_LightColor[0].rgb, unity_LightColor[1].rgb, unity_LightColor[2].rgb, unity_LightColor[3].rgb,
					unity_4LightAtten0, worldPos, worldNormal);
					#endif
					o.sh = ShadeSHPerVertex(worldNormal, o.sh);
					#endif
					#endif // !LIGHTMAP_ON

					// Compute Azure fog projection uv.
					o.projPos = ComputeScreenPos(o.pos);
					COMPUTE_EYEDEPTH(o.projPos.z);

					UNITY_TRANSFER_FOG(o,o.pos); // pass fog coordinates to pixel shader
					return o;
				}

				// fragment shader
				fixed4 frag_surf(v2f_surf IN) : SV_Target
				{
					UNITY_SETUP_INSTANCE_ID(IN);
					// prepare and unpack data
					Input surfIN;
					UNITY_INITIALIZE_OUTPUT(Input,surfIN);
					surfIN.uv_MainTex.x = 1.0;
					surfIN.uv_MainTex = IN.pack0.xy;
					float3 worldPos = IN.worldPos;
					#ifndef USING_DIRECTIONAL_LIGHT
					fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
					#else
					fixed3 lightDir = _WorldSpaceLightPos0.xyz;
					#endif
					#ifdef UNITY_COMPILER_HLSL
					SurfaceOutput o = (SurfaceOutput)0;
					#else
					SurfaceOutput o;
					#endif
					o.Albedo = 0.0;
					o.Emission = 0.0;
					o.Specular = 0.0;
					o.Alpha = 0.0;
					o.Gloss = 0.0;
					fixed3 normalWorldVertex = fixed3(0,0,1);
					o.Normal = IN.worldNormal;
					normalWorldVertex = IN.worldNormal;

					// call surface function
					surf(surfIN, o);

					// compute lighting & shadowing factor
					UNITY_LIGHT_ATTENUATION(atten, IN, worldPos)
					fixed4 c = 0;

					// Setup lighting environment
					UnityGI gi;
					UNITY_INITIALIZE_OUTPUT(UnityGI, gi);
					gi.indirect.diffuse = 0;
					gi.indirect.specular = 0;
					gi.light.color = _LightColor0.rgb;
					gi.light.dir = lightDir;
					// Call GI (lightmaps/SH/reflections) lighting function
					UnityGIInput giInput;
					UNITY_INITIALIZE_OUTPUT(UnityGIInput, giInput);
					giInput.light = gi.light;
					giInput.worldPos = worldPos;
					giInput.atten = atten;
					#if defined(LIGHTMAP_ON) || defined(DYNAMICLIGHTMAP_ON)
					giInput.lightmapUV = IN.lmap;
					#else
					giInput.lightmapUV = 0.0;
					#endif
					#if UNITY_SHOULD_SAMPLE_SH
					giInput.ambient = IN.sh;
					#else
					giInput.ambient.rgb = 0.0;
					#endif
					giInput.probeHDR[0] = unity_SpecCube0_HDR;
					giInput.probeHDR[1] = unity_SpecCube1_HDR;
					#if defined(UNITY_SPECCUBE_BLENDING) || defined(UNITY_SPECCUBE_BOX_PROJECTION)
					giInput.boxMin[0] = unity_SpecCube0_BoxMin; // .w holds lerp value for blending
					#endif
					#ifdef UNITY_SPECCUBE_BOX_PROJECTION
					giInput.boxMax[0] = unity_SpecCube0_BoxMax;
					giInput.probePosition[0] = unity_SpecCube0_ProbePosition;
					giInput.boxMax[1] = unity_SpecCube1_BoxMax;
					giInput.boxMin[1] = unity_SpecCube1_BoxMin;
					giInput.probePosition[1] = unity_SpecCube1_ProbePosition;
					#endif
					LightingLambert_GI(o, giInput, gi);

					// realtime lighting: call lighting function
					c += LightingLambert(o, gi);
					UNITY_APPLY_FOG(IN.fogCoord, c); // apply fog

					// Apply Azure fog.
					c = ApplyAzureFog(c, IN.projPos, IN.worldPos);
					return c;
				}
			#endif

			// -------- variant for: INSTANCING_ON 
			#if defined(INSTANCING_ON)
				// Surface shader code generated based on:
				// writes to per-pixel normal: no
				// writes to emission: no
				// writes to occlusion: no
				// needs world space reflection vector: no
				// needs world space normal vector: no
				// needs screen space position: no
				// needs world space position: no
				// needs view direction: no
				// needs world space view direction: no
				// needs world space position for lighting: YES
				// needs world space view direction for lighting: no
				// needs world space view direction for lightmaps: no
				// needs vertex color: no
				// needs VFACE: no
				// passes tangent-to-world matrix to pixel shader: no
				// reads from normal: no
				// 1 texcoords actually used
				//   float2 _MainTex
				#define UNITY_PASS_FORWARDBASE
				#include "UnityCG.cginc"
				#include "Lighting.cginc"
				#include "AutoLight.cginc"
				#include "AzureFogCore.cginc"

				#define INTERNAL_DATA
				#define WorldReflectionVector(data,normal) data.worldRefl
				#define WorldNormalVector(data,normal) normal

				// Original surface shader snippet:
				#line 11 ""
				#ifdef DUMMY_PREPROCESSOR_TO_WORK_AROUND_HLSL_COMPILER_LINE_HANDLING
				#endif
				/* UNITY: Original start of shader */
				//#pragma surface surf Lambert alpha:fade

				sampler2D _MainTex;
				fixed4 _Color;

				struct Input
				{
					float2 uv_MainTex;
				};

				void surf(Input IN, inout SurfaceOutput o)
				{
					fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
					o.Albedo = c.rgb;
					o.Alpha = c.a;
				}


				// vertex-to-fragment interpolation data
				// no lightmaps:
				#ifndef LIGHTMAP_ON
				struct v2f_surf
				{
					float4 pos : SV_POSITION;
					float2 pack0 : TEXCOORD0; // _MainTex
					half3 worldNormal : TEXCOORD1;
					float3 worldPos : TEXCOORD2;
					#if UNITY_SHOULD_SAMPLE_SH
					half3 sh : TEXCOORD3; // SH
					#endif
					UNITY_FOG_COORDS(4)
					#if SHADER_TARGET >= 30
					float4 lmap : TEXCOORD5;
					#endif

					// Azure fog texture coord.
					float4 projPos : TEXCOORD6;

					UNITY_VERTEX_INPUT_INSTANCE_ID
					UNITY_VERTEX_OUTPUT_STEREO
				};
				#endif
				// with lightmaps:
				#ifdef LIGHTMAP_ON
				struct v2f_surf
				{
					float4 pos : SV_POSITION;
					float2 pack0 : TEXCOORD0; // _MainTex
					half3 worldNormal : TEXCOORD1;
					float3 worldPos : TEXCOORD2;
					float4 lmap : TEXCOORD3;
					UNITY_FOG_COORDS(4)
					#ifdef DIRLIGHTMAP_COMBINED
					fixed3 tSpace0 : TEXCOORD5;
					fixed3 tSpace1 : TEXCOORD6;
					fixed3 tSpace2 : TEXCOORD7;
					#endif

					// Azure fog texture coord.
					float4 projPos : TEXCOORD8;

					UNITY_VERTEX_INPUT_INSTANCE_ID
					UNITY_VERTEX_OUTPUT_STEREO
				};
				#endif
				float4 _MainTex_ST;

				// vertex shader
				v2f_surf vert_surf(appdata_full v)
				{
					UNITY_SETUP_INSTANCE_ID(v);
					v2f_surf o;
					UNITY_INITIALIZE_OUTPUT(v2f_surf,o);
					UNITY_TRANSFER_INSTANCE_ID(v,o);
					UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
					o.pos = UnityObjectToClipPos(v.vertex);
					o.pack0.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
					float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
					fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
					#if defined(LIGHTMAP_ON) && defined(DIRLIGHTMAP_COMBINED)
					fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
					fixed tangentSign = v.tangent.w * unity_WorldTransformParams.w;
					fixed3 worldBinormal = cross(worldNormal, worldTangent) * tangentSign;
					#endif
					#if defined(LIGHTMAP_ON) && defined(DIRLIGHTMAP_COMBINED)
					o.tSpace0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
					o.tSpace1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
					o.tSpace2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);
					#endif
					o.worldPos = worldPos;
					o.worldNormal = worldNormal;
					#ifdef DYNAMICLIGHTMAP_ON
					o.lmap.zw = v.texcoord2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
					#endif
					#ifdef LIGHTMAP_ON
					o.lmap.xy = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
					#endif

					// SH/ambient and vertex lights
					#ifndef LIGHTMAP_ON
					#if UNITY_SHOULD_SAMPLE_SH
					o.sh = 0;
					// Approximated illumination from non-important point lights
					#ifdef VERTEXLIGHT_ON
					o.sh += Shade4PointLights(
						unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
						unity_LightColor[0].rgb, unity_LightColor[1].rgb, unity_LightColor[2].rgb, unity_LightColor[3].rgb,
						unity_4LightAtten0, worldPos, worldNormal);
					#endif
					o.sh = ShadeSHPerVertex(worldNormal, o.sh);
					#endif
					#endif // !LIGHTMAP_ON

					// Compute Azure fog projection uv.
					o.projPos = ComputeScreenPos(o.pos);
					COMPUTE_EYEDEPTH(o.projPos.z);

					UNITY_TRANSFER_FOG(o,o.pos); // pass fog coordinates to pixel shader
					return o;
				}

				// fragment shader
				fixed4 frag_surf(v2f_surf IN) : SV_Target
				{
					UNITY_SETUP_INSTANCE_ID(IN);
					// prepare and unpack data
					Input surfIN;
					UNITY_INITIALIZE_OUTPUT(Input,surfIN);
					surfIN.uv_MainTex.x = 1.0;
					surfIN.uv_MainTex = IN.pack0.xy;
					float3 worldPos = IN.worldPos;
					#ifndef USING_DIRECTIONAL_LIGHT
					fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
					#else
					fixed3 lightDir = _WorldSpaceLightPos0.xyz;
					#endif
					#ifdef UNITY_COMPILER_HLSL
					SurfaceOutput o = (SurfaceOutput)0;
					#else
					SurfaceOutput o;
					#endif
					o.Albedo = 0.0;
					o.Emission = 0.0;
					o.Specular = 0.0;
					o.Alpha = 0.0;
					o.Gloss = 0.0;
					fixed3 normalWorldVertex = fixed3(0,0,1);
					o.Normal = IN.worldNormal;
					normalWorldVertex = IN.worldNormal;

					// call surface function
					surf(surfIN, o);

					// compute lighting & shadowing factor
					UNITY_LIGHT_ATTENUATION(atten, IN, worldPos)
						fixed4 c = 0;

					// Setup lighting environment
					UnityGI gi;
					UNITY_INITIALIZE_OUTPUT(UnityGI, gi);
					gi.indirect.diffuse = 0;
					gi.indirect.specular = 0;
					gi.light.color = _LightColor0.rgb;
					gi.light.dir = lightDir;
					// Call GI (lightmaps/SH/reflections) lighting function
					UnityGIInput giInput;
					UNITY_INITIALIZE_OUTPUT(UnityGIInput, giInput);
					giInput.light = gi.light;
					giInput.worldPos = worldPos;
					giInput.atten = atten;
					#if defined(LIGHTMAP_ON) || defined(DYNAMICLIGHTMAP_ON)
					giInput.lightmapUV = IN.lmap;
					#else
					giInput.lightmapUV = 0.0;
					#endif
					#if UNITY_SHOULD_SAMPLE_SH
					giInput.ambient = IN.sh;
					#else
					giInput.ambient.rgb = 0.0;
					#endif
					giInput.probeHDR[0] = unity_SpecCube0_HDR;
					giInput.probeHDR[1] = unity_SpecCube1_HDR;
					#if defined(UNITY_SPECCUBE_BLENDING) || defined(UNITY_SPECCUBE_BOX_PROJECTION)
					giInput.boxMin[0] = unity_SpecCube0_BoxMin; // .w holds lerp value for blending
					#endif
					#ifdef UNITY_SPECCUBE_BOX_PROJECTION
					giInput.boxMax[0] = unity_SpecCube0_BoxMax;
					giInput.probePosition[0] = unity_SpecCube0_ProbePosition;
					giInput.boxMax[1] = unity_SpecCube1_BoxMax;
					giInput.boxMin[1] = unity_SpecCube1_BoxMin;
					giInput.probePosition[1] = unity_SpecCube1_ProbePosition;
					#endif
					LightingLambert_GI(o, giInput, gi);

					// realtime lighting: call lighting function
					c += LightingLambert(o, gi);
					UNITY_APPLY_FOG(IN.fogCoord, c); // apply fog
					
					// Apply Azure fog.
					c = ApplyAzureFog(c, IN.projPos, IN.worldPos);
					return c;
				}
			#endif
			ENDCG
		}

		// ---- forward rendering additive lights pass:
		Pass
		{
			Name "FORWARD"
			Tags{ "LightMode" = "ForwardAdd" }
			ZWrite Off Blend One One
			Blend SrcAlpha One

			CGPROGRAM
			// compile directives
			#pragma vertex vert_surf
			#pragma fragment frag_surf
			#pragma multi_compile_instancing
			#pragma multi_compile_fog
			#pragma skip_variants INSTANCING_ON
			#pragma multi_compile_fwdadd noshadow
			#include "HLSLSupport.cginc"
			#include "UnityShaderVariables.cginc"
			#include "UnityShaderUtilities.cginc"
			// -------- variant for: <when no other keywords are defined>
			#if !defined(INSTANCING_ON)
				// Surface shader code generated based on:
				// writes to per-pixel normal: no
				// writes to emission: no
				// writes to occlusion: no
				// needs world space reflection vector: no
				// needs world space normal vector: no
				// needs screen space position: no
				// needs world space position: no
				// needs view direction: no
				// needs world space view direction: no
				// needs world space position for lighting: YES
				// needs world space view direction for lighting: no
				// needs world space view direction for lightmaps: no
				// needs vertex color: no
				// needs VFACE: no
				// passes tangent-to-world matrix to pixel shader: no
				// reads from normal: no
				// 1 texcoords actually used
				//   float2 _MainTex
				#define UNITY_PASS_FORWARDADD
				#include "UnityCG.cginc"
				#include "Lighting.cginc"
				#include "AutoLight.cginc"
				#include "AzureFogCore.cginc"

				#define INTERNAL_DATA
				#define WorldReflectionVector(data,normal) data.worldRefl
				#define WorldNormalVector(data,normal) normal

						// Original surface shader snippet:
				#line 11 ""
				#ifdef DUMMY_PREPROCESSOR_TO_WORK_AROUND_HLSL_COMPILER_LINE_HANDLING
				#endif
				/* UNITY: Original start of shader */
				//#pragma surface surf Lambert alpha:fade

				sampler2D _MainTex;
				fixed4 _Color;

				struct Input
				{
					float2 uv_MainTex;
				};

				void surf(Input IN, inout SurfaceOutput o)
				{
					fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
					o.Albedo = c.rgb;
					o.Alpha = c.a;
				}


				// vertex-to-fragment interpolation data
				struct v2f_surf
				{
					float4 pos : SV_POSITION;
					float2 pack0 : TEXCOORD0; // _MainTex
					half3 worldNormal : TEXCOORD1;
					float3 worldPos : TEXCOORD2;
					UNITY_FOG_COORDS(3)

					// Azure fog texture coord.
					float4 projPos : TEXCOORD4;

					UNITY_VERTEX_INPUT_INSTANCE_ID
					UNITY_VERTEX_OUTPUT_STEREO
				};
				float4 _MainTex_ST;

				// vertex shader
				v2f_surf vert_surf(appdata_full v)
				{
					UNITY_SETUP_INSTANCE_ID(v);
					v2f_surf o;
					UNITY_INITIALIZE_OUTPUT(v2f_surf,o);
					UNITY_TRANSFER_INSTANCE_ID(v,o);
					UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
					o.pos = UnityObjectToClipPos(v.vertex);
					o.pack0.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
					float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
					fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
					o.worldPos = worldPos;
					o.worldNormal = worldNormal;

					// Compute Azure fog projection uv.
					o.projPos = ComputeScreenPos(o.pos);
					COMPUTE_EYEDEPTH(o.projPos.z);

					UNITY_TRANSFER_FOG(o,o.pos); // pass fog coordinates to pixel shader
					return o;
				}

				// fragment shader
				fixed4 frag_surf(v2f_surf IN) : SV_Target
				{
					UNITY_SETUP_INSTANCE_ID(IN);
					// prepare and unpack data
					Input surfIN;
					UNITY_INITIALIZE_OUTPUT(Input,surfIN);
					surfIN.uv_MainTex.x = 1.0;
					surfIN.uv_MainTex = IN.pack0.xy;
					float3 worldPos = IN.worldPos;
					#ifndef USING_DIRECTIONAL_LIGHT
					fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
					#else
					fixed3 lightDir = _WorldSpaceLightPos0.xyz;
					#endif
					#ifdef UNITY_COMPILER_HLSL
					SurfaceOutput o = (SurfaceOutput)0;
					#else
					SurfaceOutput o;
					#endif
					o.Albedo = 0.0;
					o.Emission = 0.0;
					o.Specular = 0.0;
					o.Alpha = 0.0;
					o.Gloss = 0.0;
					fixed3 normalWorldVertex = fixed3(0,0,1);
					o.Normal = IN.worldNormal;
					normalWorldVertex = IN.worldNormal;

					// call surface function
					surf(surfIN, o);
					UNITY_LIGHT_ATTENUATION(atten, IN, worldPos)
					fixed4 c = 0;

					// Setup lighting environment
					UnityGI gi;
					UNITY_INITIALIZE_OUTPUT(UnityGI, gi);
					gi.indirect.diffuse = 0;
					gi.indirect.specular = 0;
					gi.light.color = _LightColor0.rgb;
					gi.light.dir = lightDir;
					gi.light.color *= atten;
					c += LightingLambert(o, gi);
					UNITY_APPLY_FOG(IN.fogCoord, c); // apply fog
					
					// Apply Azure fog.
					c = ApplyAzureFog(c, IN.projPos, IN.worldPos);
					return c;
				}
			#endif
			ENDCG
		}

		// ---- meta information extraction pass:
		Pass
		{
			Name "Meta"
			Tags{ "LightMode" = "Meta" }
			Cull Off

			CGPROGRAM
			// compile directives
			#pragma vertex vert_surf
			#pragma fragment frag_surf
			#pragma multi_compile_instancing noshadow
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#pragma skip_variants INSTANCING_ON
			#pragma shader_feature EDITOR_VISUALIZATION

			#include "HLSLSupport.cginc"
			#include "UnityShaderVariables.cginc"
			#include "UnityShaderUtilities.cginc"
			// -------- variant for: <when no other keywords are defined>
			#if !defined(INSTANCING_ON)
				// Surface shader code generated based on:
				// writes to per-pixel normal: no
				// writes to emission: no
				// writes to occlusion: no
				// needs world space reflection vector: no
				// needs world space normal vector: no
				// needs screen space position: no
				// needs world space position: no
				// needs view direction: no
				// needs world space view direction: no
				// needs world space position for lighting: YES
				// needs world space view direction for lighting: no
				// needs world space view direction for lightmaps: no
				// needs vertex color: no
				// needs VFACE: no
				// passes tangent-to-world matrix to pixel shader: no
				// reads from normal: no
				// 1 texcoords actually used
				//   float2 _MainTex
				#define UNITY_PASS_META
				#include "UnityCG.cginc"
				#include "Lighting.cginc"

				#define INTERNAL_DATA
				#define WorldReflectionVector(data,normal) data.worldRefl
				#define WorldNormalVector(data,normal) normal

				// Original surface shader snippet:
				#line 11 ""
				#ifdef DUMMY_PREPROCESSOR_TO_WORK_AROUND_HLSL_COMPILER_LINE_HANDLING
				#endif
				/* UNITY: Original start of shader */
				//#pragma surface surf Lambert alpha:fade

				sampler2D _MainTex;
				fixed4 _Color;

				struct Input
				{
					float2 uv_MainTex;
				};

				void surf(Input IN, inout SurfaceOutput o)
				{
					fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
					o.Albedo = c.rgb;
					o.Alpha = c.a;
				}

				#include "UnityMetaPass.cginc"

				// vertex-to-fragment interpolation data
				struct v2f_surf
				{
					float4 pos : SV_POSITION;
					float2 pack0 : TEXCOORD0; // _MainTex
					float3 worldPos : TEXCOORD1;
					UNITY_VERTEX_INPUT_INSTANCE_ID
					UNITY_VERTEX_OUTPUT_STEREO
				};
				float4 _MainTex_ST;

				// vertex shader
				v2f_surf vert_surf(appdata_full v)
				{
					UNITY_SETUP_INSTANCE_ID(v);
					v2f_surf o;
					UNITY_INITIALIZE_OUTPUT(v2f_surf,o);
					UNITY_TRANSFER_INSTANCE_ID(v,o);
					UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
					o.pos = UnityMetaVertexPosition(v.vertex, v.texcoord1.xy, v.texcoord2.xy, unity_LightmapST, unity_DynamicLightmapST);
					o.pack0.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
					float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
					fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
					o.worldPos = worldPos;
					return o;
				}

				// fragment shader
				fixed4 frag_surf(v2f_surf IN) : SV_Target
				{
					UNITY_SETUP_INSTANCE_ID(IN);
					// prepare and unpack data
					Input surfIN;
					UNITY_INITIALIZE_OUTPUT(Input,surfIN);
					surfIN.uv_MainTex.x = 1.0;
					surfIN.uv_MainTex = IN.pack0.xy;
					float3 worldPos = IN.worldPos;
					#ifndef USING_DIRECTIONAL_LIGHT
					fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
					#else
					fixed3 lightDir = _WorldSpaceLightPos0.xyz;
					#endif
					#ifdef UNITY_COMPILER_HLSL
					SurfaceOutput o = (SurfaceOutput)0;
					#else
					SurfaceOutput o;
					#endif
					o.Albedo = 0.0;
					o.Emission = 0.0;
					o.Specular = 0.0;
					o.Alpha = 0.0;
					o.Gloss = 0.0;
					fixed3 normalWorldVertex = fixed3(0,0,1);

					// call surface function
					surf(surfIN, o);
					UnityMetaInput metaIN;
					UNITY_INITIALIZE_OUTPUT(UnityMetaInput, metaIN);
					metaIN.Albedo = o.Albedo;
					metaIN.Emission = o.Emission;
					metaIN.SpecularColor = o.Specular;
					return UnityMetaFragment(metaIN);
				}
			#endif
			ENDCG
		}

		// ---- end of surface shader generated code
		#LINE 28
	}
	Fallback "Legacy Shaders/Transparent/VertexLit"
}