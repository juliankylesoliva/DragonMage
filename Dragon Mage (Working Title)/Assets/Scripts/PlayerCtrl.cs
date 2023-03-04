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
    [HideInInspector] public PlayerForm form;

    [HideInInspector] public Rigidbody2D rb2d;
    [HideInInspector] public SpriteRenderer charSprite;

    /* DRAG AND DROP */
    [Header("Drag and Drop")]
    [SerializeField] Transform playerCamTarget;
    public Sprite tempMageSprite;
    public Sprite tempDragonSprite;
    [SerializeField] GameObject magicProjectilePrefab;
    [SerializeField] Transform projectileSpawnPoint;

    /* MISC VARIABLES */
    [Header("Miscellaneous Control Variables")]
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
    [HideInInspector] public bool isAttackCooldownActive = false;
    [HideInInspector] public bool isFireTackleActive = false;

    private MagicBlast projectileRef = null;

    void Awake()
    {
        collisions = this.gameObject.GetComponent<PlayerCollisions>();
        buffers = this.gameObject.GetComponent<PlayerBuffers>();
        movement = this.gameObject.GetComponent<PlayerMovement>();
        jumping = this.gameObject.GetComponent<PlayerJumping>();
        form = this.gameObject.GetComponent<PlayerForm>();

        rb2d = this.gameObject.GetComponent<Rigidbody2D>();
        charSprite = this.gameObject.GetComponent<SpriteRenderer>();
        playerCamTarget.position = collisions.groundCheckObj.position;
        
        stateMachine = new StateMachine(this);
        stateMachine.Initialize(stateMachine.standingState);
    }

    void Update()
    {
        stateMachine.Update();
        UpdatePlayerCamTarget();
        // UseAttack();
    }

    /* METHODS */
    private void UpdatePlayerCamTarget()
    {
        if (form.isChangingForm) { return; }
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
            if (form.currentMode == CharacterMode.MAGE)
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
        StartCoroutine(form.FormChangeCooldownCR());
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
