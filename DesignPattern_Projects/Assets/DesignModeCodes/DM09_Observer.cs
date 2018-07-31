using System;
using System.Collections.Generic;
using System.Text;
using UnityEngine;

namespace DM
{
    class DM09_Observer : MonoBehaviour
    {

        void Start()
        {
            ConcreteSubject1 sub1 = new ConcreteSubject1();
            Observer1 ob1 =new Observer1(sub1);
            sub1.RegisterObserver(ob1);

            sub1.subjectState = "AA";
        }

    }

    public abstract class Subject
    {
        List<Observer> mObservers = new List<Observer>();

        public void RegisterObserver(Observer ob)
        {
            mObservers.Add(ob);
        }
        public void RemoveObserver(Observer ob)
        {
            mObservers.Remove(ob);
        }

        public void NotifyObserver()
        {
            foreach (Observer observer in mObservers)
            {
                observer.Update();
            }
        }
    }

    public class ConcreteSubject1 : Subject
    {
        private string mSubjectState;

        public string subjectState
        {
            set { mSubjectState = value; NotifyObserver();}
            get { return mSubjectState; }
        }
    }

    public abstract class Observer
    {
        public abstract void Update();
    }

    public class Observer1:Observer
    {
        public ConcreteSubject1 mSub;
        public Observer1(ConcreteSubject1 sub)
        {
            mSub = sub;
        }
        public override void Update()
        {
            Debug.Log("Observer1 "+ mSub.subjectState);
        }
    }

    public class Observer2 : Observer
    {
        public ConcreteSubject1 mSub;
        public Observer2(ConcreteSubject1 sub)
        {
            mSub = sub;
        }
        public override void Update()
        {
            Debug.Log("Observer2 " + mSub.subjectState);
        }
    }
}
