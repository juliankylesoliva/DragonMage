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
        if (player.movement.isCrouching)
        {
            if (player.inputVector.y >= 0f && player.collisions.IsCeilingAboveWhenUncrouched())
            {
                animator.Play(player.form.currentMode == CharacterMode.MAGE ? "MagliUncrouchInvalid" : "DraelynUncrouchInvalid");
            }
            else
            {
                animator.Play(player.form.currentMode == CharacterMode.MAGE ? "MagliCrouch" : "DraelynCrouch");
            }
        }
        else
        {
            animator.Play(player.form.currentMode == CharacterMode.MAGE ? "MagliStand" : "DraelynStand");
        }
        
        animator.speed = 0f;
    }

    public void RunningAnimation()
    {
        if (player.movement.isCrouching)
        {
            animator.Play(player.form.currentMode == CharacterMode.MAGE ? "MagliCrouchWalk" : "DraelynCrouchWalk");
            animator.speed = 1f;
        }
        else
        {
            if (player.collisions.IsGrounded || player.collisions.IsOnASlope)
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
    }

    public void GroundJumpAnimation()
    {
        animator.Play(player.form.currentMode == CharacterMode.MAGE ? (player.jumping.enableCrouchJump && player.movement.isCrouching ? "MagliCrouchJump" : "MagliGroundJump") : "DraelynGroundJump");
    }

    public void MidairJumpAnimation()
    {
        animator.speed = 1f;
        animator.Play("DraelynMidairJump", -1, 0f);
    }

    public void DashJumpAnimation()
    {
        animator.speed = 1f;
        animator.Play("DraelynDashJump", -1, 0f);
    }

    public void FallingAnimation()
    {
        animator.speed = 1f;
        animator.Play(player.form.currentMode == CharacterMode.MAGE ? (player.jumping.enableCrouchJump && player.movement.isCrouching ? "MagliCrouchFall" : "MagliFall") : "DraelynFall");
    }

    public void GlidingAnimation()
    {
        animator.Play("MagliGlide");
    }

    public void WallSlidingAnimation()
    {
        animator.Play("MagliWallSlide");
    }

    public void WallClimbingAnimation()
    {
        animator.speed = Mathf.Max(player.rb2d.velocity.y / player.jumping.baseClimbingSpeed, 0.5f);
        animator.Play("DraelynWallClimb");
    }

    public void FireTackleAnimation(int n)
    {
        switch (n)
        {
            case 0:
                animator.Play("DraelynFireTackleStartup");
                break;
            case 1:
                animator.Play("DraelynFireTackleActive");
                break;
            case 2:
                animator.Play("DraelynFireTackleEndlag");
                break;
            case 3:
                animator.Play("DraelynFireTackleBump");
                break;
            case 4:
                animator.Play("DraelynFireTackleFireball");
                break;
            default:
                break;
        }
    }

    public void DodgeAnimation()
    {
        animator.Play("MagliDodge");
        animator.speed = 1f;
    }

    public void SlideAnimation()
    {
        animator.Play("DraelynSlide");
        animator.speed = 1f;
    }

    public void TransformationAnimation(CharacterMode current)
    {
        animator.speed = (0.4f / player.form.FormChangeTime);
        if (current == CharacterMode.MAGE)
        {
            animator.Play("MagliToDraelyn");

        }
        else
        {
            animator.Play("DraelynToMagli");
        }
    }

    public void DamageAnimation(CharacterMode current)
    {
        animator.speed = 1f;
        animator.Play(current == CharacterMode.MAGE ? "MagliHurt" : "DraelynHurt");
    }

    private float GetRunAnimationSpeed()
    {
        float retVal = ((player.rb2d.velocity.x / player.movement.topSpeed) * (player.movement.isFacingRight ? 1f : -1f));
        return Mathf.Min(Mathf.Max(retVal, 0f), 1f);
    }
}
