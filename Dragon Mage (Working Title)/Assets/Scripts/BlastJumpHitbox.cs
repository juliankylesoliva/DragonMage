using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BlastJumpHitbox : MonoBehaviour
{
    Rigidbody2D rb2d;
    PlayerCtrl player;
    SpriteRenderer playerSprite;

    [SerializeField] float minimumVelocityMagnitude = 8f;
    [SerializeField] float minActiveTime = 0.25f;

    private bool isHitboxActive = false;
    private float currentActiveTime = 0f;

    void Awake()
    {
        player = this.transform.parent.GetComponent<PlayerCtrl>();
        rb2d = player.gameObject.GetComponent<Rigidbody2D>();
        playerSprite = player.gameObject.GetComponent<SpriteRenderer>();
    }

    void Update()
    {
        if (isHitboxActive)
        {
            if (currentActiveTime <= 0f || player.form.isChangingForm)
            {
                if (rb2d.velocity.magnitude < minimumVelocityMagnitude ||
                                player.collisions.IsGrounded ||
                                player.form.isChangingForm ||
                                player.stateMachine.CurrentState == player.stateMachine.glidingState ||
                                player.form.currentMode != CharacterMode.MAGE)
                {
                    isHitboxActive = false;
                    playerSprite.color = Color.white;
                }
            }
            else
            {
                currentActiveTime -= Time.deltaTime;
                if (currentActiveTime < 0f || player.form.isChangingForm)
                {
                    currentActiveTime = 0f;
                }
            }
        }
    }

    void OnTriggerStay2D(Collider2D other)
    {
        if (isHitboxActive)
        {
            BreakableBlock block = other.gameObject.GetComponent<BreakableBlock>();
            if (block != null && (block.breakableBy == BreakableType.ANY || block.breakableBy == BreakableType.MAGIC))
            {
                block.onBreak.Invoke();
            }
        }
    }

    public void ActivateHitbox()
    {
        isHitboxActive = true;
        playerSprite.color = Color.blue;
        currentActiveTime = minActiveTime;
    }
}
