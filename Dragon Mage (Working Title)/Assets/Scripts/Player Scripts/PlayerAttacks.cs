using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public enum AttackState { NOTHING, STARTUP, ACTIVE, ENDLAG }

public class PlayerAttacks : MonoBehaviour
{
    PlayerCtrl player;

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
    [SerializeField] Color fireTackleStartupColor;
    [SerializeField] Color fireTackleActiveColor;
    [SerializeField] Color fireTackleEndlagColor;
    [SerializeField] float fireTackleTrailSpawnInterval = 0.05f;

    [SerializeField] float blastJumpMinVelocityMagnitude = 6f;
    [SerializeField] float blastJumpMinActiveTime = 0.25f;
    [SerializeField] float blastJumpTemperIncreaseInterval = 0.5f;
    [SerializeField] Color blastJumpActiveColor;

    [HideInInspector] public bool isAttackCooldownActive = false;
    [HideInInspector] public bool isBlastJumpActive = false;
    [HideInInspector] public bool isFireTackleActive = false;

    public AttackState currentAttackState { get; private set; }
    public bool isFireTackleEndlagCanceled { get; private set; }

    private MagicBlast projectileRef = null;

    void Awake()
    {
        player = this.gameObject.GetComponent<PlayerCtrl>();
    }

    void Start()
    {
        currentAttackState = AttackState.NOTHING;
        isFireTackleEndlagCanceled = false;
    }

    public void UseAttack()
    {
        if (!player.temper.forceFormChange && !isAttackCooldownActive && !isFireTackleActive && player.attackButtonDown)
        {
            if (player.form.currentMode == CharacterMode.MAGE)
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
                        projTemp.Setup(player.gameObject, player.temper, player.movement.isFacingRight, player.rb2d.velocity.x, player.inputVector.y);
                        projectileRef = projTemp;
                    }
                }
                StartCoroutine(AttackCooldownCR());
            }
            else
            {
                StartCoroutine(UseFireTackleCR());
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

    private IEnumerator UseFireTackleCR()
    {
        if (isFireTackleActive || isAttackCooldownActive) { yield break; }

        bool isAttackButtonHeld = true;

        isFireTackleEndlagCanceled = false;
        isFireTackleActive = true;
        currentAttackState = AttackState.STARTUP;

        player.sfxCtrl.PlaySound("attack_draelyn_startup");
        player.charSprite.color = fireTackleStartupColor;
        player.animationCtrl.FireTackleAnimation(0);
        float windupTimer = fireTackleStartup;
        float previousHorizontalVelocity = Mathf.Abs(player.rb2d.velocity.x);
        float verticalAxis = 0f;
        while (windupTimer > 0f && !player.damage.isPlayerDamaged)
        {
            if (!PauseHandler.isPaused && !player.attackButtonHeld) { isAttackButtonHeld = false; }
            player.rb2d.gravityScale = 0f;
            player.rb2d.velocity = Vector2.zero;
            player.movement.SetFacingDirection(player.inputVector.x);
            verticalAxis = player.inputVector.y;
            if (player.collisions.IsGrounded && verticalAxis < 0) { verticalAxis = 0f; }
            windupTimer -= Time.deltaTime;
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
            if (!PauseHandler.isPaused && !player.attackButtonHeld) { isAttackButtonHeld = false; }

            player.rb2d.velocity = new Vector2((!player.collisions.IsAgainstWall ? horizontalResult : 0f), player.rb2d.velocity.y);
            if (verticalAxis > 0f)
            {
                currentRisingSpeed += fireTackleVerticalSteeringSpeed * Time.deltaTime;
                player.rb2d.velocity = new Vector2(horizontalResult, currentRisingSpeed);
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
                player.rb2d.velocity = (player.collisions.GetRightVector().normalized * (!player.collisions.IsAgainstWall ? horizontalResult : 0f));
                player.collisions.SnapToGround();
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
            player.animationCtrl.FireTackleAnimation(3);
            player.rb2d.velocity = ((Vector2.up + (Vector2.right * (player.movement.isFacingRight ? -1f : 1f))).normalized * fireTackleBonkKnockback);
        }
        else
        {
            if (isAttackButtonHeld)
            {
                player.sfxCtrl.PlaySound("attack_draelyn_fireball");
                player.animationCtrl.FireTackleAnimation(4);
                firedProjectile = true;
                GameObject objTemp = Instantiate(fireProjectilePrefab, projectileSpawnPoint.position, Quaternion.identity);
                FireMissile fireTemp = objTemp.GetComponent<FireMissile>();
                if (fireTemp != null) { fireTemp.Setup(player.temper, player.movement.isFacingRight, Mathf.Abs(player.rb2d.velocity.x)); }
                player.rb2d.velocity = (new Vector2((player.movement.isFacingRight ? -1f : 1f), (!player.collisions.IsGrounded && !player.collisions.IsOnASlope ? 1f : 0f)).normalized * fireTackleRecoilStrength);
                player.temper.ChangeTemperBy(-1);
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
            if (!firedProjectile && !bumped && endlagTimer < fireTackleEndlagCancel && CanCancelFireTackleEndlag()) { isFireTackleEndlagCanceled = true; break; }
            if (!bumped && (player.collisions.IsGrounded || player.collisions.IsOnASlope) && player.rb2d.velocity.x != 0f)
            {
                Vector2 resultVector = (player.collisions.GetRightVector().normalized * (firedProjectile ? -fireTackleRecoilStrength : horizontalResult));
                player.rb2d.velocity = ((player.movement.isFacingRight && player.collisions.IsTouchingWallR) || (!player.movement.isFacingRight && player.collisions.IsTouchingWallL) || player.collisions.CheckIfNearLedge() ? Vector2.zero : Vector2.Lerp(resultVector, Vector2.zero, (fireTackleEndlag - endlagTimer) / fireTackleEndlag));
                if (player.collisions.IsOnASlope) { player.collisions.SnapToGround(); }
            }
            else if (bumped && (player.collisions.IsGrounded || player.collisions.IsOnASlope) && endlagTimer < fireTackleEndlagCancel)
            {
                player.rb2d.velocity = Vector2.zero;
                if (player.collisions.IsOnASlope) { player.collisions.SnapToGround(); }
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
        isFireTackleActive = false;
        StartCoroutine(AttackCooldownCR());
        StartCoroutine(player.form.FormChangeCooldownCR());
    }

    private bool CanCancelFireTackleEndlag()
    {
        return (!player.temper.forceFormChange && (player.jumping.CanWallClimb() || ((player.inputVector.x * (player.movement.isFacingRight ? 1f : -1f)) > 0f && player.collisions.IsGrounded && player.buffers.jumpBufferTimeLeft > 0f)));
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
