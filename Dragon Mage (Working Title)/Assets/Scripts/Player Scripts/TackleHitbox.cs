using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TackleHitbox : MonoBehaviour
{
    PlayerCtrl player;
    CapsuleCollider2D hitboxCollider;
    SpriteRenderer spriteRenderer;

    [SerializeField] DamageType damageType = DamageType.FIRE_TACKLE;
    [SerializeField] int velocityLookaheadFrames = 2;
    [SerializeField] float facingDirectionOffset = 0.125f;
    [SerializeField] Sprite[] arrowIndicatorSprites;

    private Vector2 defaultOffset;

    void Awake()
    {
        player = this.transform.parent.gameObject.GetComponent<PlayerCtrl>();
        hitboxCollider = this.gameObject.GetComponent<CapsuleCollider2D>();
        spriteRenderer = this.gameObject.GetComponent<SpriteRenderer>();
        if (hitboxCollider) { defaultOffset = hitboxCollider.offset; }
        else { defaultOffset = Vector2.zero; }
    }

    void Update()
    {
        if (PauseHandler.isPaused) { return; }

        if (player.attacks.currentAttackState == AttackState.STARTUP)
        {
            spriteRenderer.sprite = (player.inputVector.y == 0f ? arrowIndicatorSprites[0] : (player.inputVector.y > 0f ? arrowIndicatorSprites[1] : arrowIndicatorSprites[2]));
            spriteRenderer.flipX = !player.movement.isFacingRight;
            if (hitboxCollider.offset != defaultOffset) { hitboxCollider.offset = defaultOffset; }
        }
        else if (player.attacks.currentAttackState == AttackState.ACTIVE)
        {
            spriteRenderer.sprite = null;
            hitboxCollider.offset = (defaultOffset + (Vector2.right * (player.movement.isFacingRight ? facingDirectionOffset : -facingDirectionOffset)) + (player.rb2d.velocity * velocityLookaheadFrames * Time.deltaTime));
        }
        else
        {
            spriteRenderer.sprite = null;
            if (hitboxCollider.offset != defaultOffset) { hitboxCollider.offset = defaultOffset; }
        }
        
    }

    void OnTriggerEnter2D(Collider2D other)
    {
        DestroyBlock(other);
        DefeatEnemy(other);
        DestroyProjectile(other);
    }

    void OnTriggerStay2D(Collider2D other)
    {
        DestroyBlock(other);
        DefeatEnemy(other);
        DestroyProjectile(other);
    }

    private void DestroyBlock(Collider2D other)
    {
        if (player.attacks.currentAttackState == AttackState.ACTIVE)
        {
            BreakableBlock block = other.gameObject.GetComponent<BreakableBlock>();

            if (block != null && !block.isReinforced && (block.breakableBy == BreakableType.ANY || block.breakableBy == BreakableType.FIRE))
            {
                player.temper.NeutralizeTemperBy(1);
                block.onBreak.Invoke();
            }
        }
    }

    private void DefeatEnemy(Collider2D other)
    {
        if (player.attacks.currentAttackState == AttackState.ACTIVE)
        {
            EnemyBehavior enemy = other.gameObject.GetComponent<EnemyBehavior>();
            if (enemy != null)
            {
                if (enemy.DefeatEnemy(damageType))
                {
                    player.temper.NeutralizeTemperBy(1);
                }
            }
        }
    }

    private void DestroyProjectile(Collider2D other)
    {
        if (player.attacks.currentAttackState == AttackState.ACTIVE)
        {
            EnemyProjectileBehavior enemyProj = other.gameObject.GetComponent<EnemyProjectileBehavior>();
            if (enemyProj != null)
            {
                player.temper.NeutralizeTemperBy(1);
                GameObject.Destroy(other.gameObject);
            }
        }
    }
}
