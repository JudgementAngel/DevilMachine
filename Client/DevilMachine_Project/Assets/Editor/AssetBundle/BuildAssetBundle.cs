using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.IO;
public class BuildAssetBundle : EditorWindow
{

    [MenuItem("GameTool/BuildAssetBundle %&b")]
    public static void BuildAssetBundle_Fun()
    {
        Caching.ClearCache();
        string path = Application.streamingAssetsPath + "/" + "AssetBundles";

        if (!Directory.Exists(path))
        {
            Directory.CreateDirectory(path);
        }
        BuildPipeline.BuildAssetBundles(path, 0, EditorUserBuildSettings.activeBuildTarget);
        AssetDatabase.Refresh();
    }
}
