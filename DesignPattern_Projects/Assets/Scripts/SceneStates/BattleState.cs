using System;
using System.Collections.Generic;
using System.Text;


public class BattleState:ISceneState
{
    public BattleState(SceneStateController controller) : base("03_Battle", controller) { }


    public override void StateStart()
    {
        GameFacade.Instance.Init();
    }

    public override void StateEnd()
    {
        GameFacade.Instance.Release();
    }

    public override void StateUpdate()
    {
        if (GameFacade.Instance.IsGameOver)
        {
            mController.SetState(new MainMenuState(mController));
        }

        GameFacade.Instance.Update();
    }
}
