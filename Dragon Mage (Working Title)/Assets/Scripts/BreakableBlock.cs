using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public enum BreakableType { MAGIC, FIRE, ANY }

public class BreakableBlock : MonoBehaviour
{
    public BreakableType breakableBy = BreakableType.ANY;
    public bool isReinforced = false;
    public UnityEvent onBreak;
}
