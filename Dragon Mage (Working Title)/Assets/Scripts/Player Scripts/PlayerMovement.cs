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
    public bool enableCrouchWalking = false;
    public float crouchTopSpeed = 1f;

    public bool isFacingRight { get; private set; }
    public bool isCrouching { get; private set; }

    private bool isTurningAround = false;
    private bool prevIsTurningAround = false;
    private float prevXVelocity = 0f;
    private float deltaXVelocity = 0f;

    private float intendedXVelocity = 0f;

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
        if (!isCrouching && player.stateMachine.CurrentState == player.stateMachine.runningState)
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

    public void CrouchCheck()
    {
        if (player.stateMachine.CurrentState.name != "Standing" && player.stateMachine.CurrentState.name != "Running" && player.stateMachine.CurrentState.name != "Jumping" && player.stateMachine.CurrentState.name != "Falling")
        {
            Debug.Log("Non-Crouching State!");
            isCrouching = false;
            return;
        }

        if (!isCrouching)
        {
            isCrouching = ((player.collisions.IsGrounded || player.collisions.IsOnASlope) && player.inputVector.y < 0f);
        }
        else
        {
            isCrouching = (player.collisions.IsCeilingAboveWhenUncrouched() || ((player.collisions.IsGrounded || player.collisions.IsOnASlope || player.jumping.enableCrouchJump) && player.inputVector.y < 0f));
            if (!isCrouching) { player.animationCtrl.GroundJumpAnimation(); }
        }
    }

    public void ResetCrouchState()
    {
        isCrouching = false;
    }

    public void Movement()
    {
        if (player.form.isChangingForm || player.jumping.isWallJumpCooldownActive || player.attacks.isFireTackleActive) { return; }

        ApplySlopeResistance();

        if (player.inputVector.x != 0f && (!isCrouching || enableCrouchWalking))
        {
            if (player.collisions.IsAgainstWall && (player.inputVector.x * (isFacingRight ? 1f : -1f)) > 0f || (player.inputVector.x > 0f ? player.collisions.IsTouchingWallR : player.collisions.IsTouchingWallL))
            {
                player.rb2d.velocity = new Vector2(0f, player.rb2d.velocity.y);
            }
            else if ((player.rb2d.velocity.x * player.inputVector.x) >= 0f)
            {
                if (Mathf.Abs(player.rb2d.velocity.x) < (isCrouching ? crouchTopSpeed : topSpeed))
                {
                    player.rb2d.velocity += ((player.stateMachine.CurrentState == player.stateMachine.runningState && (player.collisions.IsGrounded || player.collisions.IsOnASlope) ? player.collisions.GetRightVector() : Vector2.right) * (player.collisions.IsGrounded || player.collisions.IsOnASlope ? acceleration : airAcceleration) * player.inputVector.x * Time.deltaTime);
                    if (Mathf.Abs(player.rb2d.velocity.x) > (isCrouching ? crouchTopSpeed : topSpeed))
                    {
                        player.rb2d.velocity = new Vector2((isCrouching ? crouchTopSpeed : topSpeed) * player.inputVector.x, player.rb2d.velocity.y);
                    }
                }
                else if ((player.collisions.IsGrounded || player.collisions.IsOnASlope) && Mathf.Abs(player.rb2d.velocity.x) > (isCrouching ? crouchTopSpeed : topSpeed))
                {
                    if (player.rb2d.velocity.x != 0f)
                    {
                        if (player.rb2d.velocity.x > 0f)
                        {
                            player.rb2d.velocity -= (player.collisions.GetRightVector(true) * deceleration * Time.deltaTime);
                            if (player.rb2d.velocity.x < (isCrouching ? crouchTopSpeed : topSpeed)) { player.rb2d.velocity = new Vector2((isCrouching ? crouchTopSpeed : topSpeed), player.rb2d.velocity.y); }
                        }
                        else
                        {
                            player.rb2d.velocity += (player.collisions.GetRightVector(true) * deceleration * Time.deltaTime);
                            if (player.rb2d.velocity.x > -(isCrouching ? crouchTopSpeed : topSpeed)) { player.rb2d.velocity = new Vector2(-(isCrouching ? crouchTopSpeed : topSpeed), player.rb2d.velocity.y); }
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
                player.rb2d.velocity -= ((player.collisions.IsGrounded || player.collisions.IsOnASlope ? player.collisions.GetRightVector(true) : Vector2.right) * (player.collisions.IsGrounded ? deceleration : airDeceleration) * Time.deltaTime);
                if (player.rb2d.velocity.x < 0f)
                {
                    player.rb2d.velocity = new Vector2(0f, player.rb2d.velocity.y);
                }
            }
            else if (player.rb2d.velocity.x < 0f)
            {
                player.rb2d.velocity += ((player.collisions.IsGrounded || player.collisions.IsOnASlope ? player.collisions.GetRightVector(true) : Vector2.right) * (player.collisions.IsGrounded ? deceleration : airDeceleration) * Time.deltaTime);
                if (player.rb2d.velocity.x > 0f)
                {
                    player.rb2d.velocity = new Vector2(0f, player.rb2d.velocity.y);
                }
            }
            else { /* Nothing */ }
        }

        if (player.stateMachine.CurrentState.name == "Running" && player.rb2d.velocity.y != 0f && player.collisions.CheckDistanceToGround(slopeSnapDistanceThreshold))
        {
            player.collisions.SnapToGround(false, maxMovingSlopeSnapDistance);
        }

        IntendedMovement();
    }

    public void IntendedMovement()
    {
        if (player.form.isChangingForm || player.jumping.isWallJumpCooldownActive || player.attacks.isFireTackleActive) { return; }

        if (player.inputVector.x != 0f)
        {
            if (player.collisions.IsAgainstWall && (player.inputVector.x * (isFacingRight ? 1f : -1f)) > 0f || (player.inputVector.x > 0f ? player.collisions.IsTouchingWallR : player.collisions.IsTouchingWallL))
            {
                intendedXVelocity = 0f;
            }
            else if ((intendedXVelocity * player.inputVector.x) >= 0f)
            {
                if (Mathf.Abs(intendedXVelocity) < (isCrouching ? crouchTopSpeed : topSpeed))
                {
                    intendedXVelocity += ((player.collisions.IsGrounded || player.collisions.IsOnASlope ? acceleration : airAcceleration) * player.inputVector.x * Time.deltaTime);
                    if (Mathf.Abs(intendedXVelocity) > (isCrouching ? crouchTopSpeed : topSpeed))
                    {
                        intendedXVelocity = ((isCrouching ? crouchTopSpeed : topSpeed) * player.inputVector.x);
                    }
                }
                else if ((player.collisions.IsGrounded || player.collisions.IsOnASlope) && Mathf.Abs(intendedXVelocity) > (isCrouching ? crouchTopSpeed : topSpeed))
                {
                    if (intendedXVelocity != 0f)
                    {
                        if (intendedXVelocity > 0f)
                        {
                            intendedXVelocity -= (deceleration * Time.deltaTime);
                            if (intendedXVelocity < (isCrouching ? crouchTopSpeed : topSpeed)) { intendedXVelocity = (isCrouching ? crouchTopSpeed : topSpeed); }
                        }
                        else
                        {
                            intendedXVelocity += (deceleration * Time.deltaTime);
                            if (intendedXVelocity > -(isCrouching ? crouchTopSpeed : topSpeed)) { intendedXVelocity = -(isCrouching ? crouchTopSpeed : topSpeed); }
                        }
                    }
                }
                else { /* Nothing */ }
            }
            else
            {
                if (intendedXVelocity != 0f)
                {
                    intendedXVelocity += ((player.collisions.IsGrounded ? turningSpeed : airTurningSpeed) * player.inputVector.x * Time.deltaTime);
                }
            }
        }
        else
        {
            if (intendedXVelocity > 0f)
            {
                intendedXVelocity -= ((player.collisions.IsGrounded ? deceleration : airDeceleration) * Time.deltaTime);
                if (intendedXVelocity < 0f)
                {
                    intendedXVelocity = 0f;
                }
            }
            else if (intendedXVelocity < 0f)
            {
                intendedXVelocity += ((player.collisions.IsGrounded ? deceleration : airDeceleration) * Time.deltaTime);
                if (intendedXVelocity > 0f)
                {
                    intendedXVelocity = 0f;
                }
            }
            else { /* Nothing */ }
        }

        if (intendedXVelocity != player.rb2d.velocity.x && player.inputVector.x != 0f)
        {
            if (player.inputVector.x > 0f)
            {
                if (player.rb2d.velocity.x < intendedXVelocity) { player.rb2d.velocity = new Vector2(intendedXVelocity, player.rb2d.velocity.y); }
                else if (player.rb2d.velocity.x > intendedXVelocity) { intendedXVelocity = player.rb2d.velocity.x; }
                else { /* Nothing */ }
            }
            else
            {
                if (player.rb2d.velocity.x > intendedXVelocity) { player.rb2d.velocity = new Vector2(intendedXVelocity, player.rb2d.velocity.y); }
                else if (player.rb2d.velocity.x < intendedXVelocity) { intendedXVelocity = player.rb2d.velocity.x; }
                else { /* Nothing */ }
            }
        }
    }

    public void ResetIntendedXVelocity()
    {
        intendedXVelocity = 0f;
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
