using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TackleHitbox : MonoBehaviour
{
    PlayerCtrl player;
    CapsuleCollider2D hitboxCollider;

    [SerializeField] float hitboxOffset = 0.4f;

    void Awake()
    {
        player = this.transform.parent.gameObject.GetComponent<PlayerCtrl>();
        hitboxCollider = this.gameObject.GetComponent<CapsuleCollider2D>();
    }

    void Update()
    {
        hitboxCollider.offset = new Vector2(hitboxOffset * (player.movement.isFacingRight ? 1f : -1f), hitboxCollider.offset.y);
    }

    void OnTriggerEnter2D(Collider2D other)
    {
        if (player.attacks.currentAttackState == AttackState.ACTIVE)
        {
            BreakableBlock block = other.gameObject.GetComponent<BreakableBlock>();

            if (block != null && !block.isReinforced && (block.breakableBy == BreakableType.ANY || block.breakableBy == BreakableType.FIRE))
            {
                block.onBreak.Invoke();
            }
        }
    }
}
