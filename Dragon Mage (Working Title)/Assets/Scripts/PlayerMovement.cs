using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerMovement : MonoBehaviour
{
    PlayerCtrl player;

    public bool changeFacingDirectionMidair = true;
    public float acceleration = 0.5f;
    public float deceleration = 0.5f;
    public float topSpeed = 18f;
    public float turningSpeed = 0.5f;
    public float airAcceleration = 0.5f;
    public float airDeceleration = 0.5f;
    public float airTurningSpeed = 0.5f;

    public bool isFacingRight = true;

    void Awake()
    {
        player = this.gameObject.GetComponent<PlayerCtrl>();
    }

    public void FacingDirection()
    {
        if (player.form.isChangingForm || player.attacks.isFireTackleActive || player.jumping.isWallJumpCooldownActive || (!changeFacingDirectionMidair && !player.collisions.IsGrounded && !player.collisions.IsOnASlope) || (player.jumping.currentAirStallTime > 0f && player.jumping.currentAirStallTime < player.jumping.maxAirStallTime)) { return; }
        SetFacingDirection(player.inputVector.x);
    }

    public void Movement()
    {
        if (player.form.isChangingForm || player.jumping.isWallJumpCooldownActive || player.attacks.isFireTackleActive) { return; }

        if (player.inputVector.x != 0f)
        {
            if (player.collisions.IsAgainstWall && (player.inputVector.x * (isFacingRight ? 1f : -1f)) > 0f || (player.inputVector.x > 0f ? player.collisions.IsTouchingWallR : player.collisions.IsTouchingWallL))
            {
                player.rb2d.velocity = new Vector2(0f, player.rb2d.velocity.y);
            }
            else if ((player.rb2d.velocity.x * player.inputVector.x) >= 0f)
            {
                if (Mathf.Abs(player.rb2d.velocity.x) < topSpeed)
                {
                    // player.rb2d.velocity = new Vector2(player.rb2d.velocity.x + ((player.collisions.IsGrounded ? acceleration : airAcceleration) * player.inputVector.x * Time.deltaTime), player.rb2d.velocity.y);

                    player.rb2d.velocity += ((player.stateMachine.CurrentState == player.stateMachine.runningState && (player.collisions.IsGrounded || player.collisions.IsOnASlope) ? player.collisions.GetRightVector() : Vector2.right) * (player.collisions.IsGrounded || player.collisions.IsOnASlope ? acceleration : airAcceleration) * player.inputVector.x * Time.deltaTime);
                    if (Mathf.Abs(player.rb2d.velocity.x) > topSpeed)
                    {
                        player.rb2d.velocity = new Vector2(topSpeed * player.inputVector.x, player.rb2d.velocity.y);
                    }

                }
                else if ((player.collisions.IsGrounded || player.collisions.IsOnASlope) && Mathf.Abs(player.rb2d.velocity.x) > topSpeed)
                {
                    if (player.rb2d.velocity.x != 0f)
                    {
                        if (player.rb2d.velocity.x > 0f)
                        {
                            player.rb2d.velocity -= (player.collisions.GetRightVector() * deceleration * Time.deltaTime);
                            if (player.rb2d.velocity.x < topSpeed) { player.rb2d.velocity = new Vector2(topSpeed, player.rb2d.velocity.y); }
                        }
                        else
                        {
                            player.rb2d.velocity += (player.collisions.GetRightVector() * deceleration * Time.deltaTime);
                            if (player.rb2d.velocity.x > topSpeed) { player.rb2d.velocity = new Vector2(-topSpeed, player.rb2d.velocity.y); }
                        }
                    }
                }
                else { /* Nothing */ }
            }
            else
            {
                if (player.rb2d.velocity.x != 0f)
                {
                    player.rb2d.velocity += ((player.collisions.IsGrounded || player.collisions.IsOnASlope ? player.collisions.GetRightVector() : Vector2.right) * (player.collisions.IsGrounded ? turningSpeed : airTurningSpeed) * player.inputVector.x * Time.deltaTime);
                }
            }
        }
        else
        {
            if (player.rb2d.velocity.x > 0f)
            {
                player.rb2d.velocity -= ((player.collisions.IsGrounded || player.collisions.IsOnASlope ? player.collisions.GetRightVector() : Vector2.right) * (player.collisions.IsGrounded ? deceleration : airDeceleration) * Time.deltaTime);
                if (player.rb2d.velocity.x < 0f)
                {
                    player.rb2d.velocity = new Vector2(0f, player.rb2d.velocity.y);
                }
            }
            else if (player.rb2d.velocity.x < 0f)
            {
                player.rb2d.velocity += ((player.collisions.IsGrounded || player.collisions.IsOnASlope ? player.collisions.GetRightVector() : Vector2.right) * (player.collisions.IsGrounded ? deceleration : airDeceleration) * Time.deltaTime);
                if (player.rb2d.velocity.x > 0f)
                {
                    player.rb2d.velocity = new Vector2(0f, player.rb2d.velocity.y);
                }
            }
            else { /* Nothing */ }
        }
    }

    public void SetFacingDirection(float horizontalAxis)
    {
        if (horizontalAxis > 0f)
        {
            isFacingRight = true;
            player.charSprite.flipX = false;
        }
        else if (horizontalAxis < 0f)
        {
            isFacingRight = false;
            player.charSprite.flipX = true;
        }
        else { /* Nothing */ }
    }
}
