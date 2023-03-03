using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public enum CharacterMode { MAGE, DRAGON }

public class PlayerCtrl : MonoBehaviour
{
    /* COMPONENTS */
    public StateMachine stateMachine;
    [HideInInspector] public PlayerCollisions playerCollisions;
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
    [SerializeField] GameObject fireProjectilePrefab;
    [SerializeField] Transform projectileSpawnPoint;
    
    /* EDITOR VARIABLES */
    [Header("Editor Variables")]
    [SerializeField] CharacterMode startingMode = CharacterMode.MAGE;

    /* RUNNING VARIABLES */
    [Header("Running Variables")]
    [SerializeField] float acceleration = 0.5f; // PlayerMovement
    [SerializeField] float deceleration = 0.5f; // PlayerMovement
    [SerializeField] float topSpeed = 18f; // PlayerMovement
    [SerializeField] float turningSpeed = 0.5f; // PlayerMovement

    /* JUMPING VARIABLES */
    [Header("Jumping Variables")]
    [SerializeField] bool changeFacingDirectionMidair = true;
    [SerializeField] bool enableSpeedHopping = true;
    [SerializeField] float jumpSpeed = 4f;
    [SerializeField] float risingGravity = 1f;
    [SerializeField] float fallingGravity = 1f;
    [SerializeField] float fallSpeed = 6f;
    [SerializeField] float airAcceleration = 0.5f;
    [SerializeField] float airDeceleration = 0.5f;
    [SerializeField] float airTurningSpeed = 0.5f;

    [Header("Variable Jump Variables")]
    [SerializeField] bool enableVariableJumps = true;
    [SerializeField] float variableJumpDecay = 0.5f;

    [Header("Air Stalling Variables")]
    [SerializeField] bool enableAirStalling = true;
    [SerializeField] float minimumAirStallHeight = 1f;
    [SerializeField] float airStallSpeed = 1f;
    [SerializeField, Range(0f, 5f)] float maxAirStallTime = 3f;

    [Header("Wall Climb Variables")]
    [SerializeField] bool enableWallClimbing = true;
    [SerializeField] float minimumWallClimbHeight = 1f;
    [SerializeField] float baseClimbingSpeed = 4f;
    [SerializeField] float climbingGravity = 0.25f;
    [SerializeField] float maxWallClimbTime = 3f;
    [SerializeField] float postClimbDashWindow = 1f;

    [Header("Wall Jump Variables")]
    [SerializeField] bool enableWallJumping = true;
    [SerializeField] float minimumWallJumpHeight = 1f;
    [SerializeField] float wallSlideSpeed = 1f;
    [SerializeField] float verticalWallJumpSpeed = 4f;
    [SerializeField] float horizontalWallJumpSpeed = 6f;
    [SerializeField] float wallJumpCooldown = 0.25f;

    [Header("Midair Jump Variables")]
    [SerializeField, Range(0, 5)] int maxMidairJumps = 3;
    [SerializeField] float midairJumpSpeed = 4.25f;
    [SerializeField] Vector2 forwardMidairJumpBonus;

    [Header("Running Jump Variables")]
    [SerializeField] bool enableRunningJumpBonus = true;
    [SerializeField] float runningJumpMultiplier = 1f;

    /* MISC VARIABLES */
    [Header("Miscellaneous Control Variables")]
    [SerializeField] float formChangeTime = 0.25f;
    [SerializeField] float formChangeCooldownTime = 0.1f;
    [SerializeField] float formChangeBufferTime = 0.1f;
    [SerializeField] float jumpBufferTime = 0.1f;
    [SerializeField] float highestSpeedBufferTime = 0.1f;
    [SerializeField] float coyoteTime = 0.1f;
    [SerializeField] float lookaheadDistance = 8f;
    [SerializeField] float fallingLookaheadDistance = 2f;
    [SerializeField] float fallingLookaheadThreshold = 0.1f;
    [SerializeField] float risingLookaheadDistance = 5f;
    [SerializeField] float risingLookaheadThreshold = 5f;
    [SerializeField] bool followCharacterOnJump = false;

    /* MAGIC METER VARIABLES */
    [Header("Magic Meter Variables")]
    [SerializeField] float maxMagic = 100f;
    [SerializeField] float startingMagic = 50f;
    [SerializeField] float magicChangeRate = 0.1f;
    [SerializeField, Range(1f, 99f)] float forceMageFormThreshold = 25f;
    [SerializeField, Range(1f, 99f)] float forceDragonFormThreshold = 75f;

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
    private CharacterMode currentMode = CharacterMode.MAGE;
    private bool jumpIsHeld = false;

    private float currentAirStallTime = 0f;
    private float currentWallClimbTime = 0f;
    private int currentMidairJumps = 0;

    private bool isChangingForm = false; // Make into ChangingFormState

    private bool isWallJumpCooldownActive = false;
    private bool isFormChangeCooldownActive = false;
    private bool isAttackCooldownActive = false;
    private bool isFireTackleActive = false;

    private float formChangeBufferTimeLeft = 0f;
    private float jumpBufferTimeLeft = 0f;
    private float highestSpeedBuffer = 0f;

    private float storedWallClimbSpeed = 0f;
    private float postClimbDashTimeLeft = 0f;

    private float coyoteTimeLeft = 0f;

    public bool isFacingRight = true;

    private MagicBlast projectileRef = null;
    private float currentMagic = 0f;

    void Awake()
    {
        stateMachine = new StateMachine(this);
        stateMachine.Initialize(stateMachine.standingState);

        playerCollisions = this.gameObject.GetComponent<PlayerCollisions>();

        rb2d = this.gameObject.GetComponent<Rigidbody2D>();
        charSprite = this.gameObject.GetComponent<SpriteRenderer>();
        playerCamTarget.position = playerCollisions.groundCheckObj.position;
    }

    void Start()
    {
        StartCoroutine(JumpBufferCR());
        StartCoroutine(FormChangeBufferCR());
        StartCoroutine(HighestSpeedBufferCR());
        StartCoroutine(CoyoteTimeCR());
        StartCoroutine(MagicMeterCR());
        ChangeMode(startingMode);
        currentMagic = startingMagic;
    }

    void Update()
    {
        stateMachine.Update();
        UpdatePlayerCamTarget();
        FormChange();
        FacingDirection();
        Movement();
        Jumping();
        UseAttack();
    }

    /* METHODS */
    private void UpdatePlayerCamTarget()
    {
        if (isChangingForm) { return; }
        float horizontalLookahead = (lookaheadDistance * Mathf.Min(Mathf.Abs(rb2d.velocity.x / (topSpeed * 2f)), 1f) * (rb2d.velocity.x >= 0f ? 1f : -1f));
        float initialYPos = (followCharacterOnJump || playerCollisions.IsGrounded ? playerCollisions.groundCheckObj.position.y : playerCamTarget.position.y);
        float fallingLookahead = (!playerCollisions.IsGrounded && coyoteTimeLeft <= 0f && rb2d.velocity.y < 0f && playerCollisions.groundCheckObj.position.y < (playerCamTarget.position.y - fallingLookaheadThreshold) ? fallingLookaheadDistance : 0f);
        float risingLookahead = (!playerCollisions.IsGrounded && coyoteTimeLeft <= 0f && playerCollisions.groundCheckObj.position.y > (playerCamTarget.position.y + risingLookaheadThreshold) ? risingLookaheadDistance * Mathf.Min(rb2d.velocity.y / (fallSpeed * 2f), 1f) : 0f);
        playerCamTarget.position = new Vector2(this.transform.position.x + horizontalLookahead, initialYPos + (rb2d.velocity.y > 0f ? risingLookahead : -fallingLookahead));
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
                            if (rb2d.velocity.x  < topSpeed) { rb2d.velocity = new Vector2(topSpeed, rb2d.velocity.y); }
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

    private void Jumping()
    {
        if (isChangingForm || isFireTackleActive) { return; }
        else if (isFireTackleActive && (currentWallClimbTime > 0f && currentWallClimbTime < maxWallClimbTime))
        {
            currentWallClimbTime = maxWallClimbTime;
            rb2d.gravityScale = fallingGravity;
            return;
        }
        else { /* Nothing */ }

        if (playerCollisions.IsGrounded || coyoteTimeLeft > 0f)
        {
            currentAirStallTime = 0f;
            currentWallClimbTime = 0f;
            storedWallClimbSpeed = 0f;
            postClimbDashTimeLeft = 0f;
            currentMidairJumps = 0;

            if (jumpBufferTimeLeft > 0f)
            {
                jumpBufferTimeLeft = 0f;
                jumpIsHeld = true;
                rb2d.gravityScale = risingGravity;

                float horizontalResult = (enableSpeedHopping && (rb2d.velocity.x * Input.GetAxisRaw("Horizontal")) > 0f && Mathf.Abs(rb2d.velocity.x) >= topSpeed && highestSpeedBuffer > Mathf.Abs(rb2d.velocity.x) ? (highestSpeedBuffer * Input.GetAxisRaw("Horizontal")) : rb2d.velocity.x);
                rb2d.velocity = new Vector2(horizontalResult, jumpSpeed + (enableRunningJumpBonus ? Mathf.Abs(horizontalResult / topSpeed) * runningJumpMultiplier : 0f));
            }
        }
        else if (enableWallJumping && playerCollisions.CheckDistanceToGround(minimumWallJumpHeight) && !isWallJumpCooldownActive && !playerCollisions.IsGrounded && playerCollisions.IsAgainstWall && (isFacingRight ? (Input.GetAxisRaw("Horizontal") > 0f && playerCollisions.IsTouchingWallR) : (Input.GetAxisRaw("Horizontal") < 0f && playerCollisions.IsTouchingWallL)))
        {
            if (enableWallClimbing && currentWallClimbTime > 0f && currentWallClimbTime < maxWallClimbTime) { currentWallClimbTime = maxWallClimbTime; }

            if (jumpBufferTimeLeft > 0f)
            {
                jumpBufferTimeLeft = 0f;
                jumpIsHeld = true;
                rb2d.gravityScale = risingGravity;

                float horizontalResult = Mathf.Max(highestSpeedBuffer, horizontalWallJumpSpeed);
                Vector2 newVelocity = new Vector2((isFacingRight ? -horizontalResult : horizontalResult), verticalWallJumpSpeed);
                SetFacingDirection((playerCollisions.IsTouchingWallL ? 1f : (playerCollisions.IsTouchingWallR ? -1f : (isFacingRight ? -1f : 1f))));
                rb2d.velocity = newVelocity;
                StartCoroutine(WallJumpCooldownCR());
            }
            else if (!Input.GetButton("Jump") || !jumpIsHeld || rb2d.velocity.y < 0f)
            {
                jumpIsHeld = false;
                rb2d.gravityScale = 0f;
                rb2d.velocity = new Vector2(0f, -wallSlideSpeed);
                if (currentAirStallTime > 0f) { currentAirStallTime = maxAirStallTime; }
            }
            else { /* Nothing */ }

            
        }
        else if (!playerCollisions.IsGrounded && currentMidairJumps < maxMidairJumps && jumpBufferTimeLeft > 0f && (currentWallClimbTime <= 0f || currentWallClimbTime >= maxWallClimbTime) && postClimbDashTimeLeft <= 0f)
        {
            if (enableWallClimbing && currentWallClimbTime > 0f && currentWallClimbTime < maxWallClimbTime) { currentWallClimbTime = maxWallClimbTime; }

            jumpBufferTimeLeft = 0f;
            jumpIsHeld = true;
            rb2d.gravityScale = risingGravity;
            Vector2 newVelocity = new Vector2(rb2d.velocity.x, midairJumpSpeed);
            if ((isFacingRight ? 1f : -1f) * rb2d.velocity.x > 0f)
            {
                float bonusXVelocity = forwardMidairJumpBonus.x * (rb2d.velocity.x > 0f ? 1f : -1f);
                float bonusYVelocity = Mathf.Abs(forwardMidairJumpBonus.y);
                newVelocity += new Vector2(bonusXVelocity, bonusYVelocity);
            }
            else
            {
                if (Mathf.Abs(rb2d.velocity.x) > topSpeed)
                {
                    newVelocity.x = topSpeed * (rb2d.velocity.x > 0f ? 1f : -1f);
                }
            }
            rb2d.velocity = newVelocity;
            currentMidairJumps++;
        }
        else if (enableWallClimbing && currentWallClimbTime < maxWallClimbTime && !playerCollisions.IsGrounded && playerCollisions.IsAgainstWall && (Input.GetAxisRaw("Horizontal") * (isFacingRight ? 1f : -1f)) > 0f)
        {
            if (playerCollisions.CheckDistanceToGround(minimumWallClimbHeight) || currentWallClimbTime > 0f)
            {
                if (currentAirStallTime > 0f && currentAirStallTime < maxAirStallTime) { currentAirStallTime = maxAirStallTime; }

                rb2d.gravityScale = climbingGravity;
                if (storedWallClimbSpeed <= 0f)
                {
                    storedWallClimbSpeed = Mathf.Max(highestSpeedBuffer, baseClimbingSpeed);
                    rb2d.velocity = new Vector2(0f, storedWallClimbSpeed);
                }

                if (rb2d.velocity.y > 0f) { currentWallClimbTime += Time.deltaTime; }
                else { currentWallClimbTime = maxWallClimbTime; rb2d.velocity = Vector2.zero; rb2d.gravityScale = fallingGravity; }
            }
        }
        else if (enableWallClimbing && currentWallClimbTime > 0f && currentWallClimbTime < maxWallClimbTime)
        {
            currentWallClimbTime = maxWallClimbTime;
            rb2d.gravityScale = fallingGravity;
            postClimbDashTimeLeft = postClimbDashWindow;
        }
        else if (enableWallClimbing && currentWallClimbTime == maxWallClimbTime && postClimbDashTimeLeft > 0f)
        {
            if (Input.GetButton("Jump") && !playerCollisions.IsAgainstWall && !playerCollisions.IsGrounded && rb2d.velocity.y > 0f && (Input.GetAxisRaw("Horizontal") * (isFacingRight ? 1f : -1f)) > 0f)
            {
                postClimbDashTimeLeft = 0f;

                jumpBufferTimeLeft = 0f;
                jumpIsHeld = true;
                rb2d.gravityScale = risingGravity;

                rb2d.velocity = new Vector2(storedWallClimbSpeed * Input.GetAxisRaw("Horizontal"), jumpSpeed);
                currentMidairJumps = 0;
                currentAirStallTime = 0f;
            }
            else if ((Input.GetAxisRaw("Horizontal") * (isFacingRight ? 1f : -1f)) <= 0f || rb2d.velocity.y <= 0f || playerCollisions.IsAgainstWall || playerCollisions.IsGrounded)
            {
                postClimbDashTimeLeft = 0f;
            }
            else
            {
                if (postClimbDashTimeLeft > 0f)
                {
                    postClimbDashTimeLeft -= Time.deltaTime;
                    if (postClimbDashTimeLeft < 0f)
                    {
                        postClimbDashTimeLeft = 0f;
                    }
                }
            }
        }
        else
        {
            if (rb2d.velocity.y > 0f)
            {
                if (jumpIsHeld && !Input.GetButton("Jump"))
                {
                    jumpIsHeld = false;
                }

                if (enableVariableJumps && !jumpIsHeld)
                {
                    rb2d.velocity = new Vector2(rb2d.velocity.x, rb2d.velocity.y - (variableJumpDecay * Time.deltaTime));
                }
            }
            else
            {
                jumpIsHeld = false;

                if (enableAirStalling && currentAirStallTime < maxAirStallTime && playerCollisions.CheckDistanceToGround(minimumAirStallHeight) && Input.GetButton("Jump"))
                {
                    rb2d.gravityScale = 0f;
                    rb2d.velocity = new Vector2(rb2d.velocity.x, -airStallSpeed);
                    currentAirStallTime += Time.deltaTime;
                }
                else
                {
                    rb2d.gravityScale = fallingGravity;

                    if (enableAirStalling && currentAirStallTime > 0f)
                    {
                        currentAirStallTime = maxAirStallTime;
                    }

                    if (rb2d.velocity.y < -fallSpeed)
                    {
                        rb2d.velocity = new Vector2(rb2d.velocity.x, -fallSpeed);
                    }
                }
            }
        }
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
                        projTemp.Setup(isFacingRight, rb2d.velocity.x, Input.GetAxisRaw("Vertical"));
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

    private void FormChange()
    {
        if (!isFormChangeCooldownActive && !isAttackCooldownActive && !isChangingForm && !isFireTackleActive && ((formChangeBufferTimeLeft > 0f) || (currentMode == CharacterMode.MAGE && currentMagic >= maxMagic) || (currentMode == CharacterMode.DRAGON && currentMagic <= 0f)) )
        {
            formChangeBufferTimeLeft = 0f;

            StartCoroutine(FormFreeze());
            StartCoroutine(FormChangeCooldownCR());

            if (currentMode == CharacterMode.MAGE && currentMagic > forceMageFormThreshold)
            {
                ChangeMode(CharacterMode.DRAGON);
                return;
            }

            if (currentMode == CharacterMode.DRAGON && currentMagic < forceDragonFormThreshold)
            {
                ChangeMode(CharacterMode.MAGE);
                return;
            }
        }
    }

    private void FacingDirection()
    {
        if (isChangingForm || isFireTackleActive || isWallJumpCooldownActive || (!changeFacingDirectionMidair && !playerCollisions.IsGrounded) || (currentAirStallTime > 0f && currentAirStallTime < maxAirStallTime)) { return; }
        SetFacingDirection(Input.GetAxisRaw("Horizontal"));
    }

    private void SetFacingDirection(float horizontalAxis)
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

    /* UTILITY METHODS */
    private void SetCtrlProperties(PlayerCtrlProperties p)
    {
        acceleration = p.acceleration;
        deceleration = p.deceleration;
        topSpeed = p.topSpeed;
        turningSpeed = p.turningSpeed;

        changeFacingDirectionMidair = p.changeFacingDirectionMidair;
        enableSpeedHopping = p.enableSpeedHopping;
        jumpSpeed = p.jumpSpeed;
        risingGravity = p.risingGravity;
        fallingGravity = p.fallingGravity;
        fallSpeed = p.fallSpeed;
        airAcceleration = p.airAcceleration;
        airDeceleration = p.airDeceleration;
        airTurningSpeed = p.airTurningSpeed;

        enableVariableJumps = p.enableVariableJumps;
        variableJumpDecay = p.variableJumpDecay;

        enableAirStalling = p.enableAirStalling;
        minimumAirStallHeight = p.minimumAirStallHeight;
        airStallSpeed = p.airStallSpeed;
        maxAirStallTime = p.maxAirStallTime;

        if (enableAirStalling && currentAirStallTime > 0f && maxAirStallTime > 0f) { currentAirStallTime = maxAirStallTime; }

        enableWallClimbing = p.enableWallClimbing;
        minimumWallClimbHeight = p.minimumWallClimbHeight;
        baseClimbingSpeed = p.baseClimbingSpeed;
        climbingGravity = p.climbingGravity;
        maxWallClimbTime = p.maxWallClimbTime;
        postClimbDashWindow = p.postClimbDashWindow;

        if (enableWallClimbing)
        {
            if (currentWallClimbTime > 0f && maxWallClimbTime > 0f) { currentWallClimbTime = maxWallClimbTime; }
            if (storedWallClimbSpeed > 0f) { storedWallClimbSpeed = 0f; }
            if (postClimbDashTimeLeft > 0f) { postClimbDashTimeLeft = 0f; }
        }

        enableWallJumping = p.enableWallJumping;
        minimumWallJumpHeight = p.minimumWallJumpHeight;
        wallSlideSpeed = p.wallSlideSpeed;
        verticalWallJumpSpeed = p.verticalWallJumpSpeed;
        horizontalWallJumpSpeed = p.horizontalWallJumpSpeed;
        wallJumpCooldown = p.wallJumpCooldown;

        maxMidairJumps = p.maxMidairJumps;
        midairJumpSpeed = p.midairJumpSpeed;
        forwardMidairJumpBonus = p.forwardMidairJumpBonus;

        enableRunningJumpBonus = p.enableRunningJumpBonus;
        runningJumpMultiplier = p.runningJumpMultiplier;
    }

    private IEnumerator UseFireTackleCR()
    {
        if (isFireTackleActive || isAttackCooldownActive) { yield break; }

        isFireTackleActive = true;

        charSprite.color = Color.yellow;
        float windupTimer = fireTackleStartup;
        while (windupTimer > 0f)
        {
            SetFacingDirection(Input.GetAxisRaw("Horizontal"));
            if (playerCollisions.IsGrounded) { rb2d.velocity = Vector2.zero; }
            windupTimer -= Time.deltaTime;
            yield return null;
        }

        charSprite.color = Color.red;
        rb2d.gravityScale = 0f;
        rb2d.velocity = new Vector2((Mathf.Abs(rb2d.velocity.x) + fireTackleBaseHorizontalSpeed) * (isFacingRight ? 1f : -1f), 0f);
        float attackTimer = fireTackleBaseDuration;
        while (attackTimer > 0f && !playerCollisions.IsAgainstWall && !playerCollisions.IsHeadbonking)
        {
            if (!playerCollisions.IsGrounded) { rb2d.velocity += (Vector2.up * (fireTackleVerticalSteeringSpeed * Input.GetAxisRaw("Vertical") * Time.deltaTime)); }
            attackTimer -= Time.deltaTime;
            yield return null;
        }

        charSprite.color = Color.gray;
        if (playerCollisions.IsAgainstWall || playerCollisions.IsHeadbonking) { rb2d.velocity = ((Vector2.up + (Vector2.right * (isFacingRight ? -1f : 1f))).normalized * fireTackleBonkKnockback); }
        rb2d.gravityScale = fallingGravity;
        float deceleration = Mathf.Abs(rb2d.velocity.x / fireTackleEndlag);
        float endlagTimer = fireTackleEndlag;
        while (endlagTimer > 0f)
        {
            if (endlagTimer < fireTackleEndlagCancel && (Input.GetAxisRaw("Horizontal") != 0f || jumpBufferTimeLeft > 0f)) { break; }
            if (playerCollisions.IsGrounded && rb2d.velocity.x != 0f)
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

    private IEnumerator WallJumpCooldownCR()
    {
        if (!isWallJumpCooldownActive)
        {
            isWallJumpCooldownActive = true;
            float currentWallJumpCooldownTimer = wallJumpCooldown;
            while (rb2d.velocity.y > 0f || currentWallJumpCooldownTimer > 0f)
            {
                if (!isChangingForm) { currentWallJumpCooldownTimer -= Time.deltaTime; }
                yield return null;
            }
            isWallJumpCooldownActive = false;
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

        rb2d.gravityScale = (prevVelocity.y > 0f ? risingGravity : fallingGravity);
        rb2d.velocity = prevVelocity;

        isChangingForm = false;
    }

    private IEnumerator JumpBufferCR()
    {
        while (true)
        {
            if (Input.GetButtonDown("Jump"))
            {
                jumpBufferTimeLeft = jumpBufferTime;
            }

            if (jumpBufferTimeLeft > 0f)
            {
                jumpBufferTimeLeft -= Time.deltaTime;
                if (jumpBufferTimeLeft < 0f)
                {
                    jumpBufferTimeLeft = 0f;
                }
            }

            yield return null;
        }
    }

    private IEnumerator FormChangeBufferCR()
    {
        while (true)
        {
            if (Input.GetButtonDown("Change Form"))
            {
                formChangeBufferTimeLeft = formChangeBufferTime;
            }

            if (formChangeBufferTimeLeft > 0f)
            {
                formChangeBufferTimeLeft -= Time.deltaTime;
                if (formChangeBufferTimeLeft < 0f)
                {
                    formChangeBufferTimeLeft = 0;
                }
            }

            yield return null;
        }
    }

    private IEnumerator HighestSpeedBufferCR()
    {
        float highestSpeedBufferTimeLeft = highestSpeedBufferTime;
        while (true)
        {
            float currentHorizontalSpeed = (currentWallClimbTime > 0f && currentWallClimbTime < maxWallClimbTime ? Mathf.Max(storedWallClimbSpeed, Mathf.Abs(rb2d.velocity.x)) : Mathf.Abs(rb2d.velocity.x));

            if (currentHorizontalSpeed > highestSpeedBuffer)
            {
                highestSpeedBuffer = currentHorizontalSpeed;
                highestSpeedBufferTimeLeft = highestSpeedBufferTime;
            }
            else if (currentHorizontalSpeed < highestSpeedBuffer)
            {
                if (!isChangingForm)
                {
                    if (highestSpeedBufferTimeLeft > 0f) { highestSpeedBufferTimeLeft -= Time.deltaTime; }
                    
                    if (highestSpeedBufferTimeLeft <= 0f)
                    {
                        highestSpeedBufferTimeLeft = 0f;
                        highestSpeedBuffer = currentHorizontalSpeed;
                    }
                }
            }
            else { /* Nothing */ }
            
            yield return null;
        }
    }

    private IEnumerator CoyoteTimeCR()
    {
        bool prevIsGrounded = playerCollisions.IsGrounded;
        while (true)
        {
            if (!playerCollisions.IsGrounded && prevIsGrounded && coyoteTimeLeft <= 0f && rb2d.velocity.y < 0f)
            {
                coyoteTimeLeft = coyoteTime;
            }
            else if ((playerCollisions.IsGrounded && !prevIsGrounded) || (playerCollisions.IsGrounded && prevIsGrounded))
            {
                coyoteTimeLeft = 0f;
            }
            else { /* Nothing */ }

            if (coyoteTimeLeft > 0f)
            {
                coyoteTimeLeft -= Time.deltaTime;
                if (coyoteTimeLeft < 0f)
                {
                    coyoteTimeLeft = 0f;
                }
            }

            prevIsGrounded = playerCollisions.IsGrounded;

            yield return null;
        }
    }

    private IEnumerator MagicMeterCR()
    {
        while (true)
        {
            currentMagic += ((currentMode == CharacterMode.MAGE ? 1f : -1f) * magicChangeRate * Time.deltaTime);
            if (currentMagic > maxMagic) { currentMagic = maxMagic; }
            if (currentMagic < 0f) { currentMagic = 0f; }
            yield return null;
        }
    }
}
