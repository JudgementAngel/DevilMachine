using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CampSystem : IGameSystem
{
    private Dictionary<SoldierType,SoldierCamp> mSoldierCamps = new Dictionary<SoldierType, SoldierCamp>();

    public override void Init()
    {
        base.Init();
        InitCamp(SoldierType.Rookie);
        InitCamp(SoldierType.Sergeant);
        InitCamp(SoldierType.Captain);
    }

    private void InitCamp(SoldierType soldierType)
    {
        GameObject gameObject = null;
        string gameObjectName = null;
        string name = null;
        string icon = null;
        Vector3 position = Vector3.zero;
        float trainTime = 0;

        switch (soldierType)
        {
            case SoldierType.Rookie:
                gameObjectName = "SoldierCamp_Rookie";
                name = "新手兵营";
                icon = "RookieCamp";
                trainTime = 3;
                break;
            case SoldierType.Sergeant:
                gameObjectName = "SoldierCamp_Sergeant";
                name = "中士兵营";
                icon = "SergeantCamp";
                trainTime = 4;
                break;
            case SoldierType.Captain:
                gameObjectName = "SoldierCamp_Captain";
                name = "上尉兵营";
                icon = "CaptainCamp";
                trainTime = 5;
                break;
            default:
                Debug.LogError("无法根据战士类型 "+soldierType +"创建兵营");
                break;
        }
        gameObject = GameObject.Find(gameObjectName);
         position = UnityTool.FindChild(gameObject, "TrainPoint").transform.position;
        SoldierCamp  camp = new SoldierCamp(gameObject,name,icon,soldierType,position,trainTime);

        gameObject.AddComponent<CampOnClick>().camp = camp;

        mSoldierCamps.Add(soldierType,camp);
    }
      
    public override void Update()
    {
        base.Update();
        // 更新所有兵营内部游戏逻辑
        foreach (SoldierCamp soldierCamp in mSoldierCamps.Values)
        {
            soldierCamp.Update();
        }
    }
}
