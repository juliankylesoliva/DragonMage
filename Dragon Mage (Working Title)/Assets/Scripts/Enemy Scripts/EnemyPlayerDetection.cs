using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class EnemyPlayerDetection : MonoBehaviour
{
    EnemyBehavior enemy;
    PlayerCtrl playerRef;

    [SerializeField] float playerDetectionDistance = 5f;
    [SerializeField] float enemySightlineDistance = 5f;
    [SerializeField] LayerMask sightlineLayer;
    [SerializeField] UnityEvent onPlayerApproach;
    [SerializeField] UnityEvent onPlayerRetreat;
    [SerializeField] UnityEvent onPlayerSightlineEnter;
    [SerializeField] UnityEvent onPlayerSightlneStay;
    [SerializeField] UnityEvent onPlayerSightlineExit;

    private bool isPlayerNearby = false;
    private bool isPlayerInSightline = false;

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
        if (!PauseHandler.isPaused)
        {
            CheckPlayerDetectionRadius();
            CheckEnemySightline();
        }
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
            playerRef.damage.TakeDamage(this.transform);
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
        RaycastHit2D hit = Physics2D.Raycast(this.transform.position, Vector2.right * enemy.movement.GetFacingValue(), Mathf.Infinity, sightlineLayer);
        if (hit.collider != null && hit.transform.tag == "Player" && hit.distance <= enemySightlineDistance)
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
}
