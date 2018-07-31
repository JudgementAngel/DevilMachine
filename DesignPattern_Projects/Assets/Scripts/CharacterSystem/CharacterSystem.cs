using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CharacterSystem : IGameSystem
{
    private List<ICharacter> mEnemys = new List<ICharacter>();
    private List<ICharacter> mSoldiers = new List<ICharacter>();

    public void AddEnemy(IEnemy enemy)
    {
        mEnemys.Add(enemy);
    }

    public void RemoveEnemy(IEnemy enemy)
    {
        mEnemys.Remove(enemy);
    }

    public void AddSoldier(ISoldier soldier)
    {
        mSoldiers.Add(soldier);
    }
    public void RemoveSoldier(ISoldier soldier)
    {
        mSoldiers.Remove(soldier);
    }

    public override void Update()
    {
        UpdateEnemy();
        UpdateSoldier();

        RemoveCharacterIsKilled(mEnemys);
        RemoveCharacterIsKilled(mSoldiers);
    }

    private void RemoveCharacterIsKilled(List<ICharacter> characters)
    {
        List<ICharacter> canDestoryList = new List<ICharacter>();
        foreach (ICharacter character in characters)
        {
            if (character.canDestory)
                canDestoryList.Add(character);
        }
        foreach (ICharacter character in canDestoryList)
        {
            character.Release();
            characters.Remove(character);
        }
            
    }

    private void UpdateEnemy()
    {
        foreach (var e in mEnemys)
        {
            e.Update();
            e.UpdateFSMAI(mSoldiers);
        }
    }

    private void UpdateSoldier()
    {
        foreach (var s in mSoldiers)
        {
            s.Update();
            s.UpdateFSMAI(mEnemys);
        }
    }

    public void RunVisitor(ICharacterVisitor visitor)
    {
        foreach (ICharacter soldier in mSoldiers)
        {
            soldier.RunVisitor(visitor);
        }
        foreach (ICharacter enemy in mEnemys)
        {
            enemy.RunVisitor(visitor);
        }
    }
}
