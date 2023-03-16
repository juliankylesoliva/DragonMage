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
    [SerializeField] float fireTackleVerticalSteeringSpeed = 2f;
    [SerializeField] float fireTackleDivingSpeed = 16f;
    [SerializeField] float fireTackleBonkKnockback = 3f;
    [SerializeField] float fireTackleStartup = 0.25f;
    [SerializeField] float fireTackleBaseDuration = 0.5f;
    [SerializeField] float fireTackleEndlag = 0.25f;
    [SerializeField] float fireTackleEndlagCancel = 0.125f;

    [HideInInspector] public bool isAttackCooldownActive = false;
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
        if (!isAttackCooldownActive && !isFireTackleActive && Input.GetButtonDown("Attack"))
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
                        projTemp.Setup(player.movement.isFacingRight, player.rb2d.velocity.x, Input.GetAxisRaw("Vertical"));
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
        currentAttackState = AttackState.STARTUP;

        player.charSprite.color = Color.yellow;
        float windupTimer = fireTackleStartup;
        while (windupTimer > 0f)
        {
            player.movement.SetFacingDirection(Input.GetAxisRaw("Horizontal"));
            if (player.collisions.IsGrounded) { player.rb2d.velocity = Vector2.zero; }
            windupTimer -= Time.deltaTime;
            yield return null;
        }

        currentAttackState = AttackState.ACTIVE;
        player.charSprite.color = Color.red;
        player.rb2d.gravityScale = 0f;
        player.rb2d.velocity = new Vector2((Mathf.Abs(player.rb2d.velocity.x) + fireTackleBaseHorizontalSpeed) * (player.movement.isFacingRight ? 1f : -1f), 0f);
        float attackTimer = fireTackleBaseDuration;
        while (attackTimer > 0f && !player.collisions.IsAgainstWall && !player.collisions.IsHeadbonking)
        {
            if (!player.collisions.IsGrounded)
            {
                float verticalAxis = Input.GetAxisRaw("Vertical");
                if (verticalAxis > 0f)
                {
                    if (player.rb2d.velocity.y < 0f) { player.rb2d.velocity = new Vector2(player.rb2d.velocity.x, 0f); }
                    player.rb2d.velocity += (Vector2.up * fireTackleVerticalSteeringSpeed * Time.deltaTime);
                }
                else if (verticalAxis < 0f)
                {
                    if (player.rb2d.velocity.y >= 0f)
                    {
                        player.rb2d.velocity = new Vector2(player.rb2d.velocity.x, -fireTackleDivingSpeed);
                    }
                }
                else
                {
                    if (player.rb2d.velocity.y != 0f)
                    {
                        if (player.rb2d.velocity.y > 0f)
                        {
                            player.rb2d.velocity -= (Vector2.up * fireTackleVerticalSteeringSpeed * Time.deltaTime);
                            if (player.rb2d.velocity.y < 0f)
                            {
                                player.rb2d.velocity = new Vector2(player.rb2d.velocity.x, 0f);
                            }
                        }
                        else
                        {
                            player.rb2d.velocity += (Vector2.up * fireTackleVerticalSteeringSpeed * Time.deltaTime);
                            if (player.rb2d.velocity.y > 0f)
                            {
                                player.rb2d.velocity = new Vector2(player.rb2d.velocity.x, 0f);
                            }
                        }
                    }
                }
                
            }
            attackTimer -= Time.deltaTime;
            yield return null;
        }

        currentAttackState = AttackState.ENDLAG;
        player.charSprite.color = Color.gray;
        if (player.collisions.IsAgainstWall || player.collisions.IsHeadbonking) { player.rb2d.velocity = ((Vector2.up + (Vector2.right * (player.movement.isFacingRight ? -1f : 1f))).normalized * fireTackleBonkKnockback); }
        else
        {
            GameObject objTemp = Instantiate(fireProjectilePrefab, projectileSpawnPoint.position, Quaternion.identity);
            FireMissile fireTemp = objTemp.GetComponent<FireMissile>();
            if (fireTemp != null) { fireTemp.Setup(player.movement.isFacingRight, Mathf.Abs(player.rb2d.velocity.x)); }
        }
        player.rb2d.gravityScale = player.jumping.fallingGravity;
        float deceleration = Mathf.Abs(player.rb2d.velocity.x / fireTackleEndlag);
        float endlagTimer = fireTackleEndlag;
        while (endlagTimer > 0f)
        {
            if (endlagTimer < fireTackleEndlagCancel && (Input.GetAxisRaw("Horizontal") != 0f || player.buffers.jumpBufferTimeLeft > 0f)) { break; }
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
