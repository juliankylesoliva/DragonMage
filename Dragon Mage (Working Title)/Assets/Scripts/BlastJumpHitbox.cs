using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BlastJumpHitbox : MonoBehaviour
{
    PlayerCtrl player;

    void Awake()
    {
        player = this.transform.parent.GetComponent<PlayerCtrl>();
    }

    void OnTriggerStay2D(Collider2D other)
    {
        if (player.attacks.isBlastJumpActive)
        {
            BreakableBlock block = other.gameObject.GetComponent<BreakableBlock>();
            if (block != null && (block.breakableBy == BreakableType.ANY || block.breakableBy == BreakableType.MAGIC))
            {
                player.temper.NeutralizeTemperBy(-2);
                block.onBreak.Invoke();
            }
        }
    }
}
