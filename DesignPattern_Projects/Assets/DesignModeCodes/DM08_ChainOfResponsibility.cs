using System;
using System.Collections.Generic;
using System.Text;
using UnityEngine;

namespace DM
{
    public class DM08_ChainOfResponsibility : MonoBehaviour
    {

        void Start()
        {
            char problem = 'c';

            /* 
            // �ɵĴ�������ķ���
            switch (problem)
            {
                case 'a':
                    new DMHandlerA().Handle();
                    break;
                case 'b':
                    new DMHandlerB().Handle();
                    break;
                default:
                    break;
            }
            */

        
            IDMHandler handlerA = new DMHandlerA();
            IDMHandler handlerB = new DMHandlerB();
            IDMHandler handlerC = new DMHandlerC();
            //handlerA.NextHandler = handlerB;
            //handlerB.NextHandler = handlerC;

            handlerA.SetNextHandle(handlerB).SetNextHandle(handlerC);

            handlerA.Handle(problem);
        }

    }

    public abstract class IDMHandler
    {
        protected IDMHandler mNextHandler = null;
        public IDMHandler NextHandler { set { mNextHandler = value; } }
        public virtual void Handle(char problem) { }

        public IDMHandler SetNextHandle(IDMHandler handler)
        {
            mNextHandler = handler;
            return mNextHandler;
        }
    }

    class DMHandlerA : IDMHandler
    {
        public override void Handle(char problem)
        {
            if (problem == 'a')
                Debug.Log("�������� A ����");
            else
                if (mNextHandler != null)
                mNextHandler.Handle(problem);
        }
    }
    class DMHandlerB : IDMHandler
    {
        public override void Handle(char problem)
        {
            if (problem == 'b')
                Debug.Log("�������� B ����");
            else
            if (mNextHandler != null)
                mNextHandler.Handle(problem);
        }
    }
    class DMHandlerC : IDMHandler
    {
        public override void Handle(char problem)
        {
            if (problem == 'c')
                Debug.Log("�������� C ����");
            else
            if (mNextHandler != null)
                mNextHandler.Handle(problem);
        }
    }
}
