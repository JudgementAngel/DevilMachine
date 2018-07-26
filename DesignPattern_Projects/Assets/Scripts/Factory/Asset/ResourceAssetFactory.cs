using System;
using System.Collections.Generic;
using System.Text;
using UnityEngine;
using Object = UnityEngine.Object;

public class ResourceAssetFactory : IAssetFactory
{
    private const string SoldierPath = "Characters/Soldier/";
    private const string EnemyPath = "Characters/Enemy/";
    private const string WeaponPath = "Weapons/";
    private const string EffectPath = "Effects/";
    private const string AudioPath = "Audios/";
    private const string SpritePath = "Sprites/";

    

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
        return LoadAsset(SpritePath + name) as Sprite;
    }
    public AudioClip LoadAudioClip(string name)
    {
        return LoadAsset(AudioPath + name) as AudioClip;
    }
    

    private GameObject InstantiateGameObject(string path)
    {
        Object o = Resources.Load(path);
        if(o == null)
        {
            Debug.LogError("无法加载资源，路径" + path);
            return null;
        }

        return GameObject.Instantiate(o) as GameObject;
    }

    private Object LoadAsset(string path)
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
