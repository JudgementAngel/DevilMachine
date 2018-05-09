using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;
using UnityEditor;

public class OrganizeDocuments : EditorWindow
{


    [MenuItem("Assets/OrganizeDocuments", false, 11)]
    public static void OrganizeDocs()
    {
        
        Dictionary<string, string> file_floder;
        file_floder = FileFloderNames();
        string path = AssetDatabase.GetAssetPath(Selection.objects[0]) + "/";
        string fullPath = Application.dataPath + "/" + path.Substring(7);
        //Debug.Log(File.Exists(AssetDatabase.GetAssetPath(Selection.objects[0])));

        //获取指定路径下面的所有文件
        if (Directory.Exists(path))
        {
            DirectoryInfo direction = new DirectoryInfo(path);
            //SearchOption.AllDirectories是包括子文件夹
            //SearchOption.TopDirectoryOnly是不包括子文件夹
            FileInfo[] files = direction.GetFiles("*", SearchOption.TopDirectoryOnly);
            //Debug.Log(files.Length);
            foreach (FileInfo f in files)
            {
                if (f.Name.EndsWith(".meta")) continue;
                string name = f.Name;
                string metaName = name + ".meta";
                string fileType = name.Substring(name.LastIndexOf("."));
                string lowerFileType = fileType.ToLower();

                if (file_floder.ContainsKey(lowerFileType))
                {
                    string floderName = file_floder[lowerFileType];
                    if (File.Exists(fullPath + floderName + "/" + name))
                    {
                        if (f.FullName.EndsWith(file_floder[lowerFileType] + "\\" + name))
                        {
                            continue;
                        }
                        else
                        {
                            Debug.LogWarning(name + "已经存在了!请重命名后再试！");
                        }
                        continue;
                    }
                    CreateFolder(fullPath, floderName);
                    File.Move(fullPath + metaName, fullPath + floderName + "/" + metaName);
                    File.Move(fullPath + name, fullPath + floderName + "/" + name);
                }
                else
                {
                    Debug.LogWarning("未识别文件：" + name + " 请添加键值对或手动归类！");
                }
            }
        }
        else
        {
            Debug.LogError("路径不存在");
        }

        AssetDatabase.Refresh();
        Debug.Log("Finishing up!");
    }

    [MenuItem("Assets/OrganizeDocuments", true, 0)]
    public static bool canOrganizeDocs()
    {
        UnityEngine.Object[] gos = Selection.objects;
        if (gos.Length != 1)
            return false;
        if (File.Exists(AssetDatabase.GetAssetPath(Selection.objects[0]))) return false;
        return true;

    }

    //返回文件后缀(.小写)和文件夹之间的键值对
    private static Dictionary<string, string> FileFloderNames()
    {
        Dictionary<string, string> file_floder;
        file_floder = new Dictionary<string, string>();

        /*添加文件类型和文件夹的键值对*/
        //Textures
        file_floder.Add(".jpg", "Textures");
        file_floder.Add(".png", "Textures");
        file_floder.Add(".psd", "Textures");
        file_floder.Add(".tga", "Textures");
        file_floder.Add(".dds", "Textures");
        //Shaders
        file_floder.Add(".shader", "Shaders");
        file_floder.Add(".cginc", "Shaders");
        file_floder.Add(".hlsl", "Shaders");
        //Scripts
        file_floder.Add(".cs", "Scripts");
        file_floder.Add(".js", "Scripts");

        //Models
        file_floder.Add(".fbx", "Models");
        file_floder.Add(".obj", "Models");

        file_floder.Add(".mat", "Materials");
        file_floder.Add(".unity", "Scenes");
        file_floder.Add(".prefab", "Prefabs");

        return file_floder;
    }


    private static void CreateFolder(string path, string folderName)
    {
        Directory.CreateDirectory(path + folderName);
    }

}
