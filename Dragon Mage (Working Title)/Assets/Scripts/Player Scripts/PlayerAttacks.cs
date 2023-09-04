using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public enum AttackState { NOTHING, STARTUP, ACTIVE, ENDLAG }

public class PlayerAttacks : MonoBehaviour
{
    PlayerCtrl player;

    [SerializeField] AttackReticle attackReticle;

    [SerializeField] ParticleSystem blastJumpParticles;
    [SerializeField] ParticleSystem fireTackleParticles;

    [SerializeField] GameObject magicProjectilePrefab;
    [SerializeField] GameObject fireProjectilePrefab;
    [SerializeField] GameObject fireTrailPrefab;
    [SerializeField] Transform projectileSpawnPoint;
    
    [SerializeField] float attackCooldown = 1f;

    [SerializeField] float fireTackleBaseHorizontalSpeed = 6f;
    [SerializeField] float fireTackleMaxHorizontalSpeed = 30f;
    [SerializeField] float fireTackleVerticalSteeringSpeed = 2f;
    [SerializeField] float fireTackleBonkKnockback = 3f;
    [SerializeField] float fireTackleStartup = 0.25f;
    [SerializeField] float fireTackleBumpImmunityDuration = 0.2f;
    [SerializeField] float fireTackleBaseDuration = 0.5f;
    [SerializeField] float fireTackleRecoilStrength = 4f;
    [SerializeField] float fireTackleEndlag = 0.25f;
    [SerializeField] float fireTackleEndlagCancel = 0.125f;
    [SerializeField] float fireTackleMaxSlopeSnapDistance = 1f;
    [SerializeField] Color fireTackleStartupColor;
    [SerializeField] Color fireTackleActiveColor;
    [SerializeField] Color fireTackleEndlagColor;
    [SerializeField] float fireTackleTrailSpawnInterval = 0.05f;
    [SerializeField] float fireTackleHoldTemperDrainInterval = 0.8f;

    [SerializeField] float slideBaseHorizontalSpeed = 5f;
    [SerializeField] float slideMaxHorizontalSpeed = 10f;
    [SerializeField] float slideDecelerationRate = 2.5f;
    [SerializeField] float slideMinDuration = 0.2f;
    [SerializeField] float slideNoCancelingTime = 0.25f;
    [SerializeField] float slideMaxSlopeSnapDistance = 1f;

    [SerializeField] float blastJumpMinVelocityMagnitude = 6f;
    [SerializeField] float blastJumpMaxFallSpeed = 20f;
    [SerializeField] float blastJumpMinActiveTime = 0.25f;
    [SerializeField] float blastJumpTemperIncreaseInterval = 0.5f;
    [SerializeField] Color blastJumpActiveColor;

    [SerializeField] float dodgeInitialSpeed = 8f;
    [SerializeField] float dodgeDeceleration = 8f;
    [SerializeField] float dodgeMaxSlopeSnapDistance = 1f;

    public bool isAttackCooldownActive { get; private set; }
    public bool isBlastJumpActive { get; private set; }
    public bool isDodging { get; private set; }
    public bool isFireTackleActive { get; private set; }
    public bool isSliding { get; private set; }

    public AttackState currentAttackState { get; private set; }
    public bool isFireTackleEndlagCanceled { get; private set; }
    public bool isSlideJumpCanceled { get; private set; }
    public bool isSlideTackleCanceled { get; private set; }
    public float BlastJumpMaxFallSpeed { get { return blastJumpMaxFallSpeed; } }

    private MagicBlast projectileRef = null;
    private bool reticleToggle = false;
    float previousHorizontalVelocity = 0f;

    void Awake()
    {
        player = this.gameObject.GetComponent<PlayerCtrl>();
    }

    void Start()
    {
        currentAttackState = AttackState.NOTHING;
        isFireTackleEndlagCanceled = false;
    }

    void Update()
    {
        if (!PauseHandler.isPaused)
        {
            ShowAttackReticle();
        }
    }

    public void UseAttack()
    {
        if (!player.temper.forceFormChange && !isAttackCooldownActive && !isFireTackleActive && player.buffers.attackBufferTimeLeft > 0f)
        {
            player.buffers.ResetAttackBuffer();
            if (player.form.currentMode == CharacterMode.MAGE)
            {
                if (player.movement.isCrouching)
                {
                    StartCoroutine(UseDodgeCR());
                }
                else
                {
                    if (projectileRef != null)
                    {
                        projectileRef.Detonate();
                    }
                    else
                    {
                        GameObject tempObj = Instantiate(magicProjectilePrefab, projectileSpawnPoint.position, Quaternion.identity);
                        MagicBlast projTemp = tempObj.GetComponent<MagicBlast>();
                        if (projTemp != null)
                        {
                            bool facingRight = player.movement.isFacingRight;
                            if (player.stateMachine.CurrentState.name == "WallSliding")
                            {
                                facingRight = !facingRight;
                            }
                            projTemp.Setup(player.gameObject, player.temper, player.rb2d.velocity, facingRight, player.inputVector.y);
                            projectileRef = projTemp;
                        }
                    }
                    StartCoroutine(AttackCooldownCR());
                }
            }
            else
            {
                if (player.movement.isCrouching)
                {
                    StartCoroutine(UseSlideCR());
                }
                else
                {
                    StartCoroutine(UseFireTackleCR());
                }
            }
        }
    }

    public void UseBlastJump()
    {
        if (!isBlastJumpActive) { StartCoroutine(UseBlastJumpCR()); }
    }

    public void DestroyProjectileReference()
    {
        if (projectileRef != null) { GameObject.Destroy(projectileRef.gameObject); }
    }

    private void ShowAttackReticle()
    {
        if (player.reticleButtonDown) { reticleToggle = !reticleToggle; }

        if (reticleToggle && !player.movement.isCrouching && !player.form.isChangingForm && !player.temper.forceFormChange && !isAttackCooldownActive && (currentAttackState == AttackState.STARTUP || !isFireTackleActive) && (player.form.currentMode != CharacterMode.MAGE || projectileRef == null))
        {
            if (!attackReticle.gameObject.activeSelf)
            {
                attackReticle.gameObject.SetActive(true);
                attackReticle.ResetTrailPosition();
            }

            if (player.form.currentMode == CharacterMode.MAGE)
            {
                if (projectileRef == null)
                {
                    bool facingRight = player.movement.isFacingRight;
                    if (player.stateMachine.CurrentState.name == "WallSliding")
                    {
                        facingRight = !facingRight;
                    }
                    attackReticle.SetMagicBlastReticle(projectileSpawnPoint.position, player.collisions.groundCheckObj.position, player.rb2d.velocity, facingRight, player.inputVector.y, (player.rb2d.velocity.y < 0f && !player.collisions.IsGrounded && !player.collisions.IsOnASlope));
                }
            }
            else
            {
                bool isInteractingWithWall = (player.stateMachine.CurrentState.name == "WallVaulting" || player.stateMachine.CurrentState.name == "WallClimbing");
                bool wasVaulting = (player.stateMachine.PreviousState.name == "WallVaulting");
                float calculatedTackleSpeed = Mathf.Min((Mathf.Abs(currentAttackState == AttackState.STARTUP ? (isInteractingWithWall || wasVaulting ? player.jumping.storedWallClimbSpeed : previousHorizontalVelocity) : (isInteractingWithWall ? player.jumping.storedWallClimbSpeed : player.rb2d.velocity.x)) + fireTackleBaseHorizontalSpeed), fireTackleMaxHorizontalSpeed);
                calculatedTackleSpeed *= (player.inputVector.x != 0f ? player.inputVector.x : player.movement.GetFacingValue());
                calculatedTackleSpeed *= (player.stateMachine.CurrentState.name == "WallClimbing" ? -1f : 1f);
                float verticalComponent = (!player.collisions.IsGrounded && !player.collisions.IsOnASlope && player.inputVector.y < 0f ? -Mathf.Abs(calculatedTackleSpeed) : 0f);
                float verticalAcceleration = (player.inputVector.y > 0f ? fireTackleVerticalSteeringSpeed : 0f);
                attackReticle.SetFireTackleReticle(this.transform.position, new Vector2(calculatedTackleSpeed, verticalComponent), verticalAcceleration, fireTackleBaseDuration);
            }
        }
        else
        {
            if (attackReticle.gameObject.activeSelf) { attackReticle.gameObject.SetActive(false); }
        }
    }

    private IEnumerator UseBlastJumpCR()
    {
        if (isBlastJumpActive) { yield break; }

        SoundFactory.SpawnSound("attack_magli_blastjump", this.transform.position);
        isBlastJumpActive = true;
        blastJumpParticles.Play();
        player.charSprite.color = blastJumpActiveColor;
        player.spriteTrail.ActivateTrail();
        player.temper.ChangeTemperBy(1);
        float currentActiveTime = blastJumpMinActiveTime;
        float currentTemperInterval = blastJumpTemperIncreaseInterval;
        while (isBlastJumpActive)
        {
            if (currentActiveTime <= 0f || player.form.isChangingForm)
            {
                if (player.rb2d.velocity.magnitude < blastJumpMinVelocityMagnitude ||
                                player.collisions.IsGrounded ||
                                player.form.isChangingForm ||
                                player.stateMachine.CurrentState == player.stateMachine.glidingState ||
                                player.form.currentMode != CharacterMode.MAGE)
                {
                    isBlastJumpActive = false;
                    player.spriteTrail.DeactivateTrail();
                    player.charSprite.color = Color.white;
                }
            }
            else
            {
                currentActiveTime -= Time.deltaTime;
                if (currentActiveTime < 0f || player.form.isChangingForm)
                {
                    currentActiveTime = 0f;
                }
            }

            if (currentTemperInterval > 0f)
            {
                currentTemperInterval -= Time.deltaTime;
                if (currentTemperInterval <= 0f)
                {
                    player.temper.ChangeTemperBy(1);
                    currentTemperInterval += blastJumpTemperIncreaseInterval;
                }
            }
            yield return null;
        }

        blastJumpParticles.Stop();
        isBlastJumpActive = false;
        yield break;
    }

    private IEnumerator UseDodgeCR()
    {
        if (isDodging || isAttackCooldownActive || !player.movement.isCrouching) { yield break; }

        isDodging = true;
        bool wasJumpInputOnFirstFrames = (player.jumpButtonDown || player.stateMachine.CurrentState.name == "Jumping" || player.stateMachine.CurrentState.name == "Falling");
        while (player.stateMachine.CurrentState.name != "Dodging") { yield return null; }

        SoundFactory.SpawnSound("movement_magli_dodge", this.transform.position);
        player.rb2d.gravityScale = 0f;
        player.animationCtrl.DodgeAnimation();
        float currentDodgeSpeed = dodgeInitialSpeed;
        bool didPlayerLeaveGround = (wasJumpInputOnFirstFrames || (!player.collisions.IsGrounded && !player.collisions.IsOnASlope) || player.stateMachine.CurrentState.name == "Jumping" || player.stateMachine.CurrentState.name == "Falling");
        Vector2 dodgeDirection = new Vector2(player.movement.GetFacingValue(), didPlayerLeaveGround ? -1f : 0f);
        player.rb2d.velocity = (dodgeDirection * currentDodgeSpeed);

        player.spriteTrail.ActivateTrail();
        player.effects.TurnaroundSpark();
        while (currentDodgeSpeed >= 0f && (!didPlayerLeaveGround || (!player.collisions.IsGrounded && !player.collisions.IsOnASlope)))
        {
            if (player.collisions.IsAgainstWall)
            {
                player.rb2d.velocity = new Vector2(0f, dodgeDirection.y < 0f ? dodgeDirection.y * currentDodgeSpeed : 0f);
            }
            else if (dodgeDirection.y == 0f)
            {
                Vector2 newVelocity = (player.collisions.GetRightVector() * (!player.collisions.IsAgainstWall ? currentDodgeSpeed : 0f));
                if (newVelocity.x > 0f & newVelocity.x < currentDodgeSpeed) { newVelocity *= (currentDodgeSpeed / newVelocity.x); }
                player.rb2d.velocity = (newVelocity * player.movement.GetFacingValue());
                player.collisions.SnapToGround(false, player.collisions.IsOnASlope, dodgeMaxSlopeSnapDistance);
            }
            else
            {
                player.rb2d.velocity = (dodgeDirection * currentDodgeSpeed);
            }

            if (!didPlayerLeaveGround && (!player.collisions.IsGrounded && !player.collisions.IsOnASlope)) { didPlayerLeaveGround = true; }
            currentDodgeSpeed -= (dodgeDeceleration * Time.deltaTime);

            yield return null;
        }
        player.spriteTrail.DeactivateTrail();

        player.rb2d.gravityScale = player.jumping.fallingGravity;
        player.movement.ResetIntendedXVelocity();
        if (currentDodgeSpeed <= 0f || player.collisions.IsAgainstWall) { player.rb2d.velocity = Vector2.zero; }
        else if (currentDodgeSpeed > 0f && player.collisions.IsOnASlope)
        {
            Vector2 newVelocity = (player.collisions.GetRightVector() * (!player.collisions.IsAgainstWall ? currentDodgeSpeed : 0f));
            if (newVelocity.x > 0f & newVelocity.x < currentDodgeSpeed) { newVelocity *= (currentDodgeSpeed / newVelocity.x); }
            player.collisions.SnapToGround(false, true, dodgeMaxSlopeSnapDistance);
            player.rb2d.velocity = (newVelocity * player.movement.GetFacingValue());
        }
        else { /* Nothing */ }
        StartCoroutine(AttackCooldownCR());
        StartCoroutine(player.form.FormChangeCooldownCR());
        isDodging = false;

        yield break;
    }

    private IEnumerator UseFireTackleCR()
    {
        if ((player.movement.isCrouching && player.collisions.IsCeilingAboveWhenUncrouched()) || isFireTackleActive || isAttackCooldownActive) { yield break; }

        isFireTackleActive = true;
        while (player.stateMachine.CurrentState.name != "FireTackling") { yield return null; }

        player.movement.ResetCrouchState();

        bool isAttackButtonHeld = true;

        isFireTackleEndlagCanceled = false;
        
        currentAttackState = AttackState.STARTUP;

        player.sfxCtrl.PlaySound("attack_draelyn_startup", 1f, 1f, true);
        player.charSprite.color = fireTackleStartupColor;
        player.animationCtrl.FireTackleAnimation(0);
        float windupTimer = fireTackleStartup;
        float holdTimer = fireTackleHoldTemperDrainInterval;
        previousHorizontalVelocity = Mathf.Abs(player.rb2d.velocity.x);
        float verticalAxis = 0f;
        while ((windupTimer > 0f || isAttackButtonHeld) && !player.damage.isPlayerDamaged)
        {
            if (!PauseHandler.isPaused && !player.attackButtonHeld) { isAttackButtonHeld = false; }
            player.rb2d.gravityScale = 0f;
            player.rb2d.velocity = Vector2.zero;
            player.movement.SetFacingDirection(player.inputVector.x);
            verticalAxis = player.inputVector.y;
            if (player.collisions.IsGrounded && verticalAxis < 0) { verticalAxis = 0f; }
            windupTimer -= Time.deltaTime;
            if (windupTimer <= 0f && holdTimer > 0f)
            {
                holdTimer -= Time.deltaTime;
                if (holdTimer <= 0f)
                {
                    holdTimer += fireTackleHoldTemperDrainInterval;
                    if (player.temper.currentTemperLevel >= player.temper.hotThreshold) { player.temper.ChangeTemperBy(-1); }
                    else { player.temper.NeutralizeTemperBy(-1); }
                }
            }
            yield return null;
        }

        if (player.damage.isPlayerDamaged)
        {
            EndFireTackle();
            yield break;
        }

        currentAttackState = AttackState.ACTIVE;
        player.sfxCtrl.PlaySound("attack_draelyn_tackle");
        fireTackleParticles.Play();
        player.charSprite.color = fireTackleActiveColor;
        player.spriteTrail.ActivateTrail();
        player.animationCtrl.FireTackleAnimation(1);
        bool wasInteractingWithWall = (player.stateMachine.PreviousState == player.stateMachine.wallVaultingState || player.stateMachine.PreviousState == player.stateMachine.wallClimbingState);
        float horizontalResult = (Mathf.Min(((wasInteractingWithWall ? player.jumping.storedWallClimbSpeed : previousHorizontalVelocity) + fireTackleBaseHorizontalSpeed), fireTackleMaxHorizontalSpeed) * (player.movement.isFacingRight ? 1f : -1f));
        float currentRisingSpeed = 0f;
        player.rb2d.velocity = new Vector2(horizontalResult, (verticalAxis < 0f ? -Mathf.Abs(player.rb2d.velocity.x) : 0f));
        float attackTimer = fireTackleBaseDuration;
        float trailSpawnTimer = 0f;
        float bumpImmunityTimer = fireTackleBumpImmunityDuration;
        player.temper.ChangeTemperBy(-1);
        while (attackTimer > 0f && (bumpImmunityTimer > 0f || (!player.collisions.IsAgainstWall && !player.collisions.IsHeadbonking)))
        {
            // if (!PauseHandler.isPaused && !player.attackButtonHeld) { isAttackButtonHeld = false; }

            player.rb2d.velocity = new Vector2((!player.collisions.IsAgainstWall ? horizontalResult : 0f), player.rb2d.velocity.y);
            if (verticalAxis > 0f)
            {
                currentRisingSpeed += fireTackleVerticalSteeringSpeed * Time.deltaTime;
                player.rb2d.velocity = new Vector2(!player.collisions.IsAgainstWall ? horizontalResult : 0f, currentRisingSpeed);
            }
            else if (verticalAxis < 0f)
            {
                
                if (player.collisions.IsGrounded || player.collisions.IsOnASlope)
                {
                    verticalAxis = 0f;
                    player.jumping.LandingReset();
                }
                else
                {
                    player.rb2d.velocity = new Vector2(player.rb2d.velocity.x, -Mathf.Abs(player.rb2d.velocity.x));
                }
            }
            else
            {
                player.rb2d.velocity = (player.collisions.GetRightVector() * (!player.collisions.IsAgainstWall ? horizontalResult : 0f));
                player.collisions.SnapToGround(false, player.collisions.IsOnASlope, fireTackleMaxSlopeSnapDistance);
            }

            if (player.collisions.IsGrounded && trailSpawnTimer >= 0f)
            {
                trailSpawnTimer -= (player.rb2d.velocity.magnitude * Time.deltaTime);
                if (trailSpawnTimer <= 0f)
                {
                    trailSpawnTimer = fireTackleTrailSpawnInterval;
                    Instantiate(fireTrailPrefab, player.collisions.GetSimpleGroundPoint(), Quaternion.identity);
                }
            }
            else
            {
                if (!player.collisions.IsGrounded) { trailSpawnTimer = 0f; }
            }

            player.movement.ApplySlopeResistance();

            attackTimer -= Time.deltaTime;
            bumpImmunityTimer -= Time.deltaTime;
            yield return null;
        }

        currentAttackState = AttackState.ENDLAG;
        fireTackleParticles.Stop();
        player.charSprite.color = fireTackleEndlagColor;
        player.spriteTrail.DeactivateTrail();
        bool bumped = false;
        bool firedProjectile = false;
        if (player.collisions.IsAgainstWall || player.collisions.IsHeadbonking)
        {
            player.sfxCtrl.PlaySound("attack_draelyn_bump");
            bumped = true;
            player.buffers.ResetSpeedBuffer();
            player.movement.ResetIntendedXVelocity();
            player.animationCtrl.FireTackleAnimation(3);
            player.rb2d.velocity = ((Vector2.up + (Vector2.right * (player.movement.isFacingRight ? -1f : 1f))).normalized * fireTackleBonkKnockback);
        }
        else
        {
            if (player.buffers.attackBufferTimeLeft > 0f || player.attackButtonHeld)
            {
                player.buffers.ResetAttackBuffer();

                player.sfxCtrl.PlaySound("attack_draelyn_fireball");
                player.animationCtrl.FireTackleAnimation(4);
                firedProjectile = true;
                GameObject objTemp = Instantiate(fireProjectilePrefab, projectileSpawnPoint.position, Quaternion.identity);
                FireMissile fireTemp = objTemp.GetComponent<FireMissile>();
                if (fireTemp != null) { fireTemp.Setup(player.temper, player.movement.isFacingRight, Mathf.Abs(player.rb2d.velocity.x)); }
                player.rb2d.velocity = (new Vector2((player.movement.isFacingRight ? -1f : 1f), (!player.collisions.IsGrounded && !player.collisions.IsOnASlope ? 1f : 0f)).normalized * fireTackleRecoilStrength);
                player.temper.ChangeTemperBy(-1);
                player.movement.ResetIntendedXVelocity();
            }
            else
            {
                player.sfxCtrl.PlaySound("attack_draelyn_endlag", 0.5f);
                player.animationCtrl.FireTackleAnimation(2);
            }
        }

        player.rb2d.gravityScale = player.jumping.fallingGravity;
        float deceleration = Mathf.Abs(player.rb2d.velocity.x / fireTackleEndlag);
        float endlagTimer = fireTackleEndlag;
        while (endlagTimer > 0f && !player.damage.isPlayerDamaged)
        {
            if (!firedProjectile && !bumped && endlagTimer < fireTackleEndlagCancel && CanCancelFireTackleEndlag())
            {
                isFireTackleEndlagCanceled = true;
                player.buffers.RefreshJumpBuffer();
                break;
            }
            if (!bumped && (player.collisions.IsGrounded || player.collisions.IsOnASlope) && player.rb2d.velocity.x != 0f)
            {
                Vector2 resultVector = (player.collisions.GetRightVector() * (firedProjectile ? (fireTackleRecoilStrength * -player.movement.GetFacingValue()) : horizontalResult));
                player.rb2d.velocity = ((player.movement.isFacingRight && player.collisions.IsTouchingWallR) || (!player.movement.isFacingRight && player.collisions.IsTouchingWallL) || player.collisions.CheckIfNearLedge() ? Vector2.zero : Vector2.Lerp(resultVector, Vector2.zero, (fireTackleEndlag - endlagTimer) / fireTackleEndlag));
                if (player.collisions.IsOnASlope) { player.movement.ApplySlopeResistance(); player.collisions.SnapToGround(false, true); }
            }
            else if (bumped && (player.collisions.IsGrounded || player.collisions.IsOnASlope) && endlagTimer < fireTackleEndlagCancel)
            {
                player.movement.ResetIntendedXVelocity();
                player.rb2d.velocity = Vector2.zero;
            }
            else { /* Nothing */ }

            endlagTimer -= Time.deltaTime;
            yield return null;
        }

        EndFireTackle();
        yield break;
    }

    private void EndFireTackle()
    {
        currentAttackState = AttackState.NOTHING;
        player.charSprite.color = Color.white;
        if ((player.collisions.IsGrounded || player.collisions.IsOnASlope) && !isFireTackleEndlagCanceled) { player.movement.ResetIntendedXVelocity(); }
        isFireTackleActive = false;
        StartCoroutine(AttackCooldownCR());
        StartCoroutine(player.form.FormChangeCooldownCR());
    }

    private bool CanCancelFireTackleEndlag()
    {
        return (!player.temper.forceFormChange && (player.jumping.CanWallClimb() || ((player.inputVector.x * (player.movement.isFacingRight ? 1f : -1f)) > 0f && player.collisions.IsGrounded && player.buffers.jumpBufferTimeLeft > 0f)));
    }

    private IEnumerator UseSlideCR()
    {
        if (isSliding || isAttackCooldownActive || !player.movement.isCrouching || (player.stateMachine.CurrentState.name != "Standing" && player.stateMachine.CurrentState.name != "Running") || (!player.collisions.IsGrounded && !player.collisions.IsOnASlope) || player.collisions.IsAgainstWall || player.collisions.CheckIfNearLedge()) { yield break; }

        isSliding = true;
        while (player.stateMachine.CurrentState.name != "Sliding") { yield return null; }

        SoundFactory.SpawnSound("movement_draelyn_slide", this.transform.position);
        isSlideJumpCanceled = false;
        isSlideTackleCanceled = false;
        float previousHorizontalVelocity = Mathf.Abs(player.rb2d.velocity.x);
        player.rb2d.gravityScale = 0f;
        player.animationCtrl.SlideAnimation();
        float horizontalResult = Mathf.Abs(Mathf.Min((previousHorizontalVelocity + slideBaseHorizontalSpeed), slideMaxHorizontalSpeed));
        player.rb2d.velocity = new Vector2(horizontalResult * player.movement.GetFacingValue(), 0f);
        float slideTimer = 0f;
        player.spriteTrail.ActivateTrail();
        GameObject tempObj = EffectFactory.SpawnEffect("SlideDust", player.collisions.groundCheckObj);
        SlideDust tempDust = tempObj.GetComponent<SlideDust>();
        tempDust.Setup(player);
        while (!player.damage.isPlayerDamaged && horizontalResult >= 0f && (player.inputVector.x * player.movement.GetFacingValue()) >= 0f && (slideTimer <= slideMinDuration || player.crouchButtonHeld))
        {
            if (!player.collisions.IsCeilingAboveWhenUncrouched() && slideTimer >= slideNoCancelingTime && (player.inputVector.x * player.rb2d.velocity.x) > 0f && player.buffers.jumpBufferTimeLeft > 0f)
            {
                isSlideJumpCanceled = true;
                player.buffers.ResetJumpBuffer();
                break;
            }
            else if (!player.collisions.IsCeilingAboveWhenUncrouched() && slideTimer >= slideNoCancelingTime && player.buffers.attackBufferTimeLeft > 0f)
            {
                isSlideTackleCanceled = true;
                player.buffers.ResetAttackBuffer();
                break;
            }
            else if (player.collisions.IsAgainstWall || player.collisions.CheckIfNearLedge())
            {
                break;
            }
            else { /* Nothing */ }
            
            Vector2 newVelocity = (player.collisions.GetRightVector() * (!player.collisions.IsAgainstWall && !player.collisions.CheckIfNearLedge() ? horizontalResult : 0f));
            if (newVelocity.x > 0f & newVelocity.x < horizontalResult) { newVelocity *= (horizontalResult / newVelocity.x); }
            newVelocity *= player.movement.GetFacingValue();
            player.rb2d.velocity = newVelocity;
            player.collisions.SnapToGround(false, player.collisions.IsOnASlope, slideMaxSlopeSnapDistance);

            slideTimer += Time.deltaTime;
            horizontalResult -= (slideDecelerationRate * Time.deltaTime);

            yield return null;
        }
        player.spriteTrail.DeactivateTrail();

        player.rb2d.gravityScale = player.jumping.fallingGravity;
        player.movement.ResetIntendedXVelocity();
        player.rb2d.velocity = new Vector2(isSlideJumpCanceled ? player.inputVector.x * horizontalResult * (player.damage.isPlayerDamaged ? 0f : 1f) : (player.inputVector.x * Mathf.Min(horizontalResult, player.movement.topSpeed)), 0f);
        isSliding = false;
        if (!isSlideTackleCanceled)
        {
            StartCoroutine(AttackCooldownCR());
            // StartCoroutine(player.form.FormChangeCooldownCR());
        }
        else
        {
            StartCoroutine(UseFireTackleCR());
        }

        yield break;
    }

    private IEnumerator AttackCooldownCR()
    {
        if (!isAttackCooldownActive)
        {
            isAttackCooldownActive = true;
            yield return new WaitForSeconds(attackCooldown);
            isAttackCooldownActive = false;
        }
        yield break;
    }
}
