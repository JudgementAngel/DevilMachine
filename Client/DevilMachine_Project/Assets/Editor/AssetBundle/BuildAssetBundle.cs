using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.IO;
using System;

public class BuildAssetBundle : EditorWindow
{
    static string assetDir = Application.dataPath + "/RawAssets/AssetBundles"; // 资源存放路径
    const string assetBundlesPath = "Assets/AssetBundleBuilder/AssetBundles"; // 打包后存放的路径

    [MenuItem("GameTool/AutoSetABName &b")]
    public static void AutoSetABName_Fun()
    {
        ClearAssetBundlesName(); // 清除所有的AssetBundleName;
        SetAssetBundlesName(assetDir); // 设置指定路径下所有需要打包的assetBundleName;
        AssetDatabase.Refresh();
    }

    [MenuItem("GameTool/BuildAssetBundle %&b")]
    public static void BuildAssetBundle_Fun()
    {
        Caching.ClearCache();
        if (!Directory.Exists(assetBundlesPath)) // 如果不存在则创建一个目录
        {
            Directory.CreateDirectory(assetBundlesPath);
        }

        BuildPipeline.BuildAssetBundles(assetBundlesPath, BuildAssetBundleOptions.None, BuildTarget.StandaloneWindows); // 打包所有需要打包的asset

        AssetDatabase.Refresh();
    }

   

    /// <summary>
    /// 清除所有的AssetBundleName，由于打包方法会将所有设置过AssetBundleName的资源打包，所以自动打包前需要清理;
    /// </summary>
    private static void ClearAssetBundlesName()
    {
        string[] abNames = AssetDatabase.GetAllAssetBundleNames(); // 获取所有的AssetBundle名称

        // 强制删除所有AssetBundle名称
        for(int i = 0;i<abNames.Length;++i)
        {
            AssetDatabase.RemoveAssetBundleName(abNames[i], true);
        }
    }

    /// <summary>
    /// 设置所有在指定路径下的AssetBundleName
    /// </summary>
    /// <param name="assetDir"></param>
    private static void SetAssetBundlesName(string _assetPath)
    {
        DirectoryInfo dir = new DirectoryInfo(_assetPath); // 先获取指定路径下的所有Asset，包括子文件夹下的资源;
        FileSystemInfo[] files = dir.GetFileSystemInfos(); // GetFileSystemInfos方法可以获取到指定目录下的所有文件以及子文件;

        for(int i = 0;i < files.Length;++i)
        {
            if(files[i] is DirectoryInfo) // 如果是文件夹则递归处理
            {
                SetAssetBundlesName(files[i].FullName);
            }
            else if (!files[i].Name.EndsWith(".meta")) // 如果是文件的话，则设置AssetBundleName，并排除.meta文件
            {
                SetABName(files[i].FullName); // 逐个设置AssetBundleName
            }
        }
    }

    /// <summary>
    /// 逐个设置单个AssetBundle的Name
    /// </summary>
    /// <param name="assetPath"></param>
    private static void SetABName(string assetPath)
    {
        string importerPath = "Assets" + assetPath.Substring(Application.dataPath.Length); // 这个路径必须是以Assets开始的
        AssetImporter assetImporter = AssetImporter.GetAtPath(importerPath); // 得到Asset

        string tempName = assetPath.Substring(assetPath.LastIndexOf(@"AssetBundles\" )+13);
        string assetName = tempName.Remove(tempName.LastIndexOf(".")); // 获取asset的文件名称

        assetImporter.assetBundleName = assetName; // 最终设置assetBundleName
        assetImporter.assetBundleVariant = "ab";
    }







    /*
   Caching.ClearCache();
   string path = Application.streamingAssetsPath + "/" + "AssetBundles";

   if (!Directory.Exists(path))
   {
       Directory.CreateDirectory(path);
   }
   BuildPipeline.BuildAssetBundles(path, 0, EditorUserBuildSettings.activeBuildTarget);
   AssetDatabase.Refresh();
}
*/
}
