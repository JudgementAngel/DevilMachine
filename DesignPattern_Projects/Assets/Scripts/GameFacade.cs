using System;
using System.Collections.Generic;
using System.ComponentModel.Design.Serialization;
using System.Text;
using UnityEngine;

/// <summary>
/// 对于状态管理来说是外观模式
/// 子系统之间调用来说是中介者
/// </summary>
public class GameFacade
{
    private static GameFacade _instance = new GameFacade();

    public static GameFacade Instance
    {
        get
        {
            if (_instance == null)
            {
                _instance = new GameFacade();
            }
            return _instance;
        }
    }
    
    private bool mIsGameOver = false;

    public bool IsGameOver
    {
        get { return mIsGameOver; }
    }

    private GameFacade() { }

    private ArchievementSystem mArchievementSystem;
    private CampSystem mCampSystem;
    private CharacterSystem mCharacterSystem;
    private EnergySystem mEnergySystem;
    private GameEventSystem mGameEventSystem;
    private StageSystem mStageSystem;

    private CampInfoUI mCampInfoUI;
    private GamePauseUI mGamePauseUI;
    private GameStateInfoUI mGameStateInfoUI;
    private SoldierInfoUI mSoldierInfoUI;

    public void Init()
    {
        // 创建对象
        mArchievementSystem = new ArchievementSystem();
        mCampSystem = new CampSystem();
        mCharacterSystem = new CharacterSystem();
        mEnergySystem = new EnergySystem();
        mGameEventSystem = new GameEventSystem();
        mStageSystem = new StageSystem();
        
        mCampInfoUI = new CampInfoUI();
        mGamePauseUI = new GamePauseUI();
        mGameStateInfoUI = new GameStateInfoUI();
        mSoldierInfoUI = new SoldierInfoUI();
        
        // 初始化对象
        mArchievementSystem.Init();
        mCampSystem.Init();
        mCharacterSystem.Init();
        mEnergySystem.Init();
        mGameEventSystem.Init();
        mStageSystem.Init();

        mCampInfoUI.Init();
        mGamePauseUI.Init();
        mGameStateInfoUI.Init();
        mSoldierInfoUI.Init();

    }

    public void Update()
    {
        mArchievementSystem.Update();
        mCampSystem.Update();
        mCharacterSystem.Update();
        mEnergySystem.Update();
        mGameEventSystem.Update();
        mStageSystem.Update();

        mCampInfoUI.Update();
        mGamePauseUI.Update();
        mGameStateInfoUI.Update();
        mSoldierInfoUI.Update();
    }

    public void Release()
    {
        mArchievementSystem.Release();
        mCampSystem.Release();
        mCharacterSystem.Release();
        mEnergySystem.Release();
        mGameEventSystem.Release();
        mStageSystem.Release();

        mCampInfoUI.Release();
        mGamePauseUI.Release();
        mGameStateInfoUI.Release();
        mSoldierInfoUI.Release();
    }

    public Vector3 GetEnemyTargetPosition()
    {
        //TODO
        return Vector3.zero; 
    }

    public void ShowCampInfo(ICamp camp)
    {
        mCampInfoUI.ShowCampInfo(camp);
    }

    public void AddSoldier(ISoldier soldier)
    {
        mCharacterSystem.AddSoldier(soldier);
    }

    public void AddEnemy(IEnemy enemy)
    {
        mCharacterSystem.AddEnemy(enemy);
    }
}
