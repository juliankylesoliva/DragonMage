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
    [SerializeField] ParticleSystem glidingParticles;
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
    public float ledgeSnapDistance = 0.35f;
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

    [Header("Crouch Jump and Super Jump Variables")]
    public bool enableCrouchJump = false;
    public bool enableSuperJump = false;
    public float superJumpChargeTime = 1f;
    public float superJumpRetentionTime = 3f;
    public float superJumpSpeedMultiplier = 1f;
    [SerializeField] ParticleSystem superJumpParticles;

    public float currentSuperJumpChargeTimer { get; private set; }
    private float currentSuperJumpRetentionTimer = 0f;
    public bool isSuperJumpReady { get { return currentSuperJumpRetentionTimer > 0f; } }

    public float fallTimer { get; private set; }

    void Awake()
    {
        player = this.gameObject.GetComponent<PlayerCtrl>();
    }

    void Update()
    {
        if (!PauseHandler.isPaused)
        {
            DoSuperJumpChargeTimer();
            DoSuperJumpRetentionTimer();
        }
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

    private void DoSuperJumpChargeTimer()
    {
        if (player.movement.isCrouching && player.inputVector.x == 0f && player.crouchButtonHeld && (player.collisions.IsGrounded || player.collisions.IsOnASlope) && player.stateMachine.CurrentState.name == "Standing")
        {
            if (currentSuperJumpChargeTimer < superJumpChargeTime && currentSuperJumpRetentionTimer <= 0f)
            {
                currentSuperJumpChargeTimer += Time.deltaTime;
                if (currentSuperJumpChargeTimer >= superJumpChargeTime)
                {
                    superJumpParticles.Play();
                    SoundFactory.SpawnSound("jump_draelyn_charged", this.transform.position);
                    currentSuperJumpChargeTimer = superJumpChargeTime;
                    currentSuperJumpRetentionTimer = superJumpRetentionTime;
                }
            }
        }
        else
        {
            if (currentSuperJumpRetentionTimer <= 0f)
            {
                superJumpParticles.Stop();
                currentSuperJumpChargeTimer = 0f;
            }
        }
    }

    private void DoSuperJumpRetentionTimer()
    {
        if (currentSuperJumpRetentionTimer > 0f)
        {
            if (currentSuperJumpRetentionTimer >= superJumpRetentionTime && player.movement.isCrouching && player.crouchButtonHeld && (player.collisions.IsGrounded || player.collisions.IsOnASlope) && (player.stateMachine.CurrentState.name == "Standing" || player.stateMachine.CurrentState.name == "Running"))
            {
                currentSuperJumpRetentionTimer = superJumpRetentionTime;
            }
            else
            {
                currentSuperJumpRetentionTimer -= Time.deltaTime;
                if (currentSuperJumpRetentionTimer <= 0f)
                {
                    superJumpParticles.Stop();
                    ResetSuperJumpTimers();
                }
            }
        }
    }

    public void ResetSuperJumpTimers()
    {
        superJumpParticles.Stop();
        currentSuperJumpChargeTimer = 0f;
        currentSuperJumpRetentionTimer = 0f;
    }

    public void SetFallTimer()
    {
        if (player.rb2d.velocity.y > 0f)
        {
            fallTimer = (-player.rb2d.velocity.y / (risingGravity * Physics2D.gravity.y));
        }
    }

    public void EndFallTimer()
    {
        fallTimer = 0f;
    }

    public void UpdateFallTimer()
    {
        if (fallTimer > 0f)
        {
            fallTimer -= Time.deltaTime;
            if (fallTimer < 0f)
            {
                EndFallTimer();
            }
        }
    }

    public bool CanGroundJump()
    {
        return (player.stateMachine.CurrentState.name != "Jumping" && (player.collisions.IsGrounded || player.collisions.IsOnASlope || player.buffers.coyoteTimeLeft > 0f) && (!player.movement.isCrouching || enableCrouchJump || !player.collisions.IsCeilingAboveWhenUncrouched()) && player.buffers.jumpBufferTimeLeft > 0f);
    }

    public void GroundJumpStart()
    {
        player.buffers.ResetJumpBuffer();
        jumpIsHeld = true;
        player.rb2d.gravityScale = risingGravity;

        if (!enableCrouchJump) { player.movement.ResetCrouchState(); }

        LandingReset();

        bool didPlayerSpeedHop = (enableSpeedHopping && !player.movement.isCrouching && (player.rb2d.velocity.x * player.inputVector.x) > 0f && Mathf.Abs(player.rb2d.velocity.x) > player.movement.topSpeed);
        float horizontalResult = (didPlayerSpeedHop ? Mathf.Max(player.buffers.highestSpeedBuffer, Mathf.Abs(player.rb2d.velocity.x)) : Mathf.Abs(player.rb2d.velocity.x));

        GameObject tempObj = EffectFactory.SpawnEffect(didPlayerSpeedHop ? "SpeedHopSpark" : "JumpSpark", player.collisions.IsOnASlope ? player.collisions.GetClosestGroundPoint() : player.collisions.GetSimpleGroundPoint());
        SpriteRenderer tempSprite = tempObj.GetComponent<SpriteRenderer>();
        if (tempSprite != null) { tempSprite.flipX = !player.movement.isFacingRight; }
        tempObj.transform.up = player.collisions.GetGroundNormal();

        player.animationCtrl.GroundJumpAnimation();
        player.sfxCtrl.PlaySound(player.form.currentMode == CharacterMode.MAGE ? "jump_magli" : "jump_draelyn", 1f, didPlayerSpeedHop || isSuperJumpReady ? 1.5f : 1f);
        player.rb2d.velocity = new Vector2(horizontalResult * (player.movement.isFacingRight ? 1f : -1f), ((jumpSpeed * (isSuperJumpReady ? superJumpSpeedMultiplier : 1f)) + (enableRunningJumpBonus && !player.movement.isCrouching ? Mathf.Min(Mathf.Abs(horizontalResult / player.movement.topSpeed), 1f) * runningJumpMultiplier : 0f)));

        if (isSuperJumpReady) { ResetSuperJumpTimers(); }
    }

    public void GroundJumpUpdate()
    {
        if (player.rb2d.velocity.y > 0f)
        {
            if (jumpIsHeld && !player.jumpButtonHeld)
            {
                jumpIsHeld = false;
            }

            if (!player.attacks.isBlastJumpActive && jumpIsHeld && player.collisions.IsHeadbonking)
            {
                jumpIsHeld = false;
                player.rb2d.velocity = new Vector2(Mathf.Abs(player.rb2d.velocity.x) <= player.movement.topSpeed ? player.rb2d.velocity.x : player.movement.topSpeed * player.movement.GetFacingValue(), 0f);
            }

            if (enableVariableJumps && !jumpIsHeld)
            {
                player.rb2d.velocity -= (Vector2.up * (variableJumpDecay * Time.deltaTime));
                if (player.rb2d.velocity.y < 0f) { player.rb2d.velocity = new Vector2(player.rb2d.velocity.x, 0f); }
            }
        }
    }

    public void FallingUpdate()
    {
        float maxFallSpeed = (player.attacks.isBlastJumpActive ? player.attacks.BlastJumpMaxFallSpeed : fallSpeed);
        if (player.rb2d.velocity.y < -maxFallSpeed)
        {
            player.rb2d.velocity = new Vector2(player.rb2d.velocity.x, -maxFallSpeed);
        }
    }

    public bool CanGlide()
    {
        return (enableAirStalling && !player.movement.isCrouching && (player.buffers.coyoteTimeLeft <= 0f) && (player.rb2d.velocity.y <= 0f || player.technicalButtonHeld) && currentAirStallTime <= player.buffers.EarlyGlideBufferTime && player.collisions.CheckDistanceToGround(minimumAirStallHeight) && player.jumpButtonHeld);
    }

    public void GlideStart()
    {
        player.movement.ResetCrouchState();
        player.sfxCtrl.PlaySound("jump_magli_glide");
        glidingParticles.Play();
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
        glidingParticles.Stop();
        if (currentAirStallTime > player.buffers.EarlyGlideBufferTime || !player.jumpButtonHeld)
        {
            currentAirStallTime = maxAirStallTime;
        }
    }

    public bool CanMidairJump()
    {
        return (player.stateMachine.PreviousState != player.stateMachine.wallVaultingState && !player.collisions.IsGrounded && currentMidairJumps < maxMidairJumps && player.buffers.jumpBufferTimeLeft > 0f && (currentWallClimbTime <= 0f || currentWallClimbTime >= maxWallClimbTime) && postClimbDashTimeLeft <= 0f);
    }

    public void MidairJump()
    {
        player.animationCtrl.MidairJumpAnimation();
        player.sfxCtrl.PlaySound("jump_draelyn_midair", 1f, Mathf.Lerp(1f, 1.3f, ((float)currentMidairJumps / (float)(maxMidairJumps - 1))));
        player.buffers.ResetJumpBuffer();
        jumpIsHeld = true;
        player.rb2d.gravityScale = risingGravity;
        Vector2 newVelocity = new Vector2(player.rb2d.velocity.x, midairJumpSpeed);
        if ((player.movement.isFacingRight ? 1f : -1f) * player.rb2d.velocity.x > 0f)
        {
            EffectFactory.SpawnEffect("ForwardMidairJumpParticles", this.transform.position);
            float bonusXVelocity = forwardMidairJumpBonus.x * (player.rb2d.velocity.x > 0f ? 1f : -1f);
            float bonusYVelocity = Mathf.Abs(forwardMidairJumpBonus.y);
            newVelocity += new Vector2(bonusXVelocity, bonusYVelocity);
        }
        else
        {
            EffectFactory.SpawnEffect("NeutralMidairJumpParticles", this.transform.position);
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
        return (enableWallJumping && !player.movement.isCrouching && player.collisions.CheckDistanceToGround(minimumWallJumpHeight) && !player.collisions.IsGrounded && player.collisions.IsAgainstWall && !player.collisions.IsIntangibleWall && (player.movement.isFacingRight ? (player.inputVector.x > 0f && player.collisions.IsTouchingWallR) : (player.inputVector.x < 0f && player.collisions.IsTouchingWallL)) && (!player.jumpButtonHeld || !jumpIsHeld || player.rb2d.velocity.y < 0f));
    }

    public void WallSlideStart()
    {
        player.movement.ResetCrouchState();
        player.sfxCtrl.PlaySound("jump_magli_wallslide", 0.8f);
        jumpIsHeld = false;
        player.rb2d.gravityScale = 0f;
        player.rb2d.velocity = new Vector2(0f, -wallSlideSpeed);
        player.movement.ResetIntendedXVelocity();

        GameObject tempObj = EffectFactory.SpawnEffect("WallSlideDust", player.movement.isFacingRight ? player.collisions.wallChecksR[0] : player.collisions.wallChecksL[0]);
        WallSlideDust tempDust = tempObj.GetComponent<WallSlideDust>();
        tempDust.Setup(player);
    }

    public void WallSlideUpdate()
    {
        player.rb2d.velocity = new Vector2(0f, -wallSlideSpeed);
        player.movement.ResetIntendedXVelocity();
    }

    public bool IsWallSlideCanceled()
    {
        return (player.collisions.IsIntangibleWall || !player.collisions.IsAgainstWall || player.collisions.IsGrounded || (player.inputVector.x * (player.movement.isFacingRight ? 1f : -1f)) <= 0f);
    }

    public bool CanWallJump()
    {
        return (player.stateMachine.CurrentState == player.stateMachine.wallSlidingState && !player.movement.isCrouching && !isWallJumpCooldownActive && player.buffers.jumpBufferTimeLeft > 0f);
    }

    public void WallJumpStart()
    {
        player.buffers.ResetJumpBuffer();
        jumpIsHeld = true;
        player.rb2d.gravityScale = risingGravity;
        player.movement.ResetCrouchState();

        float horizontalResult = Mathf.Max(player.buffers.highestSpeedBuffer, horizontalWallJumpSpeed);
        bool didPlayerSpeedKick = (horizontalResult > (horizontalWallJumpSpeed + 0.25f));
        Vector2 newVelocity = new Vector2((player.movement.isFacingRight ? -horizontalResult : horizontalResult), verticalWallJumpSpeed);
        player.movement.SetFacingDirection((player.collisions.IsTouchingWallL ? 1f : (player.collisions.IsTouchingWallR ? -1f : (player.movement.isFacingRight ? -1f : 1f))));
        player.rb2d.velocity = newVelocity;

        player.animationCtrl.GroundJumpAnimation();
        SoundFactory.SpawnSound("jump_magli_wallkick", this.transform.position);
        player.sfxCtrl.PlaySound("jump_magli", 1f, didPlayerSpeedKick ? 1.5f : 1f);

        GameObject tempObj = EffectFactory.SpawnEffect("WallJumpEffect", player.movement.isFacingRight ? player.collisions.wallChecksR[0].position : player.collisions.wallChecksL[0].position);
        WallJumpEffect tempFX = tempObj.GetComponent<WallJumpEffect>();
        tempFX.Setup(!player.movement.isFacingRight, didPlayerSpeedKick);

        StartCoroutine(WallJumpCooldownCR());
    }

    public bool CanWallClimb()
    {
        return (enableWallClimbing && !player.movement.isCrouching && !player.collisions.IsHeadbonking && player.collisions.CheckDistanceToGround(minimumWallClimbHeight) && currentWallClimbTime <= 0f && !player.collisions.IsGrounded && player.collisions.IsAgainstWall && !player.collisions.IsIntangibleWall && (player.inputVector.x * (player.movement.isFacingRight ? 1f : -1f)) > 0f);
    }

    public void WallClimbStart()
    {
        player.movement.ResetCrouchState();
        player.movement.ResetIntendedXVelocity();
        player.sfxCtrl.PlaySound("jump_draelyn_wallclimb");
        player.rb2d.gravityScale = climbingGravity;
        if (storedWallClimbSpeed <= 0f)
        {
            storedWallClimbSpeed = Mathf.Min(Mathf.Max(player.buffers.highestSpeedBuffer, baseClimbingSpeed), maxClimbingSpeed);
            player.rb2d.velocity = new Vector2(0f, storedWallClimbSpeed);
        }
        GameObject tempObj = EffectFactory.SpawnEffect("WallClimbSpark", player.movement.isFacingRight ? player.collisions.wallChecksR[0] : player.collisions.wallChecksL[0]);
        WallClimbSpark tempSpark = tempObj.GetComponent<WallClimbSpark>();
        tempSpark.Setup(player);
    }

    public void WallClimbUpdate()
    {
        player.rb2d.velocity = new Vector2(0f, player.rb2d.velocity.y);
        player.movement.ResetIntendedXVelocity();
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
        return (currentWallClimbTime <= 0f || player.rb2d.velocity.y <= 0f || player.collisions.IsHeadbonking || player.collisions.IsIntangibleWall || !player.collisions.IsAgainstWall || (player.inputVector.x * (player.movement.isFacingRight ? 1f : -1f)) <= 0f);
    }

    public bool CanStartWallVault()
    {
        return (currentWallClimbTime < maxWallClimbTime && player.rb2d.velocity.y > 0f && !player.collisions.IsAgainstWall && (player.inputVector.x * (player.movement.isFacingRight ? 1f : -1f)) > 0f);
    }

    public void WallVaultStart()
    {
        player.animationCtrl.MidairJumpAnimation();
        player.sfxCtrl.PlaySound("jump_draelyn_wallpopup");
        player.movement.ResetIntendedXVelocity();
        player.movement.ResetCrouchState();

        GameObject tempObj = EffectFactory.SpawnEffect("WallVaultSpark", player.collisions.GetSimpleGroundPoint() + (Vector3.right * (player.movement.isFacingRight ? 1f : -1f) * 0.25f));
        float verticalResult = Mathf.Min(maxWallVaultStartSpeed, Mathf.Max(wallVaultStartSpeed, player.rb2d.velocity.y));
        float resultScale = (verticalResult / wallVaultStartSpeed);
        tempObj.transform.localScale = new Vector3(resultScale, resultScale, 1f);

        postClimbDashTimeLeft = postClimbDashWindow;
        player.rb2d.gravityScale = risingGravity;
        player.rb2d.velocity = (Vector2.up * verticalResult);
    }

    public bool CanWallVaultDash()
    {
        return (postClimbDashTimeLeft > 0f && player.rb2d.velocity.y > 0f && !player.movement.isCrouching && !player.collisions.IsAgainstWall && (player.inputVector.x * (player.movement.isFacingRight ? 1f : -1f)) > 0f && player.jumpButtonHeld);
    }

    public void WallVaultUpdate()
    {
        player.rb2d.velocity = new Vector2(0f, player.rb2d.velocity.y);
        player.movement.ResetIntendedXVelocity();
        postClimbDashTimeLeft -= Time.deltaTime;
    }

    public void WallVaultDash()
    {
        player.animationCtrl.DashJumpAnimation();
        player.sfxCtrl.PlaySound("jump_draelyn_wallvault");
        currentAirStallTime = 0f;
        currentMidairJumps = 0;
        postClimbDashTimeLeft = 0f;

        player.buffers.ResetJumpBuffer();
        jumpIsHeld = true;
        player.rb2d.gravityScale = risingGravity;

        player.rb2d.velocity = new Vector2(storedWallClimbSpeed * player.inputVector.x, jumpSpeed);

        GameObject tempObj = EffectFactory.SpawnEffect("WallVaultRing", this.transform.position - (new Vector3(player.rb2d.velocity.x, player.rb2d.velocity.y, 0f) * Time.deltaTime));
    }

    public void WallVaultEnd()
    {
        postClimbDashTimeLeft = 0f;
    }

    public bool IsWallVaultCanceled()
    {
        return (postClimbDashTimeLeft <= 0f || player.rb2d.velocity.y <= 0f || (player.inputVector.x * (player.movement.isFacingRight ? 1f : -1f)) <= 0f);
    }

    public void LedgeSnap()
    {
        player.sfxCtrl.PlaySound("jump_draelyn_wallpopup", 1f, 1.5f);

        GameObject tempObj = EffectFactory.SpawnEffect("WallVaultSpark", player.collisions.GetSimpleGroundPoint() + (Vector3.right * (player.movement.isFacingRight ? 1f : -1f) * ledgeSnapDistance));
        float verticalResult = Mathf.Min(maxWallVaultStartSpeed, Mathf.Max(wallVaultStartSpeed, player.rb2d.velocity.y));
        float resultScale = (verticalResult / wallVaultStartSpeed);
        tempObj.transform.localScale = new Vector3(resultScale, resultScale, 1f);

        player.transform.position += (Vector3.right * (player.movement.isFacingRight ? 1f : -1f) * 0.25f);
        player.collisions.SnapToGround(false, false);
        player.rb2d.gravityScale = fallingGravity;
        player.rb2d.velocity = new Vector2(storedWallClimbSpeed * player.inputVector.x, 0f);
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
