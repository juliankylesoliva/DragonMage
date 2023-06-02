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

    [SerializeField] LayerMask groundLayer;

    [SerializeField] float groundCheckRadius = 0.1f;
    [SerializeField] float wallCheckRadius = 0.1f;
    [SerializeField] float ledgeCheckOffset = 0.25f;

    private bool isGrounded = false;
    private bool isTouchingWall = false;
    private bool isTouchingLedge = false;

    void Awake()
    {
        enemy = this.gameObject.GetComponent<EnemyBehavior>();
    }

    void Start()
    {
        
    }

    void Update()
    {
        if (!PauseHandler.isPaused)
        {
            GroundCheck();
            WallCheck();
            LedgeCheck();
        }
    }

    private void GroundCheck()
    {
        isGrounded = false;
        Collider2D[] colliders = Physics2D.OverlapCircleAll(groundCheckObj.position, groundCheckRadius, groundLayer);
        isGrounded = (colliders.Length > 0);
    }

    private void WallCheck()
    {
        Vector3 positionToCheck = (enemy.enemySprite.flipX ? wallCheckL.position : wallCheckR.position);
        Collider2D[] colliders = Physics2D.OverlapCircleAll(positionToCheck, wallCheckRadius, groundLayer);
        if (colliders.Length > 0)
        {
            if (!isTouchingWall)
            {
                onTouchingWall.Invoke();
            }
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
            Vector3 positionToCheck = (groundCheckObj.position + (Vector3.right * ledgeCheckOffset * enemy.movement.GetFacingValue()));
            Collider2D[] colliders = Physics2D.OverlapCircleAll(positionToCheck, groundCheckRadius, groundLayer);
            if (colliders.Length > 0)
            {
                isTouchingLedge = false;
            }
            else
            {
                if (!isTouchingLedge)
                {
                    onTouchingLedge.Invoke();
                }
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
}
