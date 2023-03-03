using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerMovement : MonoBehaviour
{
    PlayerCtrl player;

    [SerializeField] bool changeFacingDirectionMidair = true;
    [SerializeField] float acceleration = 0.5f;
    [SerializeField] float deceleration = 0.5f;
    [SerializeField] float topSpeed = 18f;
    [SerializeField] float turningSpeed = 0.5f;
    [SerializeField] float airAcceleration = 0.5f;
    [SerializeField] float airDeceleration = 0.5f;
    [SerializeField] float airTurningSpeed = 0.5f;

    public bool isFacingRight = true;

    void Awake()
    {
        player = this.gameObject.GetComponent<PlayerCtrl>();
    }

    void Update()
    {
        Movement();
        FacingDirection();
    }

    private void FacingDirection()  // PlayerMovement
    {
        if (isChangingForm || isFireTackleActive || isWallJumpCooldownActive || (!changeFacingDirectionMidair && !playerCollisions.IsGrounded) || (currentAirStallTime > 0f && currentAirStallTime < maxAirStallTime)) { return; }
        SetFacingDirection(Input.GetAxisRaw("Horizontal"));
    }

    private void Movement()
    {
        if (isChangingForm || isWallJumpCooldownActive || isFireTackleActive) { return; }

        if (Input.GetAxisRaw("Horizontal") != 0f)
        {
            if (playerCollisions.IsAgainstWall && (Input.GetAxisRaw("Horizontal") * (isFacingRight ? 1f : -1f)) > 0f)
            {
                rb2d.velocity = new Vector2(0f, rb2d.velocity.y);
            }
            else if ((rb2d.velocity.x * Input.GetAxisRaw("Horizontal")) >= 0f)
            {
                if (Mathf.Abs(rb2d.velocity.x) < topSpeed)
                {
                    rb2d.velocity = new Vector2(rb2d.velocity.x + ((playerCollisions.IsGrounded ? acceleration : airAcceleration) * Input.GetAxisRaw("Horizontal") * Time.deltaTime), rb2d.velocity.y);
                    if (Mathf.Abs(rb2d.velocity.x) > topSpeed)
                    {
                        rb2d.velocity = new Vector2(topSpeed * Input.GetAxisRaw("Horizontal"), rb2d.velocity.y);
                    }

                }
                else if (playerCollisions.IsGrounded && Mathf.Abs(rb2d.velocity.x) > topSpeed)
                {
                    if (rb2d.velocity.x != 0f)
                    {
                        if (rb2d.velocity.x > 0f)
                        {
                            rb2d.velocity -= (Vector2.right * deceleration * Time.deltaTime);
                            if (rb2d.velocity.x < topSpeed) { rb2d.velocity = new Vector2(topSpeed, rb2d.velocity.y); }
                        }
                        else
                        {
                            rb2d.velocity += (Vector2.right * deceleration * Time.deltaTime);
                            if (rb2d.velocity.x > topSpeed) { rb2d.velocity = new Vector2(-topSpeed, rb2d.velocity.y); }
                        }
                    }
                }
                else { /* Nothing */ }
            }
            else
            {
                if (rb2d.velocity.x != 0f)
                {
                    rb2d.velocity += (Vector2.right * (playerCollisions.IsGrounded ? turningSpeed : airTurningSpeed) * Input.GetAxisRaw("Horizontal") * Time.deltaTime);
                }
            }
        }
        else
        {
            if (rb2d.velocity.x > 0f)
            {
                rb2d.velocity -= (Vector2.right * (playerCollisions.IsGrounded ? deceleration : airDeceleration) * Time.deltaTime);
                if (rb2d.velocity.x < 0f)
                {
                    rb2d.velocity = new Vector2(0f, rb2d.velocity.y);
                }
            }
            else if (rb2d.velocity.x < 0f)
            {
                rb2d.velocity += (Vector2.right * (playerCollisions.IsGrounded ? deceleration : airDeceleration) * Time.deltaTime);
                if (rb2d.velocity.x > 0f)
                {
                    rb2d.velocity = new Vector2(0f, rb2d.velocity.y);
                }
            }
            else { /* Nothing */ }
        }
    }

    public void SetFacingDirection(float horizontalAxis)  // PlayerMovement
    {
        if (horizontalAxis > 0f)
        {
            isFacingRight = true;
            charSprite.flipX = false;
        }
        else if (horizontalAxis < 0f)
        {
            isFacingRight = false;
            charSprite.flipX = true;
        }
        else { /* Nothing */ }
    }
}
