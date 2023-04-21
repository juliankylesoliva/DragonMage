using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public enum BreakableType { MAGIC, FIRE, ANY }

public class BreakableBlock : MonoBehaviour
{
    [SerializeField] GameObject fragmentPrefab;

    public BreakableType breakableBy = BreakableType.ANY;
    public bool isReinforced = false;
    public UnityEvent onBreak;

    public void SpawnFragments()
    {
        Instantiate(fragmentPrefab, this.transform.position, fragmentPrefab.transform.rotation);
    }

    public void PlayBreakSound()
    {
        SoundFactory.SpawnSound(isReinforced ? "object_block_reinforced" : "object_block_breakable", this.transform.position);
    }
}
