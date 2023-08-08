using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class EnemyCollisionDetection : MonoBehaviour
{
    EnemyBehavior enemy;

    [SerializeField] Transform groundCheckObj;
    [SerializeField] Transform wallCheckL;
    [SerializeField] Transform wallCheckR;

    [SerializeField] UnityEvent onTouchingWall;
    [SerializeField] UnityEvent onTouchingLedge;
    [SerializeField] UnityEvent onPlayerCollision;
    [SerializeField] UnityEvent onLeavingGround;
    [SerializeField] UnityEvent onTouchingGround;

    [SerializeField] LayerMask groundLayer;

    [SerializeField] float groundCheckRadius = 0.1f;
    [SerializeField] float wallCheckRadius = 0.1f;
    [SerializeField] float ledgeCheckOffset = 0.25f;
    [SerializeField] string playerCollisionSoundName = "enemy_contact_impact";
    [SerializeField] string playerCollisionEffectName = "EnemyContactImpact";

    public bool isGrounded { get; private set; }
    public bool isTouchingWall { get; private set; }
    public bool isTouchingLedge { get; private set; }

    void Awake()
    {
        enemy = this.gameObject.GetComponent<EnemyBehavior>();
    }

    void Start()
    {
        
    }

    void Update()
    {
        if (!PauseHandler.isPaused && !enemy.isDefeated)
        {
            GroundCheck();
            WallCheck();
            LedgeCheck();
        }
    }

    public void PlayPlayerCollisionSound()
    {
        SoundFactory.SpawnSound(playerCollisionSoundName, enemy.playerDetection.GetPlayerPosition());
    }

    public void SpawnPlayerCollisionEffect()
    {
        EffectFactory.SpawnEffect(playerCollisionEffectName, enemy.playerDetection.GetPlayerPosition());
    }

    private void GroundCheck()
    {
        isGrounded = false;
        Collider2D[] colliders = Physics2D.OverlapCircleAll(groundCheckObj.position, groundCheckRadius, groundLayer);
        if (colliders.Length > 0)
        {
            onTouchingGround.Invoke();
            isGrounded = true;
        }
        else
        {
            onLeavingGround.Invoke();
            isGrounded = false;
        }
    }

    private void WallCheck()
    {
        Vector3 positionToCheck = (enemy.enemySprite.flipX ? wallCheckL.position : wallCheckR.position);
        Collider2D[] colliders = Physics2D.OverlapCircleAll(positionToCheck, wallCheckRadius, groundLayer);
        if (colliders.Length > 0)
        {
            onTouchingWall.Invoke();
            isTouchingWall = true;
        }
        else
        {
            isTouchingWall = false;
        }
    }

    private void LedgeCheck()
    {
        if (isGrounded)
        {
            Vector3 positionToCheck = (groundCheckObj.position + (Vector3.right * ledgeCheckOffset * enemy.movement.GetNormalizedXMovement()));
            RaycastHit2D hit = Physics2D.Raycast(positionToCheck, -Vector2.up, groundCheckRadius, groundLayer);
            if (hit.collider != null)
            {
                isTouchingLedge = false;
            }
            else
            {
                onTouchingLedge.Invoke();
                isTouchingLedge = true;
            }
        }
    }

    void OnCollisionEnter2D(Collision2D other)
    {
        if (other.gameObject.tag == "Player")
        {
            onPlayerCollision.Invoke();
        }
    }

    void OnCollisionStay2D(Collision2D other)
    {
        if (other.gameObject.tag == "Player")
        {
            onPlayerCollision.Invoke();
        }
    }
}
