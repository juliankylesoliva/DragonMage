using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TackleHitbox : MonoBehaviour
{
    PlayerCtrl player;
    CapsuleCollider2D hitboxCollider;
    SpriteRenderer spriteRenderer;

    [SerializeField] float hitboxOffset = 0.4f;
    [SerializeField] int framesToChangeSprite = 3;
    [SerializeField] Sprite[] upHitboxSprites;
    [SerializeField] Sprite[] forwardHitboxSprites;
    [SerializeField] Sprite[] downHitboxSprites;
    [SerializeField] Sprite[] arrowIndicatorSprites;

    private float defaultYOffSet = 0f;
    private bool showSecondSprite = false;
    private int spriteTimer = 0;

    void Awake()
    {
        player = this.transform.parent.gameObject.GetComponent<PlayerCtrl>();
        hitboxCollider = this.gameObject.GetComponent<CapsuleCollider2D>();
        spriteRenderer = this.gameObject.GetComponent<SpriteRenderer>();
        defaultYOffSet = hitboxCollider.offset.y;
    }

    void Update()
    {
        if (PauseHandler.isPaused) { return; }

        hitboxCollider.offset = new Vector2(hitboxOffset * (player.movement.isFacingRight ? 1f : -1f), defaultYOffSet + (player.collisions.IsGrounded ? 0f : (hitboxOffset * (player.rb2d.velocity.y == 0f ? 0f : (player.rb2d.velocity.y > 0f ? 1f : -1f)))));
        if (player.attacks.currentAttackState == AttackState.STARTUP)
        {
            spriteRenderer.sprite = (player.inputVector.y == 0f ? arrowIndicatorSprites[0] : (player.inputVector.y > 0f ? arrowIndicatorSprites[1] : arrowIndicatorSprites[2]));
            spriteRenderer.flipX = !player.movement.isFacingRight;
        }
        else if (player.attacks.currentAttackState == AttackState.ACTIVE)
        {
            spriteRenderer.sprite = (player.rb2d.velocity.y == 0f ? forwardHitboxSprites[showSecondSprite ? 1 : 0] : (player.rb2d.velocity.y > 0f ? upHitboxSprites[showSecondSprite ? 1 : 0] : downHitboxSprites[showSecondSprite ? 1 : 0]));
            spriteRenderer.flipX = !player.movement.isFacingRight;
            spriteTimer++;
            if (spriteTimer >= framesToChangeSprite)
            {
                spriteTimer = 0;
                showSecondSprite = !showSecondSprite;
            }
        }
        else
        {
            spriteTimer = 0;
            spriteRenderer.sprite = null;
            showSecondSprite = false;
        }
        
    }

    void OnTriggerEnter2D(Collider2D other)
    {
        DestroyBlock(other);
    }

    void OnTriggerStay2D(Collider2D other)
    {
        DestroyBlock(other);
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
}
