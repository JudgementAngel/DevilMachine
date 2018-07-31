using System;
using System.Collections.Generic;
using System.Text;
using UnityEngine;
using Object = UnityEngine.Object;

class ResourcesAssetProxyFactory : IAssetFactory
{
    private ResourcesAssetFactory mAssetFactory = new ResourcesAssetFactory();
    private Dictionary<string, GameObject> mSoldiers = new Dictionary<string, GameObject>();
    private Dictionary<string, GameObject> mEnemys = new Dictionary<string, GameObject>();
    private Dictionary<string, GameObject> mWeapons = new Dictionary<string, GameObject>();
    private Dictionary<string, GameObject> mEffects = new Dictionary<string, GameObject>();
    private Dictionary<string, AudioClip> mAudioClips = new Dictionary<string, AudioClip>();
    private Dictionary<string, Sprite> mSprites = new Dictionary<string, Sprite>();

    public GameObject LoadGameObject(string name, Dictionary<string, GameObject> dic, string path)
    {
        if (dic.ContainsKey(name))
        {
            return Object.Instantiate(dic[name]);
        }
        GameObject asset = mAssetFactory.InstantiateGameObject(path + name);
        dic.Add(name, asset);
        return asset;
    }

    public GameObject LoadSoldier(string name)
    {
        return LoadGameObject(name, mSoldiers, ResourcesAssetFactory.SoldierPath);
    }

    public GameObject LoadEnemy(string name)
    {
        return LoadGameObject(name, mEnemys, ResourcesAssetFactory.EnemyPath);
    }

    public GameObject LoadWeapon(string name)
    {
        return LoadGameObject(name, mWeapons, ResourcesAssetFactory.WeaponPath);
    }

    public GameObject LoadEffect(string name)
    {
        return LoadGameObject(name, mEffects, ResourcesAssetFactory.EffectPath);
    }

    public AudioClip LoadAudioClip(string name)
    {
        if (mAudioClips.ContainsKey(name))
        {
            return mAudioClips[name];
        }

        AudioClip audio = mAssetFactory.LoadAudioClip(name);
        mAudioClips.Add(name, audio);
        return audio;

    }
    public Sprite LoadSprite(string name)
    {

        if (mSprites.ContainsKey(name))
        {
            return mSprites[name];
        }

        Sprite sprite = mAssetFactory.LoadSprite(name);
        mSprites.Add(name, sprite);
        return sprite;
    }
}
