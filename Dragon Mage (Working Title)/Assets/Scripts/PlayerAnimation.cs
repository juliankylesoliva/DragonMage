using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerAnimation : MonoBehaviour
{
    PlayerCtrl player;
    Animator animator;

    void Awake()
    {
        player = this.gameObject.GetComponent<PlayerCtrl>();
        animator = this.gameObject.GetComponent<Animator>();
    }

    public void StandingAnimation()
    {
        animator.Play(player.form.currentMode == CharacterMode.MAGE ? "MagliStand" : "DraelynStand");
        animator.speed = 0f;
    }

    public void RunningAnimation()
    {
        if (player.collisions.IsGrounded)
        {
            if (player.rb2d.velocity.x != 0f)
            {
                animator.Play(player.form.currentMode == CharacterMode.MAGE ? "MagliMove" : "DraelynMove");
                animator.speed = GetRunAnimationSpeed();
            }
            else
            {
                StandingAnimation();
            }
        }
    }

    private float GetRunAnimationSpeed()
    {
        float retVal = ((player.rb2d.velocity.x / player.movement.topSpeed) * (player.movement.isFacingRight ? 1f : -1f));
        return Mathf.Max(retVal, 0f);
    }
}
