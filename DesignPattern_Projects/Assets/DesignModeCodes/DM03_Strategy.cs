using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DM03_Strategy : MonoBehaviour
{
    void Start()
    {
        StrategyContext context = new StrategyContext();
        context.strategy = new ConcreteStrategyA();

        context.Cal();
    }
}

public class StrategyContext
{
    public IStrategy strategy;

    public void Cal()
    {
        strategy.Cal();
    }
}

public interface IStrategy
{
    void Cal();
}

public class ConcreteStrategyA : IStrategy
{
    public void Cal()
    {
        BaseLog.Log("A");
    }
}

public class ConcreteStrategyB : IStrategy
{
    public void Cal()
    {
        BaseLog.Log("B");
    }
}