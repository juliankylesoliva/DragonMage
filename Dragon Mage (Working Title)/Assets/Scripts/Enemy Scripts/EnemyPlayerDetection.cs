using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class EnemyPlayerDetection : MonoBehaviour
{
    PlayerCtrl playerRef;

    [SerializeField] float playerDetectionDistance = 5f;
    [SerializeField] UnityEvent onPlayerApproach;
    [SerializeField] UnityEvent onPlayerRetreat;

    private bool isPlayerNearby = false;

    void Awake()
    {
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
}
