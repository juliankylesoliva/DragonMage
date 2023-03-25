using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public enum AttackState { NOTHING, STARTUP, ACTIVE, ENDLAG }

public class PlayerAttacks : MonoBehaviour
{
    PlayerCtrl player;

    [SerializeField] GameObject magicProjectilePrefab;
    [SerializeField] GameObject fireProjectilePrefab;
    [SerializeField] Transform projectileSpawnPoint;
    
    [SerializeField] float attackCooldown = 1f;
    [SerializeField] float fireTackleBaseHorizontalSpeed = 6f;
    [SerializeField] float fireTackleMaxHorizontalSpeed = 30f;
    [SerializeField] float fireTackleVerticalSteeringSpeed = 2f;
    [SerializeField] float fireTackleBonkKnockback = 3f;
    [SerializeField] float fireTackleStartup = 0.25f;
    [SerializeField] float fireTackleBumpImmunityDuration = 0.2f;
    [SerializeField] float fireTackleBaseDuration = 0.5f;
    [SerializeField] float fireTackleRecoilMultiplier = 0.75f;
    [SerializeField] float fireTackleEndlag = 0.25f;
    [SerializeField] float fireTackleEndlagCancel = 0.125f;

    [SerializeField] float blastJumpMinVelocityMagnitude = 6f;
    [SerializeField] float blastJumpMinActiveTime = 0.25f;
    [SerializeField] float blastJumpTemperIncreaseInterval = 0.5f;

    [HideInInspector] public bool isAttackCooldownActive = false;
    [HideInInspector] public bool isBlastJumpActive = false;
    [HideInInspector] public bool isFireTackleActive = false;

    public AttackState currentAttackState { get; private set; }

    private MagicBlast projectileRef = null;

    void Awake()
    {
        player = this.gameObject.GetComponent<PlayerCtrl>();
    }

    void Start()
    {
        currentAttackState = AttackState.NOTHING;
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
                        projTemp.Setup(player.temper, player.movement.isFacingRight, player.rb2d.velocity.x, player.inputVector.y);
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

    private IEnumerator UseBlastJumpCR()
    {
        if (isBlastJumpActive) { yield break; }

        isBlastJumpActive = true;
        player.charSprite.color = Color.blue;
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

        isBlastJumpActive = false;
        yield break;
    }

    private IEnumerator UseFireTackleCR()
    {
        if (isFireTackleActive || isAttackCooldownActive) { yield break; }

        isFireTackleActive = true;
        currentAttackState = AttackState.STARTUP;

        player.charSprite.color = Color.yellow;
        float windupTimer = fireTackleStartup;
        float previousHorizontalVelocity = Mathf.Abs(player.rb2d.velocity.x);
        float verticalAxis = 0f;
        while (windupTimer > 0f)
        {
            player.rb2d.gravityScale = 0f;
            player.rb2d.velocity = Vector2.zero;
            player.movement.SetFacingDirection(player.inputVector.x);
            verticalAxis = player.inputVector.y;
            if (player.collisions.IsGrounded && verticalAxis < 0) { verticalAxis = 0f; }
            windupTimer -= Time.deltaTime;
            yield return null;
        }

        currentAttackState = AttackState.ACTIVE;
        player.charSprite.color = Color.red;
        bool wasInteractingWithWall = (player.stateMachine.PreviousState == player.stateMachine.wallVaultingState || player.stateMachine.PreviousState == player.stateMachine.wallClimbingState);
        float horizontalResult = (Mathf.Min(((wasInteractingWithWall ? player.jumping.storedWallClimbSpeed : previousHorizontalVelocity) + fireTackleBaseHorizontalSpeed), fireTackleMaxHorizontalSpeed) * (player.movement.isFacingRight ? 1f : -1f));
        player.rb2d.velocity = new Vector2(horizontalResult, (verticalAxis < 0f ? -Mathf.Abs(player.rb2d.velocity.x) : 0f));
        float attackTimer = fireTackleBaseDuration;
        float bumpImmunityTimer = fireTackleBumpImmunityDuration;
        player.temper.ChangeTemperBy(-1);
        while (attackTimer > 0f && (bumpImmunityTimer > 0f || (!player.collisions.IsAgainstWall && !player.collisions.IsHeadbonking)))
        {
            player.rb2d.velocity = new Vector2((!player.collisions.IsAgainstWall ? horizontalResult : 0f), player.rb2d.velocity.y);
            if (verticalAxis > 0f)
            {
                player.rb2d.velocity += (Vector2.up * fireTackleVerticalSteeringSpeed * Time.deltaTime);
            }
            else if (verticalAxis < 0f)
            {
                
                if (player.collisions.IsGrounded)
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
                player.rb2d.velocity = new Vector2(player.rb2d.velocity.x, 0f);
            }

            attackTimer -= Time.deltaTime;
            bumpImmunityTimer -= Time.deltaTime;
            yield return null;
        }

        currentAttackState = AttackState.ENDLAG;
        player.charSprite.color = Color.gray;
        bool bumped = false;
        bool firedProjectile = false;
        if (player.collisions.IsAgainstWall || player.collisions.IsHeadbonking)
        {
            bumped = true;
            player.rb2d.velocity = ((Vector2.up + (Vector2.right * (player.movement.isFacingRight ? -1f : 1f))).normalized * fireTackleBonkKnockback);
        }
        else
        {
            if (player.attackButtonHeld)
            {
                firedProjectile = true;
                GameObject objTemp = Instantiate(fireProjectilePrefab, projectileSpawnPoint.position, Quaternion.identity);
                FireMissile fireTemp = objTemp.GetComponent<FireMissile>();
                if (fireTemp != null) { fireTemp.Setup(player.temper, player.movement.isFacingRight, Mathf.Abs(player.rb2d.velocity.x)); }
                player.rb2d.velocity = new Vector2(-player.rb2d.velocity.x * fireTackleRecoilMultiplier, player.rb2d.velocity.y);
                player.temper.ChangeTemperBy(-1);
            }
        }

        player.rb2d.gravityScale = player.jumping.fallingGravity;
        float deceleration = Mathf.Abs(player.rb2d.velocity.x / fireTackleEndlag);
        float endlagTimer = fireTackleEndlag;
        while (endlagTimer > 0f)
        {
            if (!firedProjectile && !bumped && endlagTimer < fireTackleEndlagCancel && (player.inputVector.x * (player.movement.isFacingRight ? 1f : -1f)) > 0f && player.collisions.IsGrounded && player.buffers.jumpBufferTimeLeft > 0f) { break; }
            if (player.collisions.IsGrounded && player.rb2d.velocity.x != 0f)
            {
                if (player.rb2d.velocity.x > 0f)
                {
                    player.rb2d.velocity -= (Vector2.right * deceleration * Time.deltaTime);
                    if (player.rb2d.velocity.x < 0f) { player.rb2d.velocity = new Vector2(0f, player.rb2d.velocity.y); }
                }
                else
                {
                    player.rb2d.velocity += (Vector2.right * deceleration * Time.deltaTime);
                    if (player.rb2d.velocity.x > 0f) { player.rb2d.velocity = new Vector2(0f, player.rb2d.velocity.y); }
                }
            }
            endlagTimer -= Time.deltaTime;
            yield return null;
        }

        currentAttackState = AttackState.NOTHING;
        player.charSprite.color = Color.white;
        isFireTackleActive = false;
        StartCoroutine(AttackCooldownCR());
        StartCoroutine(player.form.FormChangeCooldownCR());
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
