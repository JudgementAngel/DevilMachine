using System;
using System.Collections.Generic;
using System.Text;
using UnityEngine;

namespace DM
{
    public class DM11_Visitor : MonoBehaviour
    {
        void Start()
        {
            DMSphere sphere1 = new DMSphere();
            DMCylinder cylinder1 = new DMCylinder();
            DMCube cube1 = new DMCube();
            DMCube cube2 = new DMCube();

            DMShapeContainer container = new DMShapeContainer();
            container.AddShape(sphere1);
            container.AddShape(cylinder1);
            container.AddShape(cube1);
            container.AddShape(cube2);

            AmountVisitor amountVisitor = new AmountVisitor();
            container.RunVisitor(amountVisitor);
            Debug.Log("图形总数："+ amountVisitor.amount);

            CubeAmountVisitor cubeAmountVisitor = new CubeAmountVisitor();
            container.RunVisitor(cubeAmountVisitor);
            Debug.Log("立方体总数：" + cubeAmountVisitor.amount);

            EdgeVisitor edgeVisitor = new EdgeVisitor();
            container.RunVisitor(edgeVisitor);
            Debug.Log("边总数：" + edgeVisitor.amount);
        }
    }

    class DMShapeContainer
    {
        private List<IDMShape> mShapes = new List<IDMShape>();

        public void AddShape(IDMShape shape)
        {
            mShapes.Add(shape);
        }

        public void RunVisitor(IShapeVisitor visitor)
        {
            foreach (IDMShape shape in mShapes)
            {
                shape.RunVisitor(visitor);
            }
        }


    }

    public abstract class IDMShape
    {
        public abstract void RunVisitor(IShapeVisitor visitor);
    }

    public class DMSphere : IDMShape
    {
        public override void RunVisitor(IShapeVisitor visitor)
        {
            visitor.VisitSphere(this);

        }
    }
    public class DMCylinder : IDMShape
    {

        public override void RunVisitor(IShapeVisitor visitor)
        {
            visitor.VisitCylinder(this);

        }
    }
    public class DMCube : IDMShape
    {

        public override void RunVisitor(IShapeVisitor visitor)
        {
            visitor.VisitCube(this);

        }
    }

    public abstract class IShapeVisitor
    {
        public abstract void VisitSphere(DMSphere sphere);
        public abstract void VisitCylinder(DMCylinder cylinder);
        public abstract void VisitCube(DMCube cube);
    }

    public class AmountVisitor : IShapeVisitor
    {
        public int amount = 0;
        public override void VisitSphere(DMSphere sphere)
        {
            amount++;
        }

        public override void VisitCylinder(DMCylinder cylinder)
        {
            amount++;
        }

        public override void VisitCube(DMCube cube)
        {
            amount++;
        }
    }

    public class CubeAmountVisitor : IShapeVisitor
    {
        public int amount = 0;
        public override void VisitSphere(DMSphere sphere)
        {
            return;
        }

        public override void VisitCylinder(DMCylinder cylinder)
        {
            return;
        }

        public override void VisitCube(DMCube cube)
        {
            amount++;
        }
    }

    public class EdgeVisitor : IShapeVisitor
    {
        public int amount = 0;
        public override void VisitSphere(DMSphere sphere)
        {
            amount += 30;
        }

        public override void VisitCylinder(DMCylinder cylinder)
        {
            amount += 2; 
        }

        public override void VisitCube(DMCube cube)
        {
            amount += 12;
        }
    }


}