using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public enum CharacterMode { MAGE, DRAGON }

public class PlayerCtrl : MonoBehaviour
{
    /* COMPONENTS */
    public StateMachine stateMachine;
    [HideInInspector] public PlayerCollisions collisions;
    [HideInInspector] public PlayerBuffers buffers;
    [HideInInspector] public PlayerMovement movement;
    [HideInInspector] public PlayerJumping jumping;

    [HideInInspector] public Rigidbody2D rb2d;
    [HideInInspector] public SpriteRenderer charSprite;

    /* DRAG AND DROP */
    [Header("Drag and Drop")]
    [SerializeField] Transform playerCamTarget;
    [SerializeField] PlayerCtrlProperties mageProperties;
    [SerializeField] PlayerCtrlProperties dragonProperties;
    [SerializeField] Sprite tempMageSprite;
    [SerializeField] Sprite tempDragonSprite;
    [SerializeField] GameObject magicProjectilePrefab;
    [SerializeField] Transform projectileSpawnPoint;
    
    /* EDITOR VARIABLES */
    [Header("Editor Variables")]
    [SerializeField] CharacterMode startingMode = CharacterMode.MAGE;

    /* MISC VARIABLES */
    [Header("Miscellaneous Control Variables")]
    [SerializeField] float formChangeTime = 0.25f;
    [SerializeField] float formChangeCooldownTime = 0.1f;
    [SerializeField] float lookaheadDistance = 8f;
    [SerializeField] float fallingLookaheadDistance = 2f;
    [SerializeField] float fallingLookaheadThreshold = 0.1f;
    [SerializeField] float risingLookaheadDistance = 5f;
    [SerializeField] float risingLookaheadThreshold = 5f;
    [SerializeField] bool followCharacterOnJump = false;

    /* ATTACK VARIABLES */
    [Header("Attack Variables")]
    [SerializeField] float attackCooldown = 1f;
    [SerializeField] float fireTackleBaseHorizontalSpeed = 6f;
    [SerializeField] float fireTackleVerticalSteeringSpeed = 2f;
    [SerializeField] float fireTackleBonkKnockback = 3f;
    [SerializeField] float fireTackleStartup = 0.25f;
    [SerializeField] float fireTackleBaseDuration = 0.5f;
    [SerializeField] float fireTackleEndlag = 0.25f;
    [SerializeField] float fireTackleEndlagCancel = 0.125f;

    /* SCRIPT VARIABLES */
    [HideInInspector] public CharacterMode currentMode = CharacterMode.MAGE;

    [HideInInspector] public bool isChangingForm = false; // Make into ChangingFormState

    [HideInInspector] public bool isFormChangeCooldownActive = false;
    [HideInInspector] public bool isAttackCooldownActive = false;
    [HideInInspector] public bool isFireTackleActive = false;

    private MagicBlast projectileRef = null;

    void Awake()
    {
        collisions = this.gameObject.GetComponent<PlayerCollisions>();
        buffers = this.gameObject.GetComponent<PlayerBuffers>();
        movement = this.gameObject.GetComponent<PlayerMovement>();
        jumping = this.gameObject.GetComponent<PlayerJumping>();

        rb2d = this.gameObject.GetComponent<Rigidbody2D>();
        charSprite = this.gameObject.GetComponent<SpriteRenderer>();
        playerCamTarget.position = collisions.groundCheckObj.position;
        
        stateMachine = new StateMachine(this);
        stateMachine.Initialize(stateMachine.standingState);
    }

    void Start()
    {
        ChangeMode(startingMode);
    }

    void Update()
    {
        stateMachine.Update();
        UpdatePlayerCamTarget();
        // FormChange();
        // UseAttack();
    }

    /* METHODS */
    private void UpdatePlayerCamTarget()
    {
        if (isChangingForm) { return; }
        float horizontalLookahead = (lookaheadDistance * Mathf.Min(Mathf.Abs(rb2d.velocity.x / (movement.topSpeed * 2f)), 1f) * (rb2d.velocity.x >= 0f ? 1f : -1f));
        float initialYPos = (followCharacterOnJump || collisions.IsGrounded ? collisions.groundCheckObj.position.y : playerCamTarget.position.y);
        float fallingLookahead = (!collisions.IsGrounded && buffers.coyoteTimeLeft <= 0f && rb2d.velocity.y < 0f && collisions.groundCheckObj.position.y < (playerCamTarget.position.y - fallingLookaheadThreshold) ? fallingLookaheadDistance : 0f);
        float risingLookahead = (!collisions.IsGrounded && buffers.coyoteTimeLeft <= 0f && collisions.groundCheckObj.position.y > (playerCamTarget.position.y + risingLookaheadThreshold) ? risingLookaheadDistance * Mathf.Min(rb2d.velocity.y / (jumping.fallSpeed * 2f), 1f) : 0f);
        playerCamTarget.position = new Vector2(this.transform.position.x + horizontalLookahead, initialYPos + (rb2d.velocity.y > 0f ? risingLookahead : -fallingLookahead));
    }

    private void UseAttack()
    {
        if (!isAttackCooldownActive && !isFireTackleActive && Input.GetButtonDown("Attack"))
        {
            if (currentMode == CharacterMode.MAGE)
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
                        projTemp.Setup(movement.isFacingRight, rb2d.velocity.x, Input.GetAxisRaw("Vertical"));
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

    private void FormChange() // FormChange script will temporarily override the current state
    {
        if (!isFormChangeCooldownActive && !isAttackCooldownActive && !isChangingForm && !isFireTackleActive && buffers.formChangeBufferTimeLeft > 0f)
        {
            buffers.formChangeBufferTimeLeft = 0f;

            StartCoroutine(FormFreeze());
            StartCoroutine(FormChangeCooldownCR());

            if (currentMode == CharacterMode.MAGE)
            {
                ChangeMode(CharacterMode.DRAGON);
                return;
            }

            if (currentMode == CharacterMode.DRAGON)
            {
                ChangeMode(CharacterMode.MAGE);
                return;
            }
        }
    }

    /* UTILITY METHODS */
    private void SetCtrlProperties(PlayerCtrlProperties p)
    {
        movement.acceleration = p.acceleration;
        movement.deceleration = p.deceleration;
        movement.topSpeed = p.topSpeed;
        movement.turningSpeed = p.turningSpeed;

        movement.changeFacingDirectionMidair = p.changeFacingDirectionMidair;
        jumping.enableSpeedHopping = p.enableSpeedHopping;
        jumping.jumpSpeed = p.jumpSpeed;
        jumping.risingGravity = p.risingGravity;
        jumping.fallingGravity = p.fallingGravity;
        jumping.fallSpeed = p.fallSpeed;
        movement.airAcceleration = p.airAcceleration;
        movement.airDeceleration = p.airDeceleration;
        movement.airTurningSpeed = p.airTurningSpeed;

        jumping.enableVariableJumps = p.enableVariableJumps;
        jumping.variableJumpDecay = p.variableJumpDecay;

        jumping.enableAirStalling = p.enableAirStalling;
        jumping.minimumAirStallHeight = p.minimumAirStallHeight;
        jumping.airStallSpeed = p.airStallSpeed;
        jumping.maxAirStallTime = p.maxAirStallTime;

        if (jumping.enableAirStalling && jumping.currentAirStallTime > 0f && jumping.maxAirStallTime > 0f) { jumping.currentAirStallTime = jumping.maxAirStallTime; }

        jumping.enableWallClimbing = p.enableWallClimbing;
        jumping.minimumWallClimbHeight = p.minimumWallClimbHeight;
        jumping.baseClimbingSpeed = p.baseClimbingSpeed;
        jumping.climbingGravity = p.climbingGravity;
        jumping.maxWallClimbTime = p.maxWallClimbTime;
        jumping.postClimbDashWindow = p.postClimbDashWindow;

        if (jumping.enableWallClimbing)
        {
            if (jumping.currentWallClimbTime > 0f && jumping.maxWallClimbTime > 0f) { jumping.currentWallClimbTime = jumping.maxWallClimbTime; }
            if (jumping.storedWallClimbSpeed > 0f) { jumping.storedWallClimbSpeed = 0f; }
            if (jumping.postClimbDashTimeLeft > 0f) { jumping.postClimbDashTimeLeft = 0f; }
        }

        jumping.enableWallJumping = p.enableWallJumping;
        jumping.minimumWallJumpHeight = p.minimumWallJumpHeight;
        jumping.wallSlideSpeed = p.wallSlideSpeed;
        jumping.verticalWallJumpSpeed = p.verticalWallJumpSpeed;
        jumping.horizontalWallJumpSpeed = p.horizontalWallJumpSpeed;
        jumping.wallJumpCooldown = p.wallJumpCooldown;

        jumping.maxMidairJumps = p.maxMidairJumps;
        jumping.midairJumpSpeed = p.midairJumpSpeed;
        jumping.forwardMidairJumpBonus = p.forwardMidairJumpBonus;

        jumping.enableRunningJumpBonus = p.enableRunningJumpBonus;
        jumping.runningJumpMultiplier = p.runningJumpMultiplier;
    }

    private IEnumerator UseFireTackleCR()
    {
        if (isFireTackleActive || isAttackCooldownActive) { yield break; }

        isFireTackleActive = true;

        charSprite.color = Color.yellow;
        float windupTimer = fireTackleStartup;
        while (windupTimer > 0f)
        {
            movement.SetFacingDirection(Input.GetAxisRaw("Horizontal"));
            if (collisions.IsGrounded) { rb2d.velocity = Vector2.zero; }
            windupTimer -= Time.deltaTime;
            yield return null;
        }

        charSprite.color = Color.red;
        rb2d.gravityScale = 0f;
        rb2d.velocity = new Vector2((Mathf.Abs(rb2d.velocity.x) + fireTackleBaseHorizontalSpeed) * (movement.isFacingRight ? 1f : -1f), 0f);
        float attackTimer = fireTackleBaseDuration;
        while (attackTimer > 0f && !collisions.IsAgainstWall && !collisions.IsHeadbonking)
        {
            if (!collisions.IsGrounded) { rb2d.velocity += (Vector2.up * (fireTackleVerticalSteeringSpeed * Input.GetAxisRaw("Vertical") * Time.deltaTime)); }
            attackTimer -= Time.deltaTime;
            yield return null;
        }

        charSprite.color = Color.gray;
        if (collisions.IsAgainstWall || collisions.IsHeadbonking) { rb2d.velocity = ((Vector2.up + (Vector2.right * (movement.isFacingRight ? -1f : 1f))).normalized * fireTackleBonkKnockback); }
        rb2d.gravityScale = jumping.fallingGravity;
        float deceleration = Mathf.Abs(rb2d.velocity.x / fireTackleEndlag);
        float endlagTimer = fireTackleEndlag;
        while (endlagTimer > 0f)
        {
            if (endlagTimer < fireTackleEndlagCancel && (Input.GetAxisRaw("Horizontal") != 0f || buffers.jumpBufferTimeLeft > 0f)) { break; }
            if (collisions.IsGrounded && rb2d.velocity.x != 0f)
            {
                if (rb2d.velocity.x > 0f)
                {
                    rb2d.velocity -= (Vector2.right * deceleration * Time.deltaTime);
                    if (rb2d.velocity.x < 0f) { rb2d.velocity = new Vector2(0f, rb2d.velocity.y); }
                }
                else
                {
                    rb2d.velocity += (Vector2.right * deceleration * Time.deltaTime);
                    if (rb2d.velocity.x > 0f) { rb2d.velocity = new Vector2(0f, rb2d.velocity.y); }
                }
            }
            endlagTimer -= Time.deltaTime;
            yield return null;
        }

        charSprite.color = Color.white;
        isFireTackleActive = false;
        StartCoroutine(AttackCooldownCR());
        StartCoroutine(FormChangeCooldownCR());
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

    private IEnumerator FormChangeCooldownCR()
    {
        if (!isFormChangeCooldownActive)
        {
            isFormChangeCooldownActive = true;
            yield return new WaitForSeconds(formChangeCooldownTime);
            isFormChangeCooldownActive = false;
        }
        yield break;
    }

    private void ChangeMode(CharacterMode mode)
    {
        SetCtrlProperties(mode == CharacterMode.MAGE ? mageProperties : dragonProperties);
        charSprite.sprite = (mode == CharacterMode.MAGE ? tempMageSprite : tempDragonSprite);
        currentMode = mode;
    }

    private IEnumerator FormFreeze()
    {
        isChangingForm = true;

        Vector2 prevVelocity = rb2d.velocity;

        rb2d.gravityScale = 0f;
        rb2d.velocity = Vector2.zero;

        yield return new WaitForSeconds(formChangeTime);

        rb2d.gravityScale = (prevVelocity.y > 0f ? jumping.risingGravity : jumping.fallingGravity);
        rb2d.velocity = prevVelocity;

        isChangingForm = false;
    }
}
