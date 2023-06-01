using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class EnemyCollisionDetection : MonoBehaviour
{
    [SerializeField] Transform groundCheckObj;
    [SerializeField] Transform wallCheckL;
    [SerializeField] Transform wallCheckR;

    [SerializeField] UnityEvent onTouchingWall;
    [SerializeField] UnityEvent onTouchingLedge;

    void Start()
    {
        
    }

    void Update()
    {
        
    }
}
