using System;
using System.Collections.Generic;
using UnityEngine;

public class EnemyFactory : ICharacterFactory
{
    public ICharacter CreateCharacter<T>(WeaponType weaponType, Vector3 spawnPosition, int lv = 1)
    {
        return null;
    }
}

