using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

namespace MoveEditor
{
    public class SceneTools : EditorWindow
    {
        public enum DebugMode
        {
            None,
            Albedo,
            Normal
        }
        public static int callbackIndex = 0;
        public static List<GameObject> gameObjectsList = new List<GameObject>();
        public static Dictionary<GameObject, int> GameObject_SiblingIndex = new Dictionary<GameObject, int>();
        public static DebugMode debugMode = DebugMode.None;
        //% (ctrl on Windows, cmd on macOS), # (shift), & (alt). 

        [MenuItem("SceneTools/Group %g", false, 0)]
        public static void Group_Fun()
        {
            Handle_Group();
        }

        [MenuItem("SceneTools/Group %g", true)]
        public static bool Validate_Group_Fun()
        {
            return Selection.gameObjects.Length > 0;
        }

        [MenuItem("SceneTools/Ungroup", false, 0)]
        public static void Ungroup_Fun()
        {
            Handle_Ungroup();
        }

        [MenuItem("SceneTools/Ungroup", true)]
        public static bool Validate_Ungroup_Fun()
        {
            return Selection.gameObjects.Length > 0;
        }

        [MenuItem("SceneTools/Extract", false, 0)]
        public static void Extract_Fun()
        {
            Handle_Extract();
        }

        [MenuItem("SceneTools/Extract", true)]
        public static bool Validate_Extract_Fun()
        {
            return Selection.gameObjects.Length > 0;
        }


        [MenuItem("SceneTools/HiddenSelected %h", false, 50)]
        public static void HiddenSelected_Fun()
        {
            Handle_HiddenSelected();
        }

        [MenuItem("SceneTools/HiddenSelected %h", true)]
        public static bool Validate_HiddenSelected_Fun()
        {
            return Selection.gameObjects.Length > 0;
        }

        [MenuItem("SceneTools/HiddenUnselected", false, 50)]
        public static void HiddenUnselected_Fun()
        {
            Handle_HiddenUnselected();
        }

        [MenuItem("SceneTools/HiddenUnselected", true)]
        public static bool Validate_HiddenUnselected_Fun()
        {
            return Selection.gameObjects.Length > 0;
        }

        [MenuItem("SceneTools/UnhiddenAll ", false, 50)]
        public static void UnhiddenAll_Fun()
        {
            Handle_UnhiddenAll();
        }

        [MenuItem("SceneTools/UnhiddenAll ", true)]
        public static bool Validate_UnhiddenAll_Fun()
        {
            return Selection.gameObjects.Length > 0;
        }

        [MenuItem("SceneTools/SelectChildren", false, 100)]
        public static void SelectChildren_Fun()
        {
            Handle_SelectChildren();
        }

        [MenuItem("SceneTools/SelectChildren", true)]
        public static bool Validate_SelectChildren_Fun()
        {
            return Selection.gameObjects.Length > 0;
        }

        [MenuItem("SceneTools/SelectHidden", false, 100)]
        public static void SelectHidden_Fun()
        {
            Handle_SelectHidden();
        }
        [MenuItem("SceneTools/SelectHidden", true)]
        public static bool Validate_SelectHidden_Fun()
        {
            return Selection.gameObjects.Length > 0;
        }

        [MenuItem("SceneTools/MoveToTop %#[", false, 150)]
        public static void MoveToTop_Fun()
        {
            Handle_MoveToTop();
        }
        [MenuItem("SceneTools/MoveToTop %#[", true)]
        public static bool Validate_MoveToTop_Fun()
        {
            return Selection.gameObjects.Length >= 1;
        }

        [MenuItem("SceneTools/MoveToBottom %#]", false, 150)]
        public static void MoveToBottom_Fun()
        {
            Handle_MoveToBottom();
        }
        [MenuItem("SceneTools/MoveToBottom %#]", true)]
        public static bool Validate_MoveToBottom_Fun()
        {
            return Selection.gameObjects.Length >= 1;
        }

        [MenuItem("SceneTools/MoveUp %[", false, 150)]
        public static void MoveUp_Fun()
        {
            Handle_MoveUp();
        }
        [MenuItem("SceneTools/MoveUp %[", true)]
        public static bool Validate_MoveUp_Fun()
        {
            return Selection.gameObjects.Length == 1;
        }

        [MenuItem("SceneTools/MoveDown %]", false, 150)]
        public static void MoveDown_Fun()
        {
            Handle_MoveDown();
        }
        [MenuItem("SceneTools/MoveDown %]", true)]
        public static bool Validate_MoveDown_Fun()
        {
            return Selection.gameObjects.Length == 1;
        }
        [MenuItem("SceneTools/DebugMode/None",false,200)]
        public static void DebugMode_None_Fun()
        {
            debugMode = DebugMode.None;
            Shader.DisableKeyword("_DEBUG_ALBEDO");
            Shader.DisableKeyword("_DEBUG_NORMAL");
        }
        [MenuItem("SceneTools/DebugMode/None", true)]
        public static bool Validate_DebugMode_None_Fun()
        {
            return debugMode != DebugMode.None;
        }
        [MenuItem("SceneTools/DebugMode/Albedo", false, 200)]
        public static void DebugMode_Albedo_Fun()
        {
            debugMode = DebugMode.Albedo;
            Shader.EnableKeyword("_DEBUG_ALBEDO");
            Shader.DisableKeyword("_DEBUG_NORMAL");
        }
        [MenuItem("SceneTools/DebugMode/Albedo", true)]
        public static bool Validate_DebugMode_Albedo_Fun()
        {
            return debugMode != DebugMode.Albedo;
        }
        [MenuItem("SceneTools/DebugMode/Normal", false, 200)]
        public static void DebugMode_Normal_Fun()
        {
            debugMode = DebugMode.Normal;
            Shader.DisableKeyword("_DEBUG_ALBEDO");
            Shader.EnableKeyword("_DEBUG_NORMAL");
        }
        [MenuItem("SceneTools/DebugMode/Normal", true)]
        public static bool Validate_DebugMode_Normal_Fun()
        {
            return debugMode != DebugMode.Normal;
        }
        //--------------------------------------------------------------------------------------------
        //只会对MeshRenderer起作用
        //--------------------------------------------------------------------------------------------
        /// <summary>
        /// 传入的物体是否拥有相同的父对象
        /// </summary>
        public static bool HaveSameParent(GameObject[] gos)
        {
            Transform parent = gos[0].transform.parent;

            foreach (GameObject go in gos)
            {
                if (go.transform.parent != parent)
                    return false;
            }

            return true;
        }
        /// <summary>
        /// 成组
        /// </summary>
        public static void Handle_Group()
        {
            GameObject[] selectedObjs = Selection.gameObjects;
            if (!HaveSameParent(selectedObjs))
            {
                //Debug.Log("选择的物体必须拥有相同的父物体");
                //return;
            }
            GameObject groupGo = new GameObject();
            Undo.RegisterCreatedObjectUndo(groupGo, "Group");
            groupGo.name = "New Group";
           
            if (selectedObjs[0].transform.parent)
            {
                groupGo.transform.parent = selectedObjs[0].transform.parent;
            }
            groupGo.transform.localPosition = Vector3.zero;
            groupGo.transform.localRotation = Quaternion.identity;

            foreach (GameObject go in selectedObjs)
            {
                Undo.SetTransformParent(go.transform, groupGo.transform, "Group");
            }
            EditorGUIUtility.PingObject(groupGo);
        }
        /// <summary>
        /// 解组
        /// </summary>
        public static void Handle_Ungroup()
        {
            List<GameObject> goList = new List<GameObject>();
            GameObject[] selecGameObjects = Selection.gameObjects;
            bool hasChild = false;
            foreach (GameObject go in selecGameObjects)
            {
                if (go.transform.childCount > 0)
                    hasChild = true;
            }
            if (!hasChild)
            {
                Debug.Log("选择的物体没有子物体，不能执行解组操纵");
                return;
            }
            foreach (GameObject go in selecGameObjects)
            {
                foreach (Transform t in go.GetComponentsInChildren<Transform>())
                {
                    if (t.parent == go.transform)
                    {
                        Undo.SetTransformParent(t, go.transform.parent, "Ungroup");// t.parent = go.transform.parent;
                        goList.Add(t.gameObject);
                    }
                }
            }
            Object[] objs = new Object[goList.Count];
            objs = goList.ToArray();
            Selection.objects = objs;
        }
        /// <summary>
        /// 将选中的物体提取到它的父对象
        /// </summary>
        public static void Handle_Extract()
        {
            GameObject[] selectedObjs = Selection.gameObjects;
            foreach (GameObject go in selectedObjs)
            {
                if (go.transform.parent != null)
                {
                    Undo.SetTransformParent(go.transform, go.transform.parent.parent, "Extract");
                }
                else
                {
                    Debug.Log(go.name + "没有父物体");
                }
            }
        }
        /// <summary>
        /// 隐藏选中的物体
        /// </summary>
        public static void Handle_HiddenSelected()
        {
            GameObject[] selectedObjs = Selection.gameObjects;
            foreach (GameObject go in selectedObjs)
            {
                MeshRenderer re = go.GetComponent<MeshRenderer>();
                if (re != null)
                {
                    Undo.RecordObject(re, "HiddenSelected");
                    re.enabled = false;
                }
            }
        }
        /// <summary>
        /// 隐藏未选中的在同一个组里的物体
        /// </summary>
        public static void Handle_HiddenUnselected()
        {
            GameObject[] selectedObjs = Selection.gameObjects;
            Transform parent = null;
            foreach (GameObject go in selectedObjs)
            {
                if (go.transform.parent != parent)
                {
                    parent = go.transform.parent;
                    foreach (MeshRenderer re in parent.GetComponentsInChildren<MeshRenderer>())
                    {
                        Undo.RecordObject(re, "HiddenUnselected");
                        re.enabled = false;
                    }
                }
            }
            foreach (GameObject go in selectedObjs)
            {
                MeshRenderer re = go.GetComponent<MeshRenderer>();
                if (re != null)
                {
                    Undo.RecordObject(re, "HiddenUnselected");
                    re.enabled = true;
                }
            }
        }
        /// <summary>
        /// 物体所在组的隐藏的物体全部显示
        /// </summary>
        public static void Handle_UnhiddenAll()
        {
            GameObject[] selectedObjs = Selection.gameObjects;
            List<MeshRenderer> mrList = new List<MeshRenderer>();
            foreach (GameObject go in selectedObjs)
            {
                foreach (MeshRenderer re in go.GetComponentsInChildren<MeshRenderer>())
                {
                   mrList.Add(re);
                }
                mrList.Remove(go.GetComponent<MeshRenderer>());
            }
            if (mrList.Count == 0)
            {
                foreach (GameObject go in selectedObjs)
                {
                    Transform parentTransform = go.transform.parent;
                    if (parentTransform != null)
                    {
                        foreach (MeshRenderer mr in parentTransform.GetComponentsInChildren<MeshRenderer>())
                        {
                            mrList.Add(mr);
                        }
                        //mrList.Remove(parentTransform.GetComponent<MeshRenderer>());
                    }
                }
            }
            foreach (GameObject go in selectedObjs)
            {
                mrList.Add(go.GetComponent<MeshRenderer>());
            }
            foreach (MeshRenderer mr in mrList.ToArray())
            {
                Undo.RecordObject(mr, "UnhiddenAll");
                mr.enabled = true;
            }
        }
        /// <summary>
        /// 选择全部的子物体，不包括组本身，如果没有自物体，则选择当前同级物体
        /// </summary>
        public static void Handle_SelectChildren()
        {
            GameObject[] selectionObjects = Selection.gameObjects;
            List<GameObject> goList = new List<GameObject>();
            foreach (GameObject go in selectionObjects)
            {
                foreach (Transform t in go.GetComponentsInChildren<Transform>())
                {
                    if (t.gameObject.hideFlags == HideFlags.None && t.gameObject.transform.parent == go.transform)
                    {
                        goList.Add(t.gameObject);
                    }
                }
                goList.Remove(go);
            }
            if (goList.Count == 0)
            {
                foreach (GameObject go in selectionObjects)
                {
                    Transform parentTransform = go.transform.parent;
                    if (parentTransform != null)
                    {
                        foreach (Transform t in parentTransform.GetComponentsInChildren<Transform>())
                        {
                            if (t.gameObject.hideFlags == HideFlags.None && t.gameObject.transform.parent == parentTransform)
                            {
                                goList.Add(t.gameObject);
                            }
                        }
                        goList.Remove(parentTransform.gameObject);
                    }
                    else
                    {
                        //Selection.objects
                        GameObject[] objs = Resources.FindObjectsOfTypeAll<GameObject>();
                        foreach (GameObject obj in objs)
                        {
                            if (obj.hideFlags == HideFlags.None && obj.transform.parent == null)
                            {
                                goList.Add(obj);
                            }
                        }
                    }
                }
            }

            Undo.RecordObjects(Selection.objects, "SelectChildren");
            Selection.objects = goList.ToArray();

        }
        /// <summary>
        /// 选中当前组下面所有隐藏的物体
        /// </summary>
        public static void Handle_SelectHidden()
        {
            GameObject[] gos = Selection.gameObjects;
            List<GameObject> goList = new List<GameObject>();
            foreach (GameObject g in gos)
            {
                foreach (Transform t in g.GetComponentsInChildren<Transform>())
                {
                    if (t.GetComponent<MeshRenderer>() != null && t.GetComponent<MeshRenderer>().enabled == false)
                        goList.Add(t.gameObject);
                    
                }
                goList.Remove(g.gameObject);
            }

            if (goList.Count == 0)
            {
                foreach (GameObject go in gos)
                {
                    if (go.transform.parent != null)
                    {
                        foreach (Transform t in go.transform.parent.GetComponentsInChildren<Transform>())
                        {
                            if (t.GetComponent<MeshRenderer>() != null && t.GetComponent<MeshRenderer>().enabled == false)
                                goList.Add(t.gameObject);
                        }
                    }
                    
                }
            }

            foreach (GameObject g in gos)
            {
                if (g.GetComponent<MeshRenderer>() != null && g.GetComponent<MeshRenderer>().enabled == false)
                    goList.Add(g);
            }
            Undo.RecordObjects(Selection.objects, "SelectHidden");
            Selection.objects = goList.ToArray();
        }
        /// <summary>
        /// 撤销顺序变换的函数
        /// </summary>
        public static void UndoMove()
        {
            Selection.activeGameObject.transform.SetSiblingIndex(callbackIndex);
        }

        public static void UndoMoveGameObjects()
        {
            if (GameObject_SiblingIndex.Count != 0 && gameObjectsList.Count != 0)
            {
                foreach (GameObject go in gameObjectsList.ToArray())
                {
                    int value = 0;
                    GameObject_SiblingIndex.TryGetValue(go, out value);
                    go.transform.SetSiblingIndex( value);
                }
            }
        }
        /// <summary>
        /// 移动物体层级到最顶层
        /// </summary>
        public static void Handle_MoveToTop()
        {
            gameObjectsList.Clear();
            GameObject_SiblingIndex.Clear();
            GameObject[] selectionObjects = Selection.gameObjects;
            foreach (GameObject go in selectionObjects)
            {
                gameObjectsList.Add(go);
                GameObject_SiblingIndex.Add(go,go.transform.GetSiblingIndex());
                go.transform.SetAsFirstSibling();
                Undo.RecordObject(go.transform, "MoveToTop");
            }
            Undo.undoRedoPerformed += UndoMoveGameObjects;
            
        }
        /// <summary>
        /// 移动物体层级到最底层
        /// </summary>
        public static void Handle_MoveToBottom()
        {
            gameObjectsList.Clear();
            GameObject_SiblingIndex.Clear();
            GameObject[] selectionObjects = Selection.gameObjects;
            foreach (GameObject go in selectionObjects)
            {
                gameObjectsList.Add(go);
                GameObject_SiblingIndex.Add(go, go.transform.GetSiblingIndex());
                go.transform.SetAsLastSibling();
                Undo.RecordObject(go.transform, "MoveToBottom");
            }
            Undo.undoRedoPerformed += UndoMoveGameObjects;
        }
        /// <summary>
        /// 向上移动物体一层
        /// </summary>
        public static void Handle_MoveUp()
        {
            Transform sT = Selection.activeGameObject.transform;
            int index = sT.GetSiblingIndex();
            if (sT.parent != null)
            {
                int count = sT.parent.childCount;
                if (index - 1 < 0)
                {
                    index = count;
                }
                else
                {
                    index = index - 1;
                }
            }
            else
            {

                if (index > 0)
                {
                    index = index - 1;
                }
                else
                {
                    index = 0;
                }
            }
            callbackIndex = sT.GetSiblingIndex();
            Undo.undoRedoPerformed += UndoMove;
            Undo.RecordObject(sT, "MoveUp");
            sT.SetSiblingIndex(index);
            EditorGUIUtility.PingObject(sT);
        }
        /// <summary>
        /// 向下移动物体一层
        /// </summary>
        public static void Handle_MoveDown()
        {
            Transform sT = Selection.activeGameObject.transform;
            int index = sT.GetSiblingIndex();
            if (sT.parent != null)
            {
                int count = sT.parent.childCount;
                if (index + 1 >= count)
                {
                    index = 0;
                }
                else
                {
                    index = index + 1;
                }
            }
            else
            {
                index++;
            }
            callbackIndex = sT.GetSiblingIndex();
            Undo.undoRedoPerformed += UndoMove;
            Undo.RecordObject(sT, "MoveDown");
            sT.SetSiblingIndex(index);
            EditorGUIUtility.PingObject(sT);
        }
    }
}