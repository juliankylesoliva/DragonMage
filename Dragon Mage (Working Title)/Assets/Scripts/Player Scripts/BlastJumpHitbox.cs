using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BlastJumpHitbox : MonoBehaviour
{
    PlayerCtrl player;
    CapsuleCollider2D hitboxCollider;

    [SerializeField] DamageType damageType = DamageType.BLAST_JUMP;
    [SerializeField] int velocityLookaheadFrames = 2;
    [SerializeField] float facingDirectionOffset = 0.25f;
    [SerializeField] float enemyDefeatKnockbackMultiplier = 2f;

    private Vector2 defaultOffset;

    void Awake()
    {
        player = this.transform.parent.GetComponent<PlayerCtrl>();
        hitboxCollider = this.gameObject.GetComponent<CapsuleCollider2D>();
        if (hitboxCollider != null) { defaultOffset = hitboxCollider.offset; }
        else { defaultOffset = Vector2.zero; }
    }

    void Update()
    {
        if (PauseHandler.isPaused) { return; }

        if (player.attacks.isBlastJumpActive)
        {
            hitboxCollider.offset = (defaultOffset + (Vector2.right * (player.movement.isFacingRight ? facingDirectionOffset : -facingDirectionOffset)) + (player.rb2d.velocity * velocityLookaheadFrames * Time.deltaTime));
        }
        else
        {
            if (hitboxCollider.offset != defaultOffset) { hitboxCollider.offset = defaultOffset; }
        }
    }

    void OnTriggerEnter2D(Collider2D other)
    {
        DestroyBlock(other);
        DefeatEnemy(other);
    }

    void OnTriggerStay2D(Collider2D other)
    {
        DestroyBlock(other);
        DefeatEnemy(other);
    }

    private void DestroyBlock(Collider2D other)
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

    private void DefeatEnemy(Collider2D other)
    {
        if (player.attacks.isBlastJumpActive)
        {
            EnemyBehavior enemy = other.gameObject.GetComponent<EnemyBehavior>();
            if (enemy != null)
            {
                if (enemy.DefeatEnemy(damageType))
                {
                    player.temper.NeutralizeTemperBy(-2);
                    enemy.rb2d.velocity += (Vector2.right * player.rb2d.velocity.x * enemyDefeatKnockbackMultiplier);
                }
            }
        }
    }
}
