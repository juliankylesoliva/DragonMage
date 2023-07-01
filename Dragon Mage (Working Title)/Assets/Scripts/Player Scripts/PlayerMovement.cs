using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

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

    public bool isFacingRight { get; private set; }

    private bool isTurningAround = false;
    private bool prevIsTurningAround = false;
    private float prevXVelocity = 0f;
    private float deltaXVelocity = 0f;

    [SerializeField] float slopeSnapDistanceThreshold = 0.1f;
    [SerializeField] float maxMovingSlopeSnapDistance = 1f;
    [SerializeField, Range(0f, 1f)] float topSpeedTurnaroundPercent = 0.5f; 
    [SerializeField] UnityEvent turnaroundEvent;

    void Awake()
    {
        player = this.gameObject.GetComponent<PlayerCtrl>();
    }

    void Start()
    {
        isFacingRight = true;
    }

    void Update()
    {
        if (!PauseHandler.isPaused) { TurnaroundCheck(); }
    }

    private void TurnaroundCheck()
    {
        if (player.stateMachine.CurrentState == player.stateMachine.runningState)
        {
            deltaXVelocity = (player.rb2d.velocity.x - prevXVelocity);
            isTurningAround = ((deltaXVelocity * prevXVelocity) < 0f && (player.inputVector.x * player.rb2d.velocity.x) < 0f);

            if ((player.collisions.IsGrounded || player.collisions.IsOnASlope) && isTurningAround && !prevIsTurningAround && player.rb2d.velocity.magnitude >= (topSpeed * topSpeedTurnaroundPercent))
            {
                turnaroundEvent.Invoke();
            }

            prevXVelocity = player.rb2d.velocity.x;
            prevIsTurningAround = isTurningAround;
        }
        else
        {
            prevXVelocity = 0f;
            deltaXVelocity = 0f;
            isTurningAround = false;
            prevIsTurningAround = false;
        }
    }

    public void ApplySlopeResistance()
    {
        if (player.collisions.IsOnASlope)
        {
            Vector2 groundNormal = player.collisions.GetDirectGroundNormal();
            float angleBetweenNormal = Vector2.Angle(Vector2.up, groundNormal);
            angleBetweenNormal *= Mathf.Deg2Rad;
            Vector2 slopeResist = (player.rb2d.mass * Physics2D.gravity * player.rb2d.gravityScale * Mathf.Sin(angleBetweenNormal));

            player.rb2d.AddForce(-slopeResist);
        }
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
                    ApplySlopeResistance();

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
                            player.rb2d.velocity -= (player.collisions.GetRightVector().normalized * deceleration * Time.deltaTime);
                            if (player.rb2d.velocity.x < topSpeed) { player.rb2d.velocity = new Vector2(topSpeed, player.rb2d.velocity.y); }
                        }
                        else
                        {
                            player.rb2d.velocity += (player.collisions.GetRightVector().normalized * deceleration * Time.deltaTime);
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
                    ApplySlopeResistance();
                    player.rb2d.velocity += ((player.collisions.IsGrounded || player.collisions.IsOnASlope ? player.collisions.GetRightVector().normalized : Vector2.right) * (player.collisions.IsGrounded ? turningSpeed : airTurningSpeed) * player.inputVector.x * Time.deltaTime);
                }
            }
        }
        else
        {
            ApplySlopeResistance();

            if (player.rb2d.velocity.x > 0f)
            {
                player.rb2d.velocity -= ((player.collisions.IsGrounded || player.collisions.IsOnASlope ? player.collisions.GetRightVector().normalized : Vector2.right) * (player.collisions.IsGrounded ? deceleration : airDeceleration) * Time.deltaTime);
                if (player.rb2d.velocity.x < 0f)
                {
                    player.rb2d.velocity = new Vector2(0f, player.rb2d.velocity.y);
                }
            }
            else if (player.rb2d.velocity.x < 0f)
            {
                player.rb2d.velocity += ((player.collisions.IsGrounded || player.collisions.IsOnASlope ? player.collisions.GetRightVector().normalized : Vector2.right) * (player.collisions.IsGrounded ? deceleration : airDeceleration) * Time.deltaTime);
                if (player.rb2d.velocity.x > 0f)
                {
                    player.rb2d.velocity = new Vector2(0f, player.rb2d.velocity.y);
                }
            }
            else { /* Nothing */ }
        }

        if (player.stateMachine.CurrentState.name == "Running" && (player.collisions.IsGrounded || player.collisions.IsOnASlope) && player.rb2d.velocity.y > 0f && player.collisions.CheckDistanceToGround(slopeSnapDistanceThreshold))
        {
            player.collisions.SnapToGround(false, maxMovingSlopeSnapDistance);
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

    public float GetFacingValue()
    {
        return (isFacingRight ? 1f : -1f);
    }
}
