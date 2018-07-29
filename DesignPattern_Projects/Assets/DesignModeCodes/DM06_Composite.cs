using System;
using System.Collections.Generic;
using System.Text;
using UnityEngine;

namespace DM
{
    class DM06_Composite:MonoBehaviour
    {
        void Start()
        {
            DMComponent root = new DMComposite("Root");
            DMComponent leaf1 = new DMLeaf("leaf1");
            DMComponent leaf2 = new DMLeaf("leaf2");
            DMComponent composite1 = new DMComposite("composite1");
            root.AddChild(leaf1);
            root.AddChild(composite1);
            root.AddChild(leaf2);
            

            DMComponent leaf3 = new DMLeaf("leaf3");
            DMComponent leaf4 = new DMLeaf("leaf4");
            composite1.AddChild(leaf3);
            composite1.AddChild(leaf4);

            ReadComponent(root);
        }

        private void ReadComponent(DMComponent component)
        {
            Debug.Log(component.name);
            List<DMComponent> children = component.children;
            if(children == null || children.Count == 0)return;

            foreach (DMComponent child in children)
            {
                ReadComponent(child);
            }
        }

     
    }

    public abstract class DMComponent
    {
        protected string mName;
        public string name {get { return mName; }}

        public DMComponent(string name)
        {
            mName = name;
            mChildren = new List<DMComponent>();
        }

        protected List<DMComponent> mChildren;
        public List<DMComponent> children { get { return mChildren; } }

        public abstract void AddChild(DMComponent c);
        public abstract void RemoveChild(DMComponent c);
        public abstract DMComponent GetChild(int index);
    }

    public class DMLeaf : DMComponent
    {
        public DMLeaf(string name) : base(name)
        {
        }

        public override void AddChild(DMComponent c)
        {
            return;
        }

        public override void RemoveChild(DMComponent c)
        {
            return;
        }

        public override DMComponent GetChild(int index)
        {
            return null;
        }
    }

    public class DMComposite:DMComponent
    {
        public DMComposite(string name) : base(name)
        {
        }

        public override void AddChild(DMComponent c)
        {
            mChildren.Add(c);
        }

        public override void RemoveChild(DMComponent c)
        {
            mChildren.Remove(c);
        }

        public override DMComponent GetChild(int index)
        {
            if (index >= mChildren.Count) return null;
            return mChildren[index];
        }
    }
}
