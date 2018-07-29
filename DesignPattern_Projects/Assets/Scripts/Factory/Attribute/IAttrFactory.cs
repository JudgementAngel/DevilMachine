using System;
using System.Collections.Generic;
using System.Text;
using UnityEngine;

public interface IAttrFactory
{
    CharacterBaseAttr GetCahCharacterBaseAttr(System.Type t);
    WeaponBaseAttr GetWeaponBaseAttr(WeaponType weaponType);
}
