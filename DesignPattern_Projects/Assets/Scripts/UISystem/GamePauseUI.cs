using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class GamePauseUI : IBaseUI
{
    private Text mCurrentStageLv;

    private Button mContinueBtn;
    private Button mBackMenuBtn;

    public override void Init()
    {
        base.Init();
        GameObject canvasGO = GameObject.Find("Canvas"); ;
        mRootUI = UnityTool.FindChild(canvasGO, "GamePauseUI");

        mCurrentStageLv = UITool.FindChild<Text>(mRootUI, "CurrentStageLv");
        mContinueBtn = UITool.FindChild<Button>(mRootUI, "ContinueBtn");
        mBackMenuBtn = UITool.FindChild<Button>(mRootUI, "BackMenuBtn");

        Hide();
    }
}
