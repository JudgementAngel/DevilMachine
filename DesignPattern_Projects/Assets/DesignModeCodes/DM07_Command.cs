using System;
using System.Collections.Generic;
using System.Text;
using UnityEngine;

namespace DM
{
    class DM07_Command : MonoBehaviour
    {
        void Start()
        {
            DMInvoker invoker = new DMInvoker();
            ConcreteCommand1 cmd1 = new ConcreteCommand1(new DMReceiver1());
            invoker.AddCommand(cmd1);
            invoker.AddCommand(cmd1);

            invoker.ExecuteCommand();
        }
    }

    public class DMInvoker
    {
        private List<DMICommand> commands = new List<DMICommand>();

        public void AddCommand(DMICommand cmd)
        {
            commands.Add(cmd);
        }

        public void ExecuteCommand()
        {
            foreach (DMICommand cmd in commands)
            {
                cmd.Execute();
            }
            commands.Clear();
        }
    }

    public abstract class DMICommand
    {
        public abstract void Execute();

    }

    public class ConcreteCommand1 : DMICommand
    {
        private DMReceiver1 mReceiver1;

        public ConcreteCommand1(DMReceiver1 receiver1)
        {
            mReceiver1 = receiver1;
        }
        public override void Execute()
        {
            mReceiver1.Action("Command1");
        }

    }

    public class DMReceiver1
    {
        public void Action(string cmd)
        {
            Debug.Log("Receiver1 ÷¥––¡À√¸¡Ó" + cmd);
        }
    }
}
