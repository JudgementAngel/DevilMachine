using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class GameStateInfoUI : IBaseUI
{
    private List<GameObject> mHearts;
    private Text mSoliderCount;
    private Text mEnemyCount;
    private Text mCurrentStage;
    private Button mPauseBtn;
    private GameObject mGameOverUI;
    private Button mBackMenuBtn;
    private Text mMessage;
    private Slider mEnergySlider;

    public override void Init()
    {
        base.Init();
        GameObject canvasGO = GameObject.Find("Canvas"); ;
        mRootUI = UnityTool.FindChild(canvasGO, "GameStateUI");

        mHearts = new List<GameObject>();
        mHearts.Add(UnityTool.FindChild(mRootUI, "Heart1"));
        mHearts.Add(UnityTool.FindChild(mRootUI, "Heart2"));
        mHearts.Add(UnityTool.FindChild(mRootUI, "Heart3"));

        mSoliderCount = UITool.FindChild<Text>(mRootUI,"SoldierCount");
        mEnemyCount = UITool.FindChild<Text>(mRootUI,"EnemyCount");
        mCurrentStage = UITool.FindChild<Text>(mRootUI, "CurrentStage");
        mPauseBtn = UITool.FindChild<Button>(mRootUI, "PauseBtn");
        mGameOverUI = UnityTool.FindChild(mRootUI, "GameOverUI");
        mBackMenuBtn = UITool.FindChild<Button>(mRootUI, "BackMenuBtn");
        mMessage = UITool.FindChild<Text>(mRootUI, "Message");
        mEnergySlider = UITool.FindChild<Slider>(mRootUI, "EnergySlider");

        mGameOverUI.SetActive(false);
    }
}
