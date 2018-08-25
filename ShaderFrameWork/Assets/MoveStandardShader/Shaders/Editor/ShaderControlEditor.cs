using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class ShaderControlEditor : EditorWindow
{
    public enum DebugMode
    {
        None,
        Albedo,
        Normal
    }
    public static DebugMode debugMode = DebugMode.None;
    [MenuItem("MoveShader/DebugMode/None", false, 200)]
    public static void DebugMode_None_Fun()
    {
        debugMode = DebugMode.None;
        Shader.DisableKeyword("_DEBUG_ALBEDO");
        Shader.DisableKeyword("_DEBUG_NORMAL");
    }
    [MenuItem("MoveShader/DebugMode/None", true)]
    public static bool Validate_DebugMode_None_Fun()
    {
        return debugMode != DebugMode.None;
    }
    [MenuItem("MoveShader/DebugMode/Albedo", false, 200)]
    public static void DebugMode_Albedo_Fun()
    {
        debugMode = DebugMode.Albedo;
        Shader.EnableKeyword("_DEBUG_ALBEDO");
        Shader.DisableKeyword("_DEBUG_NORMAL");
    }
    [MenuItem("MoveShader/DebugMode/Albedo", true)]
    public static bool Validate_DebugMode_Albedo_Fun()
    {
        return debugMode != DebugMode.Albedo;
    }
    [MenuItem("MoveShader/DebugMode/Normal", false, 200)]
    public static void DebugMode_Normal_Fun()
    {
        debugMode = DebugMode.Normal;
        Shader.DisableKeyword("_DEBUG_ALBEDO");
        Shader.EnableKeyword("_DEBUG_NORMAL");
    }
    [MenuItem("MoveShader/DebugMode/Normal", true)]
    public static bool Validate_DebugMode_Normal_Fun()
    {
        return debugMode != DebugMode.Normal;
    }
}
