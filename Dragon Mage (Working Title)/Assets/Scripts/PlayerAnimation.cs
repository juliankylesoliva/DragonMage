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
                float runSpeed = GetRunAnimationSpeed();
                animator.Play(player.form.currentMode == CharacterMode.MAGE ? "MagliMove" : "DraelynMove", -1, runSpeed > 0f ? Mathf.NegativeInfinity : 0f);
                animator.speed = runSpeed;
            }
            else
            {
                StandingAnimation();
            }
        }
    }

    public void JumpingAnimation()
    {
        if (!player.collisions.IsGrounded && player.rb2d.velocity.y != 0f)
        {
            if (player.rb2d.velocity.y > 0f)
            {
                animator.Play(player.form.currentMode == CharacterMode.MAGE ? "MagliGroundJump" : (player.jumping.currentMidairJumps > 0 ? "DraelynMidairJump" : "DraelynGroundJump"), -1, (player.jumpButtonDown ? 0f : Mathf.NegativeInfinity));
            }
            else
            {
                animator.Play(player.form.currentMode == CharacterMode.MAGE ? "MagliFall" : "DraelynFall");
            }
            animator.speed = 1f;
        }
        else
        {
            StandingAnimation();
        }
    }

    public void GlidingAnimation()
    {
        if (!player.collisions.IsGrounded && player.jumpButtonHeld && player.jumping.currentAirStallTime < player.jumping.maxAirStallTime)
        {
            animator.Play("MagliGlide");
        }
    }

    private float GetRunAnimationSpeed()
    {
        float retVal = ((player.rb2d.velocity.x / player.movement.topSpeed) * (player.movement.isFacingRight ? 1f : -1f));
        return Mathf.Min(Mathf.Max(retVal, 0f), 1f);
    }
}