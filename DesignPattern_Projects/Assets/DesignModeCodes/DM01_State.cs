using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace DM
{



    public class DM01_State : MonoBehaviour
    {
        void Start()
        {
            Context context = new Context();

            context.SetState(new ConcreteStateA(context));

            context.Handle(5);
            context.Handle(20);
            context.Handle(30);
            context.Handle(4);
            context.Handle(1);
        }
    }

    public class Context
    {
        private IState mState; //m开头的是给私有变量

        public void SetState(IState state)
        {
            mState = state;
        }

        public void Handle(int arg)
        {
            mState.Handle(arg);
        }
    }

    public interface IState
    {
        void Handle(int arg); //这个参数根据实际应用的时候传递不同的参数
    }

    public class ConcreteStateA : IState
    {
        private Context mContext;

        public ConcreteStateA(Context context)
        {
            mContext = context;
        }

        public void Handle(int arg)
        {
            BaseLog.Log("A.Handle" + arg);

            if (arg > 10)
            {
                mContext.SetState(new ConcreteStateB(mContext)); //转换为状态B
            }
        }
    }

    public class ConcreteStateB : IState
    {
        private Context mContext;

        public ConcreteStateB(Context context)
        {
            mContext = context;
        }

        public void Handle(int arg)
        {
            BaseLog.Log("B.Handle" + arg);
            if (arg <= 10)
            {
                mContext.SetState(new ConcreteStateA(mContext)); //转换为状态A
            }
        }
    }
}