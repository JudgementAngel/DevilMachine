using System;
using System.Collections.Generic;
using System.Text;
using UnityEngine;

namespace DM
{
    class DM12_Adapter:MonoBehaviour
    {
        void Start()
        {
            Adapter adapter = new Adapter(new NewPlugin());
            StandardInterface si = adapter;//new StandardImplementA();
            si.Request();
        }
    }

    interface StandardInterface
    {
        void Request();
    }

    class StandardImplementA : StandardInterface
    {
        public void Request()
        {
            Debug.Log("Standard");
        }
    }

    class Adapter : StandardInterface
    {
        private NewPlugin mPlugin;

        public Adapter(NewPlugin plugin)
        {
            mPlugin = plugin;
        }
        public void Request()
        {
            mPlugin.SpecificRequest();
        }
    }

    class NewPlugin
    {
        public void SpecificRequest()
        {
            Debug.Log("Specific");
        }
    }
}
