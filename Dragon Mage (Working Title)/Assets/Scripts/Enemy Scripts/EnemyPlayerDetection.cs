using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class EnemyPlayerDetection : MonoBehaviour
{
    EnemyBehavior enemy;
    PlayerCtrl playerRef;
    
    [SerializeField] float playerDetectionDistance = 5f;
    [SerializeField] float enemySightlineDistance = 14f;
    [SerializeField] float enemyShortSightlineDistance = 7f;
    [SerializeField] float playerJumpingThreshold = 1f;
    [SerializeField] LayerMask sightlineLayer;
    [SerializeField] Transform sightlineRaycastOrigin;
    [SerializeField] bool useShortSightlineDistance = false;
    [SerializeField] bool useBehindSightline = false;
    [SerializeField] UnityEvent onPlayerApproach;
    [SerializeField] UnityEvent onPlayerRetreat;
    [SerializeField] UnityEvent onPlayerSightlineEnter;
    [SerializeField] UnityEvent onPlayerSightlneStay;
    [SerializeField] UnityEvent onPlayerSightlineExit;
    [SerializeField] UnityEvent onPlayerJump;

    private bool isPlayerNearby = false;
    private bool isPlayerInSightline = false;
    private bool didPlayerJump = false;

    void Awake()
    {
        enemy = this.gameObject.GetComponent<EnemyBehavior>();

        GameObject playerTemp = GameObject.FindWithTag("Player");
        if (playerTemp != null)
        {
            playerRef = playerTemp.GetComponent<PlayerCtrl>();
        }
    }

    void Update()
    {
        if (!PauseHandler.isPaused && !enemy.isDefeated)
        {
            CheckPlayerDetectionRadius();
            CheckEnemySightline();
            CheckPlayerJumping();
        }
    }

    public Vector3 GetPlayerPosition()
    {
        return playerRef.transform.position;
    }

    public float GetDistanceToPlayer()
    {
        if (playerRef != null)
        {
            return Vector3.Distance(this.transform.position, playerRef.transform.position);
        }
        return -1f;
    }

    public float GetDirectionToPlayer()
    {
        if (playerRef != null)
        {
            float xDiff = (playerRef.transform.position.x - this.transform.position.x);
            if (xDiff != 0f) { return (xDiff > 0f ? 1f : -1f); }
        }
        return 0f;
    }

    public void DamagePlayer()
    {
        if (playerRef != null)
        {
            playerRef.damage.TakeDamage(this.transform.position, enemy);
        }
    }

    private void CheckPlayerDetectionRadius()
    {
        float playerDistance = GetDistanceToPlayer();
        if (playerDistance >= 0f && playerDistance <= playerDetectionDistance)
        {
            if (!isPlayerNearby)
            {
                onPlayerApproach.Invoke();
            }
            isPlayerNearby = true;
        }
        else
        {
            if (isPlayerNearby)
            {
                onPlayerRetreat.Invoke();
            }
            isPlayerNearby = false;
        }
    }

    private void CheckEnemySightline()
    {
        RaycastHit2D hit = Physics2D.Raycast(sightlineRaycastOrigin.position, Vector2.right * enemy.movement.GetFacingValue(), Mathf.Infinity, sightlineLayer);
        RaycastHit2D hit2 = Physics2D.Raycast(sightlineRaycastOrigin.position, (useBehindSightline ? -1f : 0f) * Vector2.right * enemy.movement.GetFacingValue(), Mathf.Infinity, sightlineLayer);

        if (hit.collider != null && hit.transform.tag == "Player" && hit.distance <= (useShortSightlineDistance ? enemyShortSightlineDistance : enemySightlineDistance))
        {
            if (!isPlayerInSightline)
            {
                onPlayerSightlineEnter.Invoke();
            }
            else
            {
                onPlayerSightlneStay.Invoke();
            }
            isPlayerInSightline = true;
        }
        else if (hit2.collider != null && hit2.transform.tag == "Player" && hit2.distance <= (useShortSightlineDistance ? enemyShortSightlineDistance : enemySightlineDistance))
        {
            if (!isPlayerInSightline)
            {
                onPlayerSightlineEnter.Invoke();
            }
            else
            {
                onPlayerSightlneStay.Invoke();
            }
            isPlayerInSightline = true;
        }
        else
        {
            if (isPlayerInSightline)
            {
                onPlayerSightlineExit.Invoke();
            }
            isPlayerInSightline = false;
        }
    }

    private void CheckPlayerJumping()
    {
        if (enemy.isVisible && playerRef != null)
        {
            if (playerRef.stateMachine.CurrentState.name == "Jumping" && (!playerRef.collisions.IsGrounded && !playerRef.collisions.IsOnASlope) && playerRef.rb2d.velocity.y > playerJumpingThreshold)
            {
                if (!didPlayerJump)
                {
                    onPlayerJump.Invoke();
                }
                didPlayerJump = true;
            }
            else
            {
                didPlayerJump = false;
            }
        }
    }
}
