using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerJumping : MonoBehaviour
{
    PlayerCtrl player;

    [Header("Jumping Variables")]
    public bool enableSpeedHopping = true;
    public float jumpSpeed = 4f;
    public float risingGravity = 1f;
    public float fallingGravity = 1f;
    public float fallSpeed = 6f;

    [Header("Variable Jump Variables")]
    public bool enableVariableJumps = true;
    public float variableJumpDecay = 0.5f;
    [HideInInspector] public bool jumpIsHeld = false;

    [Header("Air Stalling Variables")]
    public bool enableAirStalling = true;
    public float minimumAirStallHeight = 1f;
    public float airStallSpeed = 1f;
    [Range(0f, 5f)] public float maxAirStallTime = 3f;
    [HideInInspector] public float currentAirStallTime = 0f;

    [Header("Wall Climb Variables")]
    public bool enableWallClimbing = true;
    public float minimumWallClimbHeight = 1f;
    public float baseClimbingSpeed = 4f;
    public float maxClimbingSpeed = 12f;
    public float climbingGravity = 0.25f;
    public float maxWallClimbTime = 3f;
    public float postClimbDashWindow = 1f;
    public float wallVaultStartSpeed = 3f;
    public float maxWallVaultStartSpeed = 6f;
    [HideInInspector] public float currentWallClimbTime = 0f;
    [HideInInspector] public float storedWallClimbSpeed = 0f;
    [HideInInspector] public float postClimbDashTimeLeft = 0f;

    [Header("Wall Jump Variables")]
    public bool enableWallJumping = true;
    public float minimumWallJumpHeight = 1f;
    public float wallSlideSpeed = 1f;
    public float verticalWallJumpSpeed = 4f;
    public float horizontalWallJumpSpeed = 6f;
    public float wallJumpCooldown = 0.25f;
    [HideInInspector] public bool isWallJumpCooldownActive = false;

    [Header("Midair Jump Variables")]
    [Range(0, 5)] public int maxMidairJumps = 3;
    public float midairJumpSpeed = 4.25f;
    public Vector2 forwardMidairJumpBonus;
    [HideInInspector] public int currentMidairJumps = 0;

    [Header("Running Jump Variables")]
    public bool enableRunningJumpBonus = true;
    public float runningJumpMultiplier = 1f;
    
    void Awake()
    {
        player = this.gameObject.GetComponent<PlayerCtrl>();
    }

    private IEnumerator WallJumpCooldownCR()
    {
        if (!isWallJumpCooldownActive)
        {
            isWallJumpCooldownActive = true;
            float currentWallJumpCooldownTimer = wallJumpCooldown;
            while (player.rb2d.velocity.y > 0f || currentWallJumpCooldownTimer > 0f)
            {
                if (!player.form.isChangingForm) { currentWallJumpCooldownTimer -= Time.deltaTime; }
                yield return null;
            }
            isWallJumpCooldownActive = false;
        }
        yield break;
    }

    public bool CanGroundJump()
    {
        return ((player.collisions.IsGrounded || player.buffers.coyoteTimeLeft > 0f) && player.buffers.jumpBufferTimeLeft > 0f);
    }

    public void GroundJumpStart()
    {
        player.buffers.jumpBufferTimeLeft = 0f;
        jumpIsHeld = true;
        player.rb2d.gravityScale = risingGravity;

        LandingReset();

        bool didPlayerSpeedHop = (enableSpeedHopping && (player.rb2d.velocity.x * player.inputVector.x) > 0f && Mathf.Abs(player.rb2d.velocity.x) >= player.movement.topSpeed && player.buffers.highestSpeedBuffer >= Mathf.Abs(player.rb2d.velocity.x));
        float horizontalResult = (didPlayerSpeedHop ? (player.buffers.highestSpeedBuffer * player.inputVector.x) : player.rb2d.velocity.x);
        if (didPlayerSpeedHop && Mathf.Abs(horizontalResult) >= (Mathf.Abs(player.rb2d.velocity.x) + 0.25f))
        {
            GameObject tempObj = EffectFactory.SpawnEffect("SpeedHopSpark", player.collisions.groundCheckObj.position);
            SpriteRenderer tempSprite = tempObj.GetComponent<SpriteRenderer>();
            if (tempSprite != null) { tempSprite.flipX = !player.movement.isFacingRight; }
        }
        player.rb2d.velocity = new Vector2(horizontalResult, jumpSpeed + (enableRunningJumpBonus ? Mathf.Abs(horizontalResult / player.movement.topSpeed) * runningJumpMultiplier : 0f));
    }

    public void GroundJumpUpdate()
    {
        if (player.rb2d.velocity.y > 0f)
        {
            if (jumpIsHeld && !player.jumpButtonHeld)
            {
                jumpIsHeld = false;
            }

            if (enableVariableJumps && !jumpIsHeld)
            {
                player.rb2d.velocity = new Vector2(player.rb2d.velocity.x, player.rb2d.velocity.y - (variableJumpDecay * Time.deltaTime));
            }
        }
    }

    public void FallingUpdate()
    {
        if (!player.attacks.isBlastJumpActive && player.rb2d.velocity.y < -fallSpeed)
        {
            player.rb2d.velocity = new Vector2(player.rb2d.velocity.x, -fallSpeed);
        }
    }

    public bool CanGlide()
    {
        return (enableAirStalling && player.rb2d.velocity.y <= 0f && currentAirStallTime <= 0f && player.collisions.CheckDistanceToGround(minimumAirStallHeight) && player.jumpButtonHeld);
    }

    public void GlideStart()
    {
        player.rb2d.gravityScale = 0f;
        player.rb2d.velocity = new Vector2(player.rb2d.velocity.x, -airStallSpeed);
    }

    public void GlideUpdate()
    {
        player.rb2d.velocity = new Vector2(player.rb2d.velocity.x, -airStallSpeed);
        currentAirStallTime += Time.deltaTime;
    }

    public void GlideCancel()
    {
        currentAirStallTime = maxAirStallTime;
    }

    public bool CanMidairJump()
    {
        return (player.stateMachine.PreviousState != player.stateMachine.wallVaultingState && !player.collisions.IsGrounded && currentMidairJumps < maxMidairJumps && player.buffers.jumpBufferTimeLeft > 0f && (currentWallClimbTime <= 0f || currentWallClimbTime >= maxWallClimbTime) && postClimbDashTimeLeft <= 0f);
    }

    public void MidairJump()
    {
        player.buffers.jumpBufferTimeLeft = 0f;
        jumpIsHeld = true;
        player.rb2d.gravityScale = risingGravity;
        Vector2 newVelocity = new Vector2(player.rb2d.velocity.x, midairJumpSpeed);
        if ((player.movement.isFacingRight ? 1f : -1f) * player.rb2d.velocity.x > 0f)
        {
            float bonusXVelocity = forwardMidairJumpBonus.x * (player.rb2d.velocity.x > 0f ? 1f : -1f);
            float bonusYVelocity = Mathf.Abs(forwardMidairJumpBonus.y);
            newVelocity += new Vector2(bonusXVelocity, bonusYVelocity);
        }
        else
        {
            if (Mathf.Abs(player.rb2d.velocity.x) > player.movement.topSpeed)
            {
                newVelocity.x = player.movement.topSpeed * (player.rb2d.velocity.x > 0f ? 1f : -1f);
            }
        }
        player.rb2d.velocity = newVelocity;
        currentMidairJumps++;
    }

    public bool CanWallSlide()
    {
        return (enableWallJumping && player.collisions.CheckDistanceToGround(minimumWallJumpHeight) && !player.collisions.IsGrounded && player.collisions.IsAgainstWall && (player.movement.isFacingRight ? (player.inputVector.x > 0f && player.collisions.IsTouchingWallR) : (player.inputVector.x < 0f && player.collisions.IsTouchingWallL)) && (!player.jumpButtonHeld || !jumpIsHeld || player.rb2d.velocity.y < 0f));
    }

    public void WallSlideStart()
    {
        jumpIsHeld = false;
        player.rb2d.gravityScale = 0f;
        player.rb2d.velocity = new Vector2(0f, -wallSlideSpeed);
    }

    public bool IsWallSlideCanceled()
    {
        return (!player.collisions.IsAgainstWall || !player.collisions.CheckDistanceToGround(minimumWallJumpHeight) || (player.inputVector.x * (player.movement.isFacingRight ? 1f : -1f)) <= 0f);
    }

    public bool CanWallJump()
    {
        return (player.stateMachine.CurrentState == player.stateMachine.wallSlidingState && !isWallJumpCooldownActive && player.buffers.jumpBufferTimeLeft > 0f);
    }

    public void WallJumpStart()
    {
        player.buffers.jumpBufferTimeLeft = 0f;
        jumpIsHeld = true;
        player.rb2d.gravityScale = risingGravity;

        float horizontalResult = Mathf.Max(player.buffers.highestSpeedBuffer, horizontalWallJumpSpeed);
        Vector2 newVelocity = new Vector2((player.movement.isFacingRight ? -horizontalResult : horizontalResult), verticalWallJumpSpeed);
        player.movement.SetFacingDirection((player.collisions.IsTouchingWallL ? 1f : (player.collisions.IsTouchingWallR ? -1f : (player.movement.isFacingRight ? -1f : 1f))));
        player.rb2d.velocity = newVelocity;
        StartCoroutine(WallJumpCooldownCR());
    }

    public bool CanWallClimb()
    {
        return (enableWallClimbing && player.collisions.CheckDistanceToGround(minimumWallClimbHeight) && currentWallClimbTime <= 0f && !player.collisions.IsGrounded && player.collisions.IsAgainstWall && (player.inputVector.x * (player.movement.isFacingRight ? 1f : -1f)) > 0f);
    }

    public void WallClimbStart()
    {
        player.rb2d.gravityScale = climbingGravity;
        if (storedWallClimbSpeed <= 0f)
        {
            storedWallClimbSpeed = Mathf.Min(Mathf.Max(player.buffers.highestSpeedBuffer, baseClimbingSpeed), maxClimbingSpeed);
            player.rb2d.velocity = new Vector2(0f, storedWallClimbSpeed);
        }
    }

    public void WallClimbUpdate()
    {
        player.rb2d.velocity = new Vector2(0f, player.rb2d.velocity.y);
        currentWallClimbTime += Time.deltaTime;
    }

    public void WallClimbEnd()
    {
        currentWallClimbTime = maxWallClimbTime;
    }

    public void WallClimbCancel()
    {
        player.rb2d.velocity = Vector2.zero;
        player.rb2d.gravityScale = fallingGravity;
    }

    public bool IsWallClimbCanceled()
    {
        return (currentWallClimbTime <= 0f || player.rb2d.velocity.y <= 0f || !player.collisions.IsAgainstWall || (player.inputVector.x * (player.movement.isFacingRight ? 1f : -1f)) <= 0f);
    }

    public bool CanStartWallVault()
    {
        return (currentWallClimbTime < maxWallClimbTime && player.rb2d.velocity.y > 0f && !player.collisions.IsAgainstWall && (player.inputVector.x * (player.movement.isFacingRight ? 1f : -1f)) > 0f);
    }

    public void WallVaultStart()
    {
        postClimbDashTimeLeft = postClimbDashWindow;
        player.rb2d.gravityScale = risingGravity;
        player.rb2d.velocity = (Vector2.up * Mathf.Min(maxWallVaultStartSpeed, Mathf.Max(wallVaultStartSpeed, player.rb2d.velocity.y)));
    }

    public bool CanWallVaultDash()
    {
        return (postClimbDashTimeLeft > 0f && player.rb2d.velocity.y > 0f && !player.collisions.IsAgainstWall && (player.inputVector.x * (player.movement.isFacingRight ? 1f : -1f)) > 0f && player.jumpButtonHeld);
    }

    public void WallVaultUpdate()
    {
        player.rb2d.velocity = new Vector2(0f, player.rb2d.velocity.y);
        postClimbDashTimeLeft -= Time.deltaTime;
    }

    public void WallVaultDash()
    {
        currentAirStallTime = 0f;
        currentMidairJumps = 0;
        postClimbDashTimeLeft = 0f;

        player.buffers.jumpBufferTimeLeft = 0f;
        jumpIsHeld = true;
        player.rb2d.gravityScale = risingGravity;

        player.rb2d.velocity = new Vector2(storedWallClimbSpeed * player.inputVector.x, jumpSpeed);
    }

    public void WallVaultEnd()
    {
        postClimbDashTimeLeft = 0f;
    }

    public bool IsWallVaultCanceled()
    {
        return (postClimbDashTimeLeft <= 0f || player.rb2d.velocity.y <= 0f || (player.inputVector.x * (player.movement.isFacingRight ? 1f : -1f)) <= 0f);
    }

    public void LandingReset()
    {
        currentAirStallTime = 0f;
        currentWallClimbTime = 0f;
        storedWallClimbSpeed = 0f;
        postClimbDashTimeLeft = 0f;
        currentMidairJumps = 0;
    }
}