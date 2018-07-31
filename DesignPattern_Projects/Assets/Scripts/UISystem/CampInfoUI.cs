using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class CampInfoUI : IBaseUI
{
    private Image mCampIcon;

    private Text mCampName;
    private Text mCampLevel;
    private Text mWeaponLevel;

    private Button mCampUpgradeBtn;
    private Button mWeaponUpgradeBtn;
    private Button mTrainBtn;
    private Button mCancelTrainBtn;

    private Text mAliveCount;
    private Text mTrainingCount;
    private Text mTrainingTime;
    private Text mTrainBtnText;

    private ICamp mCamp;

    public override void Init()
    {
        base.Init();
        GameObject canvasGO = GameObject.Find("Canvas");
        mRootUI = UnityTool.FindChild(canvasGO, "CampInfoUI");

        mCampIcon = UITool.FindChild<Image>(mRootUI, "CampIcon");

        mCampName = UITool.FindChild<Text>(mRootUI, "CampName");
        mCampLevel = UITool.FindChild<Text>(mRootUI, "CampLv");
        mWeaponLevel = UITool.FindChild<Text>(mRootUI, "WeaponLv");

        mCampUpgradeBtn = UITool.FindChild<Button>(mRootUI, "CampUpgradeBtn");
        mWeaponUpgradeBtn = UITool.FindChild<Button>(mRootUI, "WeaponUpgradeBtn");
        mTrainBtn = UITool.FindChild<Button>(mRootUI, "TrainBtn");
        mCancelTrainBtn = UITool.FindChild<Button>(mRootUI, "CancelTrainBtn");

        mAliveCount = UITool.FindChild<Text>(mRootUI, "AliveCount");
        mTrainingCount = UITool.FindChild<Text>(mRootUI, "TrainingCount");
        mTrainingTime = UITool.FindChild<Text>(mRootUI, "TrainingTime");
        mTrainBtnText = UITool.FindChild<Text>(mRootUI,"TrainBtnText");

        mTrainBtn.onClick.AddListener(OnTrainClick);
        mCancelTrainBtn.onClick.AddListener(OnCancelTrainClick);

        mCampUpgradeBtn.onClick.AddListener(OnCampUpgradeClick);
        mWeaponUpgradeBtn.onClick.AddListener(OnWeaponUpgradeClick);

        Hide();
    }

    private void OnTrainClick()
    {
        int energy = mCamp.energyCostTrain;
        if (mFacade.TakeEnergy(energy)) { mCamp.Train(); }
        else { mFacade.ShowMsg("能量不足:"+energy+" ，无法训练新的士兵"); }
    }

    private void OnCancelTrainClick()
    {
        int energy = mCamp.energyCostTrain;
        mFacade.RecycleEnergy(energy);
        mCamp.CancelTrainCommand();
    }

    private void OnCampUpgradeClick()
    {
        int energy = mCamp.energyCostCampUpgrade;
        if (energy < 0)
        {
            mFacade.ShowMsg("兵营已到最大等级，无法再进行升级");
            return;
        }
        if (mFacade.TakeEnergy(energy))
        {
            mCamp.UpgradeCamps();
            ShowCampInfo(mCamp);
        }
        else
        {
            mFacade.ShowMsg("能量不足:" + energy + " ，无法升级兵营");
        }
    }

    private void OnWeaponUpgradeClick()
    {
        int energy = mCamp.energyCostWeaponUpgrade;
        if (energy < 0)
        {
            mFacade.ShowMsg("武器已到最大等级，无法再进行升级");
            return;
        }
        if (mFacade.TakeEnergy(energy))
        {
            mCamp.UpgradeWeapon();
            ShowCampInfo(mCamp);
        }
        else
        {
            mFacade.ShowMsg("能量不足:" + energy + " ，无法升级武器");
        }
    }


    public void ShowCampInfo(ICamp camp)
    {
        mCamp = camp;
        Show();

        mCampIcon.sprite = FactoryManager.AssetFactory.LoadSprite(camp.iconSprite);
        mCampName.text = camp.name;
        mCampLevel.text = camp.lv.ToString();
        ShowWeaponLevel(camp.weaponType);
        mTrainBtnText.text = "训练\n" + mCamp.energyCostTrain + "点能量";

        ShowTrainingInfo();
    }

    public override void Update()
    {
        base.Update();
        if (mCamp != null)
        {
            ShowTrainingInfo();
        }
    }

    private void ShowTrainingInfo()
    {
        mTrainingCount.text = mCamp.trainCount.ToString();
        mTrainingTime.text = mCamp.trainRemainingTime.ToString("0.00");

        mCancelTrainBtn.interactable = (mCamp.trainCount != 0);
    }

    private void ShowWeaponLevel(WeaponType weaponType)
    {
        switch (weaponType)
        {
            case WeaponType.Gun:
                mWeaponLevel.text = "短枪";
                break;
            case WeaponType.Rifle:
                mWeaponLevel.text = "长枪";
                break;
            case WeaponType.Rocket:
                mWeaponLevel.text = "火箭";
                break;
            default:

                break;
        }
    }
}
