using System;
using System.Collections.Generic;
using System.Text;
using UnityEngine;

namespace DM
{

    public class DM05_Builder : MonoBehaviour
    {
        void Start()
        {
            IBuilder fatBuilder = new FatPersonBuilder();
            IBuilder thinBuilder = new ThinPersonBuilder();

            Person fatPerson = Director.Construct(fatBuilder);
            Person thinPerson = Director.Construct(thinBuilder);

            fatPerson.Show(); thinPerson.Show();
        }
    }

    class Person
    {
        List<string> parts = new List<string>();

        public void AddPart(string part)
        {
            parts.Add(part);
        }

        public void Show()
        {
            foreach (string part in parts)
            {
                Debug.Log(part);
            }
        }
    }

    class FatPerson : Person
    {

    }

    class ThinPerson : Person
    {

    }

    interface IBuilder
    {
        void AddHead();
        void AddBody();
        void AddHand();
        void AddFeet();
        Person GetResult();
    }

    class FatPersonBuilder : IBuilder
    {
        private Person person;

        public FatPersonBuilder()
        {
            person = new FatPerson();
        }

        public void AddBody()
        {
            person.AddPart("FatBody");
        }

        public void AddFeet()
        {
            person.AddPart("FatFeet");
        }

        public void AddHand()
        {
            person.AddPart("FatHand");
        }

        public void AddHead()
        {
            person.AddPart("FatHead");
        }

        public Person GetResult()
        {
            return person;
        }
    }

    class ThinPersonBuilder : IBuilder
    {
        private Person person;

        public ThinPersonBuilder()
        {
            person = new FatPerson();
        }

        public void AddBody()
        {
            person.AddPart("ThinBody");
        }

        public void AddFeet()
        {
            person.AddPart("ThinFeet");
        }

        public void AddHand()
        {
            person.AddPart("ThinHand");
        }

        public void AddHead()
        {
            person.AddPart("ThinHead");
        }

        public Person GetResult()
        {
            return person;
        }
    }

    class Director
    {
        public static Person Construct(IBuilder builder)
        {
            builder.AddBody();
            builder.AddFeet();
            builder.AddHand();
            builder.AddHead();
            return builder.GetResult();
        }
    }
}