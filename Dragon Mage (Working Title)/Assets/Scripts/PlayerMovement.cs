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
        if (player.isChangingForm || player.isFireTackleActive || player.isWallJumpCooldownActive || (!changeFacingDirectionMidair && !player.collisions.IsGrounded) || (player.currentAirStallTime > 0f && player.currentAirStallTime < player.maxAirStallTime)) { return; }
        SetFacingDirection(Input.GetAxisRaw("Horizontal"));
    }

    public void Movement()
    {
        if (player.isChangingForm || player.isWallJumpCooldownActive || player.isFireTackleActive) { return; }

        if (Input.GetAxisRaw("Horizontal") != 0f)
        {
            if (player.collisions.IsAgainstWall && (Input.GetAxisRaw("Horizontal") * (isFacingRight ? 1f : -1f)) > 0f)
            {
                player.rb2d.velocity = new Vector2(0f, player.rb2d.velocity.y);
            }
            else if ((player.rb2d.velocity.x * Input.GetAxisRaw("Horizontal")) >= 0f)
            {
                if (Mathf.Abs(player.rb2d.velocity.x) < topSpeed)
                {
                    player.rb2d.velocity = new Vector2(player.rb2d.velocity.x + ((player.collisions.IsGrounded ? acceleration : airAcceleration) * Input.GetAxisRaw("Horizontal") * Time.deltaTime), player.rb2d.velocity.y);
                    if (Mathf.Abs(player.rb2d.velocity.x) > topSpeed)
                    {
                        player.rb2d.velocity = new Vector2(topSpeed * Input.GetAxisRaw("Horizontal"), player.rb2d.velocity.y);
                    }

                }
                else if (player.collisions.IsGrounded && Mathf.Abs(player.rb2d.velocity.x) > topSpeed)
                {
                    if (player.rb2d.velocity.x != 0f)
                    {
                        if (player.rb2d.velocity.x > 0f)
                        {
                            player.rb2d.velocity -= (Vector2.right * deceleration * Time.deltaTime);
                            if (player.rb2d.velocity.x < topSpeed) { player.rb2d.velocity = new Vector2(topSpeed, player.rb2d.velocity.y); }
                        }
                        else
                        {
                            player.rb2d.velocity += (Vector2.right * deceleration * Time.deltaTime);
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
                    player.rb2d.velocity += (Vector2.right * (player.collisions.IsGrounded ? turningSpeed : airTurningSpeed) * Input.GetAxisRaw("Horizontal") * Time.deltaTime);
                }
            }
        }
        else
        {
            if (player.rb2d.velocity.x > 0f)
            {
                player.rb2d.velocity -= (Vector2.right * (player.collisions.IsGrounded ? deceleration : airDeceleration) * Time.deltaTime);
                if (player.rb2d.velocity.x < 0f)
                {
                    player.rb2d.velocity = new Vector2(0f, player.rb2d.velocity.y);
                }
            }
            else if (player.rb2d.velocity.x < 0f)
            {
                player.rb2d.velocity += (Vector2.right * (player.collisions.IsGrounded ? deceleration : airDeceleration) * Time.deltaTime);
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
