using System;
using System.Collections.Generic;
using System.Text;
using UnityEngine;
using Object = UnityEngine.Object;

public class ResourcesAssetFactory : IAssetFactory
{
    public const string SoldierPath = "Characters/Soldier/";
    public const string EnemyPath = "Characters/Enemy/";
    public const string WeaponPath = "Weapons/";
    public const string EffectPath = "Effects/";
    public const string AudioPath = "Audios/";
    public const string SpritePath = "Sprites/";

    

    public GameObject LoadEffect(string name)
    {
        return InstantiateGameObject(EffectPath + name);
       
    }

    public GameObject LoadEnemy(string name)
    {
        return InstantiateGameObject(EnemyPath + name);
        
    }

    public GameObject LoadSoldier(string name)
    {
        return InstantiateGameObject(SoldierPath + name);
        
    }
    public GameObject LoadWeapon(string name)
    {
        return InstantiateGameObject(WeaponPath + name);
    }
    public Sprite LoadSprite(string name)
    {
        //return LoadAsset(SpritePath + name) as Sprite;
        return Resources.Load(SpritePath + name, typeof(Sprite)) as Sprite;
    }
    public AudioClip LoadAudioClip(string name)
    {
        //return LoadAsset(AudioPath + name) as AudioClip;
        return Resources.Load(AudioPath + name, typeof(AudioClip)) as AudioClip;
    }
    

    public GameObject InstantiateGameObject(string path)
    {
        Object o = Resources.Load(path);
        if(o == null)
        {
            Debug.LogError("无法加载资源，路径" + path);
            return null;
        }
        
        return Object.Instantiate(o) as GameObject;
    }

    public Object LoadAsset(string path)
    {
        Object o = Resources.Load(path);
        if (o == null)
        {
            Debug.LogError("无法加载资源，路径" + path);
            return null;
        }

        return o;
    }
}
