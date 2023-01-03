using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public enum CharacterMode { MAGE, DRAGON }

public class PlayerCtrl : MonoBehaviour
{
    /* COMPONENTS */
    Rigidbody2D rb2d;
    SpriteRenderer charSprite;

    /* DRAG AND DROP */
    [Header("Drag and Drop")]
    [SerializeField] Transform groundCheckObj;
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
    [SerializeField] float groundCheckRadius = 0.1f;
    [SerializeField] LayerMask groundLayer;

    /* RUNNING VARIABLES */
    [Header("Running Variables")]
    [SerializeField] float acceleration = 0.5f;
    [SerializeField] float deceleration = 0.5f;
    [SerializeField] float topSpeed = 18f;
    [SerializeField] float turningSpeed = 0.5f;

    /* JUMPING VARIABLES */
    [Header("Jumping Variables")]
    [SerializeField] bool changeFacingDirectionMidair = true;
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
    [SerializeField] float airStallSpeed = 1f;
    [SerializeField, Range(0f, 5f)] float maxAirStallTime = 3f;

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
    [SerializeField] float jumpBufferTime = 0.1f;
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

    /* PROJECTILE VARIABLES */
    [Header("Projectile Variables")]
    [SerializeField] float projectileUsageCooldown = 1f;

    /* SCRIPT VARIABLES */
    private CharacterMode currentMode = CharacterMode.MAGE;
    private bool isGrounded = false;
    private bool jumpIsHeld = false;
    private float currentAirStallTime = 0f;
    private int currentMidairJumps = 0;
    private bool isChangingForm = false;
    private bool isProjectileCooldownActive = false;
    private float jumpBufferTimeLeft = 0f;
    private float coyoteTimeLeft = 0f;
    private bool isFacingRight = true;
    private bool isOnMovingPlatform = false;
    private MagicBlast projectileRef = null;
    private float currentMagic = 0f;

    /* PUBLIC PROPERTIES */
    public bool IsOnMovingPlatform { get { return isOnMovingPlatform; } }

    void Awake()
    {
        rb2d = this.gameObject.GetComponent<Rigidbody2D>();
        charSprite = this.gameObject.GetComponent<SpriteRenderer>();
        playerCamTarget.position = groundCheckObj.position;
    }

    void Start()
    {
        StartCoroutine(JumpBufferCR());
        StartCoroutine(CoyoteTimeCR());
        StartCoroutine(MagicMeterCR());
        ChangeMode(startingMode);
        currentMagic = startingMagic;
    }

    void Update()
    {
        GroundCheck();
        UpdatePlayerCamTarget();
        FormChange();
        FacingDirection();
        Jumping();
        Movement();
        FireProjectile();
    }

    /* METHODS */
    private void GroundCheck()
    {
        isGrounded = false;
        Collider2D[] colliders = Physics2D.OverlapCircleAll(groundCheckObj.position, groundCheckRadius, groundLayer);
        isGrounded = (colliders.Length > 0);

        if (isGrounded)
        {
            MovingPlatform platform = colliders[0].gameObject.GetComponent<MovingPlatform>();
            isOnMovingPlatform = (platform != null);
        }
        else
        {
            isOnMovingPlatform = false;
        }
    }

    private void UpdatePlayerCamTarget()
    {
        if (isChangingForm) { return; }
        float horizontalLookahead = (lookaheadDistance * Mathf.Min(Mathf.Abs(rb2d.velocity.x / topSpeed), 1f) * (rb2d.velocity.x >= 0f ? 1f : -1f));
        float initialYPos = (followCharacterOnJump || isGrounded ? groundCheckObj.position.y : playerCamTarget.position.y);
        float fallingLookahead = (!isGrounded && coyoteTimeLeft <= 0f && rb2d.velocity.y < 0f && groundCheckObj.position.y < (playerCamTarget.position.y - fallingLookaheadThreshold) ? fallingLookaheadDistance * Mathf.Min((rb2d.velocity.y / -fallSpeed) , 1f) : 0f);
        float risingLookahead = (!isGrounded && coyoteTimeLeft <= 0f && groundCheckObj.position.y > (playerCamTarget.position.y + risingLookaheadThreshold) ? risingLookaheadDistance * Mathf.Max(rb2d.velocity.y / fallSpeed, 1f) : 0f);
        playerCamTarget.position = new Vector2(groundCheckObj.position.x + horizontalLookahead, initialYPos - fallingLookahead + risingLookahead);
    }

    private void Movement()
    {
        if (isChangingForm) { return; }

        if (Input.GetAxis("Horizontal") != 0f)
        {
            if ((rb2d.velocity.x * Input.GetAxis("Horizontal")) >= 0f)
            {
                if (Mathf.Abs(rb2d.velocity.x) < topSpeed)
                {
                    rb2d.velocity = new Vector2(rb2d.velocity.x + ((isGrounded ? acceleration : airAcceleration) * (Input.GetAxis("Horizontal") > 0f ? 1f : -1f) * Time.deltaTime), rb2d.velocity.y);
                    if (Mathf.Abs(rb2d.velocity.x) > topSpeed)
                    {
                        rb2d.velocity = new Vector2(topSpeed * (Input.GetAxis("Horizontal") > 0f ? 1f : -1f), rb2d.velocity.y);
                    }

                }
                else if ((isGrounded || (enableAirStalling && (currentAirStallTime > 0f && currentAirStallTime < maxAirStallTime))) && Mathf.Abs(rb2d.velocity.x) > topSpeed)
                {
                    rb2d.velocity = new Vector2(topSpeed * (Input.GetAxis("Horizontal") > 0f ? 1f : -1f), rb2d.velocity.y);
                }
                else { /* Nothing */ }
            }
            else
            {
                if (rb2d.velocity.x != 0f)
                {
                    rb2d.velocity = new Vector2(rb2d.velocity.x + ((isGrounded ? turningSpeed : airTurningSpeed) * (Input.GetAxis("Horizontal") > 0f ? 1f : -1f) * Time.deltaTime), rb2d.velocity.y);
                }
            }
        }
        else
        {
            if (rb2d.velocity.x > 0f)
            {
                if (isGrounded && rb2d.velocity.x > topSpeed) { rb2d.velocity = new Vector2(topSpeed, rb2d.velocity.y); }

                rb2d.velocity = new Vector2(rb2d.velocity.x - ((isGrounded ? deceleration : airDeceleration) * Time.deltaTime), rb2d.velocity.y);
                if (rb2d.velocity.x < 0f)
                {
                    rb2d.velocity = new Vector2(0f, rb2d.velocity.y);
                }
            }
            else if (rb2d.velocity.x < 0f)
            {
                if (isGrounded && rb2d.velocity.x < -topSpeed) { rb2d.velocity = new Vector2(-topSpeed, rb2d.velocity.y); }

                rb2d.velocity = new Vector2(rb2d.velocity.x + ((isGrounded ? deceleration : airDeceleration) * Time.deltaTime), rb2d.velocity.y);
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
        if (isChangingForm) { return; }

        if (isGrounded || coyoteTimeLeft > 0f)
        {
            if (!isOnMovingPlatform)
            {
                currentAirStallTime = 0f;
                currentMidairJumps = 0;
            }

            if (jumpBufferTimeLeft > 0f)
            {
                jumpBufferTimeLeft = 0f;
                jumpIsHeld = true;
                rb2d.gravityScale = risingGravity;
                rb2d.velocity = new Vector2(rb2d.velocity.x, jumpSpeed + (enableRunningJumpBonus ? Mathf.Abs(rb2d.velocity.x / topSpeed) * runningJumpMultiplier : 0f));
            }
        }
        else if (!isGrounded && currentMidairJumps < maxMidairJumps && jumpBufferTimeLeft > 0f)
        {
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

                if (enableAirStalling && currentAirStallTime < maxAirStallTime && Input.GetButton("Jump"))
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

    private void FireProjectile()
    {
        if (!isProjectileCooldownActive && Input.GetButtonDown("Fire"))
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
                        projTemp.Setup(isFacingRight, rb2d.velocity.x, Input.GetAxis("Vertical"));
                        projectileRef = projTemp;
                    }
                }
                StartCoroutine(ProjectileUsageCooldownCR());
            }
            else
            {

            }
        }
    }

    private void FormChange()
    {
        if (!isChangingForm && (Input.GetButtonDown("Change Form") || (currentMode == CharacterMode.MAGE && currentMagic >= maxMagic) || (currentMode == CharacterMode.DRAGON && currentMagic <= 0f)) )
        {
            StartCoroutine(FormFreeze());

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
        if (isChangingForm || (!changeFacingDirectionMidair && !isGrounded) || (currentAirStallTime > 0f && currentAirStallTime < maxAirStallTime)) { return; }

        if (Input.GetAxis("Horizontal") > 0f)
        {
            isFacingRight = true;
            charSprite.flipX = false;
        }
        else if (Input.GetAxis("Horizontal") < 0f)
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
        airStallSpeed = p.airStallSpeed;
        maxAirStallTime = p.maxAirStallTime;

        if (enableAirStalling && currentAirStallTime > 0f && maxAirStallTime > 0f) { currentAirStallTime = maxAirStallTime; }

        maxMidairJumps = p.maxMidairJumps;
        midairJumpSpeed = p.midairJumpSpeed;
        forwardMidairJumpBonus = p.forwardMidairJumpBonus;

        enableRunningJumpBonus = p.enableRunningJumpBonus;
        runningJumpMultiplier = p.runningJumpMultiplier;
    }

    private IEnumerator ProjectileUsageCooldownCR()
    {
        if (!isProjectileCooldownActive)
        {
            isProjectileCooldownActive = true;
            yield return new WaitForSeconds(projectileUsageCooldown);
            isProjectileCooldownActive = false;
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

        float prevGravityScale = rb2d.gravityScale;
        Vector2 prevVelocity = rb2d.velocity;

        rb2d.gravityScale = 0f;
        rb2d.velocity = Vector2.zero;

        yield return new WaitForSeconds(formChangeTime);

        rb2d.gravityScale = prevGravityScale;
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

    private IEnumerator CoyoteTimeCR()
    {
        bool prevIsGrounded = isGrounded;
        while (true)
        {
            if (!isGrounded && prevIsGrounded && coyoteTimeLeft <= 0f && rb2d.velocity.y < 0f)
            {
                coyoteTimeLeft = coyoteTime;
            }
            else if ((isGrounded && !prevIsGrounded) || (isGrounded && prevIsGrounded))
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

            prevIsGrounded = isGrounded;

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
